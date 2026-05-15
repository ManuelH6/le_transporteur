import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_le_transporteur/api/v1/api_client.dart';
import 'package:shared_le_transporteur/api/v1/order_api.dart';
import 'package:shared_le_transporteur/api/v1/report_api.dart';

enum TransactionType { earning, payout }

class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final TransactionType type;

  TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
  });
}

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  String _selectedFilter = 'Tout';
  final List<String> _filters = ['Tout', 'Jour', 'Semaine', 'Mois'];
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _summary;
  List<TransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await ApiClient().user;
      if (user == null) throw Exception("Session expirée");

      final summary = await ReportApi().getHistoryMe();
      final orders = await OrderApi().getOrdersByCourier(user.id!);
      
      // Filter for completed/delivered orders
      final completedOrders = orders.where((o) {
        final s = o.status.toLowerCase();
        return s == 'completed' || s == 'terminee' || s == 'terminée' || s == 'livré' || s == 'livree';
      }).toList();

      final transactions = completedOrders.map((item) {
        final grossAmount = (item.finalPrice ?? item.propositionLivreur ?? item.propositionClient ?? 0.0).toDouble();
        return TransactionModel(
          id: item.id,
          title: "Livraison #${item.id.substring(0, min(5, item.id.length)).toUpperCase()}",
          subtitle: "Statut: ${item.statut}",
          amount: grossAmount * 0.3, // 30% for courier
          date: item.dateCreation,
          type: TransactionType.earning,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _summary = summary;
          _transactions = transactions;
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

  int min(int a, int b) => a < b ? a : b;


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFFF0EB),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? AppColors.darkText : AppColors.text, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Historique des Gains",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Erreur: $_error", style: GoogleFonts.poppins(color: isDark ? AppColors.darkText : AppColors.text)))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        _buildSummaryHeader(constraints),
                        _buildFilterSection(constraints),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _fetchHistory,
                            child: _buildTransactionList(constraints),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  Widget _buildSummaryHeader(BoxConstraints constraints) {
    final horizontalPadding = constraints.maxWidth * 0.05;
    final verticalPadding = constraints.maxWidth * 0.06;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      color: isDark ? AppColors.darkSurface : Colors.white,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        children: [
          Text(
            "Solde Actuel",
            style: GoogleFonts.poppins(
              fontSize: constraints.maxWidth * 0.035,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          SizedBox(height: constraints.maxWidth * 0.01),
          Text(
            "${_calculateTotalRevenue().toInt()} FCFA",
            style: GoogleFonts.poppins(
              fontSize: constraints.maxWidth * 0.08,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: constraints.maxWidth * 0.04),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryItem(
                constraints,
                "Ce mois",
                "${_calculateMonthlyRevenue().toInt()}",
                Icons.arrow_upward,
                Colors.green,
              ),
              Container(
                width: 1,
                height: constraints.maxWidth * 0.08,
                color: isDark ? Colors.grey[800] : Colors.grey[300],
              ),
              _buildSummaryItem(
                constraints,
                "Aujourd'hui",
                "${_calculateDailyRevenue().toInt()}",
                Icons.trending_up,
                AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateTotalRevenue() {
    return _transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateDailyRevenue() {
    final now = DateTime.now();
    return _transactions.where((t) => 
      t.date.day == now.day && t.date.month == now.month && t.date.year == now.year
    ).fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateMonthlyRevenue() {
    final now = DateTime.now();
    return _transactions.where((t) => 
      t.date.month == now.month && t.date.year == now.year
    ).fold(0.0, (sum, t) => sum + t.amount);
  }

  Widget _buildSummaryItem(
    BoxConstraints constraints,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: constraints.maxWidth * 0.035, color: color),
            SizedBox(width: constraints.maxWidth * 0.01),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: constraints.maxWidth * 0.03,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: constraints.maxWidth * 0.01),
        Text(
          "$value F",
          style: GoogleFonts.poppins(
            fontSize: constraints.maxWidth * 0.04,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(BoxConstraints constraints) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: constraints.maxWidth * 0.15,
      margin: EdgeInsets.symmetric(vertical: constraints.maxWidth * 0.03),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.05),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: EdgeInsets.only(right: constraints.maxWidth * 0.02),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
              },
              selectedColor: AppColors.primary,
              labelStyle: GoogleFonts.poppins(
                fontSize: constraints.maxWidth * 0.035,
                color: isSelected ? Colors.white : (isDark ? AppColors.darkText : AppColors.text),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(constraints.maxWidth * 0.05),
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionList(BoxConstraints constraints) {
    final now = DateTime.now();
    final filteredList = _transactions.where((t) {
      if (_selectedFilter == 'Jour') {
        return t.date.day == now.day && t.date.month == now.month && t.date.year == now.year;
      }
      if (_selectedFilter == 'Semaine') {
        return t.date.isAfter(now.subtract(const Duration(days: 7)));
      }
      if (_selectedFilter == 'Mois') {
        return t.date.month == now.month && t.date.year == now.year;
      }
      return true;
    }).toList();


    if (filteredList.isEmpty) {
      return Center(
        child: Text(
          "Aucune transaction trouvée",
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.05),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final transaction = filteredList[index];
        return _buildTransactionItem(constraints, transaction);
      },
    );
  }  Widget _buildTransactionItem(BoxConstraints constraints, TransactionModel transaction) {
    final isEarning = transaction.type == TransactionType.earning;
    final itemPadding = constraints.maxWidth * 0.04;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: constraints.maxWidth * 0.03),
      padding: EdgeInsets.all(itemPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(constraints.maxWidth * 0.03),
            decoration: BoxDecoration(
              color: (isEarning ? Colors.green : Colors.red).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarning ? Icons.add : Icons.remove,
              color: isEarning ? Colors.green : Colors.red,
              size: constraints.maxWidth * 0.05,
            ),
          ),
          SizedBox(width: constraints.maxWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: GoogleFonts.poppins(
                    fontSize: constraints.maxWidth * 0.038,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.text,
                  ),
                ),
                Text(
                  transaction.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: constraints.maxWidth * 0.03,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isEarning ? '+' : ''}${transaction.amount.toInt()} F",
                style: GoogleFonts.poppins(
                  fontSize: constraints.maxWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: isEarning ? Colors.green : Colors.red,
                ),
              ),
              Text(
                DateFormat('dd MMM, HH:mm', 'fr_FR').format(transaction.date),
                style: GoogleFonts.poppins(
                  fontSize: constraints.maxWidth * 0.028,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
 }
