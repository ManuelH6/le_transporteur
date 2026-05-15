import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/api/v1/order_api.dart';
import 'package:shared_le_transporteur/models/commande.dart';
import 'package:shared_le_transporteur/services/notification_service.dart';
import 'package:shared_le_transporteur/core/widgets/step_progress_tracker.dart';
import 'package:shared_le_transporteur/core/widgets/skeleton_loader.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Commande order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isCancelling = false;
  bool _isLoading = false;
  late Commande _currentOrder;
  bool _isInitialLoading = true;
  bool _hasReviewed = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      final results = await Future.wait([
        OrderApi().getOrderById(_currentOrder.id),
        OrderApi().getNegotiation(_currentOrder.id),
      ]);
      
      final order = results[0] as Commande;
      final neg = results[1] as Map<String, dynamic>?;

      if (neg != null) {
        order.updateFromNegotiation(neg);
      }

      if (mounted) {
        setState(() {
          _currentOrder = order;
          _isInitialLoading = false;
        });
        
        if (order.status.toLowerCase() == 'livree' && !_hasReviewed) {
          _showRatingDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitialLoading = false);
      }
    }
  }

  void _showRatingDialog() {
    int rating = 5;
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          title: Text("Course terminée !", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Comment s'est passée votre livraison ?", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14.sp)),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 32.sp,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() => rating = index + 1);
                    },
                  ),
                )),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Un petit mot sur le livreur... (optionnel)",
                  hintStyle: GoogleFonts.poppins(fontSize: 12.sp),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await OrderApi().reviewOrder(
                    orderId: _currentOrder.id, 
                    rating: rating, 
                    comment: commentController.text,
                  );
                  _hasReviewed = true;
                  if (context.mounted) Navigator.pop(context);
                  NotificationService().showSuccess("Merci pour votre avis !");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text("Envoyer", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCurrentStep() {
    final s = _currentOrder.status.toLowerCase();
    if (s == 'disponible' || s == 'available' || s == 'en_attente' || s == 'pending') return 0;
    if (s == 'assignee' || s == 'assigned' || s == 'accepted' || s == 'accepté' || s == 'en_discussion_tarifaire') return 1;
    if (s == 'prix_valide' || s == 'confirmé') return 2;
    if (s == 'en_livraison' || s == 'en_cours' || s == 'processing') return 3;
    if (s == 'livree' || s == 'livré' || s == 'delivered' || s == 'terminee' || s == 'completed') return 5;
    return 0;
  }

  // ... (rest of the methods: _confirmCourierPrice, _rejectCourierPrice, etc. remain the same)

  @override
  Widget build(BuildContext context) {
    final status = _currentOrder.status.toLowerCase();
    final canCancel = status == 'disponible' || status == 'en_attente' || status == 'available' || status == 'pending';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          "Suivi de commande",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark ? AppColors.darkText : AppColors.text,
        elevation: 0,
      ),
      body: _isInitialLoading 
          ? _buildLoadingState()
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StepProgressTracker(
                    currentStep: _getCurrentStep(),
                    steps: const [
                      "Commande créée",
                      "Négociation en cours",
                      "Prix confirmé",
                      "Livraison en cours",
                      "Livré",
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _buildStatusCard(),
                  if (_currentOrder.isScheduled && _currentOrder.scheduledAt != null) ...[
                    SizedBox(height: 20.h),
                    _buildInfoSection(
                      "Date et Heure de Livraison", 
                      DateFormat('EEEE dd MMMM yyyy à HH:mm', 'fr_FR').format(_currentOrder.scheduledAt!.toLocal()), 
                      Icons.calendar_today_outlined
                    ),
                  ],
                  SizedBox(height: 20.h),
                  _buildInfoSection("Description", _currentOrder.description, Icons.description_outlined),
                  SizedBox(height: 20.h),
                  _buildAddressSection(),
                  SizedBox(height: 20.h),
                  _buildPriceSection(),
                  SizedBox(height: 32.h),
                  if (canCancel)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          if (!_isCancelling) _cancelOrder();
                        },
                        icon: _isCancelling 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                          : const Icon(Icons.cancel_outlined, color: Colors.red),
                        label: Text("Annuler la commande", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                      ),
                    ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          SkeletonLoader(width: double.infinity, height: 200.h),
          SizedBox(height: 20.h),
          SkeletonLoader(width: double.infinity, height: 80.h),
          SizedBox(height: 20.h),
          SkeletonLoader(width: double.infinity, height: 120.h),
          SizedBox(height: 20.h),
          SkeletonLoader(width: double.infinity, height: 150.h),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          if (!isDark)
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: _getStatusColor(_currentOrder).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getStatusIcon(_currentOrder.status), color: _getStatusColor(_currentOrder)),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentOrder.getDisplayStatus(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16.sp, 
                    color: _getStatusColor(_currentOrder)
                  ),
                ),
                Text(
                  "Commande n° ${_currentOrder.orderNumber ?? _currentOrder.id.substring(0, 8)}",
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white, 
        borderRadius: BorderRadius.circular(16.r)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14.sp, color: isDark ? AppColors.darkText : AppColors.text)),
            ],
          ),
          SizedBox(height: 12.h),
          Text(content, style: GoogleFonts.poppins(fontSize: 14.sp, color: isDark ? Colors.grey[400] : Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white, 
        borderRadius: BorderRadius.circular(16.r)
      ),
      child: Column(
        children: [
          _buildAddressRow(
            "Point de départ",
            _currentOrder.pickupAddress?.street ?? _currentOrder.pickup.adresse,
            _currentOrder.pickupAddress?.phone ?? _currentOrder.pickupPhone,
            Icons.trip_origin,
            Colors.blue,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.w, top: 4.h, bottom: 4.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(width: 2, height: 20.h, color: Colors.grey[300]),
            ),
          ),
          _buildAddressRow(
            "Destination",
            _currentOrder.deliveryAddress?.street ?? _currentOrder.livraison.adresse,
            _currentOrder.deliveryAddress?.phone ?? _currentOrder.livraisonPhone,
            Icons.location_on,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(String label, String address, String phone, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey)),
              Text(address, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500, color: isDark ? AppColors.darkText : AppColors.text)),
              SizedBox(height: 4.h),
              Text(phone, style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    final status = _currentOrder.status.toLowerCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white, 
        borderRadius: BorderRadius.circular(16.r)
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Type de service", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)),
              Text(
                _currentOrder.serviceType == 'courrier' ? 'Livraison' : 'Achat', 
                style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.text)
              ),
            ],
          ),
          Divider(height: 24.h, color: isDark ? Colors.grey[800] : Colors.grey[200]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Prix final", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.text)),
              Text(
                "${(_currentOrder.propositionLivreur ?? _currentOrder.finalPrice ?? _currentOrder.estimatedPrice ?? 0).toInt()} FCFA",
                style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          if (_currentOrder.propositionLivreur != null && 
              _currentOrder.negotiationStatus == 'pending_client_approval' &&
              (status == 'available' || status == 'disponible' || status == 'en_attente' || status == 'pending' || status == 'en_discussion_tarifaire')) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Proposition du livreur", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.orange[800], fontWeight: FontWeight.bold)),
                  SizedBox(height: 4.h),
                  Text("${_currentOrder.propositionLivreur!.toInt()} FCFA", style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.orange[900])),
                  SizedBox(height: 12.h),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              _confirmCourierPrice();
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                            child: Text("Accepter", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _rejectCourierPrice();
                            },
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                            child: Text("Refuser", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- Keep original methods to avoid breakage ---
  Future<void> _confirmCourierPrice() async {
    if (_currentOrder.propositionLivreur == null) return;
    String? selectedMethod = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.r)))),
            SizedBox(height: 24.h),
            Text("Confirmer la commande", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20.sp)),
            SizedBox(height: 8.h),
            Text("Prix convenu : ${_currentOrder.propositionLivreur!.toInt()} FCFA", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600])),
            SizedBox(height: 24.h),
            Text("Moyen de paiement", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16.sp)),
            SizedBox(height: 16.h),
            _buildPaymentOption(context: context, id: 'cash', title: "Espèces", subtitle: "Payer à la livraison", icon: Icons.payments_outlined, color: Colors.green),
            SizedBox(height: 12.h),
            _buildPaymentOption(context: context, id: 'mobile_money', title: "Mobile Money", subtitle: "MTN MoMo ou Moov Money", icon: Icons.phone_android, color: Colors.orange),
            SizedBox(height: 12.h),
            _buildPaymentOption(context: context, id: 'card', title: "Carte Bancaire", subtitle: "Visa, Mastercard", icon: Icons.credit_card, color: Colors.blue),
            SizedBox(height: 32.h),
            SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))), child: Text("Annuler", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)))),
          ],
        ),
      ),
    );
    if (selectedMethod == null) return;
    setState(() => _isLoading = true);
    try {
      await OrderApi().confirmPrice(_currentOrder.id, _currentOrder.propositionLivreur!, selectedMethod);
      if (mounted) {
        NotificationService().showSuccessDialog(title: "Prix confirmé", message: "Le prix de la course a été validé avec succès.", onConfirm: () => Navigator.pop(context, true));
      }
    } catch (e) {
      if (mounted) NotificationService().showError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPaymentOption({required BuildContext context, required String id, required String title, required String subtitle, required IconData icon, required Color color}) {
    return InkWell(
      onTap: () => Navigator.pop(context, id),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16.r)),
        child: Row(
          children: [
            Container(padding: EdgeInsets.all(10.w), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
            SizedBox(width: 16.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14.sp)), Text(subtitle, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey[500]))])),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Future<void> _rejectCourierPrice() async {
    final controller = TextEditingController();
    final newPrice = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Contre-proposition", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [Text("Entrez le prix que vous souhaitez proposer au livreur.", style: GoogleFonts.poppins()), SizedBox(height: 16.h), TextField(controller: controller, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: "Ex: 1200", suffixText: "FCFA", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))))]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) Navigator.pop(context, val);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Proposer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (newPrice == null) return;
    setState(() => _isLoading = true);
    try {
      await OrderApi().proposePrice(_currentOrder.id, newPrice);
      if (mounted) { NotificationService().showSuccess("Contre-proposition envoyée"); _fetchOrderDetails(); }
    } catch (e) { if (mounted) NotificationService().showError(e); } finally { if (mounted) setState(() => _isLoading = false); }
  }

  void _contacterAdmin() async { final url = Uri.parse('tel:+2290166630101'); if (await canLaunchUrl(url)) { await launchUrl(url); } }

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Annuler la commande", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: const Text("Voulez-vous vraiment annuler cette commande ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Non"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Oui, annuler", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _isCancelling = true);
      try {
        await OrderApi().cancelOrderByClient(_currentOrder.id);
        if (mounted) { NotificationService().showSuccessDialog(title: "Commande annulée", message: "La commande a été annulée avec succès.", onConfirm: () => Navigator.pop(context, true)); }
      } catch (e) { if (mounted) NotificationService().showError(e); } finally { if (mounted) setState(() => _isCancelling = false); }
    }
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

  IconData _getStatusIcon(String status) {
    final s = status.toLowerCase();
    switch (s) {
      case 'disponible': case 'available': case 'en_attente': case 'pending': return Icons.timer_outlined;
      case 'assignee': case 'assigned': case 'accepted': case 'accepté': case 'prix_valide': return Icons.person_pin_circle_outlined;
      case 'en_livraison': case 'en_cours': case 'processing': return Icons.delivery_dining;
      case 'livree': case 'livré': case 'delivered': return Icons.check_circle_outline;
      case 'annulee_par_livreur': case 'annulee_par_client': case 'annulé': case 'cancelled': return Icons.cancel_outlined;
      case 'terminee': case 'completed': return Icons.done_all;
      default: return Icons.notifications_outlined;
    }
  }
}
