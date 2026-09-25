import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../data/pando_scripts.dart';
import '../data/properties.dart';
import '../models/property.dart';
import '../theme/app_theme.dart';
import '../widgets/pando_character.dart';
import '../widgets/pando_provider.dart';
import '../widgets/pando_sticky_note.dart';
import '../widgets/property_mini_card.dart';
import 'property_details_screen.dart';

// Camera default from the reference map analysis: roughly midway between
// Downtown Dubai and Business Bay, not the dataset centroid.
const _defaultCenter = LatLng(25.1400, 55.2200);

enum _MapLayer { street, satellite, terrain }

extension on _MapLayer {
  String get label {
    switch (this) {
      case _MapLayer.street:
        return 'Default';
      case _MapLayer.satellite:
        return 'Satellite';
      case _MapLayer.terrain:
        return 'Terrain';
    }
  }
}

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _category = 3;
  int _selected = 0;
  String _query = '';
  _MapLayer _layer = _MapLayer.street;
  bool _layersOpen = false;
  bool _filterOpen = false;
  PropertyCategory? _typeFilter;
  final _pageController = PageController(viewportFraction: 0.86);
  final _mapController = MapController();

  static const _categories = ['BUY', 'RENT', 'OFF-PLAN', 'EXPLORE'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _announce());
  }

  void _announce() {
    context.read<PandoProvider>().speak(PandoScripts.mapOverview(_filtered, _typeFilter?.label));
  }

  List<Property> get _filtered {
    var results = mockProperties.toList();
    switch (_category) {
      case 0:
        results = results.where((p) => p.purpose == PropertyPurpose.buy).toList();
      case 1:
        results = results.where((p) => p.purpose == PropertyPurpose.rent).toList();
      case 2:
        results = results.where((p) => p.purpose == PropertyPurpose.offPlan || p.category == PropertyCategory.offPlan).toList();
      default:
        break;
    }
    if (_typeFilter != null) {
      results = results.where((p) => p.category == _typeFilter).toList();
    }
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      results = results.where((p) =>
          p.community.toLowerCase().contains(q) ||
          p.type.toLowerCase().contains(q) ||
          p.title.toLowerCase().contains(q)).toList();
    }
    return results;
  }

  void _selectIndex(int i, {bool fromMarker = false}) {
    setState(() => _selected = i);
    final results = _filtered;
    if (i >= results.length) return;
    final p = results[i];
    _mapController.move(LatLng(p.lat, p.lng), _mapController.camera.zoom < 11 ? 12 : _mapController.camera.zoom);
    if (fromMarker) {
      _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    final pando = context.read<PandoProvider>();
    pando.rememberCommunity(p.community);
    pando.speak(PandoScripts.mapPinTap(p));
  }

  String get _tileUrl {
    switch (_layer) {
      case _MapLayer.street:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case _MapLayer.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case _MapLayer.terrain:
        return 'https://tile.opentopomap.org/{z}/{x}/{y}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;
    if (_selected >= results.length) _selected = 0;

    return Stack(
      fit: StackFit.expand,
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _defaultCenter,
            initialZoom: 11,
            minZoom: 3,
            maxZoom: 18,
            backgroundColor: AppColors.mapDark,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            TileLayer(
              urlTemplate: _tileUrl,
              userAgentPackageName: 'com.example.flutter_application',
            ),
            MarkerLayer(
              markers: List.generate(results.length, (i) {
                final p = results[i];
                final active = i == _selected;
                return Marker(
                  point: LatLng(p.lat, p.lng),
                  width: active ? 52 : 42,
                  height: active ? 60 : 48,
                  alignment: Alignment.topCenter,
                  child: AnimatedScale(
                    scale: active ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: PandoMapPin(size: active ? 44 : 36, onTap: () => _selectIndex(i, fromMarker: true)),
                  ),
                );
              }),
            ),
          ],
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.pill)),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (v) {
                            setState(() => _query = v);
                            _announce();
                          },
                          decoration: InputDecoration(
                            hintText: 'Search Marina, Downtown, Villa, Penthouse…',
                            hintStyle: AppText.sans(size: 13, color: AppColors.muted),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final active = i == _category;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _category = i;
                        _selected = 0;
                        _announce();
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: active ? AppColors.red : AppColors.cream.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Text(
                          _categories[i],
                          style: AppText.sans(size: 12, weight: FontWeight.w700, color: active ? Colors.white : AppColors.ink),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        Positioned(
          left: 16,
          top: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CircleButton(
                icon: Icons.layers_outlined,
                onTap: () => setState(() {
                  _layersOpen = !_layersOpen;
                  _filterOpen = false;
                }),
              ),
              if (_layersOpen)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _MapLayer.values.map((l) {
                      final active = l == _layer;
                      return InkWell(
                        onTap: () => setState(() {
                          _layer = l;
                          _layersOpen = false;
                        }),
                        child: Container(
                          width: 120,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              if (active) const Icon(Icons.check_rounded, size: 14, color: AppColors.red),
                              if (active) const SizedBox(width: 6),
                              Text(l.label, style: AppText.sans(size: 12.5, color: active ? AppColors.red : AppColors.ink, weight: active ? FontWeight.w700 : FontWeight.w500)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 12),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _CircleButton(
                    icon: Icons.tune_rounded,
                    onTap: () => setState(() {
                      _filterOpen = !_filterOpen;
                      _layersOpen = false;
                    }),
                  ),
                  if (_typeFilter != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: AppColors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                      ),
                    ),
                ],
              ),
              if (_filterOpen)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PROPERTY TYPE', style: AppText.microLabel(color: AppColors.muted)),
                      const SizedBox(height: 6),
                      _typeOption('All', _typeFilter == null, () => setState(() {
                            _typeFilter = null;
                            _filterOpen = false;
                            _announce();
                          })),
                      ...PropertyCategory.values.map((c) => _typeOption(
                            c.label,
                            _typeFilter == c,
                            () => setState(() {
                              _typeFilter = c;
                              _filterOpen = false;
                              _announce();
                            }),
                          )),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 168,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (context.watch<PandoProvider>().noteVisible) const PandoStickyNote(),
              const SizedBox(height: 8),
              PandoCharacter(size: 76, onTap: () => context.read<PandoProvider>().showNote()),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              height: 92,
              child: results.isEmpty
                  ? Center(
                      child: Text('No properties match this filter.', style: AppText.sans(size: 12.5, color: AppColors.muted)),
                    )
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: results.length,
                      onPageChanged: (i) => _selectIndex(i),
                      itemBuilder: (context, i) {
                        final p = results[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: PropertyMiniCard(
                            property: p,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: p))),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _typeOption(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            if (active) const Icon(Icons.check_rounded, size: 14, color: AppColors.red),
            if (active) const SizedBox(width: 6),
            Text(label.toUpperCase(), style: AppText.sans(size: 12, color: active ? AppColors.red : AppColors.ink, weight: active ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(radius: 22, backgroundColor: Colors.white, child: Icon(icon, color: AppColors.ink, size: 20)),
    );
  }
}
