import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:livreur_le_transporteur/pages/transactions/transaction_history_page.dart';
import 'package:shared_le_transporteur/api/v1/api_client.dart';
import 'package:shared_le_transporteur/api/v1/order_api.dart';
import 'package:shared_le_transporteur/api/v1/report_api.dart';
import 'package:intl/intl.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool _isLoading = true;
  Map<String, dynamic>? _summary;
  final _currencyFormat = NumberFormat.currency(symbol: 'FCFA', decimalDigits: 0, locale: 'fr_FR');

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    try {
      final user = await ApiClient().user;
      if (user == null) return;

      // Fetch both summary and direct orders for better accuracy
      final summary = await ReportApi().getHistoryMe();
      final orders = await OrderApi().getOrdersByCourier(user.id!);
      
      if (mounted) {
        setState(() {
          // Merge or prioritize orders from OrderApi for the 'history' part
          _summary = summary;
          _summary!['history'] = orders.map((o) => o.toJson()).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final history = (_summary?['history'] as List?) ?? [];
    
    // NEW LOGIC
    double grossTotal = 0;
    double grossWeekly = 0;
    double grossMonthly = 0;
    int totalAccepted = history.length;
    int totalDelivered = 0;
    int todayDelivered = 0;
    
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekThreshold = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final monthThreshold = DateTime(now.year, now.month, 1);

    for (var item in history) {
      final price = (item['finalPrice'] ?? item['propositionLivreur'] ?? item['estimatedPrice'] ?? 0.0).toDouble();
      final status = item['status']?.toString().toLowerCase();
      final dateStr = item['dateCreation'] ?? item['createdAt'];
      final date = dateStr != null ? DateTime.tryParse(dateStr.toString()) ?? now : now;

      grossTotal += price;
      
      if (date.isAfter(weekThreshold)) {
        grossWeekly += price;
      }
      
      if (date.isAfter(monthThreshold)) {
        grossMonthly += price;
      }

      if (status == 'livree' || status == 'terminee' || status == 'terminée' || status == 'completed') {
        totalDelivered++;
        if (date.day == now.day && date.month == now.month && date.year == now.year) {
          todayDelivered++;
        }
      }
    }

    final netTotal = grossTotal * 0.3;
    final netMonthly = grossMonthly * 0.3;
    final commissionTotal = grossTotal * 0.7;
    final successRate = totalAccepted > 0 ? (totalDelivered / totalAccepted * 100).toInt() : 0;
    final rating = (_summary?['stats']?['rating'] ?? _summary?['kpis']?['rating'] ?? 5.0).toDouble();

    return RefreshIndicator(
      onRefresh: _fetchSummary,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRevenueHeroCard(grossWeekly, netTotal, netMonthly, commissionTotal, grossTotal),
            SizedBox(height: 24.h),
            _buildStatisticsGrid(todayDelivered, rating, totalDelivered, successRate),
            SizedBox(height: 24.h),
            _buildTransactionHistoryCard(context),
            SizedBox(height: 24.h),
            _buildDetailedStats(totalDelivered, successRate.toDouble()),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueHeroCard(num weeklyGross, num netTotal, num netMonthly, num commission, num grossTotal) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.account_balance_wallet, color: Colors.white, size: constraints.maxWidth * 0.05),
                      ),
                      SizedBox(width: constraints.maxWidth * 0.02),
                      Text(
                        "Gains Cumulés (30%)",
                        style: GoogleFonts.poppins(
                          fontSize: constraints.maxWidth * 0.038,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      "SOLDE",
                      style: GoogleFonts.poppins(
                        fontSize: constraints.maxWidth * 0.025,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: constraints.maxWidth * 0.04),
              Text(
                _currencyFormat.format(netTotal),
                style: GoogleFonts.poppins(
                  fontSize: constraints.maxWidth * 0.09,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Ce mois: ${_currencyFormat.format(netMonthly)}",
                style: GoogleFonts.poppins(
                  fontSize: constraints.maxWidth * 0.035,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              SizedBox(height: constraints.maxWidth * 0.06),
              Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
              SizedBox(height: constraints.maxWidth * 0.06),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat("Total Courses", _currencyFormat.format(grossTotal), constraints),
                  _buildMiniStat("Frais Service (70%)", _currencyFormat.format(commission), constraints),
                ],
              ),
              SizedBox(height: constraints.maxWidth * 0.06),
              Container(
                padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Volume de la semaine",
                      style: GoogleFonts.poppins(
                        fontSize: constraints.maxWidth * 0.03,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _currencyFormat.format(weeklyGross),
                      style: GoogleFonts.poppins(
                        fontSize: constraints.maxWidth * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: constraints.maxWidth * 0.028,
            color: Colors.white60,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: constraints.maxWidth * 0.035,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
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

  Widget _buildStatisticsGrid(num day, num rating, num total, num successRate) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 16.w) / 2;
        
        return Wrap(
          spacing: 16.w,
          runSpacing: 16.h,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                icon: Icons.today,
                value: "$day",
                label: "Livraisons\ndu Jour",
                color: AppColors.primary,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                icon: Icons.inventory_2,
                value: "$total",
                label: "Total\nLivraisons",
                color: const Color(0xFF2196F3),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                icon: Icons.analytics,
                value: "$successRate%",
                label: "Taux de\nRéussite",
                color: const Color(0xFF4CAF50),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                icon: Icons.stars,
                value: rating.toStringAsFixed(1),
                label: "Évaluation\nClient",
                color: const Color(0xFFFFC107),
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

  Widget _buildDetailedStats(num total, num successRate) {
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
          _buildProgressStat("Livraisons Réussies", total.toInt(), (total * 1.2).toInt() + 1, const Color(0xFF4CAF50)),
          SizedBox(height: 16.h),
          _buildProgressStat("Taux de Réussite", successRate.toInt(), 100, const Color(0xFF2196F3)),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, int value, int max, Color color) {
    final percentage = max > 0 ? (value / max * 100).clamp(0, 100) : 0.0;
    
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
