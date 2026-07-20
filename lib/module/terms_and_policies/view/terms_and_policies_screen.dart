import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';

class TermsAndPoliciesScreen extends StatelessWidget {
  const TermsAndPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          "Terms & Policies",
          style: GoogleFonts.dmSans(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      "1. Introduction",
                      "Welcome to Closeté. By using our application, services, or website, you agree to comply with and be bound by the following terms and policies. Please read them carefully before using the service.",
                    ),
                    SizedBox(height: 24.h),
                    _buildSection(
                      "2. User Accounts & Security",
                      "To access certain features of the platform, you must create a verified account. You are responsible for safeguarding your login credentials and for any activities or actions under your account. We reserve the right to suspend accounts violating our guidelines.",
                    ),
                    SizedBox(height: 24.h),
                    _buildSection(
                      "3. Selling & Buying Policies",
                      "All listings of luxury products must comply with our authentication standards. Sellers warrant that their items are authentic and accurately described. Buyers are protected under our secure checkout, ensuring payments are held until verification and delivery are completed.",
                    ),
                    SizedBox(height: 24.h),
                    _buildSection(
                      "4. Privacy & Data Collection",
                      "Your privacy is important to us. We collect, store, and process personal details (such as name, email, phone number, and location) in accordance with our Privacy Policy to facilitate secure trade, verification, and user personalization.",
                    ),
                    SizedBox(height: 24.h),
                    _buildSection(
                      "5. Fees & Payments",
                      "Closeté charges processing fees for successful transactions. Detailed fee structures are presented during listing creation or checkout. Payments are securely processed through our certified gateways and escrow accounts.",
                    ),
                    SizedBox(height: 24.h),
                    _buildSection(
                      "6. Updates to Terms",
                      "We reserve the right to update these terms and policies at any time. When updates are published, they will be made available directly on this page. Continuing to use Closeté after modifications constitute acceptance of the updated terms.",
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          body,
          style: GoogleFonts.dmSans(
            fontSize: 14.sp,
            color: Colors.white.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 24.h, top: 12.h),
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.dmSans(
            fontSize: 13.sp,
            color: Colors.white38,
          ),
          children: [
            const TextSpan(text: "Need help? "),
            TextSpan(
              text: "Contact support",
              style: const TextStyle(
                color: Colors.white70,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
