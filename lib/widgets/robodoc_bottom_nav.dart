import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';

enum RoboDocTab { diagnosis, history, profile }

class RoboDocBottomNav extends StatelessWidget {
  final RoboDocTab selected;
  const RoboDocBottomNav({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
        ),
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.add,
                label: 'DIAGNOSIS',
                selected: selected == RoboDocTab.diagnosis,
                onTap: () => Get.offAllNamed(AppRoutes.results),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.history_rounded,
                label: 'HISTORY',
                selected: selected == RoboDocTab.history,
                onTap: () => Get.offAllNamed(AppRoutes.history),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'PROFILE',
                selected: selected == RoboDocTab.profile,
                onTap: () => Get.offAllNamed(AppRoutes.profile),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const _primary = Color(0xFF0E204D);
  static const _secondary = Color(0xFF21CDC0);

  @override
  Widget build(BuildContext context) {
    final inactive = Colors.black.withValues(alpha: 0.35);
    final labelColor = selected ? _secondary : inactive;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 38,
              decoration: BoxDecoration(
                color: selected ? _secondary.withValues(alpha: 0.22) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: selected ? _primary : inactive,
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.9,
                  color: labelColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

