import 'dart:convert';

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
  Future<AiAssessmentResponse> generateAssessment(AiAssessmentPayload payload) async {
    return _generateDirect(payload);
  }

  Future<AiAssessmentResponse> _generateDirect(AiAssessmentPayload payload) async {
    if (kOpenAiApiKey.isEmpty ||
        kOpenAiApiKey == 'PASTE_YOUR_OPENAI_API_KEY_HERE') {
      throw Exception(
        'Set your API key in lib/secrets/openai_api_key.local.dart first.',
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
