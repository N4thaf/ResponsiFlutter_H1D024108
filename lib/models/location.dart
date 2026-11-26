class Location {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? countryCode;
  final String? admin1;
  final String? admin2;

  const Location({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.countryCode,
    this.admin1,
    this.admin2,
  });

  static const defaultCity = Location(
    id: 1630328,
    name: 'Purwokerto',
    latitude: -7.42139,
    longitude: 109.23444,
    country: 'Indonesia',
    countryCode: 'ID',
    admin1: 'Jawa Tengah',
    admin2: 'Kabupaten Banyumas',
  );

  String get displayName {
    final a2 = admin2?.trim() ?? '';
    final cleanName = name.toLowerCase().replaceFirst('kota ', '').trim();
    if (a2.isNotEmpty && !a2.toLowerCase().contains(cleanName)) {
      return '$name, $a2';
    }
    return name;
  }

  String get subtitle => [admin1, country]
      .where((e) => e != null && e.isNotEmpty)
      .join(', ');

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String?,
      countryCode: json['country_code'] as String?,
      admin1: json['admin1'] as String?,
      admin2: json['admin2'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'country': country,
        'country_code': countryCode,
        'admin1': admin1,
        'admin2': admin2,
      };

  @override
  bool operator ==(Object other) => other is Location && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
