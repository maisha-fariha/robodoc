import 'package:get/get.dart';

import '../models/assessment_result.dart';

class AssessmentController extends GetxController {
  final RxInt age = 0.obs;
  final RxnString sexAtBirth = RxnString(); // 'male' | 'female' | 'self'
  final RxnString bloodType = RxnString();
  final RxnString profileImagePath = RxnString();
  final Rxn<AssessmentResult> latestResult = Rxn<AssessmentResult>();

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

