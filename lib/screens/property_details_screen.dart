import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/pando_scripts.dart';
import '../models/property.dart';
import '../theme/app_theme.dart';
import '../widgets/pando_ask_box.dart';
import '../widgets/pando_character.dart';
import '../widgets/pando_logo.dart';
import '../widgets/pando_provider.dart';
import '../widgets/pando_sticky_note.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property property;
  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  int _imageIndex = 0;
  PandoProvider? _pando;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pando = context.read<PandoProvider>();
      pando.setCurrentProperty(widget.property);
      pando.speak(PandoScripts.propertyDetails(widget.property));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Capture the provider reference while the context is still valid, so
    // dispose() doesn't need to look up an ancestor on a deactivated widget.
    _pando = context.read<PandoProvider>();
  }

  @override
  void dispose() {
    if (_pando?.currentProperty?.id == widget.property.id) {
      _pando?.setCurrentProperty(null);
    }
    super.dispose();
  }

  void _cycleImage(int delta) {
    final p = widget.property;
    setState(() => _imageIndex = (_imageIndex + delta + p.images.length) % p.images.length);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Image.network(
              p.images[_imageIndex],
              key: ValueKey(_imageIndex),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.mapDark),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black87, Colors.transparent, Colors.transparent, Colors.black87],
                stops: [0.0, 0.28, 0.6, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const PandoLogo(textColor: Colors.white),
                      const Spacer(),
                      _PillButton(icon: Icons.arrow_back_rounded, label: 'Back', onTap: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _cycleImage(-1),
                        child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 20),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(AppRadii.pill)),
                        child: Text('${_imageIndex + 1} / ${p.images.length}', style: AppText.microLabel()),
                      ),
                      GestureDetector(
                        onTap: () => _cycleImage(1),
                        child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(p.title, style: AppText.serif(size: 24, color: Colors.white, height: 1.15)),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.red),
                    const SizedBox(width: 4),
                    Expanded(child: Text(p.locationLine, style: AppText.sans(size: 12.5, color: Colors.white70))),
                  ]),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (context.watch<PandoProvider>().noteVisible) const PandoStickyNote(maxWidth: 190),
                  const SizedBox(height: 8),
                  PandoCharacter(size: 72, onTap: () => context.read<PandoProvider>().showNote()),
                  const SizedBox(height: 8),
                  const PandoAskBox(width: 170),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('PRIVATE SALE', style: AppText.microLabel(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(p.priceFormatted, style: AppText.serif(size: 28, weight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 14),
                    _StatStrip(p: p),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connecting you with an agent…')));
                        },
                        child: Text('CONTACT AGENT', style: AppText.sans(size: 13, weight: FontWeight.w700, color: Colors.white, letterSpacing: 0.6)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatStrip extends StatelessWidget {
  final Property p;
  const _StatStrip({required this.p});

  @override
  Widget build(BuildContext context) {
    final stats = ['${p.bedrooms} BEDROOMS', '${p.areaSqft} SQ.FT.', '${p.bathrooms} BATHROOMS', p.furnishing.toUpperCase()];
    return Row(
      children: List.generate(stats.length, (i) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: i < stats.length - 1
                ? const BoxDecoration(border: Border(right: BorderSide(color: Colors.white24)))
                : null,
            child: Text(
              stats[i],
              textAlign: TextAlign.center,
              style: AppText.sans(size: 10, weight: FontWeight.w700, color: Colors.white70, letterSpacing: 0.4),
            ),
          ),
        );
      }),
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PillButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(AppRadii.pill)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: AppColors.creamText),
          const SizedBox(width: 6),
          Text(label, style: AppText.sans(size: 12.5, weight: FontWeight.w600, color: AppColors.creamText)),
        ]),
      ),
    );
  }
}
