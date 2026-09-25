import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class NavTab {
  final IconData icon;
  final String label;
  const NavTab(this.icon, this.label);
}

const navTabs = [
  NavTab(Icons.home_rounded, 'HOME'),
  NavTab(Icons.explore_rounded, 'EXPLORE'),
  NavTab(Icons.search_rounded, 'SEARCH'),
  NavTab(Icons.bookmark_rounded, 'SAVED'),
  NavTab(Icons.person_rounded, 'PROFILE'),
];

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(navTabs.length, (i) {
              final active = i == currentIndex;
              final color = active ? AppColors.red : AppColors.muted;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(navTabs[i].icon, color: color, size: 22),
                      const SizedBox(height: 4),
                      Text(
                        navTabs[i].label,
                        style: AppText.sans(size: 9.5, weight: FontWeight.w700, color: color, letterSpacing: 1.0),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
