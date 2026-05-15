import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/models/commande.dart';
import 'package:shared_le_transporteur/utils/pricing_logic.dart';
import 'package:livreur_le_transporteur/pages/orders/order_details_page.dart';
import 'package:shared_le_transporteur/api/v1/order_api.dart';
import 'package:intl/intl.dart';

class AvailableOrdersPage extends StatefulWidget {
  const AvailableOrdersPage({super.key});

  @override
  State<AvailableOrdersPage> createState() => _AvailableOrdersPageState();
}

class _AvailableOrdersPageState extends State<AvailableOrdersPage> {
  List<Commande> _commandes = [];
  bool _isLoading = true;
  String? _error;

  // Filtres
  String _searchQuery = "";
  String _selectedType = "Tout"; // Tout, Livraison, Achat
  DateTime? _filterDate;
  RangeValues _priceRange = const RangeValues(0, 50000);
  final TextEditingController _searchController = TextEditingController();

  List<Commande> get _filteredCommandes {
    return _commandes.where((commande) {
      // Type de service
      if (_selectedType != "Tout") {
        final isAchat = commande.serviceType.toLowerCase() == 'achat';
        if (_selectedType == "Livraison" && isAchat) return false;
        if (_selectedType == "Achat" && !isAchat) return false;
      }

      // Recherche manuelle
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final desc = commande.description.toLowerCase();
        final addrFrom = commande.getDisplayLocation(true).toLowerCase();
        final addrTo = commande.getDisplayLocation(false).toLowerCase();
        if (!desc.contains(query) && !addrFrom.contains(query) && !addrTo.contains(query)) return false;
      }

      // Date
      if (_filterDate != null) {
        if (!DateUtils.isSameDay(commande.dateCreation, _filterDate)) return false;
      }

      // Prix
      final price = (commande.estimatedPrice ?? 0);
      if (price < _priceRange.start || price > _priceRange.end) return false;

      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadCommandes();
  }

  Future<void> _loadCommandes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await OrderApi().getAvailableOrders();
      if (mounted) {
        setState(() {
          _commandes = orders;
          // Sort by suggested price (custom logic)
          _commandes.sort((a, b) {
            final avgA = a.prixSuggere.isNotEmpty ? a.prixSuggere.reduce((a, b) => a + b) / a.prixSuggere.length : 0;
            final avgB = b.prixSuggere.isNotEmpty ? b.prixSuggere.reduce((a, b) => a + b) / b.prixSuggere.length : 0;
            return avgB.compareTo(avgA);
          });
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

  Future<void> _claimOrder(Commande commande) async {
    setState(() => _isLoading = true);
    try {
      await OrderApi().claimOrder(commande.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Commande acceptée ! Elle est maintenant dans 'Mes courses'.", style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
          ),
        );
        _loadCommandes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : $e", style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 60.sp, color: Colors.red[300]),
                            SizedBox(height: 16.h),
                            Text("Erreur: $_error", style: GoogleFonts.poppins(color: Colors.red)),
                            TextButton(onPressed: _loadCommandes, child: const Text("Réessayer")),
                          ],
                        ),
                      )
                    : _filteredCommandes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_outlined, size: 60.sp, color: isDark ? Colors.grey[800] : Colors.grey[300]),
                                SizedBox(height: 16.h),
                                Text(
                                  _searchQuery.isNotEmpty || _selectedType != "Tout" || _filterDate != null
                                      ? "Aucun résultat"
                                      : "Aucune commande disponible",
                                  style: GoogleFonts.poppins(fontSize: 16.sp, color: isDark ? Colors.grey[600] : Colors.grey),
                                ),
                                if (_searchQuery.isNotEmpty || _selectedType != "Tout" || _filterDate != null)
                                  TextButton(
                                    onPressed: () => setState(() {
                                      _searchQuery = "";
                                      _searchController.clear();
                                      _selectedType = "Tout";
                                      _filterDate = null;
                                      _priceRange = const RangeValues(0, 50000);
                                    }),
                                    child: const Text("Effacer les filtres"),
                                  ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async => _loadCommandes(),
                            child: ListView.builder(
                              padding: EdgeInsets.all(16.w),
                              itemCount: _filteredCommandes.length,
                              itemBuilder: (context, index) {
                                final commande = _filteredCommandes[index];
                                return _buildOrderCard(commande);
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
                      hintText: "Rechercher un lieu, colis...",
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
              children: ["Tout", "Livraison", "Achat"].map((filter) {
                final isSelected = _selectedType == filter;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedType = filter);
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
                
                Text("Date de création", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14.sp, color: isDark ? AppColors.darkText : AppColors.text)),
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
                  "Fourchette de prix (FCFA)", 
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

  Widget _buildOrderCard(Commande commande) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAchat = commande.serviceType.toLowerCase() == 'achat';
    
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
              builder: (context) => OrderDetailsPage(commande: commande, isAvailableMode: true),
            ),
          ).then((_) => _loadCommandes());
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${commande.estimatedPrice?.toInt() ?? 0} F",
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        "Gain Net",
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
}
