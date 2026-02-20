// lib/services/mock_database.dart

import 'package:shared_le_transporteur/models/commande.dart';
import 'package:shared_le_transporteur/models/lieu.dart';

/// Singleton in-memory mock database for development/demo purposes.
class MockDatabase {
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;
  MockDatabase._internal();

  final List<Commande> _commandes = [];
  bool _initialized = false;

  /// Generates initial seed data (idempotent).
  void genererDonneesInitiales() {
    if (_initialized) return;
    _initialized = true;

    final now = DateTime.now();

    _commandes.addAll([
      Commande(
        id: 'CMD-001',
        type: 'livraison',
        description: 'Sac de riz 25 kg',
        pickup: const Lieu(adresse: 'Marché Dantokpa, Cotonou', lat: 6.3654, lng: 2.4183),
        pickupPhone: '+2290161000001',
        livraison: const Lieu(adresse: 'Quartier Akpakpa, Cotonou', lat: 6.3700, lng: 2.4300),
        livraisonPhone: '+2290161000002',
        prixSuggere: [1500.0, 2500.0],
        statut: 'En cours',
        dateCreation: now.subtract(const Duration(hours: 2)),
      ),
      Commande(
        id: 'CMD-002',
        type: 'achat',
        description: 'Téléphone Samsung Galaxy A15',
        pickup: const Lieu(adresse: 'Jonquet, Cotonou', lat: 6.3600, lng: 2.4200),
        pickupPhone: '+2290161000003',
        livraison: const Lieu(adresse: 'Fidjrossè, Cotonou', lat: 6.3500, lng: 2.3900),
        livraisonPhone: '+2290161000004',
        prixSuggere: [2000.0, 3500.0],
        statut: 'Disponible',
        dateCreation: now.subtract(const Duration(minutes: 30)),
      ),
    ]);
  }

  /// Returns all commandes (for livreur view).
  List<Commande> getCommandes() => List.unmodifiable(_commandes);

  /// Returns commandes visible to a client (all for mock).
  List<Commande> getCommandesClient() => List.unmodifiable(_commandes);

  /// Returns commandes available for a livreur to pick up.
  List<Commande> getCommandesDisponibles() =>
      _commandes.where((c) => c.statut == 'Disponible').toList();

  /// Adds a new commande.
  void ajouterCommande(Commande commande) {
    _commandes.add(commande);
  }

  /// Updates an existing commande.
  void mettreAJourCommande(Commande commande) {
    final index = _commandes.indexWhere((c) => c.id == commande.id);
    if (index != -1) {
      _commandes[index] = commande;
    }
  }

  /// Updates the status of a commande by id.
  void mettreAJourStatut(String id, String nouveauStatut) {
    final index = _commandes.indexWhere((c) => c.id == id);
    if (index != -1) {
      _commandes[index].statut = nouveauStatut;
    }
  }

  /// Removes a commande by id.
  void supprimerCommande(String id) {
    _commandes.removeWhere((c) => c.id == id);
  }

  /// Clears all data (useful for tests).
  void reset() {
    _commandes.clear();
    _initialized = false;
  }
}
