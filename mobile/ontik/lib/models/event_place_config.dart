class EventPlaceConfig {
  final String numeroPlace;
  final String? range;
  final String? typePlace;
  final double? prix;
  final String? statut;
  final String? numeroSalle;
  final String? nomSalle;
  final String? typePlaceOverride;
  final double? prixOverride;
  final String? statutPlace;

  EventPlaceConfig({
    required this.numeroPlace,
    this.range,
    this.typePlace,
    this.prix,
    this.statut,
    this.numeroSalle,
    this.nomSalle,
    this.typePlaceOverride,
    this.prixOverride,
    this.statutPlace,
  });

  factory EventPlaceConfig.fromJson(Map<String, dynamic> json) {
    return EventPlaceConfig(
      numeroPlace: json['numeroPlace'] ?? '',
      range: json['range'],
      typePlace: json['typePlace'],
      prix: json['prix'] != null ? double.tryParse(json['prix'].toString()) : null,
      statut: json['statut'],
      numeroSalle: json['numeroSalle'],
      nomSalle: json['nomSalle'],
      typePlaceOverride: json['typePlaceOverride'],
      prixOverride: json['prixOverride'] != null ? double.tryParse(json['prixOverride'].toString()) : null,
      statutPlace: json['statutPlace'],
    );
  }

  String get effectiveType => typePlaceOverride ?? typePlace ?? 'Standard';
  double get effectivePrice => prixOverride ?? prix ?? 0;
}
