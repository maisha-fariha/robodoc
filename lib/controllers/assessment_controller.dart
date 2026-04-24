import 'package:flutter/material.dart';
import 'package:gems_data_layer/gems_data_layer.dart' show DatabaseService;
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../models/assessment_result.dart';

class AssessmentController extends GetxController {
  AssessmentController({required DatabaseService databaseService})
      : _databaseService = databaseService;

  static const String _boxName = 'robodoc_history';
  static const String _historyKey = 'assessment_history_v1';
  static const String _profileBoxName = 'robodoc_profile';
  static const String _profileKeyPrefix = 'profile_v1';
  static const int _maxHistoryItems = 50;

  final DatabaseService _databaseService;
  final RxInt age = 0.obs;
  final RxnString sexAtBirth = RxnString(); // 'male' | 'female' | 'self'
  final RxnString bloodType = RxnString();
  final RxnString profileImagePath = RxnString();
  final Rxn<AssessmentResult> latestResult = Rxn<AssessmentResult>();
  final RxList<AssessmentHistoryItem> history = <AssessmentHistoryItem>[].obs;
  Worker? _authScopeWorker;
  String _activeProfileScope = 'guest';

  @override
  void onInit() {
    super.onInit();
    _bindProfileToAuthScope();
    _restoreHistory();
  }

  @override
  void onClose() {
    _authScopeWorker?.dispose();
    super.onClose();
  }

  void setFromAssessment({
    required int age,
    required String? sexAtBirth,
    String? bloodType,
  }) {
    this.age.value = age;
    this.sexAtBirth.value = sexAtBirth;
    if (bloodType != null) {
      this.bloodType.value = bloodType;
    }
    _persistProfile();
  }

  void setProfileImagePath(String? path) {
    profileImagePath.value = (path?.trim().isNotEmpty ?? false) ? path!.trim() : null;
    _persistProfile();
  }

  void setLatestResult(AssessmentResult result) {
    latestResult.value = result;
  }

  Future<void> saveAssessmentResult(AssessmentResult result) async {
    latestResult.value = result;
    history.insert(
      0,
      AssessmentHistoryItem(
        result: result,
        title: result.possibleIndication,
        date: DateTime.now(),
        confidence: result.confidence / 100.0,
        tag: _confidenceTag(result.confidence),
        outcome: result.riskSummary,
      ),
    );
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    await _persistHistory();
  }

  static String _confidenceTag(int confidence) {
    if (confidence >= 90) return 'HIGH CONFIDENCE';
    if (confidence >= 70) return 'MODERATE';
    return 'LOW CONFIDENCE';
  }

  String get genderDisplay {
    switch (sexAtBirth.value) {
      case 'male':
        return 'M';
      case 'female':
        return 'F';
      case 'self':
        return '—';
      default:
        return '—';
    }
  }

  String get ageDisplay => age.value > 0 ? age.value.toString() : '—';

  String get bloodDisplay => (bloodType.value?.trim().isNotEmpty ?? false)
      ? bloodType.value!.trim()
      : '—';

  Future<void> _restoreHistory() async {
    try {
      await _databaseService.openBox(_boxName);
      final raw = _databaseService.get<List<dynamic>>(_historyKey, boxName: _boxName);
      if (raw == null) return;
      final restored = raw
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => AssessmentHistoryItem.fromMap(e))
          .toList();
      history.assignAll(restored);
      if (restored.isNotEmpty) {
        latestResult.value = restored.first.result;
      }
    } catch (_) {
      // ignore malformed or unavailable local history data
    }
  }

  Future<void> _persistHistory() async {
    try {
      await _databaseService.openBox(_boxName);
      await _databaseService.save<List<Map<String, dynamic>>>(
        _historyKey,
        history.map((e) => e.toMap()).toList(),
        boxName: _boxName,
      );
    } catch (_) {
      // ignore persistence errors for now, keep runtime history
    }
  }

  void _bindProfileToAuthScope() {
    final auth = Get.find<AuthController>();

    Future<void> restore() async {
      final scope = _profileScopeForAuth(auth);
      if (scope == _activeProfileScope) return;
      _activeProfileScope = scope;
      await _restoreProfile();
    }

    _authScopeWorker = everAll(
      [auth.user, auth.localUser, auth.isOfflineSession],
      (_) {
        restore();
      },
    );

    restore();
  }

  String _profileScopeForAuth(AuthController auth) {
    final uid = auth.user.value?.uid;
    if (uid != null && uid.isNotEmpty) {
      return 'uid:$uid';
    }
    final email = auth.localUser.value?.email.trim().toLowerCase();
    if (email != null && email.isNotEmpty) {
      return 'local:$email';
    }
    return 'guest';
  }

  String get _profileStorageKey => '$_profileKeyPrefix:$_activeProfileScope';

  Future<void> _restoreProfile() async {
    try {
      await _databaseService.openBox(_profileBoxName);
      final raw = _databaseService.get<Map<dynamic, dynamic>>(
        _profileStorageKey,
        boxName: _profileBoxName,
      );
      if (raw == null) {
        _resetProfileFields();
        return;
      }
      age.value = (raw['age'] as num?)?.toInt() ?? 0;
      final sex = (raw['sexAtBirth'] as String?)?.trim();
      sexAtBirth.value = (sex?.isNotEmpty ?? false) ? sex : null;
      final blood = (raw['bloodType'] as String?)?.trim();
      bloodType.value = (blood?.isNotEmpty ?? false) ? blood : null;
      final imagePath = (raw['profileImagePath'] as String?)?.trim();
      profileImagePath.value = (imagePath?.isNotEmpty ?? false) ? imagePath : null;
    } catch (_) {
      _resetProfileFields();
    }
  }

  Future<void> _persistProfile() async {
    try {
      await _databaseService.openBox(_profileBoxName);
      await _databaseService.save<Map<String, dynamic>>(
        _profileStorageKey,
        {
          'age': age.value,
          'sexAtBirth': sexAtBirth.value,
          'bloodType': bloodType.value,
          'profileImagePath': profileImagePath.value,
        },
        boxName: _profileBoxName,
      );
    } catch (_) {
      // ignore profile persistence errors
    }
  }

  void _resetProfileFields() {
    age.value = 0;
    sexAtBirth.value = null;
    bloodType.value = null;
    profileImagePath.value = null;
  }
}

class AssessmentHistoryItem {
  final AssessmentResult result;
  final String title;
  final DateTime date;
  final double confidence;
  final String tag;
  final String outcome;

  const AssessmentHistoryItem({
    required this.result,
    required this.title,
    required this.date,
    required this.confidence,
    required this.tag,
    required this.outcome,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'date': date.toIso8601String(),
        'confidence': confidence,
        'tag': tag,
        'outcome': outcome,
        'result': {
          'headline': result.headline,
          'possibleIndication': result.possibleIndication,
          'summary': result.summary,
          'icdCode': result.icdCode,
          'confidence': result.confidence,
          'riskLevel': result.riskLevel,
          'riskSummary': result.riskSummary,
          'temperatureF': result.temperatureF,
          'heartRate': result.heartRate,
          'spo2': result.spo2,
          'suggestions': result.suggestions
              .map(
                (s) => {
                  'iconCodePoint': s.icon.codePoint,
                  'iconFontFamily': s.icon.fontFamily,
                  'title': s.title,
                  'description': s.description,
                },
              )
              .toList(),
        },
      };

  factory AssessmentHistoryItem.fromMap(Map<dynamic, dynamic> map) {
    final resultMap = (map['result'] as Map<dynamic, dynamic>?) ?? const {};
    final suggestionsRaw =
        (resultMap['suggestions'] as List<dynamic>?) ?? const <dynamic>[];
    final suggestions = suggestionsRaw
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (s) => ResultSuggestion(
            icon: Icons.health_and_safety_rounded,
            title: (s['title'] as String?) ?? 'Suggestion',
            description: (s['description'] as String?) ?? '',
          ),
        )
        .toList();

    final result = AssessmentResult(
      headline: (resultMap['headline'] as String?) ?? 'Your results are\nready',
      possibleIndication:
          (resultMap['possibleIndication'] as String?) ?? 'General symptom review',
      summary: (resultMap['summary'] as String?) ?? '',
      icdCode: (resultMap['icdCode'] as String?) ?? 'ICD-10: R69',
      confidence: (resultMap['confidence'] as num?)?.toInt() ?? 0,
      riskLevel: (resultMap['riskLevel'] as String?) ?? 'MOD',
      riskSummary: (resultMap['riskSummary'] as String?) ?? '',
      temperatureF: (resultMap['temperatureF'] as num?)?.toInt() ?? 98,
      heartRate: (resultMap['heartRate'] as num?)?.toInt() ?? 80,
      spo2: (resultMap['spo2'] as num?)?.toInt() ?? 98,
      suggestions: suggestions,
    );

    return AssessmentHistoryItem(
      result: result,
      title: (map['title'] as String?) ?? result.possibleIndication,
      date: DateTime.tryParse((map['date'] as String?) ?? '') ?? DateTime.now(),
      confidence: (map['confidence'] as num?)?.toDouble() ?? (result.confidence / 100.0),
      tag: (map['tag'] as String?) ?? 'MODERATE',
      outcome: (map['outcome'] as String?) ?? result.riskSummary,
    );
  }
}

