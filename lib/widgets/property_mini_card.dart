import 'package:flutter/material.dart';

import '../models/property.dart';
import '../theme/app_theme.dart';

/// Compact card for the map carousel and inline chat results.
class PropertyMiniCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;

  const PropertyMiniCard({super.key, required this.property, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 14, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                property.images.first,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: AppColors.mapDark),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.community, style: AppText.serif(size: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(property.title, style: AppText.sans(size: 11, color: AppColors.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(property.priceFormatted, style: AppText.sans(size: 13, weight: FontWeight.w700, color: AppColors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
