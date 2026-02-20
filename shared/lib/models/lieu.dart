// lib/models/lieu.dart

class Lieu {
  final String adresse;
  final double lat;
  final double lng;
  final int freqUse;

  const Lieu({
    required this.adresse,
    required this.lat,
    required this.lng,
    this.freqUse = 0,
  });

  Map<String, dynamic> toJson() => {
        'adresse': adresse,
        'lat': lat,
        'lng': lng,
        'freqUse': freqUse,
      };

  factory Lieu.fromJson(Map<String, dynamic> json) => Lieu(
        adresse: json['adresse'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        freqUse: (json['freqUse'] as num?)?.toInt() ?? 0,
      );

  Lieu copyWith({
    String? adresse,
    double? lat,
    double? lng,
    int? freqUse,
  }) {
    return Lieu(
      adresse: adresse ?? this.adresse,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      freqUse: freqUse ?? this.freqUse,
    );
  }

  @override
  String toString() => adresse;
}
