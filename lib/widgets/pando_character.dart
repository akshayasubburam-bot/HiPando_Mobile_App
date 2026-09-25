import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pando_provider.dart';

const _pandoAsset = 'assets/pando/pando.png';

/// Base size for the big floating mascot — increased across every screen
/// per the revision spec so it reads as a prominent presence.
const kPandoFloatingSize = 96.0;

/// The glossy 3D red map-pin mascot. Drifts gently while Pando is speaking
/// and returns to a calm resting pose once finished.
class PandoCharacter extends StatefulWidget {
  final double size;
  final VoidCallback? onTap;

  const PandoCharacter({super.key, this.size = kPandoFloatingSize, this.onTap});

  @override
  State<PandoCharacter> createState() => _PandoCharacterState();
}

class _PandoCharacterState extends State<PandoCharacter> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSpeaking = context.watch<PandoProvider>().isSpeaking;
    final image = Image.asset(
      _pandoAsset,
      width: widget.size,
      height: widget.size * 1.15,
      fit: BoxFit.contain,
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: isSpeaking
          ? AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = _controller.value * 2 * math.pi;
                return Transform.translate(
                  // Loose, organic drift (mismatched sine frequencies so it
                  // never repeats a fixed bounce loop) plus a slight wobble.
                  offset: Offset(math.sin(t) * 3.5, math.sin(t * 1.3) * 4.5),
                  child: Transform.rotate(angle: math.sin(t * 0.8) * 0.02, child: child),
                );
              },
              child: image,
            )
          : image,
    );
  }
}

/// Static Pando-face map marker. Unlike [PandoCharacter] (the one speaking
/// assistant), map pins never move — they're location markers, not Pando.
class PandoMapPin extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;

  const PandoMapPin({super.key, this.size = 36, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        _pandoAsset,
        width: size,
        height: size * 1.15,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Small circular avatar variant used in the shared brand logo.
class PandoAvatar extends StatelessWidget {
  final double size;
  const PandoAvatar({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: const Color(0xFFE0322B),
        padding: EdgeInsets.all(size * 0.06),
        child: Image.asset(_pandoAsset, fit: BoxFit.contain),
      ),
    );
  }
}
