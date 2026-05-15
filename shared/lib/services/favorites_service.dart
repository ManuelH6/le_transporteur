import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_le_transporteur/models/lieu.dart';

class FavoritesService {
  static const String _boxName = 'favorite_locations';

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  static List<Lieu> getFavorites() {
    final box = Hive.box(_boxName);
    return box.values
        .map((e) => Lieu.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> toggleFavorite(Lieu lieu) async {
    final box = Hive.box(_boxName);
    final key = lieu.adresse.hashCode.toString();
    
    if (box.containsKey(key)) {
      await box.delete(key);
    } else {
      final favLieu = lieu.copyWith(isFavorite: true);
      await box.put(key, favLieu.toJson());
    }
  }

  static bool isFavorite(String adresse) {
    final box = Hive.box(_boxName);
    return box.containsKey(adresse.hashCode.toString());
  }
}
