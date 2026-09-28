import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/pando_scripts.dart';
import '../models/property.dart';
import '../providers/property_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PropertyProvider>();
      if (provider.status == FetchStatus.idle) {
        provider.fetchProperties();
      }
      _announceCurrentResults(provider.properties);
    });
  }

  void _announceCurrentResults(List<Property> results) {
    final filtered = _applyQuery(results);
    context.read<PandoProvider>().speak(PandoScripts.searchListOverview(filtered));
  }

  void _onScroll() {
    final provider = context.read<PropertyProvider>();
    final results = _applyQuery(provider.properties);
    if (results.isEmpty) return;

    const cardHeight = 430.0;
    final index = (_scrollController.offset / cardHeight)
        .round()
        .clamp(0, results.length - 1);
    if (index != _visibleIndex) {
      setState(() => _visibleIndex = index);
      final pando = context.read<PandoProvider>();
      pando.rememberCommunity(results[index].community);
      pando.speak(PandoScripts.searchCardFocus(results[index]));
    }

    // Infinite scroll — load next page when near the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      context.read<PropertyProvider>().fetchNextPage();
    }
  }

  List<Property> _applyQuery(List<Property> all) {
    final query = widget.initialQuery?.toLowerCase().trim() ?? '';
    if (query.isEmpty) return all;
    return all
        .where((p) =>
            p.community.toLowerCase().contains(query) ||
            p.type.toLowerCase().contains(query) ||
            p.title.toLowerCase().contains(query))
        .toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PropertyProvider>();
    final results  = _applyQuery(provider.properties);
    final query    = widget.initialQuery?.toLowerCase().trim() ?? '';

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
              child: _buildBody(provider, results, query),
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

  Widget _buildBody(
      PropertyProvider provider, List<Property> results, String query) {
    // First load — no data yet
    if (provider.isLoading && provider.properties.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.red));
    }

    // Error with no data to fall back on
    if (provider.hasError && provider.properties.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 48, color: AppColors.muted),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage,
                textAlign: TextAlign.center,
                style: AppText.sans(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill)),
                ),
                onPressed: () => provider.fetchProperties(refresh: true),
                child: Text('Retry',
                    style: AppText.sans(
                        color: Colors.white, weight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Text(
          query.isEmpty
              ? 'No properties available yet.'
              : 'No matches for "$query" yet.',
          style: AppText.sans(color: AppColors.muted),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 220),
      itemCount: results.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == results.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child:
                Center(child: CircularProgressIndicator(color: AppColors.red)),
          );
        }
        final p = results[i];
        return PropertyCard(
          property: p,
          saved: widget.savedIds.contains(p.id),
          onBookmarkTap: () => widget.onToggleSave(p.id),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PropertyDetailsScreen(property: p),
            ),
          ),
        );
      },
    );
  }
}
