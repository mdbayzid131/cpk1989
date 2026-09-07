import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/core/utils/helpers.dart';

class TermsAndPoliciesScreen extends StatelessWidget {
  const TermsAndPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
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
                      "1. INTRODUCTION",
                      "Welcome to Closeté.\n\nCloseté is a platform that enables users to buy and sell luxury items through a managed service including collection, authentication, and delivery.\n\nBy using the app, you agree to these Terms & Conditions.",
                    ),
                    _buildSubSection(
                      "2. OUR ROLE",
                      "Closeté acts as a facilitated marketplace that:\n• Connects buyers and sellers\n• Manages collection, authentication, and delivery\n• Processes payments securely\n\nCloseté is not the original owner of listed items.",
                    ),
                    _buildSubSection(
                      "3. USER ACCOUNTS",
                      "Users agree to:\n• Provide accurate information\n• Maintain account security\n• Accept responsibility for account activity\n\nCloseté may suspend or terminate accounts for misuse.",
                    ),
                    _buildSubSection(
                      "4. SELLING ON CLOSETÉ",
                      "Sellers represent and warrant that:\n• Items are authentic and legally owned\n• Listings are accurate (description, condition, images)\n\nCloseté reserves the right to:\n• Reject items during verification\n• Remove listings\n• Suspend sellers providing counterfeit or misleading items.",
                    ),
                    _buildSubSection(
                      "5. BUYING ON CLOSETÉ",
                      "Buyers agree to:\n• Review listings before purchase\n• Provide accurate delivery details\n\nAll purchases are subject to:\n• Authentication\n• Successful verification.",
                    ),
                    _buildSubSection(
                      "6. AUTHENTICATION PROCESS",
                      "All items undergo a verification process using:\n• Internal expertise\n• Third-party authentication tools\n\nCloseté performs authentication using best efforts and available technology.\n\nAuthentication outcomes are:\n• Final and binding\n• Based on inspection at the time of verification\n\nCloseté does not guarantee absolute authenticity beyond this process.",
                    ),
                    _buildSubSection(
                      "7. PAYMENTS",
                      "Payments are securely processed via third-party providers.\n\nFunds are held until:\n• The item has successfully passed authentication\n• The Buyer accepts delivery\n\nPayment is only released to the seller after successful delivery acceptance.",
                    ),
                    _buildSubSection(
                      "8. COLLECTION & DELIVERY",
                      "Closeté manages:\n• Seller collection\n• Buyer delivery\n\nUsers must:\n• Be available at scheduled times\n• Provide accurate address details\n\nCloseté is not liable for:\n• Delays caused by logistics partners\n• Failed deliveries due to incorrect information.",
                    ),
                    _buildSubSection(
                      "9. REJECTION AT DELIVERY",
                      "At delivery, the Buyer has the right to:\n• Accept the item; or\n• Reject the item.\n\nIf the item is rejected because it is not as described, its condition materially differs from the listing, or due to any issue attributable to Closeté or the Seller:\n• The item will be returned to the Seller.\n• The Buyer will receive a full refund.\n• The Seller will not be paid.\n\nIf the Buyer rejects the item solely due to a change of mind, personal preference, or any reason unrelated to the item’s authenticity, condition, or conformity with its listing:\n• The item will be returned to the Seller.\n• The Buyer will receive a refund less the applicable Closeté Handling Fee, which covers costs already incurred, including payment processing, collection, authentication, handling, logistics, and delivery.\n• The Seller will not be paid.\n\nRepeated instances of rejecting items due to a change of mind may result in Closeté restricting or suspending the Buyer’s account at its sole discretion.\n\nThis process replaces the need for a traditional returns process.",
                    ),
                    _buildSubSection(
                      "10. DISPUTE RESOLUTION",
                      "Closeté's decisions regarding:\n• Authentication\n• Item condition\n• Listing accuracy\nare final and binding. Users agree to accept Closeté's determination in resolving disputes.",
                    ),
                    _buildSubSection(
                      "11. CHARGEBACKS & FRAUD",
                      "Closeté reserves the right to:\n• Contest chargebacks with evidence\n• Suspend accounts involved in disputes\n• Take action against fraudulent activity.",
                    ),
                    _buildSubSection(
                      "12. LIMITATION OF LIABILITY",
                      "To the fullest extent permitted by law:\n\nCloseté shall not be liable for:\n• Indirect or consequential losses\n• Loss of profits or opportunity\n• Disputes between users\n\nTotal liability is limited to: the value of the transaction in question.",
                    ),
                    _buildSubSection(
                      "13. PLATFORM USE",
                      "Closeté may:\n• Remove listings\n• Suspend accounts\n• Refuse service\n\nIf users:\n• Attempt fraud\n• Misuse the platform\n• Circumvent processes.",
                    ),
                    _buildSubSection(
                      "14. CHANGES TO TERMS",
                      "Closeté may update these Terms at any time. Continued use of the app constitutes acceptance.",
                    ),

                    SizedBox(height: 24.h),
                    const Divider(color: Colors.white10),
                    SizedBox(height: 24.h),

                    /// ==================== AUTHENTICITY & DELIVERY POLICY ====================
                    _buildSectionHeader("Authenticity & Delivery Policy"),
                    SizedBox(height: 16.h),
                    _buildSubSection(
                      "1. OVERVIEW",
                      "Closeté operates an authentication-before-delivery model.\n\nEvery item is:\n• Collected\n• Authenticated\n• Delivered only after successful authentication",
                    ),
                    _buildSubSection(
                      "2. NO TRADITIONAL RETURNS",
                      "Closeté does not operate a traditional returns policy.\n\nThis is because:\n• Buyers inspect items at the point of delivery.\n• Acceptance takes place before payment is released to the Seller.\n• Once an item has been accepted, the transaction is considered final.",
                    ),
                    _buildSubSection(
                      "3. BUYER ACCEPTANCE AT DELIVERY",
                      "At delivery, the Buyer may:\n\nAccept the item:\n• The transaction is completed.\n• Payment is released to the Seller.\n\nReject the item:\nIf the item is rejected because it is not as described, its condition materially differs from the listing, or due to an issue attributable to Closeté or the Seller:\n• The item is returned to the Seller.\n• The Buyer receives a full refund.\n• The Seller is not paid.\n\nIf the item is rejected solely due to a change of mind, personal preference, or any reason unrelated to the item’s authenticity, condition, or conformity with its listing:\n• The item is returned to the Seller.\n• The Buyer receives a refund less the applicable Closeté Handling Fee.\n• The Seller is not paid.\n\nRepeated instances of rejecting items due to a change of mind may result in Closeté restricting or suspending the Buyer’s account.",
                    ),
                    _buildSubSection(
                      "4. AUTHENTICATION PROTECTION",
                      "If an item:\n• Fails authentication; or\n• Is materially different from its listing,\n\nCloseté will:\n• Cancel the transaction.\n• Refund the Buyer in full.\n• Return the item to the Seller.",
                    ),
                    _buildSubSection(
                      "5. FINAL SALE AFTER ACCEPTANCE",
                      "Once the Buyer accepts the item at delivery, the transaction is final.\n\nCloseté is not responsible for:\n• Change of mind after acceptance.\n• Fit or sizing preferences.\n• Subjective preferences that were apparent at the time of delivery.",
                    ),
                    _buildSubSection(
                      "6. FRAUD PREVENTION",
                      "Closeté may:\n• Perform additional authentication or verification checks.\n• Delay or cancel transactions where fraudulent or suspicious activity is suspected.\n• Suspend or terminate accounts involved in fraudulent activity.",
                    ),
                    _buildSubSection(
                      "7. DAMAGED ITEMS",
                      "If an item is damaged while in Closeté’s possession or control:\n• The matter will be investigated.\n• An appropriate resolution will be determined at Closeté’s discretion.",
                    ),

                    SizedBox(height: 24.h),
                    const Divider(color: Colors.white10),
                    SizedBox(height: 24.h),

                    /// ==================== PRIVACY POLICY ====================
                    _buildSectionHeader("Privacy Policy"),
                    SizedBox(height: 8.h),
                    Text(
                      "Last updated: June 2026",
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        color: Colors.white38,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildSubSection(
                      "1. INTRODUCTION",
                      "Closeté (\"we\", \"our\", \"us\") respects your privacy and is committed to protecting your personal data.\n\nThis Privacy Policy explains how we collect, use, store, disclose, and protect your personal information when you use the Closeté mobile application and related services.",
                    ),
                    _buildSubSection(
                      "2. INFORMATION WE COLLECT",
                      "Account Information:\n• Name\n• Email address\n• Phone number\n\nTransaction & Listing Information:\n• Item details (photos, videos, descriptions, and condition)\n• Pricing and listing information\n• Purchase history\n• Order history\n\nCollection & Delivery Information:\n• Collection address (for Sellers)\n• Delivery address (for Buyers)\n• Collection and delivery status\n\nPayment Information:\n• Payment details processed securely by third-party payment providers\n• We do not store your full payment card details\n\nAuthentication Information:\n• Images and information submitted for authentication\n• Authentication results\n• Operational records relating to the authentication process\n\nDevice & Usage Information:\n• Device type\n• Operating system\n• App usage information\n• Log data for security, diagnostics, and performance",
                    ),
                    _buildSubSection(
                      "3. HOW WE USE YOUR INFORMATION",
                      "We use your information to:\n• Facilitate the buying and selling of luxury items.\n• Arrange collection and delivery.\n• Authenticate items and protect against fraud.\n• Process payments and refunds securely.\n• Communicate order updates, notifications, and customer support.\n• Improve the performance, security, and functionality of the Closeté platform.\n• Comply with applicable legal and regulatory obligations.",
                    ),
                    _buildSubSection(
                      "4. AUTHENTICATION & FRAUD PREVENTION",
                      "To maintain trust within the Closeté marketplace, we use a combination of:\n• Internal authentication procedures.\n• Third-party authentication providers and tools.\n\nWe may review item information, images, and related data to authenticate items, detect fraudulent activity, investigate disputes, and protect the integrity of the platform.",
                    ),
                    _buildSubSection(
                      "5. SHARING YOUR INFORMATION",
                      "We only share your information where necessary to operate the Closeté platform.\n\nService Providers:\nIncluding payment processors, delivery and logistics partners, authentication providers, technology and cloud service providers.\n\nOther Users:\nWe may share limited information necessary to complete a transaction, including listing information and first names where appropriate.\n\nLegal Requirements:\nWe may disclose information where required by law or where reasonably necessary to comply with legal obligations, prevent fraud, or protect the rights, property, safety, or security of Closeté, our users, or third parties.",
                    ),
                    _buildSubSection(
                      "6. DATA SECURITY",
                      "We implement appropriate technical and organisational measures designed to protect your personal information, including:\n• Encrypted data transmission.\n• Secure storage systems.\n• Access controls.\n• Ongoing monitoring and security practices.\n\nWhile we take reasonable steps to protect your information, no method of electronic transmission or storage is completely secure.",
                    ),
                    _buildSubSection(
                      "7. YOUR RIGHTS",
                      "Subject to applicable law, you may have the right to:\n• Access your personal information.\n• Request correction of inaccurate information.\n• Request deletion of your personal information.\n• Withdraw consent where applicable.\n\nTo exercise your rights, please contact: Closeteapp@gmail.com",
                    ),
                    _buildSubSection(
                      "8. DATA RETENTION",
                      "We retain personal information only for as long as reasonably necessary to:\n• Provide our services.\n• Complete transactions.\n• Meet legal and regulatory obligations.\n• Resolve disputes.\n• Enforce our agreements.",
                    ),
                    _buildSubSection(
                      "9. INTERNATIONAL TRANSFERS",
                      "Closeté currently operates in Dubai, United Arab Emirates.\n\nYour information may be processed or stored by trusted third-party service providers located in other jurisdictions where necessary to provide our services. Where applicable, we take reasonable steps to ensure your information receives an appropriate level of protection.",
                    ),
                    _buildSubSection(
                      "10. UPDATES TO THIS POLICY",
                      "We may update this Privacy Policy from time to time.\n\nAny changes will become effective when the updated Privacy Policy is published within the Closeté platform and the “Last updated” date is revised.",
                    ),
                    _buildSubSection(
                      "11. CONTACT US",
                      "For any questions regarding this Privacy Policy or your personal information, please contact:\n\nEmail: closeteapp@gmail.com\nCompany: Closeté",
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
    return GestureDetector(
      onTap: () => Helpers.openSupportEmail(),
      child: Container(
        padding: EdgeInsets.only(bottom: 24.h, top: 12.h),
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
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
      ),
    );
  }
}
