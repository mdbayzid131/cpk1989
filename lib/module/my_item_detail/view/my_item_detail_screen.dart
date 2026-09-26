import 'dart:io';
import 'package:cpk1989/core/utils/status_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/core/widgets/custom_item_status_card.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';
import 'package:cpk1989/core/widgets/custom_page_indicator.dart';
import 'package:cpk1989/core/widgets/custom_gold_loader.dart';
import 'package:cpk1989/core/utils/helpers.dart';
import 'package:cpk1989/module/my_item_detail/controller/my_item_detail_controller.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:cpk1989/config/env_config.dart';

class MyItemDetailScreen extends GetView<MyItemDetailController> {
  const MyItemDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = controller.item;

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
          // Top right Delete button shown only when item can be deleted
          Obx(() {
            if (!controller.canDelete) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(right: 20.w),
              child: Center(
                child: CustomGlassButton(
                  size: 40.r,
                  onTap: () {
                    if (Get.isRegistered<ProfileController>()) {
                      Get.find<ProfileController>().deleteWardrobeItem(
                        controller.item,
                      );
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
            );
          }),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Obx(() {
            if (controller.rxIsLoadingDetails.value) {
              return Center(
                child: CustomGoldLoader(size: 44.r, strokeWidth: 3.5.r),
              );
            }
            return Stack(
              children: [
                RefreshIndicator(
                  color: const Color(0xFFFFAF2C),
                  backgroundColor: const Color(0xFF181A1E),
                  onRefresh: () async {
                    await controller.fetchFullDetails();
                  },
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Product Image Carousel (Original top carousel preserved)
                        Obx(() {
                          final prod = controller.rxProductModel.value;
                          final List<String> images =
                              (prod != null && prod.displayImages.isNotEmpty)
                              ? prod.displayImages
                              : item.itemImages;

                          return SizedBox(
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
                                      itemCount: images.length,
                                      itemBuilder: (context, index) {
                                        final imgUrl = images[index];
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              20.r,
                                            ),
                                            child: Container(
                                              color: const Color(0xFF1C1D20),
                                              child: imgUrl.startsWith('http')
                                                  ? Image.network(
                                                      imgUrl,
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (
                                                        context,
                                                        child,
                                                        loadingProgress,
                                                      ) {
                                                        if (loadingProgress == null) return child;
                                                        return Center(
                                                          child: CustomGoldLoader(
                                                            size: 24.r,
                                                            strokeWidth: 2.5.r,
                                                          ),
                                                        );
                                                      },
                                                      errorBuilder: (_, __, ___) =>
                                                          const Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          color: Colors.white38,
                                                        ),
                                                      ),
                                                    )
                                                  : Image.file(
                                                      File(imgUrl),
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) =>
                                                          const Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          color: Colors.white38,
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
                                    child: CustomPageIndicator(
                                      count: images.length,
                                      currentPage: controller.rxCurrentPage.value,
                                      isSmall: false,
                                      showBorder: false,
                                      backgroundColor: const Color(0xFF0F1012),
                                      activeColor: const Color(0xFFFFAF2C),
                                      inactiveColor: const Color(0xFF7E7E7E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        SizedBox(height: 24.h),

                        // LISTING STATUS Section (Displayed for Pending Review & Rejected)
                        Obx(() {
                          final liveStatus =
                              controller.rxOrderModel.value?.status ??
                              controller.rxProductModel.value?.status ??
                              item.status;
                          final normStatus = StatusHelper.normalize(liveStatus);
                          final isPendingOrRejected =
                              normStatus == 'pending_review' ||
                              normStatus == 'pending' ||
                              normStatus == 'rejected';

                          if (!isPendingOrRejected || controller.isReserved) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "LISTING STATUS",
                                style: GoogleFonts.dmSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white38,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              _buildListingStatusCard(normStatus),
                              SizedBox(height: 20.h),
                            ],
                          );
                        }),

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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Obx(() {
                                  final liveStatus =
                                      controller.rxOrderModel.value?.status ??
                                      controller.rxProductModel.value?.status ??
                                      item.status;
                                  final norm = StatusHelper.normalize(liveStatus);
                                  // For pending/rejected, status is already in LISTING STATUS section
                                  if (norm == 'pending_review' ||
                                      norm == 'pending' ||
                                      norm == 'rejected') {
                                    return const SizedBox.shrink();
                                  }
                                  return StatusHelper.buildStatusBadge(liveStatus);
                                }),
                                // Edit Pen Icon (shown when canEdit)
                                Obx(() {
                                  if (!controller.canEdit) {
                                    return const SizedBox.shrink();
                                  }
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(width: 8.w),
                                      GestureDetector(
                                        onTap: controller.toggleEdit,
                                        child: controller.rxIsEditing.value
                                            ? Container(
                                                padding: EdgeInsets.all(4.r),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFFFAF2C,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        6.r,
                                                      ),
                                                ),
                                                child: Icon(
                                                  Icons.close_rounded,
                                                  color: Colors.black,
                                                  size: 16.sp,
                                                ),
                                              )
                                            : SvgPicture.asset(
                                                'assets/icons/edit pen .svg',
                                                width: 18.sp,
                                                height: 18.sp,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                      Color(0xFFFFAF2C),
                                                      BlendMode.srcIn,
                                                    ),
                                              ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
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
                        Obx(() {
                          final isReserved = controller.isReserved;
                          if (!isReserved) return const SizedBox.shrink();

                          final order =
                              controller.rxOrderModel.value ??
                              item.orderModel ??
                              item.productModel?.order;
                          final buyer =
                              controller.rxBuyerModel.value ??
                              order?.buyerModel ??
                              item.productModel?.buyer;
                          final buyerName =
                              buyer?.name ?? order?.buyerName ?? "Buyer";
                          final delivery = order?.deliveryDetails;
                          final liveStatus =
                              order?.status ?? item.status ?? "Reserved";

                          String buyerAddress = "Dubai, UAE";
                          final dAddr = delivery?.address;
                          final dLoc = delivery?.location;
                          final bAddr = buyer?.address;
                          final bLoc = buyer?.location;
                          if (dAddr != null && dAddr.isNotEmpty) {
                            buyerAddress =
                                "$dAddr${(dLoc != null && dLoc.isNotEmpty) ? ', $dLoc' : ''}";
                          } else if (bAddr != null && bAddr.isNotEmpty) {
                            buyerAddress =
                                "$bAddr${(bLoc != null && bLoc.isNotEmpty) ? ', $bLoc' : ''}";
                          } else if (bLoc != null && bLoc.isNotEmpty) {
                            buyerAddress = bLoc;
                          }

                          String buyerPhone = "N/A";
                          final dPhone = delivery?.phone;
                          final bPhone = buyer?.phone;
                          if (dPhone != null && dPhone.isNotEmpty) {
                            buyerPhone = dPhone;
                          } else if (bPhone != null && bPhone.isNotEmpty) {
                            buyerPhone = bPhone;
                          }

                          final buyerAvatar = buyer?.profileImage;

                          final listingPriceVal =
                              (order?.price ?? item.price) > 0
                              ? (order?.price ?? item.price)
                              : item.price;
                          final platformFeeVal =
                              order?.platformFee ??
                              item.commissionAmount ??
                              (listingPriceVal * EnvConfig.feeRate);
                          final sellerPayoutVal =
                              order?.sellerPayout ??
                              item.sellerEarnings ??
                              (listingPriceVal - platformFeeVal);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 28.h),

                              // 1. ITEM CURRENT STATUS Section Header & Timeline
                              CustomItemStatusCard(
                                status: liveStatus,
                                statusHistory: order?.statusHistory,
                                cancellationReason: order?.cancellationReason,
                                outcome: order?.outcome,
                                isSeller: true,
                                headerTitle: "ITEM CURRENT STATUS",
                                headerStyle: GoogleFonts.dmSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white38,
                                  letterSpacing: 1.0,
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
                                    colors: [
                                      Color(0xFF2B2D32),
                                      Color(0xFF1C1D20),
                                    ],
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
                                      colors: [
                                        Color(0xFF2B2D32),
                                        Color(0xFF1C1D20),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18.r,
                                            backgroundColor: const Color(
                                              0xFF282A2E,
                                            ),
                                            backgroundImage:
                                                (buyerAvatar != null &&
                                                    buyerAvatar.isNotEmpty &&
                                                    buyerAvatar.startsWith(
                                                      'http',
                                                    ))
                                                ? NetworkImage(buyerAvatar)
                                                : const NetworkImage(
                                                    'https://i.ibb.co/z5YHLV9/profile.png',
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                    colors: [
                                      Color(0xFF2B2D32),
                                      Color(0xFF1C1D20),
                                    ],
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                        }),

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
              ],
            );
          }),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LISTING STATUS CARDS (MATCHING CLIENT FIGMA MOCKUPS)
  // ---------------------------------------------------------------------------
  Widget _buildListingStatusCard(String normStatus) {
    if (normStatus == 'rejected') {
      final rejReason =
          controller.rxProductModel.value?.rejectionReason ??
          controller.item.rejectionReason;

      String rejectionTitle = "Photos don't meet our quality standards";
      String rejectionDesc =
          "We've reviewed your listing and, unfortunately, the photos provided don't meet our quality standards. You can submit a new listing.";

      if (rejReason != null && rejReason.trim().isNotEmpty) {
        if (rejReason.contains(':')) {
          final parts = rejReason.split(':');
          rejectionTitle = parts.first.trim();
          rejectionDesc = parts.sublist(1).join(':').trim();
        } else {
          rejectionTitle = rejReason.trim();
          rejectionDesc =
              "We've reviewed your listing and, unfortunately, the details provided don't meet our quality standards. You can edit and update the listing.";
        }
      }

      return Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [
              Color(0xFF2B2D32),
              Color(0xFF1C1D20),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFFF3B30).withValues(alpha: 0.65),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rejected",
                  style: GoogleFonts.dmSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFF3B30),
                  ),
                ),
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              "REASON :",
              style: GoogleFonts.dmSans(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white38,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              rejectionTitle,
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              rejectionDesc,
              style: GoogleFonts.dmSans(
                fontSize: 12.sp,
                color: Colors.white60,
                height: 1.35,
              ),
            ),
          ],
        ),
      );
    }

    // Pending Review Status Card
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Color(0xFF2B2D32),
            Color(0xFF1C1D20),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pending Review",
                  style: GoogleFonts.dmSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFAF2C),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "Your listing has been submitted and is awaiting review. It isn't visible to buyers yet.",
                  style: GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    color: Colors.white60,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: const Color(0xFFFFAF2C),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Icon(
                Icons.access_time_rounded,
                color: Colors.black,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // READONLY DETAILS BUILDER
  // ---------------------------------------------------------------------------
  Widget _buildReadonlyDetails(BuildContext context) {
    return Obx(() {
      final item = controller.item;
      final prod = controller.rxProductModel.value;

      final title = (prod?.name != null && prod!.name!.isNotEmpty)
          ? prod.name!
          : (controller.titleController.text.isNotEmpty
                ? controller.titleController.text
                : item.itemName);

      final brand = (prod?.brand != null && prod!.brand!.isNotEmpty)
          ? prod.brand!
          : (controller.brandController.text.isNotEmpty
                ? controller.brandController.text
                : item.brand);

      final description =
          (prod?.description != null && prod!.description!.isNotEmpty)
          ? prod.description!
          : (controller.descriptionController.text.isNotEmpty
                ? controller.descriptionController.text
                : (item.description != null && item.description!.isNotEmpty
                      ? item.description!
                      : "No description provided."));

      final rawPrice =
          prod?.price ??
          (double.tryParse(controller.priceController.text) ?? item.price);
      final formattedPrice =
          "AED ${rawPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

      final condition = (prod?.condition != null && prod!.condition!.isNotEmpty)
          ? prod.condition!
          : (controller.rxSelectedCondition.value.isNotEmpty
                ? controller.rxSelectedCondition.value
                : (item.condition ?? "Like New"));

      String proofUrl = "";
      String rawProofName = "N/A";
      if (controller.rxBillPath.value.isNotEmpty) {
        proofUrl = controller.rxBillPath.value;
        rawProofName = controller.rxBillName.value.isNotEmpty
            ? controller.rxBillName.value
            : controller.rxBillPath.value.split('/').last.split('\\').last;
      } else if (prod?.proofOfPurchase != null &&
          prod!.proofOfPurchase!.isNotEmpty) {
        proofUrl = prod.proofOfPurchase!;
        rawProofName = prod.proofOfPurchase!.split('/').last.split('\\').last;
      } else if (item.proofOfPurchase != null &&
          item.proofOfPurchase!.isNotEmpty) {
        proofUrl = item.proofOfPurchase!;
        rawProofName = item.proofOfPurchase!.split('/').last.split('\\').last;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDetailRow("Title", title),
          _buildDetailRow("Brand", brand),
          _buildDescriptionDetailRow("Description", description),
          _buildDetailRow("Listing Price", formattedPrice),
          _buildConditionDetailRow("Condition", condition),
          _buildReadonlyProofOfPurchaseRow(proofUrl, rawProofName),
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
        _buildEditDescriptionRow(
          "Description",
          controller.descriptionController,
        ),

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
  String _cleanProofFileName(String rawName) {
    if (rawName.isEmpty || rawName == "N/A") return "N/A";
    final fileName = rawName.split(RegExp(r'[/\\]')).last;
    if (fileName.contains('-')) {
      final parts = fileName.split('-');
      final lastPart = parts.last;
      if (lastPart.contains('.') && lastPart.length <= 20) {
        return lastPart;
      }
      final ext = fileName.contains('.') ? '.${fileName.split('.').last}' : '';
      if (ext.isNotEmpty) {
        return "Bill$ext";
      }
    }
    return fileName;
  }

  Widget _buildReadonlyProofOfPurchaseRow(
    String proofUrl,
    String rawProofName,
  ) {
    final bool hasProof =
        proofUrl.isNotEmpty && proofUrl != "N/A" && rawProofName != "N/A";
    final bool isPdf =
        rawProofName.toLowerCase().endsWith('.pdf') ||
        proofUrl.toLowerCase().endsWith('.pdf');
    final String displayName = StatusHelper.cleanProofFileName(
      rawProofName.isNotEmpty && rawProofName != "N/A"
          ? rawProofName
          : proofUrl,
    );

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
          Text(
            "Proof of purchase",
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!hasProof)
            Text(
              "N/A",
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            GestureDetector(
              onTap: () => Helpers.openUrl(proofUrl),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPdf
                          ? Icons.picture_as_pdf_outlined
                          : Icons.image_outlined,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 120.w),
                      child: Text(
                        displayName,
                        style: GoogleFonts.dmSans(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

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
      final isEditing = controller.rxIsEditing.value;
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
              onTap: isEditing
                  ? () {
                      controller.rxOriginalPackaging.value = !isChecked;
                    }
                  : null,
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
                        color: Colors.black,
                        size: 14,
                      )
                    : null,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: GestureDetector(
                onTap: isEditing
                    ? () {
                        controller.rxOriginalPackaging.value = !isChecked;
                      }
                    : null,
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

  Widget _buildStripeConnectPayoutCard(BuildContext context) {
    return Obx(() {
      final isOnboarded = controller.rxIsStripeOnboarded.value;

      if (isOnboarded) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFF34C759).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFF34C759).withValues(alpha: 0.2),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF34C759),
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Payout Account Connected",
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Earnings will be transferred directly to your bank upon delivery.",
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFFFAF2C).withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFAF2C).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Color(0xFFFFAF2C),
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Payout Setup Required",
                        style: GoogleFonts.dmSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFAF2C),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Connect your bank via Stripe to receive your earnings.",
                        style: GoogleFonts.dmSans(
                          fontSize: 12.sp,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            CustomGoldButton(
              text: "Complete Payout Setup",
              suffix: Icon(
                Icons.arrow_forward_rounded,
                size: 16.sp,
                color: Colors.black,
              ),
              onTap: () => controller.startStripeOnboarding(),
            ),
          ],
        ),
      );
    });
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
