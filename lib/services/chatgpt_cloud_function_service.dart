import 'package:cloud_functions/cloud_functions.dart';

class ChatGptCloudFunctionService {
  final FirebaseFunctions _functions;

  ChatGptCloudFunctionService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  /// Calls the deployed Cloud Function `chat` (HTTP onRequest).
  ///
  /// The function returns `{ output_text: string, mocked: bool, ... }`.
  Future<String> chat({required String prompt}) async {
    final callable = _functions.httpsCallableFromUrl(
      // If you prefer region-specific URLs, swap to the deployed URL shown by Firebase.
      // This uses the default region routing.
      'https://us-central1-${_functions.app.options.projectId}.cloudfunctions.net/chat',
    );

    final res = await callable.call(<String, dynamic>{'prompt': prompt});
    final data = res.data;

    if (data is Map && data['output_text'] is String) {
      return data['output_text'] as String;
    }
    return '';
  }
}

