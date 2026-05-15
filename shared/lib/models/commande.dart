// shared/lib/models/commande.dart

import 'package:shared_le_transporteur/models/lieu.dart';
import 'package:shared_le_transporteur/models/address.dart';


class Commande {
  final String id;
  final String? orderNumber;
  final int? orderSeq;
  final String serviceType; // backend name
  final String? deliveryType;
  final String? transportMode;
  final String? articleType;
  final String description;
  final double? weight;
  final Address? pickupAddress; // backend name
  final Address? deliveryAddress; // backend name
  final double? estimatedPrice;
  final double? finalPrice;
  String status; // backend name
  final String? assignedTo;
  final DateTime? scheduledAt;
  final bool isScheduled;
  final String? promoCodeId;
  final double? discountAmount;
  final DateTime dateCreation;

  // Legacy fields (kept for UI compatibility)
  final String type; // maps to serviceType
  final Lieu pickup; 
  final String pickupPhone;
  final Lieu livraison;
  final String livraisonPhone;
  final String? instructions;
  final List<double> prixSuggere; // [min, max]
  final double? propositionClient;
  double? propositionLivreur;
  String? negotiationStatus;

  final double? prixFinal; // duplicate of finalPrice but kept for now

  String statut; // maps to status

  void updateFromNegotiation(Map<String, dynamic> negJson) {
    propositionLivreur = (negJson['proposedByCourier'] ?? negJson['amount'] as num?)?.toDouble();
    String? status = negJson['status']?.toString().toLowerCase();
    if (status == 'pending' || status == 'en_attente') {
      negotiationStatus = 'pending_client_approval';

    } else if (status == 'rejected') {
      negotiationStatus = 'rejected';
    } else if (status == 'accepted') {
      negotiationStatus = 'confirmed';
    } else {
      negotiationStatus = status;
    }
  }

  Commande({

    required this.id,
    this.orderNumber,
    this.orderSeq,
    required this.serviceType,
    this.deliveryType,
    this.transportMode,
    this.articleType,
    required this.description,
    this.weight,
    this.pickupAddress,
    this.deliveryAddress,
    this.estimatedPrice,
    this.finalPrice,
    required this.status,
    this.assignedTo,
    this.scheduledAt,
    this.isScheduled = false,
    this.promoCodeId,
    this.discountAmount,
    required this.dateCreation,
    // Required for legacy
    required this.type,
    required this.pickup,
    required this.pickupPhone,
    required this.livraison,
    required this.livraisonPhone,
    this.instructions,
    required this.prixSuggere,
    this.propositionClient,
    this.propositionLivreur,
    this.negotiationStatus,
    this.prixFinal,

    required this.statut,
  });

  String getDisplayStatus() {
    // Custom logic for negotiation status overrides
    if (negotiationStatus == 'pending_client_approval') {
      return 'En négociation';
    }
    if (negotiationStatus == 'rejected') {
      return 'Négociation rejetée';
    }
    if (negotiationStatus == 'confirmed') {
      return 'Prix confirmé';
    }

    switch (status.toLowerCase()) {
      case 'en_attente':
      case 'pending':
      case 'available':
      case 'disponible':
        return 'Disponible';
      case 'assignee':
      case 'assigned':
      case 'accepted':
      case 'accepté':
        return 'Commande acceptée';
      case 'en_discussion_tarifaire':
        return 'En négociation';
      case 'prix_valide':
        return 'Prix confirmé';
      case 'en_livraison':
      case 'en_cours':
      case 'processing':
      case 'ongoing':
      case 'started':
        return 'Livraison en cours';
      case 'livree':
      case 'livré':
      case 'delivered':
      case 'completed':
      case 'terminee':
      case 'terminée':
        return 'Livré';
      case 'echec':
        return 'Échec';
      case 'conflit':
        return 'Conflit';
      case 'annulee_par_livreur':
      case 'annulee_par_client':
      case 'annulé':
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  String get humanizedSummary {
    if (serviceType.toLowerCase() == 'achat') {
      return "Achat : $description";
    } else {
      final dest = deliveryAddress?.street ?? livraison.adresse;
      final destShort = dest.split(',').first.trim();
      return "De : Moi ➔ À : $destShort";
    }
  }

  String getDisplayLocation(bool isPickup) {
    final addr = isPickup ? pickupAddress : deliveryAddress;
    final fallback = isPickup ? (pickup?.adresse ?? "") : (livraison?.adresse ?? "");
    
    String? result;

    // 1. Try to build from Address object with multiple field checks
    if (addr != null) {
      final city = addr.city?.trim() ?? "";
      final district = addr.district?.trim() ?? "";
      final street = addr.street?.trim() ?? "";
      final name = addr.name?.trim() ?? "";
      
      // Prioritize City + District/Street for a concise but precise location
      if (city.isNotEmpty) {
        if (district.isNotEmpty && !district.toLowerCase().contains(city.toLowerCase())) {
          result = "$city, $district";
        } else if (street.isNotEmpty && !street.toLowerCase().contains(city.toLowerCase())) {
          result = "$city, $street";
        } else {
          result = city;
        }
      } else if (district.isNotEmpty) {
        result = street.isNotEmpty && !street.toLowerCase().contains(district.toLowerCase()) 
            ? "$district, $street" 
            : district;
      } else if (street.isNotEmpty) {
        result = street;
      } else if (name.isNotEmpty) {
        result = name;
      }
    }

    // 2. Fallback to the main address string or Lieu address if Address object was insufficient
    if (result == null || result.trim().isEmpty) {
      result = fallback;
    }

    // 3. Cleaning phase
    if (result.isNotEmpty) {
      // Remove country names and redundant segments
      result = result.replaceAll(RegExp(r',?\s*Bénin', caseSensitive: false), "");
      result = result.replaceAll(RegExp(r',?\s*Benin', caseSensitive: false), "");
      result = result.replaceAll(RegExp(r',?\s*Togo', caseSensitive: false), "");
      
      final segments = result.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      if (result.length > 45 && segments.length > 2) {
        result = "${segments[0]}, ${segments[1]}";
      }
    }
    
    result = result.trim();
    
    // 4. Final safety defaults
    if (result.isEmpty) {
      return isPickup ? "Lieu de retrait" : "Destination";
    }
    
    return result;
  }

  String getDisplayTime() {
    if (isScheduled && scheduledAt != null) {
      final hour = scheduledAt!.hour.toString().padLeft(2, '0');
      final min = scheduledAt!.minute.toString().padLeft(2, '0');
      return "Prévu à $hour:$min";
    }
    
    final now = DateTime.now();
    final diff = now.difference(dateCreation);
    
    if (diff.inMinutes < 60) {
      return "Il y a ${diff.inMinutes} min";
    } else if (diff.inHours < 24 && now.day == dateCreation.day) {
      final hour = dateCreation.hour.toString().padLeft(2, '0');
      final min = dateCreation.minute.toString().padLeft(2, '0');
      return "Aujourd'hui à $hour:$min";
    } else {
      final day = dateCreation.day.toString().padLeft(2, '0');
      final month = dateCreation.month.toString().padLeft(2, '0');
      final hour = dateCreation.hour.toString().padLeft(2, '0');
      final min = dateCreation.minute.toString().padLeft(2, '0');
      return "$day/$month à $hour:$min";
    }
  }

  // Returns a hex color string or a name that the UI can map
  String getStatusColorName() {
    final s = status.toLowerCase();
    if (negotiationStatus == 'pending_client_approval') return 'orange';
    
    switch (s) {
      case 'en_attente':
      case 'available':
      case 'disponible':
      case 'pending':
        return 'blue';
      case 'assignee':
      case 'assigned':
      case 'accepted':
      case 'accepté':
      case 'prix_valide':
        return 'orange';
      case 'en_livraison':
      case 'en_cours':
      case 'processing':
      case 'ongoing':
      case 'started':
        return 'purple';
      case 'livree':
      case 'livré':
      case 'delivered':
      case 'completed':
      case 'terminee':
      case 'terminée':
        return 'green';
      case 'echec':
      case 'conflit':
      case 'annulee_par_livreur':
      case 'annulee_par_client':
      case 'annulé':
      case 'cancelled':
        return 'red';
      default:
        return 'grey';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'orderSeq': orderSeq,
        'serviceType': serviceType,
        'deliveryType': deliveryType,
        'transportMode': transportMode,
        'articleType': articleType,
        'description': description,
        'weight': weight,
        'pickupAddress': pickupAddress?.toJson(),
        'deliveryAddress': deliveryAddress?.toJson(),
        'estimatedPrice': estimatedPrice,
        'finalPrice': finalPrice,
        'status': status,
        'assignedTo': assignedTo,
        'scheduledAt': scheduledAt?.toIso8601String(),
        'isScheduled': isScheduled,
        'promoCodeId': promoCodeId,
        'discountAmount': discountAmount,
        'dateCreation': dateCreation.toIso8601String(),
        // Legacy
        'type': type,
        'pickup': pickup.toJson(),
        'pickupPhone': pickupPhone,
        'livraison': livraison.toJson(),
        'livraisonPhone': livraisonPhone,
        'instructions': instructions,
        'prixSuggere': prixSuggere,
        'propositionClient': propositionClient,
        'propositionLivreur': propositionLivreur,
        'negotiationStatus': negotiationStatus,
        'statut': statut,

      };

  factory Commande.fromJson(Map<String, dynamic> json) {
    // Map backend fields to legacy fields if missing





    final id = (json['id'] ?? json['_id'] ?? '').toString();
    final serviceType = (json['serviceType'] ?? json['type'] ?? 'courrier').toString();
    final statusValue = (json['status'] ?? json['statut'] ?? 'disponible').toString();
    
    String? negStatus = (json['negotiationStatus'] ?? json['negotiation']?['status'])?.toString();
    if (negStatus?.toLowerCase() == 'pending') {
      negStatus = 'pending_client_approval';
    } else if (negStatus?.toLowerCase() == 'rejected') {
      negStatus = 'rejected';
    } else if (negStatus?.toLowerCase() == 'accepted') {
      negStatus = 'confirmed';
    }

    
    // Address to Lieu mapping
    Address? pAddr;
    if (json['pickupAddress'] != null) {
      pAddr = Address.fromJson(json['pickupAddress'] as Map<String, dynamic>);
    }
    
    Address? dAddr;
    if (json['deliveryAddress'] != null) {
      dAddr = Address.fromJson(json['deliveryAddress'] as Map<String, dynamic>);
    }

    DateTime? date;
    try {
      final dateStr = json['dateCreation'] ?? json['createdAt'] ?? json['date'];
      if (dateStr != null) {
        date = DateTime.parse(dateStr.toString());
      }
    } catch (_) {}
    date ??= DateTime.now();

    final commande = Commande(
      id: id,
      orderNumber: json['orderNumber'] as String?,
      orderSeq: json['orderSeq'] as int?,
      serviceType: serviceType,
      deliveryType: json['deliveryType'] as String?,
      transportMode: json['transportMode'] as String?,
      articleType: json['articleType'] as String?,
      description: (json['description'] ?? '').toString(),
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : 1.0,
      pickupAddress: pAddr,
      deliveryAddress: dAddr,
      estimatedPrice: json['estimatedPrice'] != null ? (json['estimatedPrice'] as num).toDouble() : null,
      finalPrice: json['finalPrice'] != null ? (json['finalPrice'] as num).toDouble() : null,
      status: statusValue,
      assignedTo: json['assignedTo'] as String?,
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt'].toString()) : null,
      isScheduled: json['isScheduled'] as bool? ?? false,
      promoCodeId: json['promoCodeId'] as String?,
      discountAmount: json['discountAmount'] != null ? (json['discountAmount'] as num).toDouble() : null,
      dateCreation: date,
      // Legacy mapping
      type: serviceType,
      pickup: json['pickup'] != null 
          ? Lieu.fromJson(json['pickup'] as Map<String, dynamic>) 
          : (pAddr != null ? Lieu(adresse: pAddr.street ?? '', lat: pAddr.latitude ?? 0, lng: pAddr.longitude ?? 0) : const Lieu(adresse: '', lat: 0, lng: 0)),
      pickupPhone: (json['pickupPhone'] ?? pAddr?.phone ?? '').toString(),
      livraison: json['livraison'] != null 
          ? Lieu.fromJson(json['livraison'] as Map<String, dynamic>) 
          : (dAddr != null ? Lieu(adresse: dAddr.street ?? '', lat: dAddr.latitude ?? 0, lng: dAddr.longitude ?? 0) : const Lieu(adresse: '', lat: 0, lng: 0)),
      livraisonPhone: (json['livraisonPhone'] ?? dAddr?.phone ?? '').toString(),
      instructions: json['instructions'] as String?,
      prixSuggere: json['prixSuggere'] != null 
          ? (json['prixSuggere'] as List<dynamic>).map((e) => (e as num).toDouble()).toList()
          : [json['estimatedPrice']?.toDouble() ?? 0.0, json['estimatedPrice']?.toDouble() ?? 0.0],
      propositionClient: json['propositionClient'] != null ? (json['propositionClient'] as num).toDouble() : null,
      propositionLivreur: (json['propositionLivreur'] ?? json['proposedByCourier'] ?? json['negotiation']?['proposedByCourier']) != null 
          ? (json['propositionLivreur'] ?? json['proposedByCourier'] ?? json['negotiation']?['proposedByCourier'] as num).toDouble() : null,
      negotiationStatus: negStatus,
      statut: statusValue,
    );

    return commande;
  }
}
