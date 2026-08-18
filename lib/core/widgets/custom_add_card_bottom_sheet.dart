import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/core/utils/validators.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';

class CustomAddCardBottomSheet extends StatefulWidget {
  final void Function({
    required String name,
    required String cardNumber,
    required String expiry,
    required String cvv,
  })
  onAdd;

  const CustomAddCardBottomSheet({super.key, required this.onAdd});

  @override
  State<CustomAddCardBottomSheet> createState() =>
      _CustomAddCardBottomSheetState();
}

class _CustomAddCardBottomSheetState extends State<CustomAddCardBottomSheet> {
  late final TextEditingController nameController;
  late final TextEditingController numberController;
  late final TextEditingController expiryController;
  late final TextEditingController cvvController;

  String? nameError;
  String? numberError;
  String? expiryError;
  String? cvvError;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    numberController = TextEditingController();
    expiryController = TextEditingController();
    cvvController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1012),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16.w,
        18.h,
        16.w,
        MediaQuery.of(context).padding.bottom + 16.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add a new card",
                style: GoogleFonts.dmSans(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(color: Colors.white, width: 1.0),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // Cardholder Name
          _buildTextField(
            controller: nameController,
            hintText: "Enter Card holder Name",
            svgPath: "assets/icons/person.svg",
            errorText: nameError,
            onChanged: (_) {
              if (nameError != null) setState(() => nameError = null);
            },
          ),
          SizedBox(height: 12.h),

          // Card Number
          _buildTextField(
            controller: numberController,
            hintText: "Enter Card number",
            svgPath: "assets/icons/card number.svg",
            keyboardType: TextInputType.number,
            errorText: numberError,
            onChanged: (_) {
              if (numberError != null) setState(() => numberError = null);
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberTextInputFormatter(),
              LengthLimitingTextInputFormatter(19),
            ],
          ),
          SizedBox(height: 12.h),

          // Expiry & CVV Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  controller: expiryController,
                  hintText: "MM/YY",
                  svgPath: "assets/icons/calender.svg",
                  keyboardType: TextInputType.datetime,
                  errorText: expiryError,
                  onChanged: (_) {
                    if (expiryError != null) setState(() => expiryError = null);
                  },
                  inputFormatters: [
                    _DateTextInputFormatter(),
                    LengthLimitingTextInputFormatter(5),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTextField(
                  controller: cvvController,
                  hintText: "CVV",
                  svgPath: "assets/icons/cvv.svg",
                  keyboardType: TextInputType.number,
                  errorText: cvvError,
                  onChanged: (_) {
                    if (cvvError != null) setState(() => cvvError = null);
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Add Card Gold Button
          CustomGoldButton(
            text: "Add Card",
            suffix: Icon(
              Icons.arrow_forward_rounded,
              color: Colors.black,
              size: 18.sp,
            ),
            onTap: () {
              final name = nameController.text.trim();
              final rawNumber = numberController.text.trim();
              final cleanNumber = rawNumber
                  .replaceAll(' ', '')
                  .replaceAll('-', '');
              final expiry = expiryController.text.trim();
              final cvv = cvvController.text.trim();

              setState(() {
                nameError = Validators.required(
                  name,
                  message: 'Cardholder name is required',
                );
                numberError = Validators.creditCard(cleanNumber);
                expiryError = Validators.expiryDate(expiry);
                cvvError = Validators.cvv(cvv);
              });

              if (nameError != null ||
                  numberError != null ||
                  expiryError != null ||
                  cvvError != null) {
                return;
              }

              widget.onAdd(
                name: name,
                cardNumber: cleanNumber,
                expiry: expiry,
                cvv: cvv,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? svgPath,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 52.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: errorText != null
                  ? Colors.redAccent
                  : Colors.white.withValues(alpha: 0.04),
              width: 1.0,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              if (svgPath != null)
                SvgPicture.asset(
                  svgPath,
                  width: 20.r,
                  height: 20.r,
                  colorFilter: ColorFilter.mode(
                    errorText != null ? Colors.redAccent : Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  onChanged: onChanged,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 14.sp,
                      color: Colors.white38,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              errorText,
              style: GoogleFonts.dmSans(
                fontSize: 11.sp,
                color: Colors.redAccent,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CardNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _DateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }

    final formattedText = buffer.toString();

    if (formattedText.length > 5) {
      return oldValue;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
