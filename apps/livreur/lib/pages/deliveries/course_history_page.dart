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

  // Filtres
  String _searchQuery = "";
  String _selectedQuickFilter = "Tout";
  final List<String> _filters = ["Tout", "En cours", "Terminées"];
  DateTime? _filterDate;
  RangeValues _priceRange = const RangeValues(0, 50000);
  final TextEditingController _searchController = TextEditingController();

  List<Commande> get _filteredHistory {
    return _history.where((commande) {
      // Filtre rapide par statut
      if (_selectedQuickFilter != "Tout") {
        final status = commande.status.toLowerCase();
        if (_selectedQuickFilter == "En cours") {
          final isOngoing = status == 'processing' || 
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
                 (status == 'available' && commande.assignedTo != null);
          if (!isOngoing) return false;
        } else if (_selectedQuickFilter == "Terminées") {
          final isDone = status == 'completed' || status == 'terminee' || status == 'terminée' || status == 'livré' || status == 'livree';
          if (!isDone) return false;
        }
      }

      // Recherche manuelle
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final desc = commande.description.toLowerCase();
        final id = commande.id.toLowerCase();
        final num = (commande.orderNumber ?? "").toLowerCase();
        if (!desc.contains(query) && !id.contains(query) && !num.contains(query)) return false;
      }

      // Date
      if (_filterDate != null) {
        if (!DateUtils.isSameDay(commande.dateCreation, _filterDate)) return false;
      }

      // Prix
      final price = (commande.propositionLivreur ?? commande.finalPrice ?? commande.estimatedPrice ?? 0);
      if (price < _priceRange.start || price > _priceRange.end) return false;

      return true;
    }).toList();
  }


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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Column(
        children: [
          _buildFilterBar(isDark),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text("Erreur: $_error", style: GoogleFonts.poppins(color: isDark ? AppColors.darkText : AppColors.text)))
                    : _filteredHistory.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history, size: 60.sp, color: isDark ? Colors.grey[800] : Colors.grey[300]),
                                SizedBox(height: 16.h),
                                Text(
                                  _searchQuery.isNotEmpty || _selectedQuickFilter != "Tout" || _filterDate != null
                                      ? "Aucun résultat trouvé"
                                      : "Aucun historique disponible",
                                  style: GoogleFonts.poppins(fontSize: 16.sp, color: isDark ? Colors.grey[600] : Colors.grey),
                                ),
                                if (_searchQuery.isNotEmpty || _selectedQuickFilter != "Tout" || _filterDate != null)
                                  TextButton(
                                    onPressed: () => setState(() {
                                      _searchQuery = "";
                                      _searchController.clear();
                                      _selectedQuickFilter = "Tout";
                                      _filterDate = null;
                                      _priceRange = const RangeValues(0, 50000);
                                    }),
                                    child: const Text("Effacer les filtres"),
                                  ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchHistory,
                            child: ListView.builder(
                              padding: EdgeInsets.all(16.w),
                              itemCount: _filteredHistory.length,
                              itemBuilder: (context, index) {
                                final item = _filteredHistory[index];
                                return _buildHistoryCard(item);
                              },
                            ),
                          ),
          ),
        ],
      ),
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
                      hintText: "N° commande, description...",
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
                    color: (_filterDate != null || _priceRange.start > 0 || _priceRange.end < 50000) ? AppColors.primary : (isDark ? Colors.grey[900] : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.tune,
                    color: (_filterDate != null || _priceRange.start > 0 || _priceRange.end < 50000) ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
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
              children: _filters.map((filter) {
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
                    Text("Filtres avancés", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.text)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _filterDate = null;
                          _priceRange = const RangeValues(0, 50000);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Réinitialiser"),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                
                Text("Date de livraison", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14.sp, color: isDark ? AppColors.darkText : AppColors.text)),
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
                      setState(() => _filterDate = picked);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                        SizedBox(width: 12.w),
                        Text(
                          _filterDate == null ? "Toutes les dates" : DateFormat('dd MMMM yyyy', 'fr_FR').format(_filterDate!),
                          style: GoogleFonts.poppins(color: isDark ? AppColors.darkText : AppColors.text),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                Text(
                  "Montant de la course (FCFA)", 
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14.sp, color: isDark ? AppColors.darkText : AppColors.text)
                ),
                SizedBox(height: 8.h),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 50000,
                  divisions: 50,
                  activeColor: AppColors.primary,
                  labels: RangeLabels(
                    "${_priceRange.start.toInt()} F",
                    "${_priceRange.end.toInt()} F",
                  ),
                  onChanged: (values) {
                    setModalState(() => _priceRange = values);
                    setState(() => _priceRange = values);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("0 F", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
                    Text("50 000 F+", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
                  ],
                ),
                
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text("Appliquer", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(Commande commande) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAchat = commande.serviceType.toLowerCase() == 'achat';
    final statusColor = _getStatusColor(commande);
    
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(commande: commande),
            ),
          ).then((_) => _fetchHistory());
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isAchat ? Colors.blue.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          isAchat ? "ACHAT" : "LIVRAISON",
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: isAchat ? Colors.blue : AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          commande.getDisplayStatus().toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${(commande.propositionLivreur ?? commande.finalPrice ?? commande.estimatedPrice ?? 0).toInt()} F",
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        "Gain",
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "${commande.getDisplayLocation(true)} ➔ ${commande.getDisplayLocation(false)}",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkText : AppColors.text,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              if (isAchat) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Avance de fonds requise",
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[800],
                              ),
                            ),
                            Text(
                              "Prévoir environ ${(commande.weight != null ? (commande.weight! * 1000).toInt() : 3000)} F",
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                 SizedBox(height: 8.h),
                 Text(
                   commande.description,
                   style: GoogleFonts.poppins(
                     fontSize: 13.sp, 
                     color: isDark ? Colors.grey[400] : Colors.grey[600],
                   ),
                   maxLines: 2,
                   overflow: TextOverflow.ellipsis,
                 ),
              ],
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    commande.getDisplayTime(),
                    style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey[500]),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
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
