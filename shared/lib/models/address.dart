// shared/lib/models/address.dart

class Address {
  final String? name;
  final String? phone;
  final String? country;
  final String? city;
  final String? district;
  final String? street;
  final double? latitude;
  final double? longitude;

  Address({
    this.name,
    this.phone,
    this.country,
    this.city,
    this.district,
    this.street,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'country': country,
        'city': city,
        'district': district,
        'street': street,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        name: (json['name'] ?? json['full_name'] ?? json['contact_name'])?.toString(),
        phone: (json['phone'] ?? json['phoneNumber'] ?? json['tel'])?.toString(),
        country: (json['country'] ?? json['pays'])?.toString(),
        city: (json['city'] ?? json['town'] ?? json['locality'] ?? json['ville'])?.toString(),
        district: (json['district'] ?? json['neighborhood'] ?? json['quartier'])?.toString(),
        street: (json['street'] ?? json['address'] ?? json['formatted_address'] ?? json['adresse'])?.toString(),
        latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : (json['lat'] != null ? (json['lat'] as num).toDouble() : null),
        longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : (json['lng'] != null ? (json['lng'] as num).toDouble() : null),
      );

  Address copyWith({
    String? name,
    String? phone,
    String? country,
    String? city,
    String? district,
    String? street,
  }) {
    return Address(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      city: city ?? this.city,
      district: district ?? this.district,
      street: street ?? this.street,
    );
  }

  @override
  String toString() {
    return [street, district, city, country].where((e) => e != null && e.isNotEmpty).join(', ');
  }
}
