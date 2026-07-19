import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
          ),
          SizedBox(height: 12.h),

          // Card Number
          _buildTextField(
            controller: numberController,
            hintText: "Enter Card number",
            svgPath: "assets/icons/card number.svg",
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12.h),

          // Expiry & CVV Row
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: expiryController,
                  hintText: "Enter expiry date",
                  svgPath: "assets/icons/calender.svg",
                  keyboardType: TextInputType.datetime,
                  inputFormatters: [_DateTextInputFormatter()],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTextField(
                  controller: cvvController,
                  hintText: "Enter CVV",
                  svgPath: "assets/icons/cvv.svg",
                  keyboardType: TextInputType.number,
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
              widget.onAdd(
                name: nameController.text.trim(),
                cardNumber: numberController.text.trim(),
                expiry: expiryController.text.trim(),
                cvv: cvvController.text.trim(),
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
  }) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
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
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
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
      if (i == 2 || i == 4) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }

    final formattedText = buffer.toString();

    if (formattedText.length > 10) {
      return oldValue;
    }

    int selectionIndex = formattedText.length;
    if (newValue.selection.end < newValue.text.length) {
      int digitCountBeforeCursor = newValue.text
          .substring(0, newValue.selection.end)
          .replaceAll(RegExp(r'[^0-9]'), '')
          .length;
      int formattedIndex = 0;
      int digitCount = 0;
      while (formattedIndex < formattedText.length &&
          digitCount < digitCountBeforeCursor) {
        if (formattedText[formattedIndex] != '/') {
          digitCount++;
        }
        formattedIndex++;
      }
      selectionIndex = formattedIndex;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
