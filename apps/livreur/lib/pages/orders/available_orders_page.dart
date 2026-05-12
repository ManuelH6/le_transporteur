import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/models/commande.dart';
import 'package:shared_le_transporteur/utils/pricing_logic.dart';
import 'package:livreur_le_transporteur/pages/orders/order_details_page.dart';
import 'package:shared_le_transporteur/api/v1/order_api.dart';
import 'package:intl/intl.dart';

class AvailableOrdersPage extends StatefulWidget {
  const AvailableOrdersPage({super.key});

  @override
  State<AvailableOrdersPage> createState() => _AvailableOrdersPageState();
}

class _AvailableOrdersPageState extends State<AvailableOrdersPage> {
  List<Commande> _commandes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCommandes();
  }

  Future<void> _loadCommandes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await OrderApi().getAvailableOrders();
      if (mounted) {
        setState(() {
          _commandes = orders;
          // Sort by suggested price (custom logic)
          _commandes.sort((a, b) {
            final avgA = a.prixSuggere.isNotEmpty ? a.prixSuggere.reduce((a, b) => a + b) / a.prixSuggere.length : 0;
            final avgB = b.prixSuggere.isNotEmpty ? b.prixSuggere.reduce((a, b) => a + b) / b.prixSuggere.length : 0;
            return avgB.compareTo(avgA);
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60.sp, color: Colors.red[300]),
                      SizedBox(height: 16.h),
                      Text("Erreur: $_error", style: GoogleFonts.poppins(color: Colors.red)),
                      TextButton(onPressed: _loadCommandes, child: const Text("Réessayer")),
                    ],
                  ),
                )
              : _commandes.isEmpty
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
              builder: (context) => OrderDetailsPage(commande: commande, isAvailableMode: true),
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
                    "${commande.estimatedPrice?.toInt() ?? 0} FCFA",
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
              if (commande.isScheduled && commande.scheduledAt != null) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.access_time_outlined, color: Colors.orange[800], size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                      "Planifié pour : ${DateFormat('HH:mm').format(commande.scheduledAt!.toLocal())}",
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),
              ],
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
                      Expanded(
                        child: Text(
                          "Proposition client : ${commande.propositionClient!.toInt()} FCFA",
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
