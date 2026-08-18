import 'package:cpk1989/core/services/api_client.dart';
import 'package:cpk1989/config/constants/api_constants.dart';
import 'package:cpk1989/data/models/saved_card_model.dart';

class PaymentRepository {
  final ApiClient _apiClient = ApiClient();

  /// GET /payment-methods
  Future<PaymentMethodsPageModel> getPaymentMethods({
    int limit = 20,
    String? startingAfter,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};
    if (startingAfter != null && startingAfter.isNotEmpty) {
      queryParams['startingAfter'] = startingAfter;
    }

    final response = await _apiClient.getData(
      ApiConstants.paymentMethods,
      query: queryParams,
    );

    final dataMap = Map<String, dynamic>.from(response.data['data'] as Map);
    return PaymentMethodsPageModel.fromJson(dataMap);
  }

  /// POST /payment-methods/setup-intent
  Future<String> createSetupIntent({required String idempotencyKey}) async {
    final response = await _apiClient.postData(
      ApiConstants.setupIntent,
      const {},
      extraHeaders: {'Idempotency-Key': idempotencyKey},
    );

    return response.data['data']['clientSecret'] as String;
  }

  /// DELETE /payment-methods/:id
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    await _apiClient.deleteData(
      '${ApiConstants.paymentMethods}/$paymentMethodId',
    );
  }

  /// GET /payment/connect/status
  Future<Map<String, dynamic>> getConnectStatus() async {
    try {
      final response = await _apiClient.getData(ApiConstants.connectStatus);
      if (response.data != null && response.data['data'] != null) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }
    } catch (_) {}
    return {};
  }

  /// POST /payment/connect/onboarding
  Future<String?> createConnectOnboardingUrl() async {
    try {
      final response = await _apiClient.postData(
        ApiConstants.connectOnboarding,
        const {},
      );
      if (response.data != null &&
          response.data['data'] != null &&
          response.data['data']['url'] != null) {
        return response.data['data']['url'] as String;
      }
    } catch (_) {}
    return null;
  }
}
