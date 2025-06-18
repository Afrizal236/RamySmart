import 'package:flutter/material.dart';
import 'dart:async';

import 'assignment_model.dart';

class McqAssignmentPage extends StatefulWidget {
  final Assignment assignment;

  const McqAssignmentPage({
    Key? key,
    required this.assignment,
  }) : super(key: key);

  @override
  State<McqAssignmentPage> createState() => _McqAssignmentPageState();
}

class _McqAssignmentPageState extends State<McqAssignmentPage> {
  late List<McqQuestion> _questions;
  int _currentQuestionIndex = 0;
  bool _isSubmitting = false;
  bool _isAssignmentSubmitted = false;
  Timer? _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _questions = widget.assignment.questions;

    // Calculate remaining time
    final now = DateTime.now();
    if (widget.assignment.dueDate.isAfter(now)) {
      _remainingTime = widget.assignment.dueDate.difference(now);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        } else {
          _timer?.cancel();

          // Auto-submit when time runs out
          if (!_isAssignmentSubmitted) {
            _submitAssignment();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _questions[_currentQuestionIndex].selectedAnswerIndex = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      setState(() {
        _currentQuestionIndex = index;
      });
    }
  }

  Future<void> _submitAssignment() async {
    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Calculate score
    int correctAnswers = 0;
    int totalQuestions = _questions.length;

    for (var question in _questions) {
      if (question.isAnswered && question.isCorrect) {
        correctAnswers++;
      }
    }

    // Show result dialog
    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isAssignmentSubmitted = true;
      });

      _showResultDialog(correctAnswers, totalQuestions);
    }
  }

  void _showResultDialog(int correctAnswers, int totalQuestions) {
    final score = (correctAnswers / totalQuestions) * 100;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Tugas Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Jawaban Benar: $correctAnswers / $totalQuestions'),
            const SizedBox(height: 8),
            Text(
              'Skor: ${score.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: score >= 70 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              score >= 70
                  ? 'Selamat! Anda lulus tugas ini.'
                  : 'Anda perlu belajar lebih giat lagi.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true); // Return to previous screen with completion status
            },
            child: const Text('Selesai'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentQuestionIndex = 0;
              });
            },
            child: const Text('Lihat Jawaban'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;
    final answeredQuestions = _questions.where((q) => q.isAnswered).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assignment.title),
        centerTitle: true,
        actions: [
          if (!_isAssignmentSubmitted)
            IconButton(
              icon: const Icon(Icons.school),
              onPressed: () {
                _showQuestionNavigator();
              },
              tooltip: 'Navigasi Soal',
            ),
        ],
      ),
      body: _isSubmitting
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Mengirimkan jawaban...', style: TextStyle(fontSize: 16)),
          ],
        ),
      )
          : SafeArea(
        child: Column(
          children: [
            // Timer and progress info
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mata Kuliah: ${widget.assignment.courseName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (!_isAssignmentSubmitted && _remainingTime.inSeconds > 0)
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(_remainingTime),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _remainingTime.inMinutes < 5 ? Colors.red : Colors.black,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Progress indicator
            LinearProgressIndicator(
              value: answeredQuestions / _questions.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Soal terjawab: $answeredQuestions dari ${_questions.length}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),

            // Question and answers
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question number and text
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Soal ${_currentQuestionIndex + 1} dari ${_questions.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentQuestion.question,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Answer options
                    ...List.generate(
                      currentQuestion.options.length,
                          (index) {
                        final option = currentQuestion.options[index];
                        final isSelected = currentQuestion.selectedAnswerIndex == index;
                        final isCorrectAnswer = _isAssignmentSubmitted && index == currentQuestion.correctAnswerIndex;
                        final isWrongAnswer = _isAssignmentSubmitted && isSelected && !currentQuestion.isCorrect;

                        Color? cardColor;
                        if (_isAssignmentSubmitted) {
                          if (isCorrectAnswer) {
                            cardColor = Colors.green.shade100;
                          } else if (isWrongAnswer) {
                            cardColor = Colors.red.shade100;
                          } else {
                            cardColor = Colors.grey.shade100;
                          }
                        } else {
                          cardColor = isSelected ? Colors.blue.shade100 : Colors.grey.shade100;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: _isAssignmentSubmitted ? null : () => _selectAnswer(index),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start, // Align to top for better text wrapping
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? Colors.blue : Colors.white,
                                      border: Border.all(
                                        color: isSelected ? Colors.blue : Colors.grey,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + index), // A, B, C, D, etc.
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (_isAssignmentSubmitted)
                                    Icon(
                                      isCorrectAnswer
                                          ? Icons.check_circle
                                          : (isWrongAnswer ? Icons.cancel : null),
                                      color: isCorrectAnswer ? Colors.green : Colors.red,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Show explanation after submission
                    if (_isAssignmentSubmitted)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Penjelasan:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Jawaban benar adalah opsi ${String.fromCharCode(65 + currentQuestion.correctAnswerIndex)} '
                                  'karena sesuai dengan konsep yang dipelajari pada mata kuliah ini.',
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Sebelumnya'),
                  ),
                  if (!_isAssignmentSubmitted)
                    OutlinedButton(
                      onPressed: () => _showQuestionNavigator(),
                      child: Text('${_currentQuestionIndex + 1}/${_questions.length}'),
                    ),
                  if (isLastQuestion && !_isAssignmentSubmitted)
                    ElevatedButton.icon(
                      onPressed: _submitAssignment,
                      icon: const Icon(Icons.check),
                      label: const Text('Selesai'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    TextButton.icon(
                      onPressed: isLastQuestion ? null : _nextQuestion,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Selanjutnya'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: !_isAssignmentSubmitted ? BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: _submitAssignment,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Kumpulkan Tugas'),
          ),
        ),
      ) : null,
    );
  }

  void _showQuestionNavigator() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Navigasi Soal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  final isCurrentQuestion = index == _currentQuestionIndex;
                  final isAnswered = question.isAnswered;

                  Color backgroundColor;
                  Color textColor;

                  if (isCurrentQuestion) {
                    backgroundColor = Colors.blue;
                    textColor = Colors.white;
                  } else if (isAnswered) {
                    backgroundColor = Colors.green.shade100;
                    textColor = Colors.black;
                  } else {
                    backgroundColor = Colors.grey.shade200;
                    textColor = Colors.black;
                  }

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _goToQuestion(index);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: isCurrentQuestion
                            ? Border.all(color: Colors.blue.shade800, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(Colors.grey.shade200, 'Belum Dijawab'),
                _buildLegendItem(Colors.green.shade100, 'Sudah Dijawab'),
                _buildLegendItem(Colors.blue, 'Soal Aktif'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// Contoh penggunaan:
class McqAssignmentDemo extends StatelessWidget {
  const McqAssignmentDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Contoh tugas dengan soal multiple choice
    final demoAssignment = Assignment(
      id: 'assign1',
      title: 'Quiz Bahasa Indonesia',
      courseId: 'course1',
      courseName: 'Bahasa Indonesia',
      dueDate: DateTime.now().add(const Duration(hours: 1)),
      questions: QuestionGenerator.generateQuestionsForCourse('course1', 'Bahasa Indonesia'),
    );

    return MaterialApp(
      title: 'MCQ Assignment Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: McqAssignmentPage(assignment: demoAssignment),
    );
  }
}