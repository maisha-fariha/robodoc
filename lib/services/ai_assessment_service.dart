import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import '../secrets/openai_api_key.local.dart';

class AiAssessmentPayload {
  final int age;
  final String sexAtBirth;
  final String symptoms;
  final List<String> quickAdds;
  final int durationDays;
  final int painIntensity;
  final List<String> physicalMarkers;
  final bool? travelInternational;
  final bool? takingAntibiotics;
  final List<Map<String, dynamic>> dynamicAnswers;

  const AiAssessmentPayload({
    required this.age,
    required this.sexAtBirth,
    required this.symptoms,
    required this.quickAdds,
    required this.durationDays,
    required this.painIntensity,
    required this.physicalMarkers,
    required this.travelInternational,
    required this.takingAntibiotics,
    this.dynamicAnswers = const [],
  });

  Map<String, dynamic> toJson() => {
        'age': age,
        'sexAtBirth': sexAtBirth,
        'symptoms': symptoms,
        'quickAdds': quickAdds,
        'durationDays': durationDays,
        'painIntensity': painIntensity,
        'physicalMarkers': physicalMarkers,
        'travelInternational': travelInternational,
        'takingAntibiotics': takingAntibiotics,
        'dynamicAnswers': dynamicAnswers,
      };
}

class DynamicQuestion {
  final String id;
  final String title;
  final String description;
  final String inputType; // dropdown | single_select | text | number
  final List<String> options;
  final String placeholder;

  const DynamicQuestion({
    required this.id,
    required this.title,
    required this.description,
    required this.inputType,
    required this.options,
    required this.placeholder,
  });

  factory DynamicQuestion.fromMap(Map<dynamic, dynamic> map) {
    final optionsRaw = map['options'] as List<dynamic>? ?? const [];
    return DynamicQuestion(
      id: (map['id'] as String?) ?? 'q',
      title: (map['title'] as String?) ?? 'Follow-up question',
      description: (map['description'] as String?) ?? '',
      inputType: (map['inputType'] as String?) ?? 'text',
      options: optionsRaw.map((e) => e.toString()).toList(),
      placeholder: (map['placeholder'] as String?) ?? 'Type your answer',
    );
  }
}

class AiAssessmentResponse {
  final String possibleIndication;
  final String summary;
  final int confidence;
  final String icdCode;
  final String riskLevel;
  final String riskSummary;
  final List<String> suggestions;

  const AiAssessmentResponse({
    required this.possibleIndication,
    required this.summary,
    required this.confidence,
    required this.icdCode,
    required this.riskLevel,
    required this.riskSummary,
    required this.suggestions,
  });

  factory AiAssessmentResponse.fromMap(Map<dynamic, dynamic> map) {
    final confidenceValue = (map['confidence'] as num?)?.toInt() ?? 65;
    final suggestionsRaw = map['suggestions'] as List<dynamic>? ?? const [];
    return AiAssessmentResponse(
      possibleIndication:
          (map['possibleIndication'] as String?) ?? 'General symptom review',
      summary: (map['summary'] as String?) ??
          'Please consult a clinician for full evaluation.',
      confidence: confidenceValue.clamp(0, 100),
      icdCode: (map['icdCode'] as String?) ?? 'ICD-10: R69',
      riskLevel: (map['riskLevel'] as String?) ?? 'MOD',
      riskSummary: (map['riskSummary'] as String?) ??
          'Monitor symptoms and seek care if they worsen.',
      suggestions: suggestionsRaw.map((e) => e.toString()).toList(),
    );
  }
}

class AiAssessmentService {
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  static const Duration _requestTimeout = Duration(seconds: 20);

  Future<AiAssessmentResponse> generateAssessment(AiAssessmentPayload payload) async {
    return _generateFinalAssessment(payload);
  }

  Future<DynamicQuestion> generateDynamicQuestion({
    required int stepNumber,
    required Map<String, dynamic> staticAnswers,
    required List<Map<String, dynamic>> previousDynamicAnswers,
  }) async {
    _ensureApiKey();

    final prompt = [
      'You are generating one clinical follow-up question for a step-based medical intake.',
      'Generate exactly one question for step $stepNumber.',
      'Steps 1-4 are already collected. Step 5/6/7 are dynamic.',
      'Question must depend on previous answers.',
      '',
      'Static answers (steps 1-4):',
      jsonEncode(staticAnswers),
      '',
      'Previous dynamic answers:',
      jsonEncode(previousDynamicAnswers),
      '',
      'Return only strict JSON with keys:',
      '{"id": "q$stepNumber", "title": string, "description": string, "inputType": "dropdown"|"single_select"|"text"|"number", "options": [string], "placeholder": string}',
      'Rules:',
      '- For text/number inputType, options must be []',
      '- For dropdown/single_select, options must have 2-6 short options',
      '- Keep title concise and actionable',
    ].join('\n');

    final parsed = await _postAndParseJson(prompt);
    return DynamicQuestion.fromMap(parsed);
  }

  Future<AiAssessmentResponse> _generateFinalAssessment(
    AiAssessmentPayload payload,
  ) async {
    _ensureApiKey();

    final prompt = [
      'You are RoboDoc AI. Provide non-diagnostic triage style summary.',
      'Use static answers (1-4) and dynamic answers (5-7).',
      '',
      'Assessment payload:',
      jsonEncode(payload.toJson()),
      '',
      'Return only valid JSON with keys:',
      '{"possibleIndication": string, "summary": string, "confidence": number, "icdCode": string, "riskLevel": "LOW"|"MOD"|"HIGH", "riskSummary": string, "suggestions": [string]}',
      'Rules:',
      '- suggestions must include 3 short actionable items.',
    ].join('\n');

    final parsed = await _postAndParseJson(prompt);
    return AiAssessmentResponse.fromMap(parsed);
  }

  void _ensureApiKey() {
    if (kOpenAiApiKey.isEmpty ||
        kOpenAiApiKey == 'PASTE_YOUR_OPENAI_API_KEY_HERE') {
      throw Exception(
        'Set your API key in lib/secrets/openai_api_key.local.dart first.',
      );
    }
  }

  Future<Map<String, dynamic>> _postAndParseJson(String prompt) async {
    late final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Authorization': 'Bearer $kOpenAiApiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'gpt-4o-mini',
              'response_format': {'type': 'json_object'},
              'temperature': 0.3,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are a medical triage assistant for non-diagnostic guidance.',
                },
                {
                  'role': 'user',
                  'content': prompt,
                },
              ],
            }),
          )
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw Exception('AI request timed out. Please retry.');
    }

    if (response.statusCode >= 400) {
      throw Exception('OpenAI direct call failed: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = body['choices'] as List<dynamic>? ?? const [];
    if (choices.isEmpty) {
      throw Exception('OpenAI direct call returned no choices.');
    }

    final first = choices.first as Map<String, dynamic>;
    final message = first['message'] as Map<String, dynamic>? ?? const {};
    final content = (message['content'] as String?) ?? '';
    if (content.isEmpty) {
      throw Exception('OpenAI direct call returned empty content.');
    }

    return jsonDecode(content) as Map<String, dynamic>;
  }
}
