import 'package:get/get.dart';

import '../models/assessment_result.dart';

class AssessmentController extends GetxController {
  final RxInt age = 0.obs;
  final RxnString sexAtBirth = RxnString(); // 'male' | 'female' | 'self'
  final RxnString bloodType = RxnString();
  final RxnString profileImagePath = RxnString();
  final Rxn<AssessmentResult> latestResult = Rxn<AssessmentResult>();
  final RxList<AssessmentHistoryItem> history = <AssessmentHistoryItem>[].obs;

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
  }

  void setProfileImagePath(String? path) {
    profileImagePath.value = (path?.trim().isNotEmpty ?? false) ? path!.trim() : null;
  }

  void setLatestResult(AssessmentResult result) {
    latestResult.value = result;
  }

  void saveAssessmentResult(AssessmentResult result) {
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
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
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
}

