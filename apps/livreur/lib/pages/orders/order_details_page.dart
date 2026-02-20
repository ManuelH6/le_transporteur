import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/models/commande.dart';
import 'package:shared_le_transporteur/services/mock_database.dart';
import 'package:shared_le_transporteur/utils/pricing_logic.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsPage extends StatefulWidget {
  final Commande commande;

  const OrderDetailsPage({super.key, required this.commande});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Commande _commande;
  bool _isReserved = false;

  @override
  void initState() {
    super.initState();
    _commande = widget.commande;
    _isReserved = _commande.statut != 'Disponible';
  }

  void _accepterCommande() {
    setState(() {
      _commande.statut = 'En attente de confirmation';
      _isReserved = true;
    });
    MockDatabase().mettreAJourCommande(_commande);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Commande réservée (10 min)', style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _contacterWhatsApp(String phone) async {
    final url = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d\'ouvrir WhatsApp', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmerPrix(double prix) {
    setState(() {
      _commande.statut = 'Prix confirmé';
      // In a real app, we would set prixFinal here, but Commande model has it as final.
      // We would need to update the model or create a new one.
    });
    MockDatabase().mettreAJourCommande(_commande);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Prix confirmé : \${prix.toInt()} FCFA', style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _validerEtape(String nouvelleEtape) {
    setState(() {
      _commande.statut = nouvelleEtape;
    });
    MockDatabase().mettreAJourCommande(_commande);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Étape validée : $nouvelleEtape', style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAchat = _commande.type == 'achat';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.text, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Détails de la commande",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _isReserved ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                _commande.statut,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _isReserved ? Colors.orange : Colors.green,
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Description
            Text(
              "Description",
              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              _commande.description,
              style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[800]),
            ),
            SizedBox(height: 24.h),

            // Addresses
            _buildAddressSection(
              title: isAchat ? "Lieu d'achat" : "Lieu de récupération",
              address: _commande.pickup.adresse,
              phone: _commande.pickupPhone,
              icon: Icons.trip_origin,
              color: AppColors.primary,
            ),
            SizedBox(height: 16.h),
            _buildAddressSection(
              title: "Lieu de livraison",
              address: _commande.livraison.adresse,
              phone: _commande.livraisonPhone,
              icon: Icons.location_on,
              color: AppColors.secondary,
            ),
            SizedBox(height: 24.h),

            // Instructions
            if (_commande.instructions != null && _commande.instructions!.isNotEmpty) ...[
              Text(
                "Instructions spéciales",
                style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.yellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.yellow.withValues(alpha: 0.5)),
                ),
                child: Text(
                  _commande.instructions!,
                  style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[800]),
                ),
              ),
              SizedBox(height: 24.h),
            ],

            // Pricing
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Prix suggéré",
                    style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    PricingLogic.formaterIntervalle(_commande.prixSuggere),
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (_commande.propositionClient != null) ...[
                    Divider(height: 24.h),
                    Text(
                      "Proposition du client",
                      style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "\${_commande.propositionClient!.toInt()} FCFA",
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Actions
            if (!_isReserved)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _accepterCommande,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(
                    "Accepter la commande",
                    style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              )
            else ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _contacterWhatsApp(_commande.pickupPhone),
                  icon: const Icon(Icons.chat, color: Colors.green),
                  label: Text(
                    "Contacter sur WhatsApp",
                    style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.green),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              if (_commande.statut == 'En attente de confirmation') ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _confirmerPrix(_commande.prixSuggere[0]),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text(
                          "Confirmer prix",
                          style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Show dialog to propose new price
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text(
                          "Proposer prix",
                          style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (_commande.statut == 'Prix confirmé') ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _validerEtape('En cours'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      "Démarrer la course",
                      style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ] else if (_commande.statut == 'En cours') ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _validerEtape('Livré'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      "Marquer comme Livré",
                      style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ] else if (_commande.statut == 'Livré') ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _validerEtape('Terminée'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      "Paiement reçu (Terminer)",
                      style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection({
    required String title,
    required String address,
    required String phone,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 4.h),
              Text(
                address,
                style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(Icons.phone, size: 14.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    phone,
                    style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[800]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
