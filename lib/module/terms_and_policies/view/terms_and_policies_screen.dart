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
                    /// ==================== TERMS & CONDITIONS ====================
                    _buildSectionHeader("Terms & Conditions"),
                    SizedBox(height: 16.h),
                    _buildSubSection(
                      "INTRODUCTION",
                      "Welcome to Closeté.\n\nCloseté is a platform that enables users to buy and sell luxury items through a managed service including collection, authentication, and delivery.\n\nBy using the app, you agree to these Terms & Conditions.",
                    ),
                    _buildSubSection(
                      "OUR ROLE",
                      "Closeté acts as a facilitated marketplace that:\n• Connects buyers and sellers\n• Manages collection, authentication, and delivery\n• Processes payments securely\n\nCloseté is not the original owner of listed items.",
                    ),
                    _buildSubSection(
                      "USER ACCOUNTS",
                      "Users agree to:\n• Provide accurate information\n• Maintain account security\n• Accept responsibility for account activity\n\nCloseté may suspend or terminate accounts for misuse.",
                    ),
                    _buildSubSection(
                      "SELLING ON CLOSETÉ",
                      "Sellers represent and warrant that:\n• Items are authentic and legally owned\n• Listings are accurate (description, condition, images)\n\nCloseté reserves the right to:\n• Reject items during verification\n• Remove listings\n• Suspend sellers providing counterfeit or misleading items.",
                    ),
                    _buildSubSection(
                      "BUYING ON CLOSETÉ",
                      "Buyers agree to:\n• Review listings before purchase\n• Provide accurate delivery details\n\nAll purchases are subject to:\n• Authentication\n• Successful verification.",
                    ),
                    _buildSubSection(
                      "AUTHENTICATION PROCESS",
                      "All items undergo a verification process using:\n• Internal expertise\n• Third-party authentication tools\n\nCloseté performs authentication using best efforts and available technology.\n\nAuthentication outcomes are:\n• Final and binding\n• Based on inspection at the time of verification\n\nCloseté does not guarantee absolute authenticity beyond this process.",
                    ),
                    _buildSubSection(
                      "PAYMENTS",
                      "• Payments are securely processed via third-party providers\n• Funds are held until:\n  - Item is verified\n  - Buyer accepts delivery\n\nPayment is only released to the seller after successful delivery acceptance.",
                    ),
                    _buildSubSection(
                      "COLLECTION & DELIVERY",
                      "Closeté manages:\n• Seller collection\n• Buyer delivery\n\nUsers must:\n• Be available at scheduled times\n• Provide accurate address details\n\nCloseté is not liable for:\n• Delays caused by logistics partners\n• Failed deliveries due to incorrect information.",
                    ),
                    _buildSubSection(
                      "REJECTION AT DELIVERY",
                      "At delivery, the buyer has the right to accept or reject the item.\n\nIf rejected:\n• The item is returned to the seller\n• The buyer receives a full refund\n• The seller is not paid\n\nThis replaces the need for a traditional returns process.",
                    ),
                    _buildSubSection(
                      "DISPUTE RESOLUTION",
                      "Closeté's decisions regarding:\n• Authentication\n• Item condition\n• Listing accuracy\nare final and binding. Users agree to accept Closeté's determination in resolving disputes.",
                    ),
                    _buildSubSection(
                      "CHARGEBACKS & FRAUD",
                      "Closeté reserves the right to:\n• Contest chargebacks with evidence\n• Suspend accounts involved in disputes\n• Take action against fraudulent activity.",
                    ),
                    _buildSubSection(
                      "LIMITATION OF LIABILITY",
                      "To the fullest extent permitted by law:\n\nCloseté shall not be liable for:\n• Indirect or consequential losses\n• Loss of profits or opportunity\n• Disputes between users\n\nTotal liability is limited to: the value of the transaction in question.",
                    ),
                    _buildSubSection(
                      "PLATFORM USE",
                      "Closeté may:\n• Remove listings\n• Suspend accounts\n• Refuse service\n\nIf users:\n• Attempt fraud\n• Misuse the platform\n• Circumvent processes.",
                    ),
                    _buildSubSection(
                      "CHANGES TO TERMS",
                      "Closeté may update these Terms at any time. Continued use of the app constitutes acceptance.",
                    ),
                    
                    SizedBox(height: 24.h),
                    const Divider(color: Colors.white10),
                    SizedBox(height: 24.h),

                    /// ==================== PRIVACY POLICY ====================
                    _buildSectionHeader("Privacy Policy"),
                    SizedBox(height: 16.h),
                    _buildSubSection(
                      "INTRODUCTION",
                      "Closeté (\"we\", \"our\", \"us\") respects your privacy and is committed to protecting your personal data.\n\nThis Privacy Policy explains how we collect, use, and protect your information when you use the Closeté mobile application and services.",
                    ),
                    _buildSubSection(
                      "INFORMATION WE COLLECT",
                      "Account Information:\n• Name\n• Email address\n• Phone number\n\nTransaction & Listing Information:\n• Item details (photos, videos, descriptions)\n• Pricing and listing data\n• Purchase and order history\n\nLocation & Delivery Information:\n• Collection address (for sellers)\n• Delivery address (for buyers)\n\nPayment Information:\n• Payment details (processed securely via third-party providers)\n• We do not store full card details\n\nAuthentication Data:\n• Images and scans used for item verification\n• Results of authentication checks\n\nDevice & Usage Data:\n• Device type\n• App usage\n• Log data (for performance and security).",
                    ),
                    _buildSubSection(
                      "HOW WE USE YOUR INFORMATION",
                      "We use your data to:\n• Facilitate buying and selling of luxury items\n• Arrange collection and delivery\n• Authenticate items and prevent fraud\n• Process payments securely\n• Improve app performance and user experience\n• Communicate updates, orders, and support.",
                    ),
                    _buildSubSection(
                      "AUTHENTICATION & FRAUD PREVENTION",
                      "Closeté uses a combination of:\n• Internal verification processes\n• Third-party authentication tools\n\nWe may analyze submitted item data to detect potential fraud and ensure platform trust.",
                    ),
                    _buildSubSection(
                      "SHARING YOUR INFORMATION",
                      "We only share data when necessary:\n\nWith Service Providers:\n• Payment processors\n• Delivery partners\n• Authentication providers\n\nWith Other Users:\n• Limited information (e.g. first name, listing details)\n\nLegal Requirements:\n• If required by law or to protect our platform.",
                    ),
                    _buildSubSection(
                      "DATA SECURITY",
                      "We implement appropriate security measures to protect your data, including:\n• Encrypted data transmission\n• Secure storage systems\n• Access controls.",
                    ),
                    _buildSubSection(
                      "YOUR RIGHTS",
                      "You have the right to:\n• Access your data\n• Request correction\n• Request deletion\n• Withdraw consent\n\nTo do so, contact us at: support@closete.app",
                    ),
                    _buildSubSection(
                      "DATA RETENTION",
                      "We retain your data only as long as necessary to:\n• Provide our services\n• Comply with legal obligations\n• Resolve disputes.",
                    ),
                    _buildSubSection(
                      "LOCATION OF SERVICE",
                      "Closeté currently operates in Dubai, United Arab Emirates. Some features may be limited based on your location.",
                    ),

                    SizedBox(height: 24.h),
                    const Divider(color: Colors.white10),
                    SizedBox(height: 24.h),

                    /// ==================== AUTHENTICITY & DELIVERY POLICY ====================
                    _buildSectionHeader("Authenticity & Delivery Policy"),
                    SizedBox(height: 16.h),
                    _buildSubSection(
                      "OVERVIEW",
                      "Closeté operates a verification-before-delivery model.\n\nEvery item is collected, authenticated, and delivered only after approval.",
                    ),
                    _buildSubSection(
                      "NO TRADITIONAL RETURNS",
                      "Closeté does not operate a traditional returns policy.\n\nThis is because:\n• Buyers inspect items at the point of delivery\n• Acceptance happens before payment is released.",
                    ),
                    _buildSubSection(
                      "BUYER ACCEPTANCE AT DELIVERY",
                      "At delivery, the buyer can:\n\nAccept the item:\n• Transaction is completed\n• Payment is released to the seller\n\nReject the item:\n• Item is returned to the seller\n• Buyer receives a full refund\n• Seller is not paid.",
                    ),
                    _buildSubSection(
                      "AUTHENTICATION PROTECTION",
                      "If an item fails authentication or is significantly not as described, Closeté will:\n• Cancel the transaction\n• Refund the buyer in full\n• Return the item to the seller.",
                    ),
                    _buildSubSection(
                      "FINAL SALE AFTER ACCEPTANCE",
                      "Once the buyer accepts the item, the transaction is final.\n\nCloseté is not responsible for:\n• Change of mind\n• Fit or sizing issues\n• Subjective preferences.",
                    ),
                    _buildSubSection(
                      "FRAUD PREVENTION",
                      "Closeté may:\n• Perform additional verification checks\n• Delay or cancel transactions if risk is detected.",
                    ),
                    _buildSubSection(
                      "DAMAGED ITEMS",
                      "If damage occurs while in Closeté's control, the issue will be reviewed and an appropriate resolution will be determined.",
                    ),
                    _buildSubSection(
                      "REFUNDS",
                      "Where applicable, refunds will be:\n• Issued to the original payment method\n• Processed within a reasonable timeframe.",
                    ),

                    SizedBox(height: 24.h),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSubSection(String title, String body) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            body,
            style: GoogleFonts.dmSans(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 24.h, top: 12.h),
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.white38),
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
