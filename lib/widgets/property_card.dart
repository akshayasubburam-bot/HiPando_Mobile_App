import 'package:flutter/material.dart';

import '../models/property.dart';
import '../theme/app_theme.dart';

/// Full card used on Search and Saved screens.
class PropertyCard extends StatelessWidget {
  final Property property;
  final bool saved;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  const PropertyCard({
    super.key,
    required this.property,
    required this.saved,
    required this.onTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.card),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 11,
                  child: Image.network(
                    property.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.mapDark),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Text(property.indexLabel, style: AppText.microLabel()),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onBookmarkTap,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.white,
                      child: Icon(
                        saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: AppColors.red,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                if (property.ribbon.isNotEmpty)
                  Positioned(
                    bottom: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.pink,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(
                        property.ribbon,
                        style: AppText.sans(size: 11, weight: FontWeight.w700, color: AppColors.ink),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sector 04', style: AppText.sans(size: 11, color: AppColors.muted, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(property.community, style: AppText.serif(size: 19)),
                  const SizedBox(height: 4),
                  Text(
                    '${property.type} • ${property.bedrooms} Beds • ${property.areaSqft} sq.ft',
                    style: AppText.sans(size: 12.5, color: AppColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final tag in property.tags.take(2))
                        _Tag(tag),
                      if (property.tags.length > 2) _Tag('+${property.tags.length - 2}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(property.priceFormatted,
                                style: AppText.serif(size: 20, weight: FontWeight.w700, color: AppColors.red)),
                            Text(property.priceUsdFormatted,
                                style: AppText.sans(size: 12, color: AppColors.muted)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onTap,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.red,
                          child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgWarm,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: const Color(0xFFE7E1D4)),
      ),
      child: Text(text, style: AppText.sans(size: 11, color: AppColors.ink)),
    );
  }
}
