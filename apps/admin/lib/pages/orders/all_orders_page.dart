// apps/admin/lib/pages/orders/all_orders_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/api/v1/admin_api.dart';
import 'package:shared_le_transporteur/models/commande.dart';
import 'package:intl/intl.dart';

class AllOrdersPage extends StatefulWidget {
  const AllOrdersPage({super.key});

  @override
  State<AllOrdersPage> createState() => _AllOrdersPageState();
}

class _AllOrdersPageState extends State<AllOrdersPage> {
  final _adminApi = AdminApi();
  List<Commande> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _adminApi.getAllOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toutes les Commandes'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrders),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('Aucune commande trouvée'))
              : ListView.separated(
                  itemCount: _orders.length,
                  padding: EdgeInsets.all(16.w),
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, i) {
                    final order = _orders[i];
                    return _buildOrderCard(order);
                  },
                ),
    );
  }

  Widget _buildOrderCard(Commande order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Commande #${order.id.substring(order.id.length - 6).toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildStatusBadge(order.status),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  order.getDisplayLocation(true),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              const Icon(Icons.flag, size: 16, color: Colors.orange),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  order.getDisplayLocation(false),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${NumberFormat.currency(symbol: '', decimalDigits: 0).format(order.finalPrice ?? 0)} FCFA',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16.sp),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to Order Detail / Override
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.withValues(alpha: 0.1),
                  foregroundColor: Colors.orange,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                ),
                child: const Text('Gérer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    switch (status.toLowerCase()) {
      case 'pending': color = Colors.blue; break;
      case 'accepted': color = Colors.orange; break;
      case 'picked_up': color = Colors.purple; break;
      case 'delivered': color = Colors.green; break;
      case 'cancelled': color = Colors.red; break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10.sp, fontWeight: FontWeight.bold),
      ),
    );
  }
}
