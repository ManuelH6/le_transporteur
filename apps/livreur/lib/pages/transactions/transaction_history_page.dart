import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

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
  final List<String> _filters = ['Tout', 'Gains', 'Retraits'];

  final List<TransactionModel> _mockTransactions = [
    TransactionModel(
      id: '1',
      title: 'Livraison #8822',
      subtitle: 'Akwa - Bonapriso',
      amount: 2500,
      date: DateTime.now(),
      type: TransactionType.earning,
    ),
    TransactionModel(
      id: '2',
      title: 'Livraison #8821',
      subtitle: 'Deido - Bonanjo',
      amount: 1800,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      type: TransactionType.earning,
    ),
    TransactionModel(
      id: '3',
      title: 'Virement Hebdomadaire',
      subtitle: 'Vers Orange Money',
      amount: -25000,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: TransactionType.payout,
    ),
    TransactionModel(
      id: '4',
      title: 'Livraison #8819',
      subtitle: 'Logpom - Kotto',
      amount: 3200,
      date: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      type: TransactionType.earning,
    ),
    TransactionModel(
      id: '5',
      title: 'Livraison #8818',
      subtitle: 'Bonamoussadi - Makepe',
      amount: 2100,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: TransactionType.earning,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0EB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.text, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Historique des Gains",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              _buildSummaryHeader(constraints),
              _buildFilterSection(constraints),
              Expanded(
                child: _buildTransactionList(constraints),
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

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        children: [
          Text(
            "Solde Actuel",
            style: GoogleFonts.poppins(
              fontSize: constraints.maxWidth * 0.035,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: constraints.maxWidth * 0.01),
          Text(
            "45 800 FCFA",
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
                "125 000",
                Icons.arrow_upward,
                Colors.green,
              ),
              Container(
                width: 1,
                height: constraints.maxWidth * 0.08,
                color: Colors.grey[300],
              ),
              _buildSummaryItem(
                constraints,
                "Retraits",
                "80 000",
                Icons.arrow_downward,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BoxConstraints constraints,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
                color: Colors.grey[600],
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
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(BoxConstraints constraints) {
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
                color: isSelected ? Colors.white : AppColors.text,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(constraints.maxWidth * 0.05),
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey[300]!,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionList(BoxConstraints constraints) {
    final filteredList = _mockTransactions.where((t) {
      if (_selectedFilter == 'Gains') return t.type == TransactionType.earning;
      if (_selectedFilter == 'Retraits') return t.type == TransactionType.payout;
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
  }

  Widget _buildTransactionItem(BoxConstraints constraints, TransactionModel transaction) {
    final isEarning = transaction.type == TransactionType.earning;
    final itemPadding = constraints.maxWidth * 0.04;

    return Container(
      margin: EdgeInsets.only(bottom: constraints.maxWidth * 0.03),
      padding: EdgeInsets.all(itemPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                    color: AppColors.text,
                  ),
                ),
                Text(
                  transaction.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: constraints.maxWidth * 0.03,
                    color: Colors.grey[600],
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
                DateFormat('dd MMM, HH:mm').format(transaction.date),
                style: GoogleFonts.poppins(
                  fontSize: constraints.maxWidth * 0.028,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
