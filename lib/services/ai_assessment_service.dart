import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;

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
      };
}

class AiAssessmentResponse {
  final String possibleIndication;
  final String summary;
  final int confidence;
  final String icdCode;
  final String riskLevel;

  const AiAssessmentResponse({
    required this.possibleIndication,
    required this.summary,
    required this.confidence,
    required this.icdCode,
    required this.riskLevel,
  });

  factory AiAssessmentResponse.fromMap(Map<dynamic, dynamic> map) {
    final confidenceValue = (map['confidence'] as num?)?.toInt() ?? 65;
    return AiAssessmentResponse(
      possibleIndication:
          (map['possibleIndication'] as String?) ?? 'General symptom review',
      summary: (map['summary'] as String?) ??
          'Please consult a clinician for full evaluation.',
      confidence: confidenceValue.clamp(0, 100),
      icdCode: (map['icdCode'] as String?) ?? 'ICD-10: R69',
      riskLevel: (map['riskLevel'] as String?) ?? 'MOD',
    );
  }
}

class AiAssessmentService {
  AiAssessmentService({required FirebaseFunctions functions})
      : _functions = functions;

  final FirebaseFunctions _functions;
  static const bool _useDirectOpenAi =
      bool.fromEnvironment('USE_DIRECT_OPENAI', defaultValue: false);
  static const String _openAiApiKey =
      String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');

  Future<AiAssessmentResponse> generateAssessment(AiAssessmentPayload payload) async {
    if (_useDirectOpenAi) {
      return _generateDirect(payload);
    }

    final callable = _functions.httpsCallable('generateAssessmentReportClean');
    final result = await callable.call<Map<String, dynamic>>(payload.toJson());
    final data = result.data;
    return AiAssessmentResponse.fromMap(data);
  }

  Future<AiAssessmentResponse> _generateDirect(AiAssessmentPayload payload) async {
    if (_openAiApiKey.isEmpty) {
      throw Exception(
        'Direct OpenAI mode enabled but OPENAI_API_KEY dart-define is missing.',
      );
    }

    final prompt = [
      'You are RoboDoc AI. Return concise triage guidance, not a diagnosis.',
      'Always include a safety note to seek urgent care for severe symptoms.',
      '',
      'Patient profile:',
      '- age: ${payload.age}',
      '- sexAtBirth: ${payload.sexAtBirth}',
      '- symptoms: ${payload.symptoms}',
      '- quickAdds: ${payload.quickAdds.join(', ')}',
      '- durationDays: ${payload.durationDays}',
      '- painIntensity(0-10): ${payload.painIntensity}',
      '- physicalMarkers: ${payload.physicalMarkers.join(', ')}',
      '- travelInternational(last14days): ${payload.travelInternational}',
      '- takingAntibiotics: ${payload.takingAntibiotics}',
      '',
      'Return only valid JSON with keys:',
      '{"possibleIndication": string, "summary": string, "confidence": number, "icdCode": string, "riskLevel": "LOW"|"MOD"|"HIGH"}',
    ].join('\n');

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_openAiApiKey',
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
    );

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

    final parsed = jsonDecode(content) as Map<String, dynamic>;
    return AiAssessmentResponse.fromMap(parsed);
  }
}
