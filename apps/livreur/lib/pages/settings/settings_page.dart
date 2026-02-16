import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Paramètres en construction",
          style: GoogleFonts.poppins(fontSize: 18),
        ),
      ),
    );
  }
}
