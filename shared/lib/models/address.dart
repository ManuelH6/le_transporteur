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
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        country: json['country'] as String?,
        city: json['city'] as String?,
        district: json['district'] as String?,
        street: json['street'] as String?,
        latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
        longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
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
