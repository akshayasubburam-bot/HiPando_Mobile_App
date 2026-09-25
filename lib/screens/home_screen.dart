import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/pando_scripts.dart';
import '../theme/app_theme.dart';
import '../widgets/pando_ask_box.dart';
import '../widgets/pando_character.dart';
import '../widgets/pando_logo.dart';
import '../widgets/pando_provider.dart';
import '../widgets/pando_sticky_note.dart';
import 'sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<String> onSearch;
  const HomeScreen({super.key, required this.onSearch});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pando = context.read<PandoProvider>();
      pando.speak(PandoScripts.landing(pando.lastCommunity));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/landing.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: AppColors.mapDark),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black54, Colors.transparent, Colors.black87],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const PandoLogo(textColor: Colors.white),
                    const Spacer(),
                    const _PressableSignInButton(),
                  ],
                ),
                const SizedBox(height: 26),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: 'Find your\n', style: AppText.serif(size: 44, weight: FontWeight.w800, color: Colors.white, height: 1.1)),
                      TextSpan(
                        text: 'next place.',
                        style: AppText.serif(size: 44, weight: FontWeight.w800, color: AppColors.red, style: FontStyle.italic, height: 1.1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text('WHAT ARE YOU LOOKING FOR?', style: AppText.microLabel()),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.pill)),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onSubmitted: widget.onSearch,
                          decoration: InputDecoration(
                            hintText: 'A home, a neighborhood, a plan…',
                            hintStyle: AppText.sans(size: 13, color: AppColors.muted),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const Icon(Icons.mic_none_rounded, color: AppColors.muted),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => widget.onSearch(_controller.text),
                        child: const CircleAvatar(radius: 19, backgroundColor: AppColors.red, child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (context.watch<PandoProvider>().noteVisible) const PandoStickyNote(),
                      const SizedBox(height: 10),
                      PandoCharacter(
                        onTap: () => context.read<PandoProvider>().showNote(),
                      ),
                      const SizedBox(height: 10),
                      const PandoAskBox(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PressableSignInButton extends StatefulWidget {
  const _PressableSignInButton();

  @override
  State<_PressableSignInButton> createState() => _PressableSignInButtonState();
}

class _PressableSignInButtonState extends State<_PressableSignInButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen())),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.red,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: _pressed
                ? [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 6, offset: const Offset(0, 1))]
                : [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 5))],
          ),
          child: Text('SIGN IN', style: AppText.microLabel()),
        ),
      ),
    );
  }
}
