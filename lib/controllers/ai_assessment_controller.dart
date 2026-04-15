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
    } catch (e) {
      final message = e.toString();
      if (message.contains('insufficient_quota') ||
          message.contains('resource-exhausted')) {
        errorMessage.value =
            'AI quota exceeded. Please add OpenAI billing or use another API key.';
      } else {
        errorMessage.value = message.isEmpty
            ? 'Unable to generate AI response right now.'
            : message;
      }
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<DynamicQuestion?> generateQuestion({
    required int stepNumber,
    required Map<String, dynamic> staticAnswers,
    required List<Map<String, dynamic>> previousDynamicAnswers,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      return await _service.generateDynamicQuestion(
        stepNumber: stepNumber,
        staticAnswers: staticAnswers,
        previousDynamicAnswers: previousDynamicAnswers,
      );
    } catch (e) {
      final message = e.toString();
      errorMessage.value = message.isEmpty
          ? 'Unable to generate follow-up question right now.'
          : message;
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
