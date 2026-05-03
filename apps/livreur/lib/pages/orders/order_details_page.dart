import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/api/v1/order_api.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

import 'package:shared_le_transporteur/core/widgets/app_image.dart';
import 'package:shared_le_transporteur/models/commande.dart';
import 'package:shared_le_transporteur/services/mock_database.dart';
import 'package:shared_le_transporteur/utils/pricing_logic.dart';
import 'package:url_launcher/url_launcher.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Commande acceptée avec succès !', style: GoogleFonts.poppins()), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e', style: GoogleFonts.poppins()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _proposerNouveauPrix(double amount) async {
    setState(() => _isLoading = true);
    try {
      final orderApi = OrderApi();
      if (widget.isAvailableMode) {
        await orderApi.claimOrder(_commande.id);
      }
      await orderApi.proposePrice(_commande.id, amount);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Proposition envoyée au client.', style: GoogleFonts.poppins()), backgroundColor: Colors.blue),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e', style: GoogleFonts.poppins()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('WhatsApp n\'est pas installé ou ce numéro n\'est pas valide sur WhatsApp.', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible de passer l\'appel', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Statut mis à jour : ${_commande.getDisplayStatus()}', style: GoogleFonts.poppins()),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
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
                color: Colors.green.withValues(alpha: 0.1),
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
              "La livraison a été marquée comme terminée avec succès.",
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


  @override
  Widget build(BuildContext context) {
    final isAchat = _commande.type == 'achat';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.text, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Détails de la commande",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _getStatusColor(_commande).withValues(alpha: 0.1),
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
              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              _commande.description,
              style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[800]),
            ),
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

            // Instructions
            if (_commande.instructions != null && _commande.instructions!.isNotEmpty) ...[
              Text(
                "Instructions spéciales",
                style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.yellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.yellow.withValues(alpha: 0.5)),
                ),
                child: Text(
                  _commande.instructions!,
                  style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[800]),
                ),
              ),
              SizedBox(height: 24.h),
            ],

            // Pricing
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_commande.negotiationStatus == 'confirmed' || 
                      _commande.status.toLowerCase() == 'processing' || 
                      _commande.status.toLowerCase() == 'en_cours' ||
                      _commande.status.toLowerCase() == 'en_livraison') ...[
                    Text(
                      "Prix final convenu",
                      style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "${(_commande.finalPrice ?? _commande.propositionLivreur ?? _commande.propositionClient ?? 0).toInt()} FCFA",
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ] else ...[
                    Text(
                      "Prix suggéré (intervalle)",
                      style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      PricingLogic.formaterIntervalle(_commande.prixSuggere),
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    if (_commande.propositionClient != null && _commande.propositionClient! > 0) ...[
                      Divider(height: 24.h),
                      Text(
                        "Proposition du client",
                        style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "${_commande.propositionClient!.toInt()} FCFA",
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                    if (_commande.propositionLivreur != null) ...[
                      Divider(height: 24.h),
                      Text(
                        "Ma proposition",
                        style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "${_commande.propositionLivreur!.toInt()} FCFA",
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Actions Section
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (widget.isAvailableMode)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Confirmer', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                            content: Text('Voulez-vous accepter cette course au prix proposé par le client (${_commande.propositionClient?.toInt() ?? 0} FCFA) ?', style: GoogleFonts.poppins()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Annuler', style: GoogleFonts.poppins(color: Colors.grey)),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _accepterCommande();
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                child: Text('Accepter', style: GoogleFonts.poppins(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(
                        "Valider le prix client",
                        style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _showProposePriceDialog,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(
                        "Proposer mon prix",
                        style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              )
            else if (_commande.negotiationStatus == 'rejected')
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            "Le client a rejeté votre proposition. En cas de conflit, contactez un administrateur.",
                            style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _contacterAdmin,
                      icon: const Icon(Icons.support_agent, color: Colors.white),
                      label: Text(
                        "Contacter un administrateur",
                        style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                  ),
                ],
              )
            else if (_isReserved) ...[
              _buildContactSection(),
              SizedBox(height: 24.h),
              _buildActionButtons(),
            ],
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final status = _commande.status.toLowerCase();
    
    // 1. Negotiation Phase
    if (_commande.negotiationStatus == 'pending_client_approval') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _accepterCommande(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                "Confirmer prix",
                style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: OutlinedButton(
              onPressed: _showProposePriceDialog,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                "Proposer prix",
                style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
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
          color: Colors.green.withValues(alpha: 0.1),
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
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
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
              backgroundColor: Colors.green.withValues(alpha: 0.1),
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
            color: color.withValues(alpha: 0.1),
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
