// lib/utils/pricing_logic.dart

/// Pricing logic for delivery orders.
/// Calculates suggested price ranges based on distance and special days.
class PricingLogic {
  // Minimum price (FCFA)
  static const double _minimumPrice = 500.0;

  // Holiday/weekend surcharge multiplier (+5%)
  static const double _ferieSurcharge = 1.05;

  static const Map<String, List<double>> _tranchesPrix = {
    '0-3 km': [500, 1500],
    '3-7 km': [1200, 2500],
    '7-12 km': [2000, 3500],
    '12-20 km': [3000, 5000],
    '>20 km': [4500, 8000],
  };

  /// Calculates a suggested price interval [min, max] in FCFA
  /// based on [distanceKm] and whether it's a holiday/weekend [isFerie].
  static List<double> calculerIntervallePrix(double distanceKm, bool isFerie) {
    String tranche = '>20 km'; // default
    if (distanceKm <= 3) {
      tranche = '0-3 km';
    } else if (distanceKm <= 7) {
      tranche = '3-7 km';
    } else if (distanceKm <= 12) {
      tranche = '7-12 km';
    } else if (distanceKm <= 20) {
      tranche = '12-20 km';
    }

    var intervalle = List<double>.from(_tranchesPrix[tranche]!);
    
    if (isFerie) {
      intervalle = [
        (intervalle[0] * _ferieSurcharge).roundToDouble(),
        (intervalle[1] * _ferieSurcharge).roundToDouble()
      ];
    }

    if (intervalle[0] < _minimumPrice) {
      intervalle[0] = _minimumPrice;
    }

    return intervalle;
  }

  /// Returns true if [date] is a public holiday or weekend in Benin.
  static bool estJourFerie(DateTime date) {
    // Weekend check
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return true;
    }

    // Benin public holidays (month, day)
    const List<List<int>> joursFeries = [
      [1, 1],   // Jour de l'An
      [1, 10],  // Fête du Vodoun
      [4, 18],  // Vendredi Saint (approximate)
      [4, 21],  // Lundi de Pâques (approximate)
      [5, 1],   // Fête du Travail
      [5, 29],  // Ascension (approximate)
      [6, 9],   // Lundi de Pentecôte (approximate)
      [8, 1],   // Fête Nationale
      [8, 15],  // Assomption
      [11, 1],  // Toussaint
      [11, 30], // Fête Nationale (Bénin)
      [12, 25], // Noël
    ];

    for (final jour in joursFeries) {
      if (date.month == jour[0] && date.day == jour[1]) {
        return true;
      }
    }

    return false;
  }

  /// Formats a price value as a FCFA string.
  static String formaterPrix(double prix) {
    return '${prix.toInt()} FCFA';
  }

  /// Formats a price range as a FCFA string.
  static String formaterIntervalle(List<double> intervalle) {
    return '${intervalle[0].toInt()} - ${intervalle[1].toInt()} FCFA';
  }
}
