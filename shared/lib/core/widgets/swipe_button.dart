import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:flutter/services.dart';

class SwipeButton extends StatefulWidget {
  final String text;
  final VoidCallback onSwipe;
  final Color? color;
  final IconData icon;
  final bool isLoading;

  const SwipeButton({
    super.key,
    required this.text,
    required this.onSwipe,
    this.color,
    this.icon = Icons.arrow_forward_rounded,
    this.isLoading = false,
  });

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton> {
  double _dragValue = 0.0;
  bool _completed = false;

  @override
  void didUpdateWidget(SwipeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset state if text or color changed, or if it was loading and finished
    if (oldWidget.text != widget.text || 
        oldWidget.color != widget.color || 
        (oldWidget.isLoading && !widget.isLoading)) {
      setState(() {
        _dragValue = 0.0;
        _completed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    final double thumbSize = 50.h;

    return Container(
      width: double.infinity,
      height: thumbSize + 10.h,
      padding: EdgeInsets.all(5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxDrag = constraints.maxWidth - thumbSize;
          
          return Stack(
            alignment: Alignment.center,
            children: [
              Text(
                widget.text.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: color.withOpacity(0.8),
                  letterSpacing: 0.5,
                ),
              ),
              Positioned(
                left: _dragValue,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_completed || widget.isLoading) return;
                    setState(() {
                      _dragValue = (_dragValue + details.delta.dx).clamp(0.0, maxDrag);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_completed || widget.isLoading) return;
                    if (_dragValue >= maxDrag * 0.8) {
                      setState(() {
                        _dragValue = maxDrag;
                        _completed = true;
                      });
                      HapticFeedback.heavyImpact();
                      widget.onSwipe();
                    } else {
                      setState(() {
                        _dragValue = 0.0;
                      });
                    }
                  },
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                              width: 24.sp,
                              height: 24.sp,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              _completed ? Icons.check_rounded : widget.icon,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
