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
}
