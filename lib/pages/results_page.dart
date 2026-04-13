import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';

class AssessmentResult {
  final String headline;
  final String possibleIndication;
  final String summary;
  final String icdCode;
  final int confidence; // 0-100
  final int temperatureF;
  final int heartRate;
  final int spo2;
  final List<ResultSuggestion> suggestions;

  const AssessmentResult({
    required this.headline,
    required this.possibleIndication,
    required this.summary,
    required this.icdCode,
    required this.confidence,
    required this.temperatureF,
    required this.heartRate,
    required this.spo2,
    required this.suggestions,
  });
}

class ResultSuggestion {
  final IconData icon;
  final String title;
  final String description;

  const ResultSuggestion({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  static const _primary = Color(0xFF0E204D);
  static const _secondary = Color(0xFF21CDC0);

  @override
  Widget build(BuildContext context) {
    final result = Get.arguments as AssessmentResult?;
    if (result == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('No results available.')),
      );
    }

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.offAllNamed(AppRoutes.assessment),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
      bottomNavigationBar: _BottomBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.headline,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.05,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 14),
              _PrimaryCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.health_and_safety_rounded,
                              color: _secondary.withValues(alpha: 0.95)),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'PRIMARY INDICATION',
                          style: textTheme.labelMedium?.copyWith(
                            color: Colors.black.withValues(alpha: 0.65),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      result.possibleIndication,
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      result.summary,
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colors.black.withValues(alpha: 0.68),
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        _Pill(
                          text: result.icdCode,
                          bg: _secondary.withValues(alpha: 0.95),
                          fg: Colors.black.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 10),
                        _Pill(
                          text: 'CONFIDENCE: ${result.confidence}%',
                          bg: Colors.black.withValues(alpha: 0.08),
                          fg: Colors.black.withValues(alpha: 0.75),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RISK ASSESSMENT',
                      style: textTheme.titleMedium?.copyWith(
                        color: _secondary.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: SizedBox(
                        width: 190,
                        height: 190,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 190,
                              height: 190,
                              child: CircularProgressIndicator(
                                value: (result.confidence.clamp(0, 100)) / 100.0,
                                strokeWidth: 12,
                                color: _secondary,
                                backgroundColor: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'MOD',
                                  style: textTheme.displaySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'LEVEL',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Text(
                        'Your risk profile is currently moderate. Monitor vitals every 4 hours.',
                        style: textTheme.titleMedium?.copyWith(
                          color: _secondary.withValues(alpha: 0.95),
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _VitalsSection(
                temperatureF: result.temperatureF,
                heartRate: result.heartRate,
                spo2: result.spo2,
              ),
              const SizedBox(height: 18),
              _CareSuggestionsSection(suggestions: result.suggestions),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.video_call_rounded),
                  label: const Text('Consult Doctor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.save_alt_rounded),
                  label: const Text('Save Results'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Powered by RoboDoc',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.black.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryCard extends StatelessWidget {
  final Widget child;
  const _PrimaryCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _Pill({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w900,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _VitalsSection extends StatelessWidget {
  final int temperatureF;
  final int heartRate;
  final int spo2;

  const _VitalsSection({
    required this.temperatureF,
    required this.heartRate,
    required this.spo2,
  });

  static const _primary = Color(0xFF0E204D);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Vitals',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.black.withValues(alpha: 0.08), height: 1),
          const SizedBox(height: 18),
          _VitalsRow(
            label: 'TEMPERATURE',
            value: '$temperatureF',
            unit: '°F',
            valueColor: _primary,
            trailing: Icon(Icons.trending_up_rounded,
                color: Colors.red.withValues(alpha: 0.85), size: 28),
          ),
          const SizedBox(height: 20),
          _VitalsRow(
            label: 'HEART RATE',
            value: '$heartRate',
            unit: 'BPM',
            valueColor: Colors.black.withValues(alpha: 0.9),
            trailing: Icon(Icons.favorite_border_rounded,
                color: Colors.black.withValues(alpha: 0.45), size: 28),
          ),
          const SizedBox(height: 20),
          _VitalsRow(
            label: 'SPO2',
            value: '$spo2',
            unit: '%',
            valueColor: Colors.black.withValues(alpha: 0.9),
            trailing: Icon(Icons.air_rounded, color: _primary, size: 28),
          ),
        ],
      ),
    );
  }
}

class _VitalsRow extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color valueColor;
  final Widget trailing;

  const _VitalsRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.valueColor,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.black.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: valueColor,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      unit,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        trailing,
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final ResultSuggestion s;
  const _SuggestionCard({required this.s});

  static const _secondary = Color(0xFF21CDC0);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _secondary.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              s.icon,
              color: const Color(0xFF0E204D),
              size: 30,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.description,
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.black.withValues(alpha: 0.6),
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CareSuggestionsSection extends StatelessWidget {
  final List<ResultSuggestion> suggestions;
  const _CareSuggestionsSection({required this.suggestions});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Care Suggestions',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 14),
          ...suggestions.map((s) => _SuggestionCard(s: s)),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
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
        children: const [
          _BottomItem(icon: Icons.add_box_rounded, label: 'DIAGNOSIS', selected: true),
          _BottomItem(icon: Icons.history_rounded, label: 'HISTORY', selected: false),
          _BottomItem(icon: Icons.person_outline_rounded, label: 'PROFILE', selected: false),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _BottomItem({
    required this.icon,
    required this.label,
    required this.selected,
  });

  static const _primary = Color(0xFF0E204D);
  static const _secondary = Color(0xFF21CDC0);

  @override
  Widget build(BuildContext context) {
    final color = selected ? _secondary : Colors.black.withValues(alpha: 0.4);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 32,
          decoration: BoxDecoration(
            color: selected ? _secondary.withValues(alpha: 0.25) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: selected ? _primary : color),
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
    );
  }
}

