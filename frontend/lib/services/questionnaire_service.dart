import 'dart:convert';

import 'package:http/http.dart' as http;

class QuestionnaireService {
  static const String baseUrl = 'http://127.0.0.1:8001';

  // Start a new questionnaire
  Future<Map<String, dynamic>> startQuestionnaire(String language) async {
    final uri = Uri.parse('$baseUrl/questionnaire/start?language=$language');

    final response = await http.post(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Failed to start questionnaire: ${response.body}');
  }

  // Submit an answer and receive the next question
  Future<Map<String, dynamic>> submitAnswer({
    required String sessionId,
    required String questionId,
    required dynamic answer,
  }) async {
    final uri = Uri.parse('$baseUrl/questionnaire/$sessionId/answer');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'question_id': questionId, 'answer': answer}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Failed to submit answer: ${response.body}');
  }
}
