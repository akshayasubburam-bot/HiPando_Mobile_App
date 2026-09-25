import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'sign_in_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool signedIn;
  final VoidCallback onSignOut;

  const ProfileScreen({
    super.key,
    required this.signedIn,
    required this.onSignOut,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: widget.signedIn ? _signedInBody(context) : _signedOutBody(context),
    );
  }

  Widget _signedOutBody(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You are not signed in', style: AppText.serif(size: 20)),
            const SizedBox(height: 8),
            Text(
              'Sign in from the Home screen to manage your account, saved searches, and preferences.',
              textAlign: TextAlign.center,
              style: AppText.sans(size: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignInScreen()),
              ),
              child: Text(
                'GO TO SIGN IN',
                style: AppText.sans(
                  size: 12.5,
                  weight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signedInBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        Text('Profile', style: AppText.serif(size: 26)),
        const SizedBox(height: 20),
        _SectionTile(
          icon: Icons.person_outline_rounded,
          title: 'Account details',
        ),
        _SectionTile(
          icon: Icons.bookmark_outline_rounded,
          title: 'Saved searches',
        ),
        _SectionTile(
          icon: Icons.notifications_none_rounded,
          title: 'Notification preferences',
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
            onPressed: widget.onSignOut,
            child: Text(
              'SIGN OUT',
              style: AppText.sans(
                size: 12.5,
                weight: FontWeight.w700,
                color: AppColors.red,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.ink, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppText.sans(size: 14, weight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
