import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';

class UnavailableServiceScreen extends StatelessWidget {
  const UnavailableServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Service indisponible dans ce pays",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.red),
            ),
            SizedBox(height: 16.h),
            Text(
              "Nous vous prions de saisir votre adresse e-mail pour être notifié lorsque notre service sera disponible dans votre région.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 32.h),
            // TODO: Add an email text field here if needed
            AppButton(
              text: "Je veux savoir",
              onPressed: () {
                // TODO: Implement email submission logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
