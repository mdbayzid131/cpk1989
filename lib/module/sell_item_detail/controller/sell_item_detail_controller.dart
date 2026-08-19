import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cpk1989/core/utils/helpers.dart';
import 'package:cpk1989/core/utils/validators.dart';
import 'package:cpk1989/data/repositories/product_repository.dart';
import 'package:cpk1989/data/repositories/payment_repository.dart';

class SellItemDetailController extends GetxController
    with WidgetsBindingObserver {
  late final ProfileItem item;
  final rxCurrentPage = 0.obs;
  late final PageController pageController;

  final rxIsEditMode = true.obs;
  final rxStep = 1.obs;
  late final TextEditingController titleController;
  late final TextEditingController brandController;
  late final TextEditingController descriptionController;
  late final TextEditingController priceController;
  late final TextEditingController conditionController;
  late final TextEditingController sellerNameController;
  late final TextEditingController sellerLocationController;
  late final TextEditingController sellerCountryController;
  late final TextEditingController sellerPhoneController;

  final rxTitle = "".obs;
  final rxBrand = "".obs;
  final rxDescription = "".obs;
  final rxPrice = "".obs;
  final rxCondition = "".obs;
  final rxSellerName = "".obs;
  final rxSellerLocation = "".obs;
  final rxSellerCountry = "".obs;
  final rxSellerPhone = "".obs;
  final rxOriginalPackaging = false.obs;
  final rxBillName = "".obs;
  final rxBillPath = "".obs;

  Future<void> pickBillFile() async {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1F22),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Upload Proof of Purchase",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Material(
              color: Colors.transparent,
              child: ListTile(
                leading: const Icon(Icons.image, color: Color(0xFFFFAF2C)),
                title: const Text(
                  "Pick Image from Gallery",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Get.back();
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    rxBillPath.value = picked.path;
                    rxBillName.value = picked.name;
                  }
                },
              ),
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: Color(0xFFFFAF2C),
                ),
                title: const Text(
                  "Pick Document (PDF)",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Get.back();
                  try {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );
                    if (result != null && result.files.single.path != null) {
                      rxBillPath.value = result.files.single.path!;
                      rxBillName.value = result.files.single.name;
                    }
                  } catch (e) {
                    Get.snackbar("Error", "Failed to pick file: $e");
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  ProfileController get profileController {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController(), permanent: true);
    }
    return Get.find<ProfileController>();
  }

  // Payment method variables
  final rxSelectedCardId = "".obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    pageController = PageController(viewportFraction: 0.88);

    if (Get.arguments is ProfileItem) {
      item = Get.arguments as ProfileItem;
    } else {
      // Fallback
      item = ProfileItem(
        id: 'fallback',
        imageUrl: '',
        price: 0,
        likes: 0,
        isSold: false,
        brand: "",
        itemName: "",
        status: null,
      );
    }

    final user = profileController.rxUserProfile.value;
    titleController = TextEditingController(text: "");
    brandController = TextEditingController(text: "");
    descriptionController = TextEditingController(text: "");
    priceController = TextEditingController(text: "");
    conditionController = TextEditingController(text: "Select condition");
    sellerNameController = TextEditingController(text: user?.name ?? "");
    sellerLocationController = TextEditingController(
      text: user?.location ?? "",
    );
    sellerCountryController = TextEditingController(text: user?.country ?? "");
    sellerPhoneController = TextEditingController(text: user?.phone ?? "");

    rxTitle.value = titleController.text;
    rxBrand.value = brandController.text;
    rxDescription.value = descriptionController.text;
    rxPrice.value = priceController.text;
    rxCondition.value = conditionController.text;
    rxSellerName.value = sellerNameController.text;
    rxSellerLocation.value = sellerLocationController.text;
    rxSellerCountry.value = sellerCountryController.text;
    rxSellerPhone.value = sellerPhoneController.text;

    // Listen for profile changes and populate fields if empty
    ever(profileController.rxUserProfile, (userModel) {
      if (userModel != null) {
        if (sellerNameController.text.isEmpty &&
            (userModel.name?.isNotEmpty ?? false)) {
          sellerNameController.text = userModel.name!;
          rxSellerName.value = userModel.name!;
        }
        if (sellerLocationController.text.isEmpty &&
            (userModel.location?.isNotEmpty ?? false)) {
          sellerLocationController.text = userModel.location!;
          rxSellerLocation.value = userModel.location!;
        }
        if (sellerCountryController.text.isEmpty &&
            (userModel.country?.isNotEmpty ?? false)) {
          sellerCountryController.text = userModel.country!;
          rxSellerCountry.value = userModel.country!;
        }
        if (sellerPhoneController.text.isEmpty &&
            (userModel.phone?.isNotEmpty ?? false)) {
          sellerPhoneController.text = userModel.phone!;
          rxSellerPhone.value = userModel.phone!;
        }
      }
    });

    // Sync saved cards
    profileController.fetchUserProfile();
    profileController.fetchSavedCards();

    ever(profileController.rxSavedCards, (cards) {
      if (rxSelectedCardId.value.isEmpty && cards.isNotEmpty) {
        rxSelectedCardId.value = cards.first.id;
      }
    });
    if (profileController.rxSavedCards.isNotEmpty) {
      rxSelectedCardId.value = profileController.rxSavedCards.first.id;
    }

    // Listen to changes in controllers to keep rx variables in sync
    titleController.addListener(() {
      rxTitle.value = titleController.text;
    });
    brandController.addListener(() {
      rxBrand.value = brandController.text;
    });
    priceController.addListener(() {
      rxPrice.value = priceController.text;
    });
    descriptionController.addListener(() {
      rxDescription.value = descriptionController.text;
    });
    conditionController.addListener(() {
      rxCondition.value = conditionController.text;
    });
    sellerNameController.addListener(() {
      rxSellerName.value = sellerNameController.text;
    });
    sellerLocationController.addListener(() {
      rxSellerLocation.value = sellerLocationController.text;
    });
    sellerCountryController.addListener(() {
      rxSellerCountry.value = sellerCountryController.text;
    });
    sellerPhoneController.addListener(() {
      rxSellerPhone.value = sellerPhoneController.text;
    });
  }

  void toggleEditMode() {
    // Edit mode is always true
  }

  final rxFormSubmitted = false.obs;
  final rxIsPosting = false.obs;

  String? validateForm() {
    final titleError = Validators.required(
      rxTitle.value,
      message: "Title is required",
    );
    if (titleError != null) return titleError;

    final brandError = Validators.required(
      rxBrand.value,
      message: "Brand is required",
    );
    if (brandError != null) return brandError;

    final descriptionError = Validators.required(
      rxDescription.value,
      message: "Description is required",
    );
    if (descriptionError != null) return descriptionError;

    final priceError = Validators.required(
      rxPrice.value,
      message: "Listing price is required",
    );
    if (priceError != null) return priceError;

    final amountError = Validators.amount(
      rxPrice.value,
      min: 1,
      message: "Please enter a valid listing price",
    );
    if (amountError != null) return amountError;

    if (rxCondition.value.trim().isEmpty ||
        rxCondition.value == "Select condition") {
      return "Please select item condition";
    }

    final nameError = Validators.required(
      rxSellerName.value,
      message: "Seller name is required",
    );
    if (nameError != null) return nameError;

    final locationError = Validators.required(
      rxSellerLocation.value,
      message: "Seller location is required",
    );
    if (locationError != null) return locationError;

    final countryError = Validators.required(
      rxSellerCountry.value,
      message: "Seller country is required",
    );
    if (countryError != null) return countryError;

    final phoneError = Validators.phone(
      rxSellerPhone.value,
      message: "Valid seller phone number is required",
    );
    if (phoneError != null) return phoneError;

    return null;
  }

  Future<bool> postProductListing() async {
    rxFormSubmitted.value = true;

    final validationError = validateForm();
    if (validationError != null) {
      return false;
    }

    final ProductRepository productRepo = Get.find<ProductRepository>();
    if (!Get.isRegistered<PaymentRepository>()) {
      Get.put(PaymentRepository());
    }
    final PaymentRepository paymentRepo = Get.find<PaymentRepository>();

    rxIsPosting.value = true;
    Helpers.showLoadingDialog(message: "Checking payout status...");

    try {
      final statusData = await paymentRepo.getConnectStatus();
      final bool isReady =
          statusData['connected'] == true &&
          statusData['detailsSubmitted'] == true &&
          statusData['payoutsEnabled'] == true;

      if (!isReady) {
        Helpers.hideLoadingDialog();
        rxIsPosting.value = false;
        _showStripeOnboardingDialog();
        return false;
      }

      Helpers.showLoadingDialog(message: "Publishing item...");

      final name = rxTitle.value.trim();
      final brand = rxBrand.value.trim();
      final price = double.tryParse(rxPrice.value.trim()) ?? 0.0;
      final condition = rxCondition.value.trim();
      final description = rxDescription.value.trim();

      // Local images from the previous camera flow
      final List<String> imagePaths = item.images ?? [];

      final response = await productRepo.createProduct(
        name: name,
        brand: brand,
        price: price,
        condition: condition,
        description: description,
        originalPackagingAvailable: rxOriginalPackaging.value,
        imagePaths: imagePaths,
        proofOfPurchasePath: rxBillPath.value.isNotEmpty
            ? rxBillPath.value
            : null,
      );

      Helpers.hideLoadingDialog();
      rxIsPosting.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final errorMsg = response.statusMessage ?? "Failed to publish listing";
        Helpers.showError(errorMsg);
        return false;
      }
    } on DioException catch (e) {
      Helpers.hideLoadingDialog();
      rxIsPosting.value = false;
      final responseData = e.response?.data;
      final msg = responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : e.message;

      if (e.response?.statusCode == 409 ||
          (msg != null && msg.contains('Stripe payout onboarding'))) {
        _showStripeOnboardingDialog();
      } else {
        Helpers.showError(msg ?? "Failed to publish listing.");
      }
      return false;
    } catch (e) {
      Helpers.hideLoadingDialog();
      rxIsPosting.value = false;
      if (e.toString().contains('Stripe payout onboarding')) {
        _showStripeOnboardingDialog();
      } else {
        Helpers.showError("An error occurred while posting: $e");
      }
      return false;
    }
  }

  void _showStripeOnboardingDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1C1D20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(
            color: const Color(0xFFE2B744).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: const BoxDecoration(
                  color: Color(0xFF2C281C),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: const Color(0xFFE2B744),
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Payout Setup Required",
                style: GoogleFonts.dmSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "To create product listings and receive payouts from sales, you must complete your Stripe Connect payout setup first.",
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.dmSans(
                          fontSize: 13.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        Helpers.showLoadingDialog(
                          message: "Generating setup link...",
                        );
                        final paymentRepo = Get.find<PaymentRepository>();
                        final onboardingUrl = await paymentRepo
                            .createConnectOnboardingUrl();
                        Helpers.hideLoadingDialog();
                        if (onboardingUrl != null && onboardingUrl.isNotEmpty) {
                          final uri = Uri.parse(onboardingUrl);
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          Helpers.showError(
                            "Unable to generate payout setup link. Please try again.",
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2B744),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        "Setup Payout",
                        style: GoogleFonts.dmSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkStatusOnResume();
    }
  }

  Future<void> _checkStatusOnResume() async {
    try {
      if (!Get.isRegistered<PaymentRepository>()) {
        Get.put(PaymentRepository());
      }
      final paymentRepo = Get.find<PaymentRepository>();
      final statusData = await paymentRepo.getConnectStatus();
      final bool isReady =
          statusData['connected'] == true &&
          statusData['detailsSubmitted'] == true &&
          statusData['payoutsEnabled'] == true;

      if (isReady && Get.isDialogOpen == true) {
        Get.back(); // Dismiss onboarding popup automatically when seller becomes ready!
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    pageController.dispose();
    titleController.dispose();
    brandController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    conditionController.dispose();
    sellerNameController.dispose();
    sellerLocationController.dispose();
    sellerCountryController.dispose();
    sellerPhoneController.dispose();
    super.onClose();
  }
}
