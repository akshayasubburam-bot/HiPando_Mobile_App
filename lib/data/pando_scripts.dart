import '../models/property.dart';

/// Screen-aware Pando dialogue (voice content spec v3). Every script is a
/// generator over live data — never a static filler line.
class PandoScripts {
  /// Landing screen welcome. Varies if the user has already browsed a
  /// community earlier in this session.
  static String landing(String? lastCommunity) {
    if (lastCommunity != null) {
      return "Welcome back. Want to pick up where you left off in $lastCommunity, or start a new search?";
    }
    return "Hi, I'm Pando. Welcome to Hi Pando. I help you find a place in Dubai that actually "
        "feels right for you — not just a list of listings. Tell me an area, your budget, and "
        "one thing that's non-negotiable, and I'll start narrowing things down for you. You can "
        "type in the box above, or just ask me directly.";
  }

  /// Explore map default state: describes everything currently visible.
  static String mapOverview(List<Property> visible, String? activeFilterLabel) {
    if (visible.isEmpty) {
      return "No properties match this view. Try a different filter or search.";
    }
    final communities = <String>[];
    for (final p in visible) {
      if (!communities.contains(p.community)) communities.add(p.community);
    }
    final named = communities.take(3).join(', ');
    if (activeFilterLabel != null) {
      return "Showing ${visible.length} $activeFilterLabel across $named. "
          "Tap any pin for details, or clear the filter to see everything.";
    }
    final saleCount = visible.where((p) => p.purpose == PropertyPurpose.buy).length;
    final rentCount = visible.where((p) => p.purpose == PropertyPurpose.rent).length;
    return "I'm showing ${visible.length} properties right now across $named. "
        "That includes $saleCount for sale and $rentCount for rent. "
        "Tap any pin to see the details, or search a specific area or project in Dubai.";
  }

  /// Explore map, pin tapped: describes that one property.
  static String mapPinTap(Property p) {
    final purpose = p.purpose == PropertyPurpose.rent ? 'for rent' : 'for sale';
    final highlight = p.highlight.isNotEmpty ? ' ${p.highlight}' : '';
    return "This is ${p.title} in ${p.community} — $purpose at ${p.priceFormatted}. "
        "It has ${p.bedrooms} bedrooms, ${p.bathrooms} bathrooms, and ${p.areaSqft} square feet.$highlight";
  }

  /// Search screen, first load: summarizes the whole recommended list.
  static String searchListOverview(List<Property> properties) {
    if (properties.isEmpty) {
      return "I don't have any recommended properties to show right now.";
    }
    final top = properties.take(3);
    final picks = top.map((p) => '${p.title} in ${p.community} at ${p.priceFormatted}').join(', ');
    return "I've put together ${properties.length} properties that match what you're looking for. "
        "Top picks: $picks. Scroll through and I'll tell you more about each one as you go.";
  }

  /// Search screen, a specific card scrolled into focus.
  static String searchCardFocus(Property p) =>
      "This ${p.community} ${p.type.toLowerCase()} scores well for ${p.standoutReason}. "
      "It's ${p.priceFormatted} for ${p.bedrooms} bedrooms and ${p.areaSqft} square feet.";

  /// Selected Property (Details) screen: full narration, since there's no
  /// separate Description/Amenities section anymore.
  static String propertyDetails(Property p) {
    final purpose = p.purpose == PropertyPurpose.rent ? 'for rent' : 'for sale';
    final amenities = p.amenities.take(3).join(', ');
    return "${p.title}, in ${p.community}. This is $purpose at ${p.priceFormatted}. "
        "It offers ${p.bedrooms} bedrooms, ${p.bathrooms} bathrooms, and ${p.areaSqft} square feet "
        "of ${p.furnishing.toLowerCase()} space. ${p.description} It also comes with $amenities.";
  }

  static const saved =
      "Everything you've bookmarked lives here. Want me to compare any two of them?";

  static const profile =
      "You can manage your preferences here — I'll tune my recommendations to match.";

  static const signIn =
      "Welcome. I'll keep your searches, saved homes, and conversations ready whenever you return.";
}
