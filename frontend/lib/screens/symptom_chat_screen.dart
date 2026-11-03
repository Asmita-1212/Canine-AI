
import 'package:flutter/material.dart';
import '../services/questionnaire_service.dart';

class SymptomChatScreen extends StatefulWidget {
  const SymptomChatScreen({super.key});

  @override
  State<SymptomChatScreen> createState() => _SymptomChatScreenState();
}

class _SymptomChatScreenState extends State<SymptomChatScreen> {
  static const Color primaryColor = Color(0xFF287C68);
  static const Color backgroundColor = Color(0xFFF5F8F6);

  final QuestionnaireService _service = QuestionnaireService();

  String selectedLanguage = 'English';
  bool isLoading = false;
  bool questionnaireStarted = false;

  String? errorMessage;
  String? sessionId;

  Map<String, dynamic>? currentQuestion;
  Map<String, dynamic>? prediction;

  final Set<String> selectedAnswers = {};
  final List<Map<String, dynamic>> history = [];

  String get languageCode {
    return {
      'English': 'en',
      'Hindi': 'hi',
      'Marathi': 'mr',
    }[selectedLanguage]!;
  }

  Future<void> _startQuestionnaire() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      selectedAnswers.clear();
      history.clear();
      prediction = null;
    });

    try {
      final response =
          await _service.startQuestionnaire(languageCode);

      setState(() {
        sessionId = response['session_id'];
        currentQuestion = response['question'];
        questionnaireStarted = true;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _selectAnswer(String value, bool isMulti) {
    setState(() {
      if (isMulti) {
        if (selectedAnswers.contains(value)) {
          selectedAnswers.remove(value);
        } else {
          selectedAnswers.add(value);
        }
      } else {
        selectedAnswers
          ..clear()
          ..add(value);
      }
    });
  }

  Future<void> _submitAnswer() async {
    if (selectedAnswers.isEmpty ||
        sessionId == null ||
        currentQuestion == null) {
      return;
    }

    final question = Map<String, dynamic>.from(currentQuestion!);
    final questionId = question['id'].toString();
    final isMulti = question['multi'] == true;

    final answerValues = selectedAnswers.toList();

    final answerLabels = (question['options'] as List)
        .where((option) =>
            answerValues.contains(option['value'].toString()))
        .map((option) => option['label'].toString())
        .toList();

    final dynamic answer =
        isMulti ? answerValues : answerValues.first;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _service.submitAnswer(
        sessionId: sessionId!,
        questionId: questionId,
        answer: answer,
      );

      setState(() {
        history.add({
          'questionId': questionId,
          'questionText': question['text'] ?? '',
          'answerValues': answerValues,
          'answerLabels': answerLabels,
        });

        selectedAnswers.clear();

        if (response['completed'] == true) {
          prediction = response['prediction'];
          currentQuestion = null;
        } else {
          currentQuestion = response['question'];
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Rebuild the backend session using previously submitted answers.
  Future<void> _goPrevious() async {
    if (history.isEmpty || isLoading) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final previousHistory =
          history.map((item) => Map<String, dynamic>.from(item)).toList();

      // Remove the most recently answered question.
      previousHistory.removeLast();

      // Start a fresh backend session.
      final startResponse =
          await _service.startQuestionnaire(languageCode);

      final newSessionId = startResponse['session_id'].toString();
      Map<String, dynamic>? nextQuestion =
          startResponse['question'] == null
              ? null
              : Map<String, dynamic>.from(startResponse['question']);

      // Replay all answers before the question we want to revisit.
      for (final item in previousHistory) {
        if (nextQuestion == null) {
          throw Exception('Could not rebuild the previous questions.');
        }

        final values =
            List<String>.from(item['answerValues'] as List);

        final bool isMulti = nextQuestion['multi'] == true;

        final dynamic answer =
            isMulti ? values : values.first;

        final response = await _service.submitAnswer(
          sessionId: newSessionId,
          questionId: item['questionId'].toString(),
          answer: answer,
        );

        if (response['completed'] == true) {
          throw Exception('The questionnaire ended unexpectedly.');
        }

        nextQuestion = response['question'] == null
            ? null
            : Map<String, dynamic>.from(response['question']);
      }

      setState(() {
        sessionId = newSessionId;
        history
          ..clear()
          ..addAll(previousHistory);
        currentQuestion = nextQuestion;
        prediction = null;
        selectedAnswers.clear();
        questionnaireStarted = true;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Could not go back: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 75, color: primaryColor),
            const SizedBox(height: 20),
            const Text(
              'CanineAI',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Let’s understand your dog’s skin symptoms.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Text(
              'Select your preferred language',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),
            ...['English', 'Hindi', 'Marathi'].map(
              (language) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _languageOption(language),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _startQuestionnaire,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Start Symptom Check'),
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(errorMessage!,
                  style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _languageOption(String language) {
    final isSelected = selectedLanguage == language;

    return InkWell(
      onTap: () {
        setState(() => selectedLanguage = language);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.10)
              : Colors.white,
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: primaryColor,
            ),
            const SizedBox(width: 12),
            Text(language),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    if (history.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Previous Questions & Answers',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          ...history.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final answers =
                List<String>.from(item['answerLabels'] as List);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${index + 1}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['questionText'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: primaryColor,
                        size: 17,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(answers.join(', ')),
                      ),
                    ],
                  ),
                  if (index != history.length - 1)
                    const Divider(height: 18),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCurrentQuestion() {
    final question = currentQuestion!;
    final options = question['options'] as List<dynamic>;
    final isMulti = question['multi'] == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${history.length + 1}',
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            question['text'] ?? '',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isMulti
                ? 'Select all that apply'
                : 'Select one option',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),

          ...options.map((option) {
            final value = option['value'].toString();
            final label = option['label'].toString();
            final isSelected = selectedAnswers.contains(value);

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: isLoading
                    ? null
                    : () => _selectAnswer(value, isMulti),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withOpacity(0.08)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isMulti
                            ? (isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank)
                            : (isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off),
                        color: primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(label)),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 18),
          Row(
            children: [
              if (history.isNotEmpty)
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : _goPrevious,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Previous'),
                  ),
                ),
              if (history.isNotEmpty) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading || selectedAnswers.isEmpty
                      ? null
                      : _submitAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Continue'),
                ),
              ),
            ],
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final disease = prediction?['disease'] ?? 'Unknown';
    final score = prediction?['confidence'];

    return Column(
      children: [
        _buildHistory(),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: primaryColor,
                size: 65,
              ),
              const SizedBox(height: 16),
              const Text(
                'Symptom Check Completed',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text('Predicted condition'),
              const SizedBox(height: 8),
              Text(
                disease.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (score != null) ...[
                const SizedBox(height: 10),
                Text('Model score: $score'),
              ],
              const SizedBox(height: 16),
              Text(
                prediction?['message'] ??
                    'Veterinary confirmation is recommended.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : _goPrevious,
                      child: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _startQuestionnaire,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Start Again'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'CanineAI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: !questionnaireStarted
              ? _buildWelcomeScreen()
              : prediction != null
                  ? SingleChildScrollView(
                      child: _buildResultScreen(),
                    )
                  : currentQuestion != null
                      ? SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHistory(),
                              if (history.isNotEmpty)
                                const SizedBox(height: 16),
                              _buildCurrentQuestion(),
                            ],
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
        ),
      ),
    );
  }
}
