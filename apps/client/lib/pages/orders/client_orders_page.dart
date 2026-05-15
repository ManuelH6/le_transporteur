import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/api/v1/user_api.dart';
import 'package:shared_le_transporteur/api/v1/order_api.dart';
import 'package:shared_le_transporteur/core/widgets/notification_bell.dart';
import 'package:shared_le_transporteur/models/commande.dart';
import 'package:shared_le_transporteur/screens/orders/order_details_screen.dart';
import 'package:shared_le_transporteur/core/widgets/skeleton_loader.dart';
import 'package:shared_le_transporteur/core/widgets/empty_state.dart';
import 'package:ms_undraw/ms_undraw.dart';
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

  // Filtres
  String _searchQuery = "";
  String _selectedQuickFilter = "Tout";
  DateTime? _filterDate;
  RangeValues _priceRange = const RangeValues(0, 50000);
  String? _advancedStatus;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Commande> get _filteredOrders {
    return _orders.where((order) {
      // Filtre rapide par statut
      if (_selectedQuickFilter != "Tout") {
        final status = order.status.toLowerCase();
        if (_selectedQuickFilter == "En attente" && !['pending', 'available', 'disponible', 'en_attente'].contains(status)) return false;
        if (_selectedQuickFilter == "En cours" && !['ongoing', 'processing', 'en_livraison', 'started', 'accepted'].contains(status)) return false;
        if (_selectedQuickFilter == "Terminées" && !['delivered', 'completed', 'livrée', 'terminée'].contains(status)) return false;
      }

      // Recherche manuelle (Lieu ou Description)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final desc = order.description.toLowerCase();
        final addr = (order.deliveryAddress?.street ?? order.livraison.adresse).toLowerCase();
        if (!desc.contains(query) && !addr.contains(query)) return false;
      }

      // Filtre par date
      if (_filterDate != null) {
        if (!DateUtils.isSameDay(order.dateCreation, _filterDate)) return false;
      }

      // Filtre par prix
      final price = (order.propositionLivreur ?? order.estimatedPrice ?? 0);
      if (price < _priceRange.start || price > _priceRange.end) return false;

      // Filtre avancé par statut précis
      if (_advancedStatus != null && order.status.toLowerCase() != _advancedStatus!.toLowerCase()) return false;

      return true;
    }).toList();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        title: Text(
          "Mes Commandes",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu, color: isDark ? Colors.white : AppColors.text, size: 28.sp),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          const NotificationBell(),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(isDark),
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: 5,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: const SkeletonCard(),
                    ),
                  )
                : _error != null
                    ? _buildErrorView()
                    : _filteredOrders.isEmpty
                        ? _buildEmptyView()
                        : RefreshIndicator(
                            onRefresh: _fetchOrders,
                            color: AppColors.primary,
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              itemCount: _filteredOrders.length,
                              itemBuilder: (context, index) {
                                return _buildOrderCard(_filteredOrders[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return EmptyState(
      illustration: UnDrawIllustration.no_data,
      title: _searchQuery.isNotEmpty || _selectedQuickFilter != "Tout" || _filterDate != null
          ? "Aucun résultat" 
          : "Aucune commande",
      description: _searchQuery.isNotEmpty 
          ? "Aucune commande ne correspond à votre recherche."
          : "Vous n'avez pas encore passé de commande. Commencez dès maintenant !",
      buttonText: "Actualiser",
      onButtonPressed: () {
        setState(() {
          _searchQuery = "";
          _searchController.clear();
          _selectedQuickFilter = "Tout";
          _filterDate = null;
          _advancedStatus = null;
          _priceRange = const RangeValues(0, 50000);
        });
        _fetchOrders();
      },
    );
  }

  Widget _buildFilterBar(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          if (!isDark)
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45.h,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: "Lieu, description...",
                      hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: _showFilterSheet,
                child: Container(
                  height: 45.h,
                  width: 45.h,
                  decoration: BoxDecoration(
                    color: (_filterDate != null || _advancedStatus != null) ? AppColors.primary : (isDark ? Colors.grey[900] : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.tune,
                    color: (_filterDate != null || _advancedStatus != null) ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["Tout", "En attente", "En cours", "Terminées"].map((filter) {
                final isSelected = _selectedQuickFilter == filter;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedQuickFilter = filter);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          
          return Container(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 40.h),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Filtres avancés", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _filterDate = null;
                          _advancedStatus = null;
                          _priceRange = const RangeValues(0, 50000);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Réinitialiser"),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                
                // Filtre Date
                Text("Date de commande", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14.sp)),
                SizedBox(height: 12.h),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _filterDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setModalState(() => _filterDate = picked);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                        SizedBox(width: 12.w),
                        Text(
                          _filterDate == null ? "Toutes les dates" : DateFormat('dd MMMM yyyy', 'fr_FR').format(_filterDate!),
                          style: GoogleFonts.poppins(fontSize: 13.sp),
                        ),
                        const Spacer(),
                        if (_filterDate != null)
                          GestureDetector(
                            onTap: () => setModalState(() => _filterDate = null),
                            child: const Icon(Icons.close, size: 16),
                          ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Intervalle de Prix
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Prix (FCFA)", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14.sp)),
                    Text(
                      "${_priceRange.start.toInt()} - ${_priceRange.end.toInt()}",
                      style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 50000,
                  divisions: 50,
                  activeColor: AppColors.primary,
                  onChanged: (RangeValues values) {
                    setModalState(() => _priceRange = values);
                  },
                ),
                
                SizedBox(height: 24.h),
                
                // Statut Précis
                Text("Statut précis", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14.sp)),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  children: ["En attente", "En cours", "Livrée"].map((s) {
                    final isSelected = _advancedStatus == s;
                    return ChoiceChip(
                      label: Text(s),
                      selected: isSelected,
                      onSelected: (val) {
                        setModalState(() => _advancedStatus = val ? s : null);
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                    );
                  }).toList(),
                ),
                
                SizedBox(height: 32.h),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Appliquer au state principal
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text("Appliquer les filtres", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
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
        borderRadius: BorderRadius.circular(20.r),
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
                      color: _getStatusColor(order).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
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
                    order.getDisplayTime(),
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp, 
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.humanizedSummary,
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkText : AppColors.text,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14.sp, color: Colors.grey),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                order.getDisplayLocation(false),
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp, 
                                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "${(order.propositionLivreur ?? order.estimatedPrice ?? 0).toInt()} F",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 16.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (order.orderNumber != null) ...[
                const Divider(height: 24),
                Text(
                  "N° ${order.orderNumber}",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp, 
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
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
