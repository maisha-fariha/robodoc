import 'package:get_it/get_it.dart';

import '../../controllers/ai_assessment_controller.dart';
import '../../services/ai_assessment_service.dart';
import '../di_helper.dart';

Future<void> setupAiDomainServices() async {
  final getIt = GetIt.instance;

  DIHelper.registerRepository<AiAssessmentService>(
    factory: () => AiAssessmentService(),
  );

  DIHelper.registerController<AiAssessmentController>(
    factory: () => AiAssessmentController(
      service: getIt<AiAssessmentService>(),
    ),
  );
}
