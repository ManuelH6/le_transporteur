// lib/services/address_search_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:shared_le_transporteur/models/lieu.dart';

class AddressSearchService {
  static const String _geoapifyApiKey = 'VOTRE_CLE_GEOAPIFY'; // TODO: Replace with real key

  /// Searches for addresses matching [query].
  /// 1. Hive 'lieux'
  /// 2. Nominatim
  /// 3. Geoapify
  Future<List<Lieu>> rechercherAdresse(String query) async {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();
    List<Lieu> results = [];

    // 1. Search in Hive
    try {
      final box = Hive.box('lieux');
      final allLieux = box.values.map((e) {
        if (e is Map) {
          return Lieu.fromJson(Map<String, dynamic>.from(e));
        } else if (e is String) {
          return Lieu.fromJson(jsonDecode(e));
        }
        return null;
      }).whereType<Lieu>().toList();

      results = allLieux
          .where((l) => l.adresse.toLowerCase().contains(queryLower))
          .toList();
      
      // Sort by freqUse DESC
      results.sort((a, b) => b.freqUse.compareTo(a.freqUse));
      
      if (results.length > 8) {
        results = results.sublist(0, 8);
      }
    } catch (e) {
      print('Error reading from Hive: $e');
    }

    // If we have enough results from Hive, return them
    if (results.length >= 3) {
      return results;
    }

    // 2. Nominatim
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query, Benin&format=json&limit=5');
      final response = await http.get(url, headers: {
        'User-Agent': 'LivraisonExpressBenin/1.0 (manuel@email.com)'
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        for (var item in data) {
          final lieu = Lieu(
            adresse: item['display_name'],
            lat: double.parse(item['lat']),
            lng: double.parse(item['lon']),
          );
          if (!results.any((r) => r.adresse == lieu.adresse)) {
            results.add(lieu);
          }
        }
      }
    } catch (e) {
      print('Nominatim error: $e');
    }

    if (results.length >= 3) {
      return results;
    }

    // 3. Geoapify (Fallback)
    try {
      final url = Uri.parse(
          'https://api.geoapify.com/v1/geocode/autocomplete?text=$query&apiKey=$_geoapifyApiKey&bias=countrycode:bj&limit=5');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List<dynamic>;
        for (var feature in features) {
          final props = feature['properties'];
          final lieu = Lieu(
            adresse: props['formatted'] ?? props['address_line1'] ?? 'Adresse inconnue',
            lat: props['lat']?.toDouble() ?? 0.0,
            lng: props['lon']?.toDouble() ?? 0.0,
          );
          if (!results.any((r) => r.adresse == lieu.adresse)) {
            results.add(lieu);
          }
        }
      }
    } catch (e) {
      print('Geoapify error: $e');
    }

    return results;
  }

  /// Calculates the approximate distance in km between two [Lieu] objects
  /// using the Haversine formula, or retrieves it from Hive if previously saved.
  Future<double> calculerDistance(Lieu from, Lieu to) async {
    final key = '${from.adresse}-${to.adresse}';
    final reverseKey = '${to.adresse}-${from.adresse}';

    try {
      final box = Hive.box('distances');
      if (box.containsKey(key)) {
        return box.get(key) as double;
      }
      if (box.containsKey(reverseKey)) {
        return box.get(reverseKey) as double;
      }
    } catch (e) {
      print('Error reading distance from Hive: $e');
    }

    const double earthRadiusKm = 6371.0;

    final double dLat = _toRadians(to.lat - from.lat);
    final double dLng = _toRadians(to.lng - from.lng);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(from.lat)) *
            cos(_toRadians(to.lat)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadiusKm * c;

    final finalDistance = distance < 1.0 ? 1.0 : distance;

    // Save to Hive
    try {
      final box = Hive.box('distances');
      await box.put(key, finalDistance);
    } catch (e) {
      print('Error saving distance to Hive: $e');
    }

    return finalDistance;
  }

  /// Saves a [Lieu] to the local history (Hive).
  Future<void> sauvegarderLieu(Lieu lieu) async {
    try {
      final box = Hive.box('lieux');
      
      // Check if it exists to increment freqUse
      String? existingKey;
      Lieu? existingLieu;
      
      for (var key in box.keys) {
        final val = box.get(key);
        Lieu? l;
        if (val is Map) {
          l = Lieu.fromJson(Map<String, dynamic>.from(val));
        } else if (val is String) {
          l = Lieu.fromJson(jsonDecode(val));
        }
        
        if (l != null && l.adresse == lieu.adresse) {
          existingKey = key.toString();
          existingLieu = l;
          break;
        }
      }

      if (existingKey != null && existingLieu != null) {
        final updatedLieu = existingLieu.copyWith(freqUse: existingLieu.freqUse + 1);
        await box.put(existingKey, updatedLieu.toJson());
      } else {
        final newKey = DateTime.now().millisecondsSinceEpoch.toString();
        final newLieu = lieu.copyWith(freqUse: 1);
        await box.put(newKey, newLieu.toJson());
      }
    } catch (e) {
      print('Error saving lieu to Hive: $e');
    }
  }

  double _toRadians(double degrees) => degrees * pi / 180;
}
