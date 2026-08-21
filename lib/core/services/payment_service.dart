import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:cpk1989/config/constants/api_constants.dart';
import 'package:cpk1989/core/services/api_client.dart';
import 'package:cpk1989/data/models/order_model.dart';
import 'package:cpk1989/data/repositories/payment_repository.dart';

class PaymentResult {
  final bool success;
  final String? errorMessage;
  final bool isCancelled;
  final OrderModel? orderData;

  PaymentResult({
    required this.success,
    this.errorMessage,
    this.isCancelled = false,
    this.orderData,
  });
}

class PaymentService extends GetxService {
  static PaymentService get to {
    if (!Get.isRegistered<PaymentService>()) {
      Get.put(PaymentService(), permanent: true);
    }
    return Get.find<PaymentService>();
  }

  String get stripePublishableKey => ApiConstants.stripePublishableKey;

  bool _isStripeInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _initStripe();
  }

  Future<void> _initStripe({String? customKey}) async {
    try {
      final keyToUse = (customKey != null && customKey.isNotEmpty)
          ? customKey
          : ApiConstants.stripePublishableKey;
      Stripe.publishableKey = keyToUse;
      Stripe.merchantIdentifier = 'merchant.app.closete';
      Stripe.urlScheme = 'closete';
      await Stripe.instance.applySettings();
      _isStripeInitialized = true;
      debugPrint('✅ Stripe initialized with key: ${Stripe.publishableKey}');
    } catch (e) {
      debugPrint('❌ Stripe init error: $e');
    }
  }

  /// Step 1: Call backend POST /orders/:productId/checkout to get clientSecret
  Future<CheckoutResponseModel> _createCheckoutOrder({
    required String productId,
    required String address,
    required String location,
    required String phone,
  }) async {
    try {
      final apiClient = Get.find<ApiClient>();
      final Response response = await apiClient.postData(
        '${ApiConstants.orders}/$productId/checkout',
        {
          'deliveryDetails': {
            'address': address,
            'location': location,
            'phone': phone,
          },
        },
      );

      if (response.data != null && response.data is Map<String, dynamic>) {
        return CheckoutResponseModel.fromJson(response.data);
      }
      return CheckoutResponseModel(
        success: false,
        message: 'Invalid response from server',
      );
    } on DioException catch (e) {
      debugPrint('❌ Checkout API DioException: ${e.response?.data}');
      final responseData = e.response?.data;
      String errorMsg = 'Checkout failed.';
      if (responseData is Map) {
        if (responseData['message'] != null &&
            responseData['message'].toString().isNotEmpty) {
          errorMsg = responseData['message'].toString();
        } else if (responseData['errorMessages'] is List &&
            (responseData['errorMessages'] as List).isNotEmpty) {
          final first = (responseData['errorMessages'] as List).first;
          if (first is Map && first['message'] != null) {
            errorMsg = first['message'].toString();
          }
        }
      } else if (e.message != null && e.message!.isNotEmpty) {
        errorMsg = e.message!;
      }
      return CheckoutResponseModel(success: false, message: errorMsg);
    } catch (e) {
      debugPrint('❌ Checkout API exception: $e');
      return CheckoutResponseModel(success: false, message: e.toString());
    }
  }

  /// Step 2: Present Stripe PaymentSheet with clientSecret (Card / Google Pay / Apple Pay)
  Future<PaymentResult> _presentPaymentSheet(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Closeté',
          style: ThemeMode.dark,
          allowsDelayedPaymentMethods: true,
          applePay: const PaymentSheetApplePay(merchantCountryCode: 'AE'),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'AE',
            currencyCode: 'AED',
            testEnv: true,
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return PaymentResult(success: true);
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return PaymentResult(success: false, isCancelled: true);
      }
      return PaymentResult(
        success: false,
        errorMessage: e.error.localizedMessage ?? 'Payment failed',
      );
    } catch (e) {
      return PaymentResult(success: false, errorMessage: e.toString());
    }
  }

  /// Main entry: Get clientSecret from backend → Present Stripe PaymentSheet
  Future<PaymentResult> processPayment({
    required String paymentMethod, // 'apple_pay', 'google_pay', or 'card'
    required String productId,
    required String address,
    required String location,
    required String phone,
    String? selectedPaymentMethodId,
  }) async {
    debugPrint('🚀 Hitting backend checkout API for productId: $productId...');

    // Step 1: ALWAYS call backend API to create order and get clientSecret
    final checkoutResponse = await _createCheckoutOrder(
      productId: productId,
      address: address,
      location: location,
      phone: phone,
    );

    if (checkoutResponse.success == false) {
      final msg =
          checkoutResponse.message ?? 'This item is no longer available';
      debugPrint('❌ Backend Checkout Error: $msg');
      return PaymentResult(success: false, errorMessage: msg);
    }

    final checkoutData = checkoutResponse.data;
    final clientSecret = checkoutData?.clientSecret;
    if (clientSecret == null || clientSecret.isEmpty) {
      debugPrint('❌ clientSecret missing from backend response');
      return PaymentResult(
        success: false,
        errorMessage:
            checkoutResponse.message ??
            'Unable to initiate payment. Missing clientSecret.',
      );
    }

    // Dynamic publishable key update if backend returns matching key
    if (checkoutData?.publishableKey != null &&
        checkoutData!.publishableKey!.isNotEmpty) {
      Stripe.publishableKey = checkoutData.publishableKey!;
      await Stripe.instance.applySettings();
      _isStripeInitialized = true;
    }

    // Step 2: Confirm payment using selected saved card or present native PaymentSheet
    if (_isStripeInitialized) {
      if (paymentMethod == 'card' &&
          selectedPaymentMethodId != null &&
          selectedPaymentMethodId.isNotEmpty) {
        debugPrint(
          '💳 Confirming payment with selected saved card ID: $selectedPaymentMethodId',
        );
        try {
          await Stripe.instance.confirmPayment(
            paymentIntentClientSecret: clientSecret,
            data: PaymentMethodParams.cardFromMethodId(
              paymentMethodData: PaymentMethodDataCardFromMethod(
                paymentMethodId: selectedPaymentMethodId,
              ),
            ),
          );
          return PaymentResult(success: true, orderData: checkoutData?.order);
        } on StripeException catch (e) {
          debugPrint(
            '❌ StripeException during confirmPayment: ${e.error.localizedMessage}',
          );
          if (e.error.code == FailureCode.Canceled) {
            return PaymentResult(success: false, isCancelled: true);
          }
          return PaymentResult(
            success: false,
            errorMessage:
                e.error.localizedMessage ?? 'Payment confirmation failed.',
          );
        } catch (e) {
          debugPrint('❌ Exception during confirmPayment: $e');
          return PaymentResult(success: false, errorMessage: e.toString());
        }
      }

      final sheetResult = await _presentPaymentSheet(clientSecret);
      if (sheetResult.success) {
        return PaymentResult(success: true, orderData: checkoutData?.order);
      }
      return sheetResult;
    } else {
      debugPrint('⚠️ Stripe SDK not initialized, but API succeeded.');
      await Future.delayed(const Duration(milliseconds: 1000));
      return PaymentResult(success: true, orderData: checkoutData?.order);
    }
  }

  /// Add a new card using SetupIntent and Stripe PaymentSheet
  Future<PaymentResult> addCardWithSetupIntent() async {
    final operationId = const Uuid().v4();
    try {
      await _initStripe();
      final paymentRepo = Get.find<PaymentRepository>();
      final clientSecret = await paymentRepo.createSetupIntent(
        idempotencyKey: operationId,
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: clientSecret,
          merchantDisplayName: 'Closeté',
          primaryButtonLabel: 'Save card',
          style: ThemeMode.dark,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return PaymentResult(success: true);
    } on StripeException catch (error) {
      if (error.error.code == FailureCode.Canceled) {
        return PaymentResult(success: false, isCancelled: true);
      }
      final message =
          error.error.localizedMessage ?? 'Unable to save this card';
      return PaymentResult(success: false, errorMessage: message);
    } catch (e) {
      return PaymentResult(success: false, errorMessage: e.toString());
    }
  }

  /// Add a new card using custom form inputs (Name, Card Number, Expiry, CVV)
  Future<PaymentResult> addCardWithDetails({
    required String name,
    required String cardNumber,
    required String expiry,
    required String cvv,
  }) async {
    final operationId = const Uuid().v4();
    try {
      final cleanNumber = cardNumber.replaceAll(' ', '').replaceAll('-', '');
      if (cleanNumber.length < 13) {
        return PaymentResult(
          success: false,
          errorMessage: 'Please enter a valid card number',
        );
      }

      final cleanExpiry = expiry.replaceAll(' ', '');
      final expParts = cleanExpiry.split('/');
      if (expParts.length < 2) {
        return PaymentResult(
          success: false,
          errorMessage: 'Invalid expiry format (use MM/YY)',
        );
      }
      final month = int.tryParse(expParts[0]) ?? 0;
      int year = int.tryParse(expParts[1]) ?? 0;
      if (year < 100) year += 2000;

      if (month < 1 || month > 12) {
        return PaymentResult(
          success: false,
          errorMessage: 'Invalid expiry month',
        );
      }

      // Step 1: Hit backend API POST /payment-methods/setup-intent
      await _initStripe();
      final paymentRepo = Get.find<PaymentRepository>();
      final clientSecret = await paymentRepo.createSetupIntent(
        idempotencyKey: operationId,
      );

      // Step 2: Pass CardDetails to Stripe SDK
      await Stripe.instance.dangerouslyUpdateCardDetails(
        CardDetails(
          number: cleanNumber,
          cvc: cvv.trim(),
          expirationMonth: month,
          expirationYear: year,
        ),
      );

      // Step 3: Confirm SetupIntent with Stripe SDK
      await Stripe.instance.confirmSetupIntent(
        paymentIntentClientSecret: clientSecret,
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(name: name.isNotEmpty ? name : null),
          ),
        ),
      );

      return PaymentResult(success: true);
    } on StripeException catch (error) {
      if (error.error.code == FailureCode.Canceled) {
        return PaymentResult(success: false, isCancelled: true);
      }
      final message =
          error.error.localizedMessage ?? 'Unable to save this card';
      return PaymentResult(success: false, errorMessage: message);
    } catch (e) {
      debugPrint('❌ Add card error: $e');
      return PaymentResult(success: false, errorMessage: e.toString());
    }
  }

  /// Pay with a selected saved card using confirmPayment
  Future<PaymentResult> payWithSavedCard({
    required String productId,
    required String address,
    required String location,
    required String phone,
    required String savedCardId,
  }) async {
    final checkoutResponse = await _createCheckoutOrder(
      productId: productId,
      address: address,
      location: location,
      phone: phone,
    );

    if (checkoutResponse.success == false) {
      final msg =
          checkoutResponse.message ?? 'This item is no longer available';
      return PaymentResult(success: false, errorMessage: msg);
    }

    final clientSecret = checkoutResponse.data?.clientSecret;
    if (clientSecret == null || clientSecret.isEmpty) {
      return PaymentResult(
        success: false,
        errorMessage: checkoutResponse.message ?? 'Missing clientSecret.',
      );
    }

    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(
            paymentMethodId: savedCardId,
          ),
        ),
      );
      return PaymentResult(success: true);
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return PaymentResult(success: false, isCancelled: true);
      }
      return PaymentResult(
        success: false,
        errorMessage: e.error.localizedMessage ?? 'Payment failed',
      );
    } catch (e) {
      return PaymentResult(success: false, errorMessage: e.toString());
    }
  }
}
