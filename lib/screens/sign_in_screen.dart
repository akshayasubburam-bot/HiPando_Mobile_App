import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/pando_scripts.dart';
import '../theme/app_theme.dart';
import '../widgets/pando_ask_box.dart';
import '../widgets/pando_character.dart';
import '../widgets/pando_logo.dart';
import '../widgets/pando_provider.dart';
import '../widgets/pando_sticky_note.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback? onVerified;

  const SignInScreen({super.key, this.onVerified});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _otpStep = false;
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PandoProvider>().speak(PandoScripts.signIn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=1400',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: AppColors.mapDark),
          ),
          BackdropFilterBlur(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.ink,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const PandoLogo(textColor: Colors.white),
                        const SizedBox(height: 22),
                        Text(
                          'PRIVATE ACCESS',
                          style: AppText.microLabel(color: AppColors.red),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome back',
                          style: AppText.serif(size: 32, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Continue with your UAE mobile number.',
                          style: AppText.sans(size: 13, color: Colors.white70),
                        ),
                        const SizedBox(height: 26),
                        if (!_otpStep)
                          ..._buildPhoneStep()
                        else
                          ..._buildOtpStep(),
                        const SizedBox(height: 18),
                        if (!_otpStep)
                          RichText(
                            text: TextSpan(
                              style: AppText.sans(
                                size: 12.5,
                                color: Colors.white70,
                              ),
                              children: [
                                const TextSpan(text: "New to Hi Pando? "),
                                TextSpan(
                                  text: 'Create an account',
                                  style:
                                      AppText.sans(
                                        size: 12.5,
                                        color: Colors.white,
                                        weight: FontWeight.w700,
                                      ).copyWith(
                                        decoration: TextDecoration.underline,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (context.watch<PandoProvider>().noteVisible)
                  const PandoStickyNote(),
                const SizedBox(height: 8),
                PandoCharacter(
                  onTap: () => context.read<PandoProvider>().showNote(),
                ),
                const SizedBox(height: 8),
                const PandoAskBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPhoneStep() {
    return [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bgWarm,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                'AE +971',
                style: AppText.sans(size: 13, weight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '50 123 4567',
                  hintStyle: AppText.sans(size: 13, color: AppColors.muted),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.red,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
          onPressed: () => setState(() => _otpStep = true),
          child: Text(
            'CONTINUE',
            style: AppText.sans(
              size: 13,
              weight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildOtpStep() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (i) {
          return Container(
            width: 40,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              textAlign: TextAlign.center,
              maxLength: 1,
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
              ),
              style: AppText.sans(size: 18, weight: FontWeight.w700),
            ),
          );
        }),
      ),
      const SizedBox(height: 16),
      Text(
        "Didn't get a code? Resend in 00:30",
        style: AppText.sans(size: 12, color: Colors.white70),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.red,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
          onPressed: () {
            widget.onVerified?.call();
            Navigator.pop(context);
          },
          child: Text(
            'VERIFY',
            style: AppText.sans(
              size: 13,
              weight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    ];
  }
}

class BackdropFilterBlur extends StatelessWidget {
  const BackdropFilterBlur({super.key});
  @override
  Widget build(BuildContext context) =>
      Container(color: Colors.black.withOpacity(0.45));
}
