import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static const _primary = Color(0xFF0E204D);
  static const _secondary = Color(0xFF21CDC0);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final items = <_HistoryItem>[
      const _HistoryItem(
        title: 'Possible Viral Fever',
        date: 'Oct 24, 2023',
        confidence: 0.94,
        tag: 'HIGH CONFIDENCE',
        outcome: 'Resolved with Hydration',
      ),
      const _HistoryItem(
        title: 'Allergic Rhinitis',
        date: 'Sep  2, 2023',
        confidence: 0.78,
        tag: 'MODERATE',
        outcome: 'Antihistamine Regimen',
      ),
      const _HistoryItem(
        title: 'Acute Lumbar Strain',
        date: 'Aug  6, 2023',
        confidence: 0.91,
        tag: 'HIGH CONFIDENCE',
        outcome: 'Physical Therapy',
      ),
      const _HistoryItem(
        title: 'Tension Headache',
        date: 'Jul 19, 2023',
        confidence: 0.83,
        tag: 'MODERATE',
        outcome: 'Stress Management',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Robo Doc AI',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 34,
                height: 34,
                color: Colors.white.withValues(alpha: 0.12),
                child: const Icon(Icons.person_rounded, size: 20),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomBar(selected: _NavTab.history),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A6B4E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'SYSTEM STATUS: OPTIMAL',
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.black.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'History',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.2,
                  color: Colors.black.withValues(alpha: 0.92),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Review your past clinical evaluations and diagnostic insights processed by the RoboDoc autonomous engine.',
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.black.withValues(alpha: 0.55),
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        color: Colors.black.withValues(alpha: 0.35)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search records, symptoms or diagnoses',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.black.withValues(alpha: 0.35),
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.03),
                          foregroundColor: Colors.black.withValues(alpha: 0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        child: const Text(
                          'Filter',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        child: const Text(
                          'Export PDF',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...items.expand((i) sync* {
                yield _HistoryCard(item: i);
                if (i != items.last) yield const SizedBox(height: 14);
              }),
              const SizedBox(height: 18),
              Text(
                'INTELLIGENCE SUMMARY',
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.black.withValues(alpha: 0.45),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Based on your clinical history, there is a 14% decrease in acute symptomatic triggers over the last quarter. Robo Doc recommends maintaining current preventative measures.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.black.withValues(alpha: 0.6),
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.assignment_turned_in_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Health Score',
                      style: textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Aggregate diagnostic stability score',
                      style: textTheme.titleSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '88',
                          style: textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -2.0,
                            height: 0.95,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(
                            '/100',
                            style: textTheme.headlineSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryItem {
  final String title;
  final String date;
  final double confidence;
  final String tag;
  final String outcome;

  const _HistoryItem({
    required this.title,
    required this.date,
    required this.confidence,
    required this.tag,
    required this.outcome,
  });
}

class _HistoryCard extends StatelessWidget {
  final _HistoryItem item;
  const _HistoryCard({required this.item});

  static const _primary = Color(0xFF0E204D);
  static const _secondary = Color(0xFF21CDC0);
  static const _mutedBar = Color(0xFFBFC6C5);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final pct = (item.confidence * 100).round();
    final isHigh = item.tag.toUpperCase().contains('HIGH');
    final barColor = isHigh ? _secondary.withValues(alpha: 0.9) : _mutedBar;
    final tagBg = isHigh
        ? _secondary.withValues(alpha: 0.25)
        : Colors.black.withValues(alpha: 0.06);
    final tagFg = Colors.black.withValues(alpha: 0.7);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 2),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.black.withValues(alpha: 0.9),
                            height: 1.08,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.tag,
                          textAlign: TextAlign.center,
                          style: textTheme.labelSmall?.copyWith(
                            color: tagFg,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.date,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.black.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Icon(
                        Icons.auto_graph_rounded,
                        size: 16,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$pct% Confidence',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.black.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'OUTCOME',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.black.withValues(alpha: 0.35),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      item.outcome,
                      style: textTheme.titleMedium?.copyWith(
                        color: _primary.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _NavTab { diagnosis, history, profile }

class _BottomBar extends StatelessWidget {
  final _NavTab selected;
  const _BottomBar({required this.selected});

  static const _primary = Color(0xFF0E204D);
  static const _secondary = Color(0xFF21CDC0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomItem(
            icon: Icons.add_box_rounded,
            label: 'DIAGNOSIS',
            selected: selected == _NavTab.diagnosis,
            onTap: () => Get.offAllNamed(AppRoutes.results),
          ),
          _BottomItem(
            icon: Icons.history_rounded,
            label: 'HISTORY',
            selected: selected == _NavTab.history,
            onTap: () => Get.offAllNamed(AppRoutes.history),
          ),
          _BottomItem(
            icon: Icons.person_outline_rounded,
            label: 'PROFILE',
            selected: selected == _NavTab.profile,
            onTap: () => Get.snackbar('Profile', 'Coming soon'),
          ),
        ],
      ),
    );
  }

  static Widget _pillIcon(IconData icon, bool selected) {
    final color = selected ? _secondary : Colors.black.withValues(alpha: 0.4);
    return Container(
      width: 42,
      height: 32,
      decoration: BoxDecoration(
        color: selected ? _secondary.withValues(alpha: 0.25) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: selected ? _primary : color),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const _secondary = Color(0xFF21CDC0);

  @override
  Widget build(BuildContext context) {
    final color = selected ? _secondary : Colors.black.withValues(alpha: 0.4);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 32,
              decoration: BoxDecoration(
                color: selected ? _secondary.withValues(alpha: 0.25) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected ? const Color(0xFF0E204D) : color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

