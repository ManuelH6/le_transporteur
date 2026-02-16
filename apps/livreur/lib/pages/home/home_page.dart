import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Accueil Livreur",
          style: GoogleFonts.poppins(color: AppColors.text, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "Bienvenue Livreur !",
          style: GoogleFonts.poppins(fontSize: 20, color: AppColors.text),
        ),
      ),
    );
  }
}
