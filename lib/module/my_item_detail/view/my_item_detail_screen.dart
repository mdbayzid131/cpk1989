import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/core/widgets/vertical_stepper.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';
import 'package:cpk1989/core/widgets/custom_page_indicator.dart';
import 'package:cpk1989/core/widgets/custom_gold_loader.dart';
import 'package:cpk1989/core/utils/helpers.dart';
import 'package:cpk1989/module/my_item_detail/controller/my_item_detail_controller.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';

class MyItemDetailScreen extends GetView<MyItemDetailController> {
  const MyItemDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = controller.item;
    final isReserved = controller.isReserved;
    final rawStatus = item.status ?? (isReserved ? "Reserved" : null);

    final String currentStatus = (item.status ?? '').toLowerCase();

    // Determine states for exact 4 UI steps: Reserved -> Collected -> Authenticating -> Delivered
    // Uses same mapping as ProfileItem.displayStatus
    StepperStepState step1State = StepperStepState.completed;
    StepperStepState step2State = StepperStepState.inactive;
    StepperStepState step3State = StepperStepState.inactive;
    StepperStepState step4State = StepperStepState.inactive;

    if (currentStatus == 'collected' || currentStatus == 'in_transit') {
      // Collected: step 1 done, step 2 done, step 3 active
      step1State = StepperStepState.completed;
      step2State = StepperStepState.completed;
      step3State = StepperStepState.active;
    } else if (currentStatus == 'authenticating') {
      // Authenticating: steps 1-3 done, step 4 active
      step1State = StepperStepState.completed;
      step2State = StepperStepState.completed;
      step3State = StepperStepState.completed;
      step4State = StepperStepState.active;
    } else if (currentStatus == 'delivered' || currentStatus == 'completed') {
      // Delivered: all done
      step1State = StepperStepState.completed;
      step2State = StepperStepState.completed;
      step3State = StepperStepState.completed;
      step4State = StepperStepState.completed;
    } else {
      // Reserved / Secured / Pending / Unknown: step 1 done, step 2 active
      step1State = StepperStepState.completed;
      step2State = StepperStepState.active;
      step3State = StepperStepState.inactive;
      step4State = StepperStepState.inactive;
    }

    final List<StepperStep> steps = [
      StepperStep(
        title: "Reserved",
        subtitle: "Item reserved for you",
        state: step1State,
      ),
      StepperStep(
        title: "Collected",
        subtitle: "Picked up from seller",
        state: step2State,
      ),
      StepperStep(
        title: "Authenticating",
        subtitle: "Being verified by experts",
        state: step3State,
      ),
      StepperStep(
        title: "Delivered",
        subtitle: "On its way to you",
        state: step4State,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leadingWidth: 70.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Center(
            child: CustomGlassButton(
              size: 40.r,
              onTap: () => Get.back(),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16.sp,
              ),
            ),
          ),
        ),
        title: Text(
          "Item Detail",
          style: GoogleFonts.dmSans(
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        actions: [
          // Top right Delete button shown only when item is NOT reserved
          if (!isReserved)
            Padding(
              padding: EdgeInsets.only(right: 20.w),
              child: Center(
                child: CustomGlassButton(
                  size: 40.r,
                  onTap: () {
                    if (Get.isRegistered<ProfileController>()) {
                      Get.find<ProfileController>()
                          .deleteWardrobeItem(controller.item);
                    } else {
                      Get.snackbar(
                        "Delete Item",
                        "Are you sure you want to delete this item?",
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: const Color(0xFF161719),
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: SvgPicture.asset(
                    'assets/icons/delete .svg',
                    width: 16.r,
                    height: 16.r,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image Carousel
              SizedBox(
                height: 300.h,
                child: OverflowBox(
                  minWidth: MediaQuery.of(context).size.width,
                  maxWidth: MediaQuery.of(context).size.width,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned.fill(
                        child: PageView.builder(
                          controller: controller.pageController,
                          onPageChanged: (index) {
                            controller.rxCurrentPage.value = index;
                          },
                          itemCount: item.itemImages.length,
                          itemBuilder: (context, index) {
                            final imgUrl = item.itemImages[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: Container(
                                  color: const Color(0xFF1C1D20),
                                  child: imgUrl.startsWith('http')
                                      ? Image.network(
                                          imgUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(
                                              child: CustomGoldLoader(
                                                size: 24.r,
                                                strokeWidth: 2.5.r,
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Center(
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      color: Colors.white30,
                                                    ),
                                                  ),
                                        )
                                      : Image.file(
                                          File(imgUrl),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Center(
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      color: Colors.white30,
                                                    ),
                                                  ),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: -9.h,
                        child: Obx(
                          () => CustomPageIndicator(
                            count: item.itemImages.length,
                            currentPage: controller.rxCurrentPage.value,
                            isSmall: false,
                            showBorder: false,
                            backgroundColor: const Color(0xFF0F1012),
                            activeColor: const Color(0xFFFFAF2C),
                            inactiveColor: const Color(0xFF7E7E7E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // ITEM DETAILS Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ITEM DETAILS",
                    style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white38,
                      letterSpacing: 1.0,
                    ),
                  ),
                  // If item is NOT reserved: show Gold Edit Pencil icon
                  if (!isReserved)
                    Obx(
                      () => GestureDetector(
                        onTap: controller.toggleEdit,
                        child: Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: controller.rxIsEditing.value
                                ? const Color(0xFFFFAF2C).withValues(alpha: 0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/edit pen .svg',
                            width: 18.sp,
                            height: 18.sp,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFFFAF2C),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    // If item IS reserved: show Status Pill Badge (● Reserved)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFAF2C),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            rawStatus ?? "Reserved",
                            style: GoogleFonts.dmSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              SizedBox(height: 12.h),

              // ITEM DETAILS Fields (View vs Edit mode)
              Obx(() {
                final isEditing = controller.rxIsEditing.value;
                if (isEditing) {
                  return _buildEditForm(context);
                } else {
                  return _buildReadonlyDetails(context);
                }
              }),

              // -------------------------------------------------------------
              // EXTRA SECTIONS: ONLY SHOWN WHEN ITEM IS RESERVED (isReserved == true)
              // -------------------------------------------------------------
              if (isReserved) ...[
                Builder(
                  builder: (context) {
                    final order = item.orderModel;
                    final buyerName = order?.buyerModel?.name ?? order?.buyerName ?? "Aisha Khan";
                    final delivery = order?.deliveryDetails;
                    final buyerAddress =
                        (delivery?.address != null && delivery!.address!.isNotEmpty)
                            ? "${delivery.address}${delivery.location != null ? ', ${delivery.location}' : ''}"
                            : "Palm Jumeirah, Building 5, Apt 1204";
                    final buyerPhone =
                        (delivery?.phone != null && delivery!.phone!.isNotEmpty)
                            ? delivery.phone!
                            : "+971 50 123 4567";

                    final listingPriceVal = (order?.price ?? item.price) > 0
                        ? (order?.price ?? item.price)
                        : 4000.0;
                    final platformFeeVal =
                        order?.platformFee ?? (listingPriceVal * 0.12);
                    final sellerPayoutVal =
                        order?.sellerPayout ?? (listingPriceVal - platformFeeVal);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 28.h),

                        // 1. ITEM CURRENT STATUS Section Header & Timeline
                        Text(
                          "ITEM CURRENT STATUS",
                          style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white38,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161719),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                              width: 1.0,
                            ),
                          ),
                          child: VerticalStepper(
                            steps: steps,
                            nodeSize: 26.r,
                            activeDashedSize: 26.r,
                            lineWidth: 2.w,
                            stepHeight: 52.h,
                            titleStyle: GoogleFonts.dmSans(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.1,
                            ),
                            subtitleStyle: GoogleFonts.dmSans(
                              fontSize: 12.sp,
                              color: Colors.white54,
                              height: 1.1,
                            ),
                          ),
                        ),

                        SizedBox(height: 28.h),

                        // 2. BUYER DETAILS Section Header & Card
                        Text(
                          "BUYER DETAILS",
                          style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white38,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        CustomPaint(
                          painter: _GradientBorderPainter(
                            gradient: const LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
                            ),
                            strokeWidth: 1.0,
                            borderRadius: 16.r,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18.r,
                                      backgroundColor: const Color(0xFF282A2E),
                                      backgroundImage: const NetworkImage(
                                        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=150',
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      buyerName,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                const Divider(color: Colors.white10),
                                SizedBox(height: 12.h),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/location.svg',
                                      width: 16.sp,
                                      height: 16.sp,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white38,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        buyerAddress,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13.sp,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/phone.svg',
                                      width: 16.sp,
                                      height: 16.sp,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white38,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      buyerPhone,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13.sp,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 28.h),

                        // 3. YOUR EARNINGS Section Header & Breakdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "YOUR EARNINGS",
                              style: GoogleFonts.dmSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white38,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildEarningsRow(
                                "Listing price",
                                "AED ${listingPriceVal.toInt()}",
                              ),
                              SizedBox(height: 8.h),
                              _buildEarningsRow(
                                "Closeté fee (12%)",
                                "AED ${platformFeeVal.toInt()}",
                              ),
                              SizedBox(height: 10.h),
                              const Divider(color: Colors.white10),
                              SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "You'll Earn",
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14.sp,
                                      color: const Color(0xFFFFAF2C),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    "AED ${sellerPayoutVal.toInt()}",
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16.sp,
                                      color: const Color(0xFFFFAF2C),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],

              SizedBox(height: 16.h),

              // Bottom disclaimer note
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white38,
                    size: 14.sp,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      "Final verification happens after pickup.",
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        color: Colors.white38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Bottom Support Contact
              GestureDetector(
                onTap: () => Helpers.openSupportEmail(),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      text: "Need help? ",
                      style: GoogleFonts.dmSans(
                        fontSize: 13.sp,
                        color: Colors.white54,
                      ),
                      children: [
                        TextSpan(
                          text: "Contact support",
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // READONLY DETAILS BUILDER
  // ---------------------------------------------------------------------------
  Widget _buildReadonlyDetails(BuildContext context) {
    final item = controller.item;
    final formattedPrice =
        "AED ${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

    return Obx(() {
      String proofText = "N/A";
      if (controller.rxBillName.value.isNotEmpty) {
        proofText = controller.rxBillName.value;
      } else if (controller.rxBillPath.value.isNotEmpty) {
        proofText = controller.rxBillPath.value.split('/').last.split('\\').last;
      } else if (item.proofOfPurchase != null &&
          item.proofOfPurchase!.isNotEmpty) {
        proofText = item.proofOfPurchase!.split('/').last.split('\\').last;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDetailRow("Title", item.itemName),
          _buildDetailRow("Brand", item.brand),
          _buildDescriptionDetailRow(
            "Description",
            controller.descriptionController.text.isNotEmpty
                ? controller.descriptionController.text
                : "Black caviar leather with gold hardware. Comes with original dust bag and authenticity card.",
          ),
          _buildDetailRow("Listing Price", formattedPrice),
          _buildConditionDetailRow(
            "Condition",
            controller.rxSelectedCondition.value,
          ),
          _buildDetailRow("Proof of purchase", proofText),
          _buildOriginalPackagingRow(),
        ],
      );
    });
  }

  // ---------------------------------------------------------------------------
  // EDIT FORM BUILDER
  // ---------------------------------------------------------------------------
  Widget _buildEditForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title Input
        _buildEditInputRow("Title", controller.titleController),

        // Brand Input
        _buildEditInputRow("Brand", controller.brandController),

        // Description Input
        _buildEditDescriptionRow("Description", controller.descriptionController),

        // Price Input
        _buildEditInputRow(
          "Listing Price",
          controller.priceController,
          keyboardType: TextInputType.number,
          prefixText: "AED ",
        ),

        // Condition Picker Dropdown
        _buildConditionPickerRow(context),

        // Proof of Purchase & Packaging
        _buildProofOfPurchaseRow("Proof of purchase (Optional)"),
        _buildOriginalPackagingRow(),

        SizedBox(height: 20.h),

        // Save Changes Gold Button
        Obx(
          () => CustomGoldButton(
            text: "Save Changes",
            height: 50.h,
            width: double.infinity,
            onTap: controller.rxIsSaving.value
                ? () {}
                : () => controller.saveChanges(),
          ),
        ),
      ],
    );
  }

  // Editable single-line text row (Matches Profile Details dark sleek style)
  Widget _buildEditInputRow(
    String label,
    TextEditingController textCtrl, {
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          TextField(
            controller: textCtrl,
            keyboardType: keyboardType,
            style: GoogleFonts.dmSans(
              fontSize: 15.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              prefixText: prefixText,
              prefixStyle: GoogleFonts.dmSans(
                fontSize: 15.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Editable multi-line description row (Matches Profile Details dark sleek style)
  Widget _buildEditDescriptionRow(
    String label,
    TextEditingController textCtrl,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: textCtrl,
            maxLines: 3,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              color: Colors.white,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  // Condition Dropdown Picker (Matches Profile Details dark sleek style)
  Widget _buildConditionPickerRow(BuildContext context) {
    return Obx(() {
      final selected = controller.rxSelectedCondition.value;
      return GestureDetector(
        onTap: () => _showConditionBottomSheet(context),
        child: Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Condition",
                    style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      color: Colors.white38,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    selected,
                    style: GoogleFonts.dmSans(
                      fontSize: 15.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white70,
                size: 22.sp,
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showConditionBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: const Color(0xFF161719),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Select Condition",
              style: GoogleFonts.dmSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12.h),
            ...controller.conditionOptions.map((cond) {
              final isSel = controller.rxSelectedCondition.value == cond;
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  title: Text(
                    cond,
                    style: GoogleFonts.dmSans(
                      fontSize: 15.sp,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? const Color(0xFFFFAF2C) : Colors.white70,
                    ),
                  ),
                  trailing: isSel
                      ? Icon(
                          Icons.check_rounded,
                          color: const Color(0xFFFFAF2C),
                          size: 20.sp,
                        )
                      : null,
                  onTap: () {
                    controller.rxSelectedCondition.value = cond;
                    Get.back();
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------
  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: (label.contains("Proof") && value != "N/A")
                  ? () {
                      final url = controller.rxBillPath.value.isNotEmpty
                          ? controller.rxBillPath.value
                          : (controller.item.proofOfPurchase ?? "");
                      Helpers.openUrl(url);
                    }
                  : null,
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  color: (label.contains("Proof") && value != "N/A")
                      ? const Color(0xFFFFAF2C)
                      : Colors.white,
                  fontWeight: FontWeight.w600,
                  decoration: (label.contains("Proof") && value != "N/A")
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionDetailRow(String label, String value) {
    final description = _getConditionDescription(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  color: Colors.white38,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Expanded(
                flex: 2,
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (description.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 12.h),
            child: Text(
              description,
              style: GoogleFonts.dmSans(
                fontSize: 12.sp,
                color: const Color(0xFFA2A2A2),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  String _getConditionDescription(String condition) {
    switch (condition) {
      case 'New with Tags':
        return 'Brand new, never used, original tags attached';
      case 'Like New':
        return 'Excellent condition with little to no visible signs of wear';
      case 'Excellent':
        return 'Light signs of use, very well maintained';
      case 'Very Good':
        return 'Noticeable but minor wear, no significant defects';
      case 'Good':
        return 'Visible signs of wear but fully functional and presentable';
      case 'Fair':
        return 'Heavy wear or imperfections, reflected in the price';
      default:
        return '';
    }
  }

  Widget _buildDescriptionDetailRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              color: Colors.white,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofOfPurchaseRow(String label) {
    return Obx(() {
      if (controller.rxBillName.value.isEmpty) {
        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: Colors.white38,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: controller.pickBillFile,
                child: Text(
                  "Upload Bill",
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: const Color(0xFFFFAF2C),
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFFFFAF2C),
                    decorationThickness: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: Colors.white38,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      controller.rxBillName.value.toLowerCase().endsWith('.pdf')
                          ? Icons.picture_as_pdf_outlined
                          : Icons.image_outlined,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 120.w),
                      child: Text(
                        controller.rxBillName.value,
                        style: GoogleFonts.dmSans(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: controller.removeBillFile,
                      child: Icon(
                        Icons.close,
                        color: Colors.white38,
                        size: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget _buildOriginalPackagingRow() {
    return Obx(() {
      final isChecked = controller.rxOriginalPackaging.value;
      return Container(
        height: 52.h,
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1.0,
          ),
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                controller.rxOriginalPackaging.value = !isChecked;
              },
              child: Container(
                width: 20.r,
                height: 20.r,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(
                    color: isChecked ? const Color(0xFFFFAF2C) : Colors.white38,
                    width: 1.5.w,
                  ),
                  color: isChecked
                      ? const Color(0xFFFFAF2C)
                      : Colors.transparent,
                ),
                child: isChecked
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  controller.rxOriginalPackaging.value = !isChecked;
                },
                child: Text(
                  "Original packaging available?",
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEarningsRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13.sp,
            color: Colors.white38,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 13.sp,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final LinearGradient gradient;
  final double strokeWidth;
  final double borderRadius;

  _GradientBorderPainter({
    required this.gradient,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..shader = gradient.createShader(rect);

    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
