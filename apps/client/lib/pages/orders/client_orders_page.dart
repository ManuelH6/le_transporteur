import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/api/v1/user_api.dart';
import 'package:shared_le_transporteur/api/v1/order_api.dart';
import 'package:shared_le_transporteur/core/widgets/notification_bell.dart';
import 'package:shared_le_transporteur/models/commande.dart';
import 'package:shared_le_transporteur/screens/orders/order_details_screen.dart';
import 'package:intl/intl.dart';

class ClientOrdersPage extends StatefulWidget {
  const ClientOrdersPage({super.key});

  @override
  State<ClientOrdersPage> createState() => _ClientOrdersPageState();
}

class _ClientOrdersPageState extends State<ClientOrdersPage> {
  List<Commande> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await UserApi().getMe();
      final orders = await OrderApi().getOrdersByClient(user.id!);
      
      // Parallel fetch of negotiations for each order
      await Future.wait(orders.map((order) async {
        final neg = await OrderApi().getNegotiation(order.id);
        if (neg != null) {
          order.updateFromNegotiation(neg);
        }
      }));

      if (mounted) {
        setState(() {
          _orders = orders;
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppColors.text, size: 24.sp),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Text(
          "Mes Livraisons",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
        actions: [
          const NotificationBell(),
          SizedBox(width: 8.w),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _buildErrorView()
              : _orders.isEmpty
                  ? _buildEmptyView()
                  : RefreshIndicator(
                      onRefresh: _fetchOrders,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(_orders[index]);
                        },
                      ),
                    ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            "Aucune commande pour le moment",
            style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red[300]),
            SizedBox(height: 16.h),
            Text(
              "Impossible de charger vos commandes",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(_error!, textAlign: TextAlign.center, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            TextButton(onPressed: _fetchOrders, child: const Text("Réessayer")),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Commande order) {
    debugPrint("DEBUG Client UI Card: id=${order.id}, propLivreur=${order.propositionLivreur}");
    final dateStr = DateFormat('dd MMM yyyy à HH:mm', 'fr_FR').format(order.dateCreation);

    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
          );
          if (result == true) {
            _fetchOrders();
          }
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
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      order.getDisplayStatus(),
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(order),
                      ),
                    ),
                  ),

                  Text(
                    "${(order.propositionLivreur ?? order.estimatedPrice ?? 0).toInt()} FCFA",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: AppColors.primary,
                    ),
                  ),

                ],
              ),
              SizedBox(height: 12.h),
              Text(
                order.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      order.deliveryAddress?.street ?? order.livraison.adresse,
                      style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (order.isScheduled && order.scheduledAt != null) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.access_time_outlined, size: 14.sp, color: AppColors.primary),
                    SizedBox(width: 4.w),
                    Text(
                      "Prévu pour : ${DateFormat('HH:mm').format(order.scheduledAt!.toLocal())}",
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp, 
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber ?? "N° ${order.id.substring(0, 8)}",
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey),
                  ),
                  Text(
                    dateStr,
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(Commande order) {
    final colorName = order.getStatusColorName();
    switch (colorName) {
      case 'blue': return Colors.blue;
      case 'orange': return Colors.orange;
      case 'purple': return Colors.purple;
      case 'green': return Colors.green;
      case 'red': return Colors.red;
      default: return Colors.grey;
    }
  }
}

