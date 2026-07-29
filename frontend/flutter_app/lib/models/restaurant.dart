class Restaurant {
  final int id;
  final String name;
  final double? lat;
  final double? lon;
  final String? mapLink;
  final String? openingHr;
  final String? closingHr;
  final String? openingDays;

  const Restaurant({
    required this.id,
    required this.name,
    this.lat,
    this.lon,
    this.mapLink,
    this.openingHr,
    this.closingHr,
    this.openingDays,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      mapLink: json['map_link'],
      openingHr: json['opening_hr'],
      closingHr: json['closing_hr'],
      openingDays: json['opening_days'],
    );
  }
}