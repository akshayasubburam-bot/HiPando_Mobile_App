import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'pando_character.dart';

/// Shared brand lockup (avatar + "Hi Pando" wordmark) — must render
/// identically in size and position treatment on every screen.
class PandoLogo extends StatelessWidget {
  final Color textColor;
  const PandoLogo({super.key, this.textColor = AppColors.ink});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const PandoAvatar(size: 32),
        const SizedBox(width: 8),
        Text('Hi Pando', style: AppText.serif(size: 20, color: textColor)),
      ],
    );
  }
}
