import 'package:flutter/material.dart';

class AssessmentResult {
  final String headline;
  final String possibleIndication;
  final String summary;
  final String icdCode;
  final int confidence; // 0-100
  final String riskLevel; // LOW | MOD | HIGH
  final String riskSummary;
  final int temperatureF;
  final int heartRate;
  final int spo2;
  final List<ResultSuggestion> suggestions;

  const AssessmentResult({
    required this.headline,
    required this.possibleIndication,
    required this.summary,
    required this.icdCode,
    required this.confidence,
    required this.riskLevel,
    required this.riskSummary,
    required this.temperatureF,
    required this.heartRate,
    required this.spo2,
    required this.suggestions,
  });
}

class ResultSuggestion {
  final IconData icon;
  final String title;
  final String description;

  const ResultSuggestion({
    required this.icon,
    required this.title,
    required this.description,
  });
}

