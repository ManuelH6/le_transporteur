import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/models/commande.dart';
import 'package:shared_le_transporteur/services/mock_database.dart';
import 'package:shared_le_transporteur/utils/pricing_logic.dart';
import 'package:livreur_le_transporteur/pages/orders/order_details_page.dart';

class AvailableOrdersPage extends StatefulWidget {
  const AvailableOrdersPage({super.key});

  @override
  State<AvailableOrdersPage> createState() => _AvailableOrdersPageState();
}

class _AvailableOrdersPageState extends State<AvailableOrdersPage> {
  List<Commande> _commandes = [];

  @override
  void initState() {
    super.initState();
    _loadCommandes();
  }

  void _loadCommandes() {
    final all = MockDatabase().getCommandes();
    setState(() {
      _commandes = all.where((c) => c.statut == 'Disponible').toList();
      // Tri par prix suggéré médian descendant
      _commandes.sort((a, b) {
        final medianA = (a.prixSuggere[0] + a.prixSuggere[1]) / 2;
        final medianB = (b.prixSuggere[0] + b.prixSuggere[1]) / 2;
        return medianB.compareTo(medianA);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Commandes disponibles",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: _commandes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 60.sp, color: Colors.grey[300]),
                  SizedBox(height: 16.h),
                  Text(
                    "Aucune commande disponible",
                    style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => _loadCommandes(),
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: _commandes.length,
                itemBuilder: (context, index) {
                  final commande = _commandes[index];
                  return _buildOrderCard(commande);
                },
              ),
            ),
    );
  }

  Widget _buildOrderCard(Commande commande) {
    final isAchat = commande.type == 'achat';
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(commande: commande),
            ),
          ).then((_) => _loadCommandes());
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isAchat ? Colors.blue.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      isAchat ? "Achat & Livraison" : "Livraison simple",
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isAchat ? Colors.blue : AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    PricingLogic.formaterIntervalle(commande.prixSuggere),
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Icon(Icons.trip_origin, color: AppColors.primary, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      commande.pickup.adresse,
                      style: GoogleFonts.poppins(fontSize: 13.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.secondary, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      commande.livraison.adresse,
                      style: GoogleFonts.poppins(fontSize: 13.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (commande.propositionClient != null) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_offer_outlined, color: Colors.green, size: 16.sp),
                      SizedBox(width: 8.w),
                      Text(
                        "Proposition client : \${commande.propositionClient!.toInt()} FCFA",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
