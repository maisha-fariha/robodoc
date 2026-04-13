import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({super.key});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  static const _primary = Color(0xFF0E204D);
  static const _secondary = Color(0xFF21CDC0);

  static const int _totalSteps = 7;
  int _currentStep = 1; // 1-based

  String? _sexAtBirth; // 'male' | 'female' | 'self'
  final _ageController = TextEditingController();
  final _ageFocus = FocusNode();
  final PageController _pageController = PageController();

  final _symptomsController = TextEditingController();
  final FocusNode _symptomsFocus = FocusNode();
  final Set<String> _quickAdds = {};
  String? _durationPreset; // 'hours' | 'days' | 'week' | 'month'
  double _exactDays = 14;

  @override
  void dispose() {
    _ageController.dispose();
    _ageFocus.dispose();
    _pageController.dispose();
    _symptomsController.dispose();
    _symptomsFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Image.asset('assets/images/robo_doc_logo_no_bg.png', width: 24,),
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
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
              child: Row(
                children: [
                  Text(
                    'ASSESSMENT',
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.black.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.3,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Step $_currentStep/$_totalSteps',
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.black.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: _StepProgress(
                totalSteps: _totalSteps,
                currentStep: _currentStep,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index + 1),
                children: [
                  _buildStep1(context),
                  _buildStep2(context),
                  _buildStep3(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us more about yourself',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.2,
              letterSpacing: -0.4,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This clinical data ensures your health benchmarks are calculated with surgical precision.',
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.black.withValues(alpha: 0.55),
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'BIOLOGICAL AGE',
            style: textTheme.labelMedium?.copyWith(
              color: Colors.black.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _ageController,
                  focusNode: _ageFocus,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  style: textTheme.displayMedium?.copyWith(
                    color: Colors.black.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                  decoration: InputDecoration(
                    hintText: '00',
                    hintStyle: textTheme.displayMedium?.copyWith(
                      color: Colors.black.withValues(alpha: 0.15),
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                    ),
                    isDense: true,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Years',
                  style: textTheme.titleLarge?.copyWith(
                    color: _secondary.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'GENDER',
            style: textTheme.labelMedium?.copyWith(
              color: Colors.black.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _OptionCard(
            title: 'Male',
            subtitle: 'Xᵃ Chromosomes',
            icon: Icons.male_rounded,
            selected: _sexAtBirth == 'male',
            onTap: () => setState(() => _sexAtBirth = 'male'),
          ),
          const SizedBox(height: 12),
          _OptionCard(
            title: 'Female',
            subtitle: 'XX Chromosomes',
            icon: Icons.female_rounded,
            selected: _sexAtBirth == 'female',
            onTap: () => setState(() => _sexAtBirth = 'female'),
          ),
          const SizedBox(height: 12),
          _OptionCard(
            title: 'Self-identify',
            subtitle: 'Other options',
            icon: Icons.format_list_bulleted_rounded,
            selected: _sexAtBirth == 'self',
            onTap: () => setState(() => _sexAtBirth = 'self'),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _secondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'RoboDoc uses biological metrics to personalize clinical outcomes. Your data is encrypted and managed under strict HIPAA compliance standards.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.black.withValues(alpha: 0.7),
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _pageController.nextPage(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    const quickAdds = <String>[
      'Fever',
      'Headache',
      'Cough',
      'Palpitations',
      'Fatigue',
    ];

    void toggleQuickAdd(String label) {
      setState(() {
        if (_quickAdds.contains(label)) {
          _quickAdds.remove(label);
        } else {
          _quickAdds.add(label);
        }
        final joined = _quickAdds.join(', ');
        _symptomsController.text = joined.isEmpty ? '' : joined;
        _symptomsController.selection = TextSelection.fromPosition(
          TextPosition(offset: _symptomsController.text.length),
        );
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are your main symptoms?',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.05,
              letterSpacing: -0.4,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Describe how you’re feeling in your own words. Our system will analyze the clinical keywords.',
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.black.withValues(alpha: 0.55),
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _symptomsController,
                  focusNode: _symptomsFocus,
                  minLines: 5,
                  maxLines: 7,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText:
                        'e.g. I have been feeling sharp pains in my chest for the last two hours, accompanied by mild nausea...',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withValues(alpha: 0.25),
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: _secondary.withValues(
                      alpha: _symptomsFocus.hasFocus ? 0.10 : 0.06,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          size: 16, color: Colors.black.withValues(alpha: 0.45)),
                      const SizedBox(width: 6),
                      Text(
                        'AI Analysis Active',
                        style: textTheme.labelMedium?.copyWith(
                          color: Colors.black.withValues(alpha: 0.45),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'COMMON QUICK-ADDS',
            style: textTheme.labelMedium?.copyWith(
              color: Colors.black.withValues(alpha: 0.8),
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: quickAdds.map((label) {
              final selected = _quickAdds.contains(label);
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => toggleQuickAdd(label),
                selectedColor: _secondary.withValues(alpha: 0.25),
                backgroundColor: Colors.black.withValues(alpha: 0.03),
                labelStyle: TextStyle(
                  color: Colors.black.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w700,
                ),
                side: BorderSide(
                  color: selected
                      ? _secondary.withValues(alpha: 0.7)
                      : Colors.transparent,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _secondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/icons/shield.png', width: 30,),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RoboDoc Privacy',
                        style: textTheme.titleMedium?.copyWith(
                          color: _primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your symptom description is encrypted end-to-end. Clinical data is used exclusively for immediate diagnostic triage and is not shared with third-party providers without explicit consent.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: _primary.withValues(alpha: 0.7),
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Save for later',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.black.withValues(alpha: 0.45),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget durationTile({
      required String id,
      required String title,
      required IconData icon,
    }) {
      final selected = _durationPreset == id;
      return Expanded(
        child: Material(
          color: Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => setState(() => _durationPreset = id),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 140,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? _secondary.withValues(alpha: 0.9) : Colors.transparent,
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: _primary.withValues(alpha: 0.9)),
                  const Spacer(),
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.black.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How long have you been feeling this?',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.05,
              letterSpacing: -0.4,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              durationTile(id: 'hours', title: 'A few hours', icon: Icons.schedule_rounded),
              const SizedBox(width: 14),
              durationTile(id: 'days', title: 'A few days', icon: Icons.calendar_month_rounded),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              durationTile(id: 'week', title: 'Over a week', icon: Icons.calendar_today_rounded),
              const SizedBox(width: 14),
              durationTile(id: 'month', title: 'More than a\nmonth', icon: Icons.event_repeat_rounded),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exact duration',
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.black.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fine-tune the timeline',
                            style: textTheme.bodyLarge?.copyWith(
                              color: Colors.black.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _secondary.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _exactDays.round().toString(),
                            style:  TextStyle(
                              color: Colors.black.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'DAYS',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    activeTrackColor: _primary,
                    inactiveTrackColor: Colors.black.withValues(alpha: 0.10),
                    thumbColor: _primary,
                    overlayColor: _primary.withValues(alpha: 0.10),
                  ),
                  child: Slider(
                    value: _exactDays,
                    min: 1,
                    max: 30,
                    divisions: 29,
                    onChanged: (v) => setState(() => _exactDays = v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1 DAY',
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.black.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '15 DAYS',
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.black.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '30+ DAYS',
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.black.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                // Placeholder for Step 4+
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Next', style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white.withValues(alpha: 0.9)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Information provided is part of the RoboDoc assessment protocol.',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.black.withValues(alpha: 0.35),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  final int totalSteps; // e.g. 7
  final int currentStep; // 1-based

  const _StepProgress({
    required this.totalSteps,
    required this.currentStep,
  });

  static const _secondary = Color(0xFF21CDC0);

  @override
  Widget build(BuildContext context) {
    final clamped = currentStep.clamp(1, totalSteps);

    return Row(
      children: List.generate(totalSteps, (index) {
        final stepIndex = index + 1;
        final isActive = stepIndex <= clamped;
        final isCurrent = stepIndex == clamped;

        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 10),
            decoration: BoxDecoration(
              color: isActive
                  ? _secondary.withValues(alpha: isCurrent ? 1.0 : 0.45)
                  : Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  static const _secondary = Color(0xFF21CDC0);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.black.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? _secondary.withValues(alpha: 0.9) : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _secondary.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.black.withValues(alpha: 0.85)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.black.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.black.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: _secondary.withValues(alpha: 0.95)),
            ],
          ),
        ),
      ),
    );
  }
}

