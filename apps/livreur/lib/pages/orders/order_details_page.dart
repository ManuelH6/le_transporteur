import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/api/v1/order_api.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_image.dart';
import 'package:shared_le_transporteur/models/commande.dart';
import 'package:shared_le_transporteur/utils/pricing_logic.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:shared_le_transporteur/services/notification_service.dart';
import 'package:shared_le_transporteur/core/widgets/swipe_button.dart';
import 'package:shared_le_transporteur/core/widgets/skeleton_loader.dart';
import 'package:flutter/services.dart';

class OrderDetailsPage extends StatefulWidget {
  final Commande commande;
  final bool isAvailableMode;

  const OrderDetailsPage({
    super.key,
    required this.commande,
    this.isAvailableMode = false,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Commande _commande;
  bool _isReserved = false;
  final TextEditingController _priceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _commande = widget.commande;
    _isReserved = !widget.isAvailableMode && 
                  _commande.status.toLowerCase() != 'available' && 
                  _commande.status.toLowerCase() != 'disponible';
    _fetchNegotiation();
  }

  @override
  Widget build(BuildContext context) {
    final isAchat = _commande.type == 'achat';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? AppColors.darkText : AppColors.text, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Détails de la commande",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          Expanded(
            child: AbsorbPointer(
              absorbing: _isLoading,
              child: _isLoading && _commande.description.isEmpty 
                  ? _buildLoadingState()
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: _getStatusColor(_commande).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              _commande.getDisplayStatus(),
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(_commande),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Description
                          Text(
                            "Description",
                            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkText : AppColors.text),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _commande.description,
                            style: GoogleFonts.poppins(fontSize: 14.sp, color: isDark ? Colors.grey[400] : Colors.grey[800]),
                          ),
                          if (_commande.isScheduled && _commande.scheduledAt != null) ...[
                            SizedBox(height: 24.h),
                            Text(
                              "Date et Heure de Livraison",
                              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkText : AppColors.text),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: Colors.orange.withOpacity(0.5)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_outlined, color: Colors.orange[800], size: 20.sp),
                                  SizedBox(width: 12.w),
                                  Text(
                                    DateFormat('EEEE dd MMMM yyyy à HH:mm', 'fr_FR').format(_commande.scheduledAt!.toLocal()),
                                    style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.orange[900], fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          SizedBox(height: 24.h),

                          // Addresses
                          _buildAddressSection(
                            title: isAchat ? "Lieu d'achat" : "Lieu de récupération",
                            address: _commande.pickup.adresse,
                            phone: _commande.pickupPhone,
                            icon: Icons.trip_origin,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 16.h),
                          _buildAddressSection(
                            title: "Lieu de livraison",
                            address: _commande.livraison.adresse,
                            phone: _commande.livraisonPhone,
                            icon: Icons.location_on,
                            color: AppColors.secondary,
                          ),
                          SizedBox(height: 24.h),

                          // Pricing
                          _buildPricingCard(),
                          
                          SizedBox(height: 32.h),
                          _buildActionSection(),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Prix de la course",
            style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 4.h),
          Text(
            "${(_commande.finalPrice ?? _commande.estimatedPrice ?? 0).toInt()} FCFA",
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          SkeletonLoader(width: double.infinity, height: 100.h),
          SizedBox(height: 24.h),
          SkeletonLoader(width: double.infinity, height: 200.h),
          SizedBox(height: 24.h),
          SkeletonLoader(width: double.infinity, height: 150.h),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    final status = _commande.status.toLowerCase();
    
    // Ongoing Phase - Use Swipe to Finish
    if (status == 'en_cours' || status == 'en_livraison' || status == 'ongoing' || status == 'started' || status == 'picked_up' || status == 'in_transit') {
      return SwipeButton(
        text: "Glisser pour marquer comme Livré",
        isLoading: _isLoading,
        onSwipe: () {
          HapticFeedback.heavyImpact();
          _validerEtape('livree');
        },
        color: Colors.green,
        icon: Icons.check_circle_outline,
      );
    }

    // Ready to Start - Use Swipe to Start
    if (status == 'accepted' || status == 'assigned' || status == 'assignee' || status == 'processing' || status == 'accepté' || _commande.statut == 'Prix confirmé') {
      final needsNegotiation = _commande.negotiationStatus != 'confirmed' && _commande.statut != 'Prix confirmé';
      
      return Column(
        children: [
          if (needsNegotiation) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showProposePriceDialog,
                icon: const Icon(Icons.edit_note, color: AppColors.primary),
                label: Text(
                  _commande.propositionLivreur != null ? "Modifier ma proposition" : "Proposer mon prix",
                  style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
          SwipeButton(
            text: "Glisser pour démarrer la course",
            isLoading: _isLoading,
            onSwipe: () {
              HapticFeedback.heavyImpact();
              _validerEtape('en_livraison');
            },
            color: AppColors.primary,
            icon: Icons.delivery_dining,
          ),
        ],
      );
    }

    // Available Mode - Use Swipe to Accept
    if (widget.isAvailableMode) {
      return SwipeButton(
        text: "Glisser pour accepter",
        isLoading: _isLoading,
        onSwipe: () {
          HapticFeedback.heavyImpact();
          _checkTimingAndProceed("Voulez-vous accepter cette course ?", () {
            _accepterCommande();
          });
        },
        color: AppColors.primary,
        icon: Icons.check_circle_outline,
      );
    }

    // ... (rest of the action buttons like Accept/Propose remain the same)
    return _buildActionButtons();
  }

  Future<void> _fetchNegotiation() async {
    final neg = await OrderApi().getNegotiation(_commande.id);
    if (neg != null && mounted) {
      setState(() {
        _commande.updateFromNegotiation(neg);
      });
    }
  }


  Future<void> _accepterCommande() async {
    setState(() => _isLoading = true);
    try {
      final orderApi = OrderApi();
      await orderApi.claimOrder(_commande.id);
      if (_commande.propositionClient != null) {
        await orderApi.validatePrice(_commande.id);
      }
      if (mounted) {
        NotificationService().showSuccessDialog(
          title: "Commande acceptée",
          message: "La commande est maintenant dans votre liste 'Mes courses'.",
          onConfirm: () => Navigator.pop(context, true),
        );
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains("scheduled") && _commande.scheduledAt != null) {
        final scheduledLocal = _commande.scheduledAt!.toLocal();
        final timeStr = DateFormat('HH:mm').format(scheduledLocal);
        
        if (DateTime.now().isBefore(scheduledLocal)) {
          errorMessage = "Il est trop tôt pour réserver cette course planifiée pour $timeStr.";
        } else {
          errorMessage = "L'heure prévue ($timeStr) pour cette course est déjà passée.";
        }
        
        if (mounted) {
          NotificationService().showError(errorMessage);
          return;
        }
      }
      
      if (mounted) {
        NotificationService().showError(e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _proposerNouveauPrix(double amount) async {
    setState(() => _isLoading = true);
    try {
      final orderApi = OrderApi();
      // Removed auto-claiming here as it must be done separately now
      await orderApi.proposePrice(_commande.id, amount);
      if (mounted) {
        NotificationService().showSuccessDialog(
          title: "Proposition envoyée",
          message: "Votre proposition de prix a été envoyée au client.",
          onConfirm: () => Navigator.pop(context, true),
        );
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains("scheduled") && _commande.scheduledAt != null) {
        final scheduledLocal = _commande.scheduledAt!.toLocal();
        final timeStr = DateFormat('HH:mm').format(scheduledLocal);
        
        if (DateTime.now().isBefore(scheduledLocal)) {
          errorMessage = "Il est trop tôt pour réserver cette course planifiée pour $timeStr.";
        } else {
          errorMessage = "L'heure prévue ($timeStr) pour cette course est déjà passée.";
        }
        
        if (mounted) {
          NotificationService().showError(errorMessage);
          return;
        }
      }

      if (mounted) {
        NotificationService().showError(e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _checkTimingAndProceed(String message, VoidCallback onProceed) {
    if (_commande.isScheduled && _commande.scheduledAt != null) {
      final scheduledLocal = _commande.scheduledAt!.toLocal();
      if (DateTime.now().isAfter(scheduledLocal)) {
        final timeStr = DateFormat('HH:mm').format(scheduledLocal);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange[800]),
                SizedBox(width: 8.w),
                Text('Heure dépassée', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Attention, l'heure prévue ($timeStr) pour cette course est déjà passée.",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.orange[900]),
                ),
                SizedBox(height: 12.h),
                Text(
                  message,
                  style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[800]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler', style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onProceed();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Continuer quand même', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        return;
      }
    }
    onProceed();
  }

  void _contacterAdmin() async {
    final url = Uri.parse('tel:+2290166630101');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showProposePriceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Proposer un prix', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Entrez le prix que vous souhaitez proposer pour cette course.', style: GoogleFonts.poppins()),
            SizedBox(height: 16.h),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Ex: 2500',
                suffixText: 'FCFA',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_priceController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                _proposerNouveauPrix(amount);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Envoyer', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  String _formatPhone(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    if (!cleaned.startsWith('+')) {
      // Default to Benin country code if missing
      return '+229$cleaned';
    }
    return cleaned;
  }

  void _contacterWhatsApp(String phone) async {
    final formattedPhone = _formatPhone(phone);
    // Use the deep link for WhatsApp
    final url = Uri.parse('whatsapp://send?phone=${formattedPhone.replaceAll('+', '')}');
    final webUrl = Uri.parse('https://wa.me/${formattedPhone.replaceAll('+', '')}');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      if (mounted) {
        NotificationService().showError(e);
      }
    }
  }

  void _appelerDirect(String phone) async {
    final formattedPhone = _formatPhone(phone);
    final url = Uri.parse('tel:$formattedPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        NotificationService().showError("Impossible de passer l'appel. Veuillez vérifier les permissions de votre téléphone.");
      }
    }
  }


  Future<void> _validerEtape(String nouvelleEtape) async {
    setState(() => _isLoading = true);
    try {
      final updatedOrder = await OrderApi().updateOrderStatus(_commande.id, nouvelleEtape);
      
      if (mounted) {
        setState(() {
          _commande = updatedOrder;
        });

        if (nouvelleEtape == 'livree') {
          _showCompletionDialog();
        } else {
          NotificationService().showSuccessDialog(
            title: "Statut mis à jour",
            message: "La course est maintenant marquée comme : ${_commande.getDisplayStatus()}",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        NotificationService().showError(e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: Colors.green, size: 64.sp),
            ),
            SizedBox(height: 24.h),
            Text(
              "Félicitations !",
              style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              "La course a été marquée comme terminée avec succès.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Go back to history
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  "Retour à mes courses",
                  style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildActionButtons() {
    final status = _commande.status.toLowerCase();
    
    // 1. Negotiation Phase
    // 1. Negotiation Phase (after claiming)
    if (_commande.negotiationStatus == 'pending_client_approval' || 
        status == 'assigned' || status == 'assignee' || status == 'accepted' || status == 'accepté') {
      return Column(
        children: [
          if (_commande.propositionClient != null && _commande.propositionClient! > 0 && _commande.negotiationStatus != 'confirmed') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _accepterCommande(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  "Valider le prix client (${_commande.propositionClient!.toInt()} FCFA)",
                  style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _showProposePriceDialog,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(
                    _commande.propositionLivreur != null ? "Modifier prix" : "Proposer prix",
                    style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
              ),
              if (status == 'accepted' || status == 'assigned' || status == 'assignee' || status == 'accepté' || _commande.statut == 'Prix confirmé') ...[
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _validerEtape('en_livraison'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      "Démarrer",
                      style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    }

    // 2. Ready to Start Phase
    if (status == 'accepted' || status == 'assigned' || status == 'assignee' || status == 'processing' || status == 'accepté' || _commande.statut == 'Prix confirmé') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _validerEtape('en_livraison'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          child: Text(
            "Démarrer la course",
            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      );
    }

    // 3. Ongoing Phase
    if (status == 'en_cours' || status == 'en_livraison' || status == 'ongoing' || status == 'started' || status == 'picked_up' || status == 'in_transit') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _validerEtape('livree'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          child: Text(
            "Marquer comme Livré",
            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      );
    }

    /* 
       NOTE: Bloc de bouton pour la confirmation de paiement. 
       Commenté pour l'instant selon la demande car la logique backend (commissions, solde) 
       doit être implémentée pour que cette étape soit réellement fonctionnelle.
    */
    /*
    if (status == 'livré' || status == 'delivered' || status == 'livree') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _validerEtape('livree'), 
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          child: Text(
            "Paiement reçu (Terminer)",
            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      );
    }
    */

    // 5. Finalized Phase
    if (status == 'completed' || status == 'terminee' || status == 'terminée') {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8.w),
            Text(
              "Course terminée",
              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }


  Widget _buildContactSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Contacter via",
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              Text(
                _commande.pickupPhone,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _appelerDirect(_commande.pickupPhone),
            icon: const Icon(Icons.phone, color: AppColors.primary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.1),
            ),
          ),
          SizedBox(width: 8.w),
          IconButton(
            onPressed: () => _contacterWhatsApp(_commande.pickupPhone),
            icon: AppImage(
              assetPath: 'assets/images/whatsapp.png',
              width: 24.sp,
              height: 24.sp,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.green.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection({

    required String title,
    required String address,
    required String phone,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 4.h),
              Text(
                address,
                style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(Icons.phone, size: 14.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    phone,
                    style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[800]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
