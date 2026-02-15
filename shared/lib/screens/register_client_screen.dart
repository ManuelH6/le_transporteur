import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/core/constants/assets.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';

class RegisterClientScreen extends StatelessWidget {
  const RegisterClientScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300.h,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppAssets.backgroundLivreurColis),
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
                      Text("Inscrivez-vous", style: Theme.of(context).textTheme.displayLarge),
                      SizedBox(height: 32.h),
                      const AppTextField(hintText: "Nom et prénom", prefixIcon: Icons.person_outline),
                      SizedBox(height: 16.h),
                      const AppTextField(hintText: "Numéro de téléphone", prefixIcon: Icons.phone_outlined),
                      SizedBox(height: 16.h),
                      const AppTextField(hintText: "Mot de passe", prefixIcon: Icons.lock_outline, isPassword: true),
                      SizedBox(height: 16.h),
                      const AppTextField(hintText: "Confirmer mot de passe", prefixIcon: Icons.lock_outline, isPassword: true),
                      SizedBox(height: 24.h),
                      AppButton(
                        text: "S'inscrire",
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            // TODO: Implement registration logic
                          }
                        },
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Vous avez déjà un compte ? ", style: Theme.of(context).textTheme.bodyMedium),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Se connecter",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
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
