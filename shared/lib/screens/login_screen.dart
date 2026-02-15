// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';

class LoginScreen extends StatelessWidget {
  final String backgroundImage;
  final String title;

  const LoginScreen({
    Key? key,
    required this.backgroundImage,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Image Section
            Container(
              height: 350.h,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(backgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Bottom Form Section
            Transform.translate(
              offset: Offset(0, -40.h),
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
                      Text(title, style: Theme.of(context).textTheme.displayLarge),
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
                      )
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
// Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(
//   backgroundImage: AppAssets.backgroundMotoLivreur,
//   title: "Connectez-vous !\nUne livraison vous attend !!"
// )));
