// apps/admin/lib/pages/dashboard/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/api/v1/admin_api.dart';
import 'package:shared_le_transporteur/models/dashboard_stats.dart';
import 'package:shared_le_transporteur/core/widgets/user_drawer_header.dart';
import 'package:admin_le_transporteur/pages/dashboard/widgets/kpi_card.dart';
import 'package:admin_le_transporteur/pages/users/user_management_page.dart';
import 'package:admin_le_transporteur/pages/orders/all_orders_page.dart';
import 'package:admin_le_transporteur/pages/fleet/fleet_tracking_page.dart';
import 'package:admin_le_transporteur/pages/finance/transaction_history_page.dart';
import 'package:admin_le_transporteur/pages/settings/config_page.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _adminApi = AdminApi();
  DashboardStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final data = await _adminApi.getDashboardStats();
      setState(() {
        _stats = DashboardStats.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // TODO: Show error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Control Center'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onPressed: _loadStats,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vue d\'ensemble',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _buildKpiGrid(),
                    SizedBox(height: 30.h),
                    Text(
                      'Croissance des Revenus',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _buildRevenueChart(),
                    SizedBox(height: 30.h),
                    _buildRecentActivity(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildKpiGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      childAspectRatio: 1.1,
      children: [
        KpiCard(
          title: 'CA Total',
          value: '${_stats?.totalRevenue.toStringAsFixed(0)} FCFA',
          icon: Icons.account_balance_wallet,
          color: Colors.green,
        ),
        KpiCard(
          title: 'Courses Actives',
          value: '${_stats?.activeOrders}',
          icon: Icons.local_shipping,
          color: Colors.orange,
        ),
        KpiCard(
          title: 'Livreurs en Attente',
          value: '${_stats?.pendingLivreurs}',
          icon: Icons.person_add,
          color: Colors.blue,
        ),
        KpiCard(
          title: 'Clients Total',
          value: '${_stats?.totalClients}',
          icon: Icons.people,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildRevenueChart() {
    if (_stats == null || _stats!.revenueChart.isEmpty) {
      return const SizedBox();
    }

    return Container(
      height: 250.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _stats!.revenueChart.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.amount);
              }).toList(),
              isCurved: true,
              color: Colors.orange,
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activités Récentes', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10.h),
          const ListTile(
            leading: CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
            title: Text('Nouveau livreur inscrit'),
            subtitle: Text('Il y a 5 minutes'),
          ),
          const ListTile(
            leading: CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.check, color: Colors.white)),
            title: Text('Course #1234 terminée'),
            subtitle: Text('Il y a 12 minutes'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserDrawerHeader(),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', isActive: true, onTap: () => Navigator.pop(context)),
          _buildDrawerItem(Icons.people, 'Utilisateurs', onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementPage()));
          }),
          _buildDrawerItem(Icons.local_shipping, 'Livraisons', onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AllOrdersPage()));
          }),
          _buildDrawerItem(Icons.map, 'Suivi de Flotte', onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FleetTrackingPage()));
          }),
          _buildDrawerItem(Icons.account_balance_wallet, 'Finances', onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionHistoryPage()));
          }),
          _buildDrawerItem(Icons.settings, 'Configuration', onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigPage()));
          }),
          const Divider(),
          _buildDrawerItem(Icons.logout, 'Déconnexion', isDestructive: true, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, {bool isActive = false, bool isDestructive = false, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : (isActive ? Colors.orange : Colors.grey)),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : (isActive ? Colors.orange : Colors.black87),
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }
}
