import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cpk1989/core/utils/helpers.dart';
import 'package:cpk1989/core/utils/validators.dart';
import 'package:cpk1989/data/repositories/product_repository.dart';

class SellItemDetailController extends GetxController {
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
            ListTile(
              leading: const Icon(Icons.image, color: Color(0xFFFFAF2C)),
              title: const Text("Pick Image from Gallery", style: TextStyle(color: Colors.white)),
              onTap: () async {
                Get.back();
                final picker = ImagePicker();
                final picked = await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  rxBillPath.value = picked.path;
                  rxBillName.value = picked.name;
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Color(0xFFFFAF2C)),
              title: const Text("Pick Document (PDF)", style: TextStyle(color: Colors.white)),
              onTap: () async {
                Get.back();
                try {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
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
          ],
        ),
      ),
    );
  }

  // Payment method variables
  final rxHasPaymentMethod = false.obs;
  final rxSelectedCardIndex = 1.obs; // Index 1 is Visa Card by default
  final rxCards = <Map<String, String>>[
    {
      'type': 'Card',
      'logo': 'card',
      'cardNumber': 'Card',
      'expiry': 'Exp 12/29',
    },
    {
      'type': 'Visa Card',
      'logo': 'visa',
      'cardNumber': '**** **** **** 4526',
      'expiry': 'Exp 08/28',
    },
    {
      'type': 'Master Card',
      'logo': 'mastercard',
      'cardNumber': '**** **** **** 4526',
      'expiry': 'Exp 08/28',
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 0.88);

    if (Get.arguments is ProfileItem) {
      item = Get.arguments as ProfileItem;
    } else {
      // Fallback
      item = ProfileItem(
        id: 'fallback',
        imageUrl:
            'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=400&auto=format&fit=crop',
        price: 3200,
        likes: 2000,
        isSold: false,
        brand: "Channel",
        itemName: "Classic Flap Bag",
        status: null,
      );
    }

    final isFallback = item.id == 'fallback';

    titleController = TextEditingController(text: "");
    brandController = TextEditingController(text: "");
    descriptionController = TextEditingController(text: "");
    priceController = TextEditingController(text: "");
    conditionController = TextEditingController(text: "Select condition");
    sellerNameController = TextEditingController(text: "Olivia Mendes");
    sellerLocationController = TextEditingController(
      text: "Palm Jumeirah, Building 5, Apt 1204",
    );
    sellerCountryController = TextEditingController(text: "Dubai, UAE");
    sellerPhoneController = TextEditingController(text: "(+971) 50 123 4567");

    rxTitle.value = titleController.text;
    rxBrand.value = brandController.text;
    rxDescription.value = descriptionController.text;
    rxPrice.value = priceController.text;
    rxCondition.value = conditionController.text;
    rxSellerName.value = sellerNameController.text;
    rxSellerLocation.value = sellerLocationController.text;
    rxSellerCountry.value = sellerCountryController.text;
    rxSellerPhone.value = sellerPhoneController.text;

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
    final titleError = Validators.required(rxTitle.value, message: "Title is required");
    if (titleError != null) return titleError;

    final brandError = Validators.required(rxBrand.value, message: "Brand is required");
    if (brandError != null) return brandError;

    final descriptionError = Validators.required(rxDescription.value, message: "Description is required");
    if (descriptionError != null) return descriptionError;

    final priceError = Validators.required(rxPrice.value, message: "Listing price is required");
    if (priceError != null) return priceError;

    final amountError = Validators.amount(rxPrice.value, min: 1, message: "Please enter a valid listing price");
    if (amountError != null) return amountError;

    if (rxCondition.value.trim().isEmpty || rxCondition.value == "Select condition") {
      return "Please select item condition";
    }

    final nameError = Validators.required(rxSellerName.value, message: "Seller name is required");
    if (nameError != null) return nameError;

    final locationError = Validators.required(rxSellerLocation.value, message: "Seller location is required");
    if (locationError != null) return locationError;

    final countryError = Validators.required(rxSellerCountry.value, message: "Seller country is required");
    if (countryError != null) return countryError;

    final phoneError = Validators.phone(rxSellerPhone.value, message: "Valid seller phone number is required");
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
    
    rxIsPosting.value = true;
    Helpers.showLoadingDialog(message: "Publishing item...");

    try {
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
        proofOfPurchasePath: rxBillPath.value.isNotEmpty ? rxBillPath.value : null,
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
    } catch (e) {
      Helpers.hideLoadingDialog();
      rxIsPosting.value = false;
      Helpers.showError("An error occurred while posting: $e");
      return false;
    }
  }

  @override
  void onClose() {
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
