import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/pando_scripts.dart';
import '../data/properties.dart';
import '../models/property.dart';
import '../theme/app_theme.dart';
import '../widgets/pando_ask_box.dart';
import '../widgets/pando_character.dart';
import '../widgets/pando_logo.dart';
import '../widgets/pando_provider.dart';
import '../widgets/pando_sticky_note.dart';
import '../widgets/property_card.dart';
import 'property_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final Set<String> savedIds;
  final ValueChanged<String> onToggleSave;
  final VoidCallback onProfileTap;

  const SearchScreen({
    super.key,
    this.initialQuery,
    required this.savedIds,
    required this.onToggleSave,
    required this.onProfileTap,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _scrollController = ScrollController();
  int _visibleIndex = 0;
  List<Property> _results = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = widget.initialQuery?.toLowerCase().trim() ?? '';
      _results = query.isEmpty
          ? mockProperties
          : mockProperties
              .where((p) =>
                  p.community.toLowerCase().contains(query) ||
                  p.type.toLowerCase().contains(query) ||
                  p.title.toLowerCase().contains(query))
              .toList();
      context.read<PandoProvider>().speak(PandoScripts.searchListOverview(_results));
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_results.isEmpty) return;
    const cardHeight = 430.0;
    final index = (_scrollController.offset / cardHeight).round().clamp(0, _results.length - 1);
    if (index != _visibleIndex) {
      setState(() => _visibleIndex = index);
      final pando = context.read<PandoProvider>();
      pando.rememberCommunity(_results[index].community);
      pando.speak(PandoScripts.searchCardFocus(_results[index]));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.initialQuery?.toLowerCase().trim() ?? '';
    final results = query.isEmpty
        ? mockProperties
        : mockProperties
              .where(
                (p) =>
                    p.community.toLowerCase().contains(query) ||
                    p.type.toLowerCase().contains(query) ||
                    p.title.toLowerCase().contains(query),
              )
              .toList();

    return Stack(
      children: [
        Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const PandoLogo(),
                        const Spacer(),
                        InkWell(
                          onTap: widget.onProfileTap,
                          borderRadius: BorderRadius.circular(18),
                          child: const Padding(
                            padding: EdgeInsets.all(3),
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: AppColors.cream,
                              child: Icon(
                                Icons.person,
                                size: 16,
                                color: AppColors.creamText,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'DIFC DUBAI PRIME RESIDENTIAL INTELLIGENCE',
                      style: AppText.microLabel(color: AppColors.muted),
                    ),
                    const SizedBox(height: 16),
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
                          'DUBAI PRIME / AI CONCIERGE WORKSPACE',
                          style: AppText.microLabel(color: AppColors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Recommended Properties',
                      style: AppText.serif(size: 26),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Handpicked homes that match your preferences',
                      style: AppText.sans(size: 13, color: AppColors.muted),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(
                        'No matches for "$query" yet.',
                        style: AppText.sans(color: AppColors.muted),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 8, bottom: 220),
                      itemCount: results.length,
                      itemBuilder: (context, i) {
                        final p = results[i];
                        return PropertyCard(
                          property: p,
                          saved: widget.savedIds.contains(p.id),
                          onBookmarkTap: () => widget.onToggleSave(p.id),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PropertyDetailsScreen(property: p),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 96,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (context.watch<PandoProvider>().noteVisible)
                const PandoStickyNote(maxWidth: 200),
              const SizedBox(height: 8),
              PandoCharacter(
                size: 76,
                onTap: () => context.read<PandoProvider>().showNote(),
              ),
              const SizedBox(height: 8),
              const PandoAskBox(width: 190),
            ],
          ),
        ),
      ],
    );
  }
}
