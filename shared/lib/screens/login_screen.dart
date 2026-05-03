// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:shared_le_transporteur/core/widgets/app_image.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';
import 'package:shared_le_transporteur/core/widgets/legal_notice_widget.dart';

class LoginScreen extends StatelessWidget {
  final String backgroundImage;
  final String title;

  const LoginScreen({
    super.key,
    required this.backgroundImage,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Image Section
            SizedBox(
              height: 0.4.sh,
              width: double.infinity,
              child: AppImage(
                assetPath: backgroundImage,
                fit: BoxFit.cover,
              ),
            ),
            // Bottom Form Section
            Transform.translate(
              offset: Offset(0, -40.r),
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.displayMedium),
                      SizedBox(height: 32.h),
                      const AppTextField(
                        hintText: "Numéro de téléphone",
                        prefixIcon: Icons.phone_outlined,
                      ),
                      SizedBox(height: 16.h),
                      const AppTextField(
                        hintText: "Mot de passe",
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // "Se rappeler" would need a stateful widget to manage state
                          Text("Se rappeler", style: Theme.of(context).textTheme.bodyMedium),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Mot de passe oublié ?",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      AppButton(
                        text: "Se connecter",
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            // TODO: Implement login logic
                          }
                        },
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Pas de compte ? ", style: Theme.of(context).textTheme.bodyMedium),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "S'inscrire",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const LegalNoticeWidget(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example of how to use it in your navigation:
// import 'package:shared_le_transporteur/core/constants/assets.dart';
// Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(
//   backgroundImage: AppAssets.backgroundMotoLivreur,
//   title: "Connectez-vous !\nUne livraison vous attend !!"
// )));
