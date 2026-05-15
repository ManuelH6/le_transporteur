// apps/admin/lib/pages/finance/transaction_history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/api/v1/admin_api.dart';
import 'package:intl/intl.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final _adminApi = AdminApi();
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      // Assuming stats has transaction logs for now or we add an endpoint
      final stats = await _adminApi.getDashboardStats();
      setState(() {
        _transactions = List<Map<String, dynamic>>.from(stats['recentTransactions'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des Transactions')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? const Center(child: Text('Aucune transaction trouvée'))
              : ListView.separated(
                  itemCount: _transactions.length,
                  padding: EdgeInsets.all(16.w),
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, i) {
                    final tx = _transactions[i];
                    return ListTile(
                      leading: Icon(
                        tx['type'] == 'payment' ? Icons.arrow_downward : Icons.arrow_upward,
                        color: tx['type'] == 'payment' ? Colors.green : Colors.red,
                      ),
                      title: Text(tx['description'] ?? 'Transaction'),
                      subtitle: Text(tx['date'] ?? ''),
                      trailing: Text(
                        '${tx['amount']} FCFA',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
    );
  }
}
