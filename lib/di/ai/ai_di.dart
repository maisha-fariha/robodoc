import 'package:cloud_functions/cloud_functions.dart';
import 'package:get_it/get_it.dart';

import '../../controllers/ai_assessment_controller.dart';
import '../../services/ai_assessment_service.dart';
import '../di_helper.dart';

Future<void> setupAiDomainServices() async {
  final getIt = GetIt.instance;

  if (!getIt.isRegistered<FirebaseFunctions>()) {
    getIt.registerLazySingleton<FirebaseFunctions>(
      () => FirebaseFunctions.instanceFor(region: 'us-central1'),
    );
  }

  DIHelper.registerRepository<AiAssessmentService>(
    factory: () => AiAssessmentService(
      functions: getIt<FirebaseFunctions>(),
    ),
  );

  DIHelper.registerController<AiAssessmentController>(
    factory: () => AiAssessmentController(
      service: getIt<AiAssessmentService>(),
    ),
  );
}
