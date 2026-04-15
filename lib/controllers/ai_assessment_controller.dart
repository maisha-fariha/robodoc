import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';

import '../services/ai_assessment_service.dart';

class AiAssessmentController extends GetxController {
  AiAssessmentController({required AiAssessmentService service})
      : _service = service;

  final AiAssessmentService _service;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  Future<AiAssessmentResponse?> generate(AiAssessmentPayload payload) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      return await _service.generateAssessment(payload);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'resource-exhausted') {
        errorMessage.value =
            'AI quota exceeded. Please add OpenAI billing or use another API key.';
      } else {
        errorMessage.value = e.message ?? 'Cloud function failed.';
      }
      return null;
    } catch (_) {
      errorMessage.value = 'Unable to generate AI response right now.';
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
