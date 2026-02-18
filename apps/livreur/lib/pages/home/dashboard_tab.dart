import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:livreur_le_transporteur/pages/transactions/transaction_history_page.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Revenue Section
          _buildRevenueHeroCard(),
          SizedBox(height: 24.h),
          
          // Statistics Grid 2x2
          _buildStatisticsGrid(),
          SizedBox(height: 24.h),
          
          // Transaction History Access
          _buildTransactionHistoryCard(context),
          SizedBox(height: 24.h),
          
          // Detailed Statistics
          _buildDetailedStats(),
          SizedBox(height: 100.h), // Space for bottom navigation
        ],
      ),
    );
  }

  Widget _buildRevenueHeroCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(constraints.maxWidth * 0.06),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.white, size: constraints.maxWidth * 0.07),
                  SizedBox(width: constraints.maxWidth * 0.03),
                  Flexible(
                    child: Text(
                      "Revenu Hebdomadaire",
                      style: GoogleFonts.poppins(
                        fontSize: constraints.maxWidth * 0.04,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: constraints.maxWidth * 0.04),
              Text(
                "25 000 FCFA",
                style: GoogleFonts.poppins(
                  fontSize: constraints.maxWidth * 0.09,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              SizedBox(height: constraints.maxWidth * 0.02),
              Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.greenAccent, size: constraints.maxWidth * 0.045),
                  SizedBox(width: constraints.maxWidth * 0.015),
                  Flexible(
                    child: Text(
                      "+15% vs semaine dernière",
                      style: GoogleFonts.poppins(
                        fontSize: constraints.maxWidth * 0.033,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: constraints.maxWidth * 0.05),
              Container(
                padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    _buildRevenueDetailRow("Revenu Total", "150 000 FCFA", constraints),
                    SizedBox(height: constraints.maxWidth * 0.03),
                    _buildRevenueDetailRow("Commission (30%)", "45 000 FCFA", constraints, isHighlight: true),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRevenueDetailRow(String label, String value, BoxConstraints constraints, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: constraints.maxWidth * 0.035,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isHighlight ? constraints.maxWidth * 0.04 : constraints.maxWidth * 0.035,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }


  Widget _buildStatisticsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 16.w) / 2; // 2 columns with spacing
        
        return Wrap(
          spacing: 16.w,
          runSpacing: 16.h,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                icon: Icons.local_shipping,
                value: "5",
                label: "Livraisons\ndu Jour",
                color: const Color(0xFF4CAF50),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                icon: Icons.star,
                value: "4.8",
                label: "Évaluation\nMoyenne",
                color: const Color(0xFFFFC107),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                icon: Icons.check_circle,
                value: "100",
                label: "Livraisons\nRéussies",
                color: const Color(0xFF2196F3),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                icon: Icons.access_time,
                value: "50h",
                label: "Heures de\nTravail",
                color: const Color(0xFF9C27B0),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive sizes based on available width
        final cardPadding = constraints.maxWidth * 0.08;
        final iconPadding = constraints.maxWidth * 0.06;
        final iconSize = constraints.maxWidth * 0.15;
        final valueSize = constraints.maxWidth * 0.14;
        final labelSize = constraints.maxWidth * 0.07;
        
        return Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: iconSize),
              ),
              SizedBox(height: constraints.maxWidth * 0.05),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: valueSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: constraints.maxWidth * 0.02),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: labelSize,
                  color: Colors.grey[600],
                  height: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildTransactionHistoryCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TransactionHistoryPage()),
        );
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.receipt_long, color: AppColors.primary, size: 28.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Historique des Transactions",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Consultez tous vos paiements",
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.white, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                "Statistiques Détaillées",
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildProgressStat("Livraisons Réussies", 100, 120, const Color(0xFF4CAF50)),
          SizedBox(height: 16.h),
          _buildProgressStat("Retours", 2, 120, const Color(0xFFFF5252)),
          SizedBox(height: 16.h),
          _buildProgressStat("Taux de Réussite", 98, 100, const Color(0xFF2196F3)),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, int value, int max, Color color) {
    final percentage = (value / max * 100).clamp(0, 100);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            Text(
              label == "Taux de Réussite" ? "$value%" : "$value",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8.h,
          ),
        ),
      ],
    );
  }
}
