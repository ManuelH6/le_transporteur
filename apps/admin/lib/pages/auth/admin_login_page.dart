// apps/admin/lib/pages/auth/admin_login_page.dart

import 'package:flutter/material.dart';
import 'package:shared_le_transporteur/screens/login_screen.dart';
import 'package:shared_le_transporteur/api/v1/auth_api.dart';
import 'package:shared_le_transporteur/services/notification_service.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final authApi = AuthApi();
      final response = await authApi.login(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        // BYPASS POUR TEST: On accepte temporairement tous les rôles
        /*
        if (response.user.role != 'admin') {
          await authApi.logout(null);
          throw "Accès refusé. Seuls les administrateurs peuvent se connecter à cette application.";
        }
        */

        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        NotificationService().showError(e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      backgroundImage: 'assets/images/background_moto_livreur.jpg',
      title: 'Portail Admin\nSécurisé',
      emailController: _emailController,
      passwordController: _passwordController,
      onLogin: _handleLogin,
      onForgotPassword: () {
        // Rediriger vers la récupération de mot de passe partagée
        // Navigator.pushNamed(context, '/forgot-password');
        NotificationService().showInfo("Veuillez contacter le support technique pour réinitialiser votre mot de passe administrateur.");
      },
      isLoading: _isLoading,
      showRegisterSection: true,
      onRegister: () {
        Navigator.pushNamed(context, '/register');
      },
    );
  }
}
