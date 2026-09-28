enum PropertyPurpose { buy, rent, offPlan }

/// Mirrors the `category` taxonomy from the web map dataset
/// (Apartments / Villas / Off-Plan / Penthouses / Townhouses).
enum PropertyCategory { apartments, villas, offPlan, penthouses, townhouses }

extension PropertyCategoryLabel on PropertyCategory {
  String get label {
    switch (this) {
      case PropertyCategory.apartments:
        return 'Apartments';
      case PropertyCategory.villas:
        return 'Villas';
      case PropertyCategory.offPlan:
        return 'Off-Plan';
      case PropertyCategory.penthouses:
        return 'Penthouses';
      case PropertyCategory.townhouses:
        return 'Townhouses';
    }
  }
}

class Property {
  final String id;
  final String title;
  final String community;
  final String type;
  final PropertyPurpose purpose;
  final PropertyCategory category;
  final int price;
  final int priceUsd;
  final int bedrooms;
  final int bathrooms;
  final int areaSqft;
  final String furnishing;
  final List<String> images;
  final List<String> amenities;
  final List<String> tags;
  final String description;
  final String locationLine;
  final double lat;
  final double lng;
  final String indexLabel;
  final bool verified;
  final String ribbon;
  final String highlight;
  final String standoutReason;

  const Property({
    required this.id,
    required this.title,
    required this.community,
    required this.type,
    required this.purpose,
    required this.category,
    required this.price,
    required this.priceUsd,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqft,
    required this.furnishing,
    required this.images,
    required this.amenities,
    required this.tags,
    required this.description,
    required this.locationLine,
    required this.lat,
    required this.lng,
    this.indexLabel = '',
    this.verified = true,
    this.ribbon = '',
    this.highlight = '',
    this.standoutReason = 'value and location',
  });

  String get priceFormatted => 'AED ${_group(price)}';
  String get priceUsdFormatted => 'USD ${_group(priceUsd)}';

  static String _group(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      buf.write(s[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  // ── MongoDB API deserialization ────────────────────────────────────────────
  /// Converts a JSON map returned by the backend `/api/v1/properties` endpoint
  /// into a [Property].  All optional fields are safely defaulted so the app
  /// never crashes when a field is missing or null.
  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id:            json['id']?.toString()        ?? '',
      title:         json['title']?.toString()     ?? 'Untitled Property',
      community:     json['community']?.toString() ?? '',
      type:          json['type']?.toString()      ?? '',
      purpose:       _parsePurpose(json['purpose']?.toString()),
      category:      _parseCategory(json['category']?.toString()),
      price:         _parseInt(json['price']),
      priceUsd:      _parseInt(json['priceUsd']),
      bedrooms:      _parseInt(json['bedrooms']),
      bathrooms:     _parseInt(json['bathrooms']),
      areaSqft:      _parseInt(json['areaSqft']),
      furnishing:    json['furnishing']?.toString()    ?? 'Unfurnished',
      images:        _parseStringList(json['images']),
      amenities:     _parseStringList(json['amenities']),
      tags:          _parseStringList(json['tags']),
      description:   json['description']?.toString()   ?? '',
      locationLine:  json['locationLine']?.toString()  ?? '',
      lat:           _parseDouble(json['lat']),
      lng:           _parseDouble(json['lng']),
      indexLabel:    json['indexLabel']?.toString()    ?? '',
      verified:      json['verified'] as bool?          ?? true,
      ribbon:        json['ribbon']?.toString()         ?? '',
      highlight:     json['highlight']?.toString()      ?? '',
      standoutReason: json['standoutReason']?.toString() ?? 'value and location',
    );
  }

  // ── Private parsing helpers ───────────────────────────────────────────────

  static PropertyPurpose _parsePurpose(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'rent':
        return PropertyPurpose.rent;
      case 'off-plan':
      case 'offplan':
        return PropertyPurpose.offPlan;
      default:
        return PropertyPurpose.buy; // 'sale' or anything else → buy
    }
  }

  static PropertyCategory _parseCategory(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'villas':
        return PropertyCategory.villas;
      case 'off-plan':
      case 'offplan':
        return PropertyCategory.offPlan;
      case 'penthouses':
        return PropertyCategory.penthouses;
      case 'townhouses':
        return PropertyCategory.townhouses;
      default:
        return PropertyCategory.apartments;
    }
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static List<String> _parseStringList(dynamic v) {
    if (v == null) return [];
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }
}
