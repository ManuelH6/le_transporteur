// shared/test/api_models_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_le_transporteur/models/user.dart';
import 'package:shared_le_transporteur/models/commande.dart';

void main() {
  group('Model Serialization Tests', () {
    test('User.fromJson maps backend fields correctly', () {
      final json = {
        '_id': 'user-123',
        'name': 'Jane Doe',
        'email': 'jane@ex.com',
        'phoneNumber': '+22901020304',
        'role': 'livreur',
        'isEmailVerified': true,
      };

      final user = User.fromJson(json);

      expect(user.id, 'user-123');
      expect(user.name, 'Jane Doe');
      expect(user.role, 'livreur');
      expect(user.isEmailVerified, true);
    });

    test('Commande.fromJson maps backend fields and legacy fields', () {
      final json = {
        'id': 'order-789',
        'serviceType': 'courrier',
        'description': 'Colis important',
        'pickupAddress': {
          'city': 'Cotonou',
          'street': 'Rue 15'
        },
        'status': 'en_livraison',
        'estimatedPrice': 3000
      };

      final cmd = Commande.fromJson(json);

      expect(cmd.id, 'order-789');
      expect(cmd.serviceType, 'courrier');
      expect(cmd.type, 'courrier'); // legacy
      expect(cmd.status, 'en_livraison');
      expect(cmd.statut, 'en_livraison'); // legacy
      expect(cmd.pickupAddress?.city, 'Cotonou');
      expect(cmd.estimatedPrice, 3000.0);
    });
  });
}
