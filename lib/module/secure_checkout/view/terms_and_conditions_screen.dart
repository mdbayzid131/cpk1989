import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String title = Get.arguments as String? ?? "Terms And Conditions";

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
          title,
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
                      "Title",
                      "Lorem ipsum dolor sit amet . The graphic and typographic operators know this well, in reality all the professions dealing with tLorem ipsum dolor sit amet. The graphic and tyraphic operators know this well, in reality all the professions dealing with the universe of ommunication have a stable relationship with these words, but what is it?he universe of ommunication have a stable relationship with these words, but what is it?",
                    ),
                    SizedBox(height: 24.h),
                    _buildSection(
                      "Title",
                      "Lorem ipsum dolor sit amet. The graphic and typraphic operators know this well, in reality all the professions dealing with the universe of ommunication have a stable relationship with these words, but what is it?\n\nLorem ipsum dolor sit amet. The graphic and typographic operators know this well, in reality all the professions dealing with the universe of ommunication have a stable relationship with these words, but what is it?",
                    ),
                    SizedBox(height: 24.h),
                    _buildSection(
                      "Title",
                      "Lorem ipsum dolor sit amet. The graphic and typographic operators know this well, in reality all the professions dealing with the universe of ommunication have a stable relationship with these words, but what is it?",
                    ),
                    SizedBox(height: 24.h),
                    _buildSection(
                      "Title",
                      "Lorem ipsum dolor sit amet . The graphic and typographic operators know this well, in reality all the professions dealing with the universe of communication have a stable relationship with these words, but what is it?",
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
              // Optional: Add gesture recognizer here if support action is needed
            ),
          ],
        ),
      ),
    );
  }
}
