import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/api/v1/report_api.dart';
import 'package:shared_le_transporteur/models/commande.dart';
import 'package:intl/intl.dart';
import 'package:livreur_le_transporteur/pages/orders/order_details_page.dart';
import 'package:shared_le_transporteur/api/v1/order_api.dart';
import 'package:shared_le_transporteur/api/v1/api_client.dart';

class CourseHistoryPage extends StatefulWidget {
  const CourseHistoryPage({super.key});

  @override
  State<CourseHistoryPage> createState() => _CourseHistoryPageState();
}

class _CourseHistoryPageState extends State<CourseHistoryPage> {
  List<Commande> _history = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'En cours';
  final List<String> _filters = ['En cours', 'Terminées'];


  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await ApiClient().user;
      if (user == null || user.id == null) {
        throw Exception("Utilisateur non connecté");
      }

      // Use OrderApi.getOrdersByCourier which specifically fetches orders assigned to the courier
      final orders = await OrderApi().getOrdersByCourier(user.id!);
      
      // Parallel fetch of negotiations for each order
      await Future.wait(orders.map((order) async {
        try {
          final neg = await OrderApi().getNegotiation(order.id);
          if (neg != null) {
            order.updateFromNegotiation(neg);
          }
        } catch (_) {}
      }));
      
      if (mounted) {
        setState(() {
          _history = orders;
          _isLoading = false;
        });
      }

    } catch (e) {
      debugPrint("CourseHistoryPage primary fetch error: $e");
      // Fallback to ReportApi
      try {
        final summary = await ReportApi().getHistoryMe();
        final List<dynamic> historyData = summary['history'] ?? (summary is List ? summary : []);
        final orders = historyData.map((e) => Commande.fromJson(e)).toList();
        
        if (mounted) {
          setState(() {
            _history = orders;
            _isLoading = false;
          });
        }
      } catch (fallbackError) {
        if (mounted) {
          setState(() {
            _error = e.toString();
            _isLoading = false;
          });
        }
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
              ? Center(child: Text("Erreur: $_error"))
              : Column(
                  children: [
                    _buildFilterSection(),
                    Expanded(
                      child: _buildList(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      color: Colors.white,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedFilter = filter);
              },
              selectedColor: AppColors.primary,
              labelStyle: GoogleFonts.poppins(
                color: isSelected ? Colors.white : AppColors.text,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList() {
    final filteredHistory = _history.where((commande) {
      final status = commande.status.toLowerCase();
      if (_selectedFilter == 'En cours') {
        return status == 'processing' || 
               status == 'en_cours' || 
               status == 'pending' || 
               status == 'en_attente' || 
               status == 'negotiating' || 
               status == 'waiting_confirmation' ||
               status == 'accepted' ||
               status == 'assigned' ||
               status == 'en_livraison' ||
               status == 'assignee' ||
               status == 'accepté' ||
               status == 'ongoing' ||
               status == 'started' ||
               status == 'picked_up' ||
               status == 'in_transit' ||
               status == 'shipped' ||
               status == 'active' ||
               status == 'available' && commande.assignedTo != null; // Claims waiting for confirmation
      } else {

        return status == 'completed' || status == 'terminee' || status == 'terminée' || status == 'livré' || status == 'livree';
      }
    }).toList();

    if (filteredHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 60.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(
              "Aucun historique pour $_selectedFilter",
              style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHistory,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: filteredHistory.length,
        itemBuilder: (context, index) {
          final item = filteredHistory[index];
          return _buildHistoryCard(item);
        },
      ),
    );
  }


  Widget _buildHistoryCard(Commande commande) {
    final statusColor = _getStatusColor(commande);
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsPage(commande: commande),
          ),
        ).then((_) => _fetchHistory());
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 12.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Commande #${commande.orderNumber ?? commande.id.substring(0, 8)}",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      commande.getDisplayStatus(),
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                commande.description,
                style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey[800]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (commande.isScheduled && commande.scheduledAt != null) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.access_time_outlined, color: Colors.orange[800], size: 14.sp),
                    SizedBox(width: 4.w),
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
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('dd MMM yyyy, HH:mm', 'fr_FR').format(commande.dateCreation),
                      style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "${(commande.propositionLivreur ?? commande.finalPrice ?? commande.estimatedPrice ?? 0).toInt()} FCFA",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
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
