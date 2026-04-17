import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/ai_assessment_controller.dart';
import '../controllers/assessment_controller.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../services/ai_assessment_service.dart';
import '../models/assessment_result.dart';
import '../utils/app_snackbar.dart';
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
  late final AiAssessmentController _aiController;
  final Map<int, DynamicQuestion> _dynamicQuestions = {};
  final Map<int, dynamic> _dynamicAnswers = {};
  final Map<int, TextEditingController> _dynamicTextControllers = {};
  final Map<int, TextEditingController> _dynamicNoteControllers = {};
  final Map<int, String> _dynamicQuestionErrors = {};
  bool _isGeneratingDynamicQuestion = false;
  bool _isSubmittingResults = false;
  bool _isStepActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _aiController = Get.find<AiAssessmentController>();
  }

  Future<void> _goNext() {
    return _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> _goBack() {
    return _pageController.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Map<String, dynamic> _staticAnswerContext() {
    return {
      'age': int.tryParse(_ageController.text.trim()) ?? 0,
      'sexAtBirth': _sexAtBirth ?? '',
      'symptoms': _symptomsController.text.trim(),
      'quickAdds': _quickAdds.toList(),
      'durationDays': _exactDays.round(),
      'painIntensity': _painIntensity.round(),
    };
  }

  List<Map<String, dynamic>> _dynamicAnswerContext() {
    return [5, 6, 7]
        .where((step) => _dynamicQuestions.containsKey(step))
        .map((step) {
          final q = _dynamicQuestions[step]!;
          final raw = _dynamicAnswers[step];
          final answer = raw is Map<String, dynamic>
              ? {
                  'selected': raw['selected'],
                  'note': raw['note'],
                }
              : raw;
          return {
            'step': step,
            'questionId': q.id,
            'question': q.title,
            'answer': answer,
            'inputType': q.inputType,
          };
        })
        .toList();
  }

  Future<void> _ensureDynamicQuestion(int stepNumber) async {
    if (_dynamicQuestions.containsKey(stepNumber)) return;
    if (!mounted) return;

    setState(() {
      _isGeneratingDynamicQuestion = true;
      _dynamicQuestionErrors.remove(stepNumber);
    });

    try {
      final question = await _aiController.generateQuestion(
        stepNumber: stepNumber,
        staticAnswers: _staticAnswerContext(),
        previousDynamicAnswers: _dynamicAnswerContext(),
      );
      if (!mounted) return;
      setState(() {
        if (question != null) {
          _dynamicQuestions[stepNumber] = question;
          _dynamicQuestionErrors.remove(stepNumber);
        } else {
          final error = _aiController.errorMessage.value;
          _dynamicQuestionErrors[stepNumber] =
              (error == null || error.trim().isEmpty)
                  ? 'Unable to generate follow-up question right now.'
                  : error;
        }
        _isGeneratingDynamicQuestion = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _dynamicQuestionErrors[stepNumber] =
            'Unable to generate follow-up question right now.';
        _isGeneratingDynamicQuestion = false;
      });
    }
  }

  bool _validateDynamicAnswer(int stepNumber) {
    final question = _dynamicQuestions[stepNumber];
    if (question == null) return false;
    final answer = _dynamicAnswers[stepNumber];
    bool ok = false;
    if (answer is Map<String, dynamic>) {
      final selected = (answer['selected'] ?? '').toString().trim();
      final note = (answer['note'] ?? '').toString().trim();
      ok = selected.isNotEmpty || note.isNotEmpty;
    } else {
      ok = answer != null && answer.toString().trim().isNotEmpty;
    }
    if (!ok) {
      AppSnackbar.show('Answer required', 'Please answer this question to continue.');
    }
    return ok;
  }

  bool _validateStep1() {
    final age = int.tryParse(_ageController.text.trim());
    if (age == null || age <= 0) {
      AppSnackbar.show('Age required', 'Please enter a valid age.');
      return false;
    }
    if (_sexAtBirth == null) {
      AppSnackbar.show('Gender required', 'Please select your gender.');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    final hasSymptomsText = _symptomsController.text.trim().isNotEmpty;
    if (!hasSymptomsText) {
      AppSnackbar.show('Symptoms required', 'Please describe your symptoms.');
      return false;
    }
    return true;
  }

  bool _validateStep3() {
    if (_durationPreset == null) {
      AppSnackbar.show('Duration required', 'Please select symptom duration.');
      return false;
    }
    if (_exactDays < 1) {
      AppSnackbar.show('Duration required', 'Please set exact duration.');
      return false;
    }
    return true;
  }

  bool _validateStep4() {
    if (_painIntensity < 0 || _painIntensity > 10) {
      AppSnackbar.show('Pain level required', 'Please set pain intensity.');
      return false;
    }
    return true;
  }

  Widget _navRow({
    required BuildContext context,
    required String nextLabel,
    Future<void> Function()? onNext,
    bool nextLoading = false,
    bool disableBack = false,
  }) {
    final canGoBack = _currentStep > 1 && !disableBack && !_isStepActionInProgress;
    final loading = nextLoading || _isStepActionInProgress;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: canGoBack ? _goBack : null,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text(
                'Back',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (_isStepActionInProgress) return;
                      setState(() {
                        _isStepActionInProgress = true;
                      });
                      try {
                        await (onNext ?? _goNext)();
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isStepActionInProgress = false;
                          });
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      nextLabel,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _ageFocus.dispose();
    _pageController.dispose();
    _symptomsController.dispose();
    _symptomsFocus.dispose();
    for (final c in _dynamicTextControllers.values) {
      c.dispose();
    }
    for (final c in _dynamicNoteControllers.values) {
      c.dispose();
    }
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
          Obx(() {
            final auth = Get.find<AuthController>();
            return IconButton(
              onPressed: auth.isLoading.value
                  ? null
                  : () async {
                      await auth.signOut();
                    },
              icon: auth.isLoading.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.logout_rounded),
              tooltip: 'Log out',
            );
          }),
          const SizedBox(width: 8),
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
              onPressed: () async {
                if (!_validateStep1()) return;
                await _goNext();
              },
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
          _navRow(
            context: context,
            nextLabel: 'Continue',
            onNext: () async {
              if (!_validateStep2()) return;
              await _goNext();
            },
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
          _navRow(
            context: context,
            nextLabel: 'Next',
            onNext: () async {
              if (!_validateStep3()) return;
              await _goNext();
            },
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
          _navRow(
            context: context,
            nextLabel: 'Continue',
            onNext: () async {
              if (!_validateStep4()) return;
              await _ensureDynamicQuestion(5);
              if (!_dynamicQuestions.containsKey(5)) return;
              await _goNext();
            },
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
    return _buildDynamicStep(context, 5);
  }

  Widget _buildStep6(BuildContext context) {
    return _buildDynamicStep(context, 6);
  }

  Widget _buildStep7(BuildContext context) {
    return _buildDynamicStep(context, 7);
  }

  Widget _buildDynamicStep(BuildContext context, int stepNumber) {
    final textTheme = Theme.of(context).textTheme;
    final question = _dynamicQuestions[stepNumber];
    final questionError = _dynamicQuestionErrors[stepNumber];

    if (_isGeneratingDynamicQuestion) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              'Generating follow-up question...',
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.black.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (question == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step $stepNumber question',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.black.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                questionError ?? 'Unable to load follow-up question.',
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.black.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _navRow(
              context: context,
              nextLabel: 'Retry',
              onNext: () async {
                await _ensureDynamicQuestion(stepNumber);
              },
            ),
          ],
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
            'Step $stepNumber question',
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
                Text(
                  question.title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.85),
                  ),
                ),
                if (question.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    question.description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withValues(alpha: 0.55),
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                _buildDynamicInput(context, stepNumber, question),
              ],
            ),
          ),
          const SizedBox(height: 25),
          _navRow(
            context: context,
            nextLabel: stepNumber == 7 ? 'See Results' : 'Continue',
            nextLoading: stepNumber == 7 && _isSubmittingResults,
            onNext: () async {
              if (!_validateDynamicAnswer(stepNumber)) return;
              if (stepNumber < 7) {
                await _ensureDynamicQuestion(stepNumber + 1);
                if (mounted && _dynamicQuestions.containsKey(stepNumber + 1)) {
                  await _goNext();
                }
                return;
              }
              setState(() {
                _isSubmittingResults = true;
              });
              try {
                final result = await _analyzeAnswers();
                if (mounted) {
                  Get.toNamed(AppRoutes.results, arguments: result);
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isSubmittingResults = false;
                  });
                }
              }
            },
            disableBack: stepNumber == 7 && _isSubmittingResults,
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicInput(
    BuildContext context,
    int stepNumber,
    DynamicQuestion question,
  ) {
    final currentValue = _dynamicAnswers[stepNumber];
    switch (question.inputType) {
      case 'dropdown':
      case 'single_select':
        final options = question.options;
        final answerMap = currentValue is Map<String, dynamic>
            ? currentValue
            : <String, dynamic>{'selected': null, 'note': ''};
        final selectedRaw = answerMap['selected'];
        final selected =
            options.contains(selectedRaw) ? selectedRaw as String? : null;
        final noteController = _dynamicNoteControllers.putIfAbsent(
          stepNumber,
          () => TextEditingController(text: (answerMap['note'] ?? '').toString()),
        );
        if (question.inputType == 'dropdown') {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selected,
                items: options
                    .map((o) => DropdownMenuItem<String>(value: o, child: Text(o)))
                    .toList(),
                decoration: const InputDecoration(
                  hintText: 'Select one option',
                ),
                onChanged: (v) => setState(
                  () => _dynamicAnswers[stepNumber] = {
                    'selected': v,
                    'note': noteController.text.trim(),
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                onChanged: (v) => _dynamicAnswers[stepNumber] = {
                  'selected': selected,
                  'note': v.trim(),
                },
                decoration: const InputDecoration(
                  hintText: 'Additional details (optional)',
                ),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: options.map((o) {
                final isSelected = selected == o;
                return ChoiceChip(
                  label: Text(o),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _dynamicAnswers[stepNumber] = {
                        'selected': o,
                        'note': noteController.text.trim(),
                      }),
                  selectedColor: _secondary.withValues(alpha: 0.25),
                  backgroundColor: Colors.black.withValues(alpha: 0.03),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              onChanged: (v) => _dynamicAnswers[stepNumber] = {
                'selected': selected,
                'note': v.trim(),
              },
              decoration: const InputDecoration(
                hintText: 'Additional details (optional)',
              ),
            ),
          ],
        );
      case 'number':
      case 'text':
      default:
        final controller = _dynamicTextControllers.putIfAbsent(
          stepNumber,
          () => TextEditingController(text: currentValue?.toString() ?? ''),
        );
        return TextField(
          controller: controller,
          keyboardType:
              question.inputType == 'number' ? TextInputType.number : TextInputType.text,
          onChanged: (v) => _dynamicAnswers[stepNumber] = v,
          decoration: InputDecoration(
            hintText: question.placeholder,
          ),
        );
    }
  }

  Future<AssessmentResult> _analyzeAnswers() async {
    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    final symptomsRaw = _symptomsController.text.trim();
    final symptoms = symptomsRaw.toLowerCase();
    final dynamicAnswerText = _dynamicAnswerContext()
        .map((e) => (e['answer'] ?? '').toString().toLowerCase())
        .join(' ');

    // Persist key demographics so Profile can be dynamic.
    Get.find<AssessmentController>().setFromAssessment(
      age: age,
      sexAtBirth: _sexAtBirth,
    );

    final hasFever = _quickAdds.contains('Fever') ||
        symptoms.contains('fever') ||
        dynamicAnswerText.contains('fever');
    final hasCough = _quickAdds.contains('Cough') ||
        symptoms.contains('cough') ||
        dynamicAnswerText.contains('cough');
    final hasHeadache = _quickAdds.contains('Headache') ||
        symptoms.contains('headache') ||
        dynamicAnswerText.contains('headache');
    final hasFatigue = _quickAdds.contains('Fatigue') ||
        symptoms.contains('fatigue') ||
        dynamicAnswerText.contains('fatigue');

    int riskPoints = 0;
    riskPoints += hasFever ? 18 : 0;
    riskPoints += hasCough ? 14 : 0;
    riskPoints += hasHeadache ? 10 : 0;
    riskPoints += hasFatigue ? 10 : 0;
    riskPoints += dynamicAnswerText.contains('travel') ? 8 : 0;
    riskPoints += (_painIntensity >= 7) ? 10 : 0;
    riskPoints += (_exactDays >= 7) ? 6 : 0;
    riskPoints += (age >= 60) ? 8 : 0;
    riskPoints += dynamicAnswerText.contains('antibiotic') ? 2 : 0;

    final confidence = (60 + riskPoints).clamp(55, 92);

    String indication = 'Possible Viral Fever';
    String icd = 'ICD-10: J10.1';
    if (hasCough && !hasFever) {
      indication = 'Upper Respiratory Infection';
      icd = 'ICD-10: J06.9';
    }
    if ((_painIntensity >= 8) && symptoms.contains('chest')) {
      indication = 'Chest Pain (Needs Evaluation)';
      icd = 'ICD-10: R07.9';
    }

    final temp = hasFever ? 101 : 98;
    final hr = (hasFever ? 96 : 84) + (_painIntensity >= 7 ? 6 : 0);
    final spo2 = hasCough ? 97 : 98;

    final shortSymptom = symptomsRaw.isEmpty
        ? 'your reported symptoms'
        : (symptomsRaw.length > 120 ? '${symptomsRaw.substring(0, 120)}…' : symptomsRaw);

    final summary =
        'Based on the details provided (${_exactDays.round()} days, intensity ${_painIntensity.round()}/10), '
        'the symptom pattern suggests a likely acute process. This is not a diagnosis.\n\n'
        'Summary: $shortSymptom';

    final suggestions = <ResultSuggestion>[
      const ResultSuggestion(
        icon: Icons.water_drop_rounded,
        title: 'Optimal Hydration',
        description: 'Increase fluid intake and consider oral rehydration if needed.',
      ),
      const ResultSuggestion(
        icon: Icons.bed_rounded,
        title: 'Mandatory Rest',
        description: 'Reduce activity for 24–48 hours and prioritize sleep.',
      ),
      const ResultSuggestion(
        icon: Icons.thermostat_rounded,
        title: 'Thermal Control',
        description: 'Monitor temperature and use comfort measures as needed.',
      ),
    ];

    final localResult = AssessmentResult(
      headline: 'Your results are\nready',
      possibleIndication: indication,
      summary: summary,
      icdCode: icd,
      confidence: confidence,
      riskLevel: 'MOD',
      riskSummary:
          'Your risk profile is currently moderate. Monitor vitals every 4 hours.',
      temperatureF: temp,
      heartRate: hr,
      spo2: spo2,
      suggestions: suggestions,
    );

    final aiResponse = await _aiController.generate(
      AiAssessmentPayload(
        age: age,
        sexAtBirth: _sexAtBirth ?? '',
        symptoms: symptomsRaw,
        quickAdds: _quickAdds.toList(),
        durationDays: _exactDays.round(),
        painIntensity: _painIntensity.round(),
        physicalMarkers: const [],
        travelInternational: null,
        takingAntibiotics: null,
        dynamicAnswers: _dynamicAnswerContext(),
      ),
    );

    if (aiResponse == null) {
      final error = _aiController.errorMessage.value;
      if (error != null && error.isNotEmpty) {
        AppSnackbar.show('AI unavailable', '$error Showing local assessment.');
      }
      return localResult;
    }

    return AssessmentResult(
      headline: localResult.headline,
      possibleIndication: aiResponse.possibleIndication,
      summary: aiResponse.summary,
      icdCode: aiResponse.icdCode,
      confidence: aiResponse.confidence,
      riskLevel: aiResponse.riskLevel,
      riskSummary: aiResponse.riskSummary,
      temperatureF: localResult.temperatureF,
      heartRate: localResult.heartRate,
      spo2: localResult.spo2,
      suggestions: aiResponse.suggestions.isEmpty
          ? localResult.suggestions
          : aiResponse.suggestions.map((s) {
              final parts = s.split(':');
              final title = parts.first.trim();
              final description = parts.length > 1
                  ? parts.sublist(1).join(':').trim()
                  : s.trim();
              return ResultSuggestion(
                icon: Icons.health_and_safety_rounded,
                title: title.isEmpty ? 'Suggestion' : title,
                description: description,
              );
            }).toList(),
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

