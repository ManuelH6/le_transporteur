import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final Function(String) onVerified;
  final VoidCallback onResend;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.onVerified,
    required this.onResend,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _start = 30;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      _start = 30;
      _canResend = false;
    });
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _canResend = true;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = AppColors.primary;
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    final borderColor = AppColors.primary.withOpacity(0.4);

    final defaultPinTheme = PinTheme(
      width: 56.w,
      height: 56.h,
      textStyle: GoogleFonts.poppins(
        fontSize: 22.sp,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19.r),
        border: Border.all(color: borderColor),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Text(
                  "Vérification OTP",
                  style: GoogleFonts.poppins(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 10.h),
                RichText(
                  text: TextSpan(
                    text: "Entrez le code envoyé au ",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                    children: [
                      TextSpan(
                        text: widget.phoneNumber,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                
                Center(
                  child: Pinput(
                    controller: _pinController,
                    focusNode: _focusNode,
                    length: 4,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: focusedBorderColor),
                      ),
                    ),
                    submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        color: fillColor,
                        borderRadius: BorderRadius.circular(19.r),
                        border: Border.all(color: focusedBorderColor),
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyBorderWith(
                      border: Border.all(color: Colors.redAccent),
                    ),
                    // Removed onCompleted to prevent auto-submit if causing issues, or keep it but ensure single call
                    // For now, let's rely on the button or explicit action to avoid accidental navigation
                    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  ),
                ),

                SizedBox(height: 30.h),
                
                Center(
                  child: _canResend
                      ? TextButton(
                          onPressed: () {
                            widget.onResend();
                            startTimer();
                          },
                          child: Text(
                            "Renvoyer le code",
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : RichText(
                          text: TextSpan(
                            text: "Renvoyer le code dans ",
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                            children: [
                              TextSpan(
                                text: "00:${_start.toString().padLeft(2, '0')}",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),

                SizedBox(height: 100.h), // Spacing for scroll
                
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_pinController.text.length == 4) {
                        widget.onVerified(_pinController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Vérifier",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
