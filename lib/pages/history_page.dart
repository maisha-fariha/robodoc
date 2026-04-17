import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/assessment_controller.dart';
import '../routes/app_routes.dart';
import '../utils/app_snackbar.dart';
import '../widgets/robodoc_bottom_nav.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const _primary = Color(0xFF0E204D);
  String _selectedFilter = 'ALL';

  List<AssessmentHistoryItem> _applyFilter(List<AssessmentHistoryItem> all) {
    switch (_selectedFilter) {
      case 'HIGH':
        return all.where((e) => e.tag == 'HIGH CONFIDENCE').toList();
      case 'MOD':
        return all.where((e) => e.tag == 'MODERATE').toList();
      case 'LOW':
        return all.where((e) => e.tag == 'LOW CONFIDENCE').toList();
      case 'ALL':
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final assessment = Get.find<AssessmentController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Robo Doc AI',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      bottomNavigationBar: const RoboDocBottomNav(selected: RoboDocTab.history),
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
                  letterSpacing: -0.8,
                  color: Colors.black.withValues(alpha: 0.92),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Review previous assessments and open each item to view full summary details.',
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.black.withValues(alpha: 0.55),
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: TextButton(
                        onPressed: () {
                          Get.bottomSheet<void>(
                            SafeArea(
                              top: false,
                              child: Material(
                                color: Colors.white,
                                borderRadius:
                                    const BorderRadius.vertical(top: Radius.circular(20)),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Filter history',
                                        style: textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ...const [
                                        ('ALL', 'All records'),
                                        ('HIGH', 'High confidence'),
                                        ('MOD', 'Moderate confidence'),
                                        ('LOW', 'Low confidence'),
                                      ].map((entry) {
                                        final id = entry.$1;
                                        final label = entry.$2;
                                        final selected = _selectedFilter == id;
                                        return ListTile(
                                          title: Text(label),
                                          trailing: selected
                                              ? const Icon(Icons.check_circle_rounded)
                                              : null,
                                          onTap: () {
                                            setState(() => _selectedFilter = id);
                                            Get.back();
                                          },
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.03),
                          foregroundColor: Colors.black.withValues(alpha: 0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                        onPressed: () => AppSnackbar.show(
                          'Coming soon',
                          'Export PDF will be available in a future update.',
                          isError: false,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
              SizedBox(
                height: 320,
                child: Obx(() {
                  final items = _applyFilter(assessment.history.toList());
                  if (items.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'No history yet. Complete an assessment and your records will appear here.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: Colors.black.withValues(alpha: 0.6),
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final i = items[index];
                      return _HistoryCard(
                        item: i,
                        onTap: () {
                          assessment.setLatestResult(i.result);
                          Get.toNamed(AppRoutes.results, arguments: i.result);
                        },
                      );
                    },
                  );
                }),
              ),
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
                child: Obx(
                  () {
                    final items = assessment.history;
                    final count = items.length;
                    final avg = count == 0
                        ? 0
                        : (items.fold<double>(
                              0,
                              (sum, item) => sum + (item.confidence * 100),
                            ) /
                            count)
                            .round();
                    final summary = count == 0
                        ? 'No assessments have been completed yet. Once you submit results, your trend summary will appear here.'
                        : 'Based on your last $count assessment${count == 1 ? '' : 's'}, average confidence is $avg%. Continue regular check-ins for stronger trend insights.';
                    return Text(
                      summary,
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colors.black.withValues(alpha: 0.6),
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
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
                    Obx(
                      () {
                        final items = assessment.history;
                        final avg = items.isEmpty
                            ? 0
                            : (items.fold<double>(
                                  0,
                                  (sum, item) => sum + (item.confidence * 100),
                                ) /
                                items.length)
                                .round();
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              avg.toString(),
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
                        );
                      },
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

class _HistoryCard extends StatelessWidget {
  final AssessmentHistoryItem item;
  final VoidCallback onTap;
  const _HistoryCard({required this.item, required this.onTap});

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

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 84,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.black.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item.tag,
                          style: textTheme.labelSmall?.copyWith(
                            color: tagFg,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _MetaText(
                        icon: Icons.calendar_today_rounded,
                        text: _formatDate(item.date),
                      ),
                      _MetaText(
                        icon: Icons.auto_graph_rounded,
                        text: '$pct% Confidence',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.outcome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: _primary.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black.withValues(alpha: 0.45)),
        const SizedBox(width: 5),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black.withValues(alpha: 0.6),
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

