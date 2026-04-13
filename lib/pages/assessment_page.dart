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
  double _painIntensity = 7;
  final Set<String> _physicalMarkers = {};
  bool? _travelInternational; // null = not selected, true/false
  bool? _antibiotics; // null = not selected, true/false

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
                      color: _currentStep == _totalSteps
                          ? _secondary
                          : Colors.black.withValues(alpha: 0.6),
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
                  _buildStep4(context),
                  _buildStep5(context),
                  _buildStep6(context),
                  _buildStep7(context),
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
                width: 60,
                child: TextField(
                  controller: _ageController,
                  focusNode: _ageFocus,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  style: textTheme.displaySmall?.copyWith(
                    color: Colors.black.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                  decoration: InputDecoration(
                    hintText: '00',
                    hintStyle: textTheme.displaySmall?.copyWith(
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
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
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
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
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
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Next', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
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
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.black.withValues(alpha: 0.45),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final symptomTitle = _quickAdds.isNotEmpty
        ? _quickAdds.first
        : (_symptomsController.text.trim().isEmpty
            ? 'Symptoms'
            : _symptomsController.text.trim().split(RegExp(r'[,.]')).first);
    final startedDays = _exactDays.round().clamp(1, 365);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How severe are your symptoms?',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.05,
              letterSpacing: -0.4,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Currently assessing',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.black.withValues(alpha: 0.5),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.medical_services_rounded,
                    color: _secondary.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symptomTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.black.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Started: $startedDays days ago',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.black.withValues(alpha: 0.45),
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
          Row(
            children: [
              Text(
                'Pain Intensity',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withValues(alpha: 0.85),
                ),
              ),
              const Spacer(),
              Text(
                _painIntensity.round().toString().padLeft(2, '0'),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _primary,
                ),
              ),
              Text(
                '/10',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.black.withValues(alpha: 0.45),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: _secondary.withValues(alpha: 0.95),
              inactiveTrackColor: Colors.black.withValues(alpha: 0.12),
              thumbColor: _secondary,
              overlayColor: _secondary.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: _painIntensity,
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (v) => setState(() => _painIntensity = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SUBTLE',
                  style: textTheme.labelMedium?.copyWith(
                    color: Colors.black.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  'DISTRESSING',
                  style: textTheme.labelMedium?.copyWith(
                    color: Colors.black.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  'UNBEARABLE',
                  style: textTheme.labelMedium?.copyWith(
                    color: Colors.black.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _DetailCard(
            icon: Icons.nights_stay_rounded,
            title: 'Sleep Impact',
            description:
                'Unable to find a comfortable position; waking up multiple times.',
            onModify: () {},
            accent: _secondary,
          ),
          const SizedBox(height: 14),
          _DetailCard(
            icon: Icons.directions_walk_rounded,
            title: 'Daily Function',
            description:
                'Mobility is limited but self-care remains possible with caution.',
            onModify: () {},
            accent: _secondary,
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
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'SAVE PROGRESS',
              style: textTheme.labelMedium?.copyWith(
                color: Colors.black.withValues(alpha: 0.45),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep5(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const markers = <String>['Fever', 'Cough', 'Headache', 'Fatigue'];

    Widget markerRow(String label) {
      final selected = _physicalMarkers.contains(label);
      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            setState(() {
              if (selected) {
                _physicalMarkers.remove(label);
              } else {
                _physicalMarkers.add(label);
              }
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: selected
                          ? _secondary.withValues(alpha: 0.9)
                          : Colors.black.withValues(alpha: 0.25),
                      width: 1.4,
                    ),
                    color: selected ? _secondary.withValues(alpha: 0.18) : Colors.transparent,
                  ),
                  child: selected
                      ? Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: _secondary.withValues(alpha: 0.95),
                        )
                      : null,
                ),
              ],
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
            'DIAGNOSTIC INTAKE',
            style: textTheme.labelLarge?.copyWith(
              color: Colors.black.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'A few more questions...',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.05,
              letterSpacing: -0.4,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.monitor_heart_outlined,
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Physical Markers',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...markers.expand((m) sync* {
                  yield markerRow(m);
                  if (m != markers.last) yield const SizedBox(height: 10);
                }),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _secondary.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _secondary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: Colors.black.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RoboDoc Assistant',
                        style: textTheme.titleMedium?.copyWith(
                          color: _primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your data is encrypted end-to- end. These markers help our clinical engine provide a more precise diagnostic overview.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: _primary.withValues(alpha: 0.9),
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
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep6(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget choiceButton({
      required String label,
      required bool value,
    }) {
      final selected = _travelInternational == value;
      return Expanded(
        child: SizedBox(
          height: 42,
          child: TextButton(
            onPressed: () => setState(() => _travelInternational = value),
            style: TextButton.styleFrom(
              backgroundColor: selected ? _primary : Colors.transparent,
              foregroundColor:
                  selected ? Colors.white : Colors.black.withValues(alpha: 0.65),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
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
            'DIAGNOSTIC INTAKE',
            style: textTheme.labelLarge?.copyWith(
              color: Colors.black.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'A few more questions...',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.05,
              letterSpacing: -0.4,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.public_rounded, color: Colors.black.withValues(alpha: 0.7)),
                    const SizedBox(width: 10),
                    Text(
                      'Travel History',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Have you traveled internationally in the last 14 days?',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withValues(alpha: 0.55),
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    children: [
                      choiceButton(label: 'No', value: false),
                      const SizedBox(width: 6),
                      choiceButton(label: 'Yes', value: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _secondary.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _secondary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: Colors.black.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RoboDoc Assistant',
                        style: textTheme.titleMedium?.copyWith(
                          color: _primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your data is encrypted end-to-end. These markers help our clinical engine provide a more precise diagnostic overview.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: _primary.withValues(alpha: 0.7),
                          height: 1.2,
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
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep7(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget choiceButton({
      required String label,
      required bool value,
    }) {
      final selected = _antibiotics == value;
      return Expanded(
        child: SizedBox(
          height: 42,
          child: TextButton(
            onPressed: () => setState(() => _antibiotics = value),
            style: TextButton.styleFrom(
              backgroundColor: selected ? _primary : Colors.transparent,
              foregroundColor:
                  selected ? Colors.white : Colors.black.withValues(alpha: 0.65),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
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
            'DIAGNOSTIC INTAKE',
            style: textTheme.labelLarge?.copyWith(
              color: Colors.black.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'A few more questions...',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.05,
              letterSpacing: -0.4,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.medication_rounded, color: Colors.black.withValues(alpha: 0.7)),
                    const SizedBox(width: 10),
                    Text(
                      'Antibiotics',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Are you currently taking any prescribed antibiotics?',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withValues(alpha: 0.55),
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    children: [
                      choiceButton(label: 'No', value: false),
                      const SizedBox(width: 6),
                      choiceButton(label: 'Yes', value: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _secondary.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _secondary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: Colors.black.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RoboDoc Assistant',
                        style: textTheme.titleMedium?.copyWith(
                          color: _primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your data is encrypted end-to-end. These markers help our clinical engine provide a more precise diagnostic overview.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: _primary.withValues(alpha: 0.7),
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Results screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text('See Results', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
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

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onModify;
  final Color accent;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onModify,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.black.withValues(alpha: 0.8)),
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
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.black.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.black.withValues(alpha: 0.55),
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: onModify,
                  child: Text(
                    'Modify detail',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.black.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                    ),
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

