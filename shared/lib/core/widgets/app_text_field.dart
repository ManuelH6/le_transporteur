// lib/core/widgets/app_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData prefixIcon;
  final Color? prefixIconColor;
  final bool isPassword;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final int? maxLines;
  final int? minLines;

  const AppTextField({
    super.key,
    this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.prefixIconColor,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.focusNode,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.minLines,
  });


  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      onFieldSubmitted: widget.onFieldSubmitted,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      minLines: widget.minLines,
      validator: widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ ne peut pas être vide';
            }
            if (widget.keyboardType == TextInputType.emailAddress &&
                !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
              return 'Veuillez saisir une adresse e-mail valide';
            }
            return null;
          },
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: Colors.grey[400],
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          widget.prefixIcon, 
          color: widget.prefixIconColor ?? Colors.grey[400], 
          size: 20.sp
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey[400],
                  size: 20.sp,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.redAccent),
      ),
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        color: AppColors.text,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
