import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/pando_scripts.dart';
import '../data/properties.dart';
import '../theme/app_theme.dart';
import '../widgets/pando_character.dart';
import '../widgets/pando_provider.dart';
import '../widgets/pando_sticky_note.dart';
import '../widgets/property_card.dart';
import 'property_details_screen.dart';

class SavedScreen extends StatefulWidget {
  final Set<String> savedIds;
  final ValueChanged<String> onToggleSave;

  const SavedScreen({super.key, required this.savedIds, required this.onToggleSave});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PandoProvider>().speak(PandoScripts.saved);
    });
  }

  @override
  Widget build(BuildContext context) {
    final saved = mockProperties.where((p) => widget.savedIds.contains(p.id)).toList();
    return Stack(
      children: [
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text('Saved', style: AppText.serif(size: 26)),
              ),
              Expanded(
                child: saved.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bookmark_border_rounded, size: 44, color: AppColors.muted),
                              const SizedBox(height: 12),
                              Text('Nothing saved yet', style: AppText.serif(size: 18)),
                              const SizedBox(height: 6),
                              Text('Tap the bookmark on any property to keep it here.', textAlign: TextAlign.center, style: AppText.sans(size: 13, color: AppColors.muted)),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 120),
                        itemCount: saved.length,
                        itemBuilder: (context, i) {
                          final p = saved[i];
                          return PropertyCard(
                            property: p,
                            saved: true,
                            onBookmarkTap: () => widget.onToggleSave(p.id),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: p))),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 96,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (context.watch<PandoProvider>().noteVisible) const PandoStickyNote(),
              const SizedBox(height: 8),
              PandoCharacter(onTap: () => context.read<PandoProvider>().showNote()),
            ],
          ),
        ),
      ],
    );
  }
}
