import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import 'pando_provider.dart';

/// Cream sticky note anchored beside Pando. Header shows only a speaker
/// icon now — it mutes mid-speech on tap, or replays the note if idle.
class PandoStickyNote extends StatelessWidget {
  final double maxWidth;

  const PandoStickyNote({super.key, this.maxWidth = 220});

  @override
  Widget build(BuildContext context) {
    final pando = context.watch<PandoProvider>();
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'PANDO SAYS',
                style: AppText.microLabel(color: AppColors.red),
              ),
              const Spacer(),
              IconButton(
                onPressed: pando.toggleSpeaker,
                tooltip: pando.isSpeaking
                    ? 'Turn Pando voice off'
                    : 'Turn Pando voice on',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: Icon(
                  pando.isSpeaking
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  size: 18,
                  color: AppColors.creamText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            pando.noteText,
            style: AppText.sans(
              size: 13,
              color: AppColors.creamText,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
