// lib/models/commande.dart

import 'package:shared_le_transporteur/models/lieu.dart';

class Commande {
  final String id;
  final String type; // 'livraison' ou 'achat'
  final String description;
  final Lieu pickup;
  final String pickupPhone;
  final Lieu livraison;
  final String livraisonPhone;
  final String? instructions;
  final List<double> prixSuggere; // [min, max]
  final double? propositionClient;
  final double? prixFinal;
  String statut; // 'Disponible', 'En cours', 'Terminée', 'Livré'
  final DateTime dateCreation;

  Commande({
    required this.id,
    required this.type,
    required this.description,
    required this.pickup,
    required this.pickupPhone,
    required this.livraison,
    required this.livraisonPhone,
    this.instructions,
    required this.prixSuggere,
    this.propositionClient,
    this.prixFinal,
    required this.statut,
    required this.dateCreation,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'description': description,
        'pickup': pickup.toJson(),
        'pickupPhone': pickupPhone,
        'livraison': livraison.toJson(),
        'livraisonPhone': livraisonPhone,
        'instructions': instructions,
        'prixSuggere': prixSuggere,
        'propositionClient': propositionClient,
        'prixFinal': prixFinal,
        'statut': statut,
        'dateCreation': dateCreation.toIso8601String(),
      };

  factory Commande.fromJson(Map<String, dynamic> json) => Commande(
        id: json['id'] as String,
        type: json['type'] as String,
        description: json['description'] as String,
        pickup: Lieu.fromJson(json['pickup'] as Map<String, dynamic>),
        pickupPhone: json['pickupPhone'] as String,
        livraison: Lieu.fromJson(json['livraison'] as Map<String, dynamic>),
        livraisonPhone: json['livraisonPhone'] as String,
        instructions: json['instructions'] as String?,
        prixSuggere: (json['prixSuggere'] as List<dynamic>)
            .map((e) => (e as num).toDouble())
            .toList(),
        propositionClient: json['propositionClient'] != null
            ? (json['propositionClient'] as num).toDouble()
            : null,
        prixFinal: json['prixFinal'] != null
            ? (json['prixFinal'] as num).toDouble()
            : null,
        statut: json['statut'] as String,
        dateCreation: DateTime.parse(json['dateCreation'] as String),
      );
}
