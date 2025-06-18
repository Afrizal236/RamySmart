import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'essay_model.dart';
import 'course_manager.dart';

class EssayAssignmentScreen extends StatefulWidget {
  final EssayAssignment assignment;
  final Function(String, String, String) onSaveAnswer; // Function to save answers
  final VoidCallback onSubmit; // Function to submit the entire assignment

  const EssayAssignmentScreen({
    Key? key,
    required this.assignment,
    required this.onSaveAnswer,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<EssayAssignmentScreen> createState() => _EssayAssignmentScreenState();
}

class _EssayAssignmentScreenState extends State<EssayAssignmentScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  late List<TextEditingController> _textControllers;
  late Timer _timer;
  int _remainingTimeInSeconds = 0;
  bool _isExpanded = true; // Toggle for instruction panel

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Initialize text controllers for each question
    _textControllers = List.generate(
      widget.assignment.questions.length,
          (index) => TextEditingController(
        text: widget.assignment.questions[index].userAnswer ?? '',
      ),
    );

    // Set remaining time
    _remainingTimeInSeconds = widget.assignment.getRemainingTimeInSeconds();
    if (_remainingTimeInSeconds <= 0) {
      _remainingTimeInSeconds = widget.assignment.duration * 60; // Fallback to assignment duration
    }

    // Start the timer
    _startTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _textControllers) {
      controller.dispose();
    }
    _timer.cancel();
    super.dispose();
  }

  // Start countdown timer
  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (_remainingTimeInSeconds > 0) {
          setState(() {
            _remainingTimeInSeconds--;
          });
        } else {
          _timer.cancel();
          _showTimeUpDialog();
        }
      },
    );
  }

  // Format seconds to HH:MM:SS
  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Show dialog when time is up
  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Waktu Habis'),
          content: const Text(
            'Waktu pengerjaan telah habis. Jawaban Anda akan otomatis disimpan dan dikirimkan.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitAssignment();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Count words in text
  int _countWords(String text) {
    if (text.isEmpty) return 0;
    return text.split(' ').where((word) => word.trim().isNotEmpty).length;
  }

  // Save the current answer
  void _saveCurrentAnswer() {
    final currentQuestion = widget.assignment.questions[_currentPage];
    final text = _textControllers[_currentPage].text;
    widget.onSaveAnswer(widget.assignment.id, currentQuestion.id, text);
  }

  // Submit the entire assignment
  void _submitAssignment() {
    // Save all answers first
    for (int i = 0; i < widget.assignment.questions.length; i++) {
      final question = widget.assignment.questions[i];
      final text = _textControllers[i].text;
      widget.onSaveAnswer(widget.assignment.id, question.id, text);
    }
    widget.onSubmit();
    Navigator.of(context).pop(); // Return to previous screen
  }

  // Get category color based on category name
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Literasi Bahasa Indonesia':
        return Colors.red.shade100;
      case 'Literasi Bahasa Inggris':
        return Colors.blue.shade100;
      case 'Penalaran Umum':
        return Colors.green.shade100;
      case 'Penalaran Kuantitatif':
        return Colors.orange.shade100;
      case 'Penalaran Matematika':
        return Colors.purple.shade100;
      default:
        return Colors.blue.shade100;
    }
  }

  // Get category border color based on category name
  Color _getCategoryBorderColor(String category) {
    switch (category) {
      case 'Literasi Bahasa Indonesia':
        return Colors.red.shade300;
      case 'Literasi Bahasa Inggris':
        return Colors.blue.shade300;
      case 'Penalaran Umum':
        return Colors.green.shade300;
      case 'Penalaran Kuantitatif':
        return Colors.orange.shade300;
      case 'Penalaran Matematika':
        return Colors.purple.shade300;
      default:
        return Colors.blue.shade300;
    }
  }

  // Confirm submission dialog
  void _confirmSubmission() {
    // Check if all questions have been answered
    bool hasUnansweredQuestions = false;
    for (int i = 0; i < widget.assignment.questions.length; i++) {
      if (_textControllers[i].text.trim().isEmpty) {
        hasUnansweredQuestions = true;
        break;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Pengiriman'),
          content: hasUnansweredQuestions
              ? const Text(
              'Beberapa pertanyaan belum dijawab. Apakah Anda yakin ingin mengirimkan jawaban?')
              : const Text(
              'Apakah Anda yakin ingin mengirimkan semua jawaban? Anda tidak dapat mengubahnya lagi setelah dikirim.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitAssignment();
              },
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );
  }

  // Show confirmation dialog when trying to leave the page
  Future<bool> _onWillPop() async {
    _saveCurrentAnswer(); // Save current answer before showing dialog

    bool shouldPop = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Keluar dari Tugas?'),
          content: const Text(
            'Progres Anda akan disimpan, tetapi tugas tidak akan diselesaikan. Apakah Anda yakin ingin keluar?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Stay on this page
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Leave this page
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    ) ?? false;

    return shouldPop;
  }

  @override
  Widget build(BuildContext context) {
    final String categoryName = widget.assignment.questions.isNotEmpty
        ? widget.assignment.questions[0].category
        : 'Tugas Essay';

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.assignment.title),
              Text(
                categoryName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _formatTime(_remainingTimeInSeconds),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          backgroundColor: _getCategoryColor(categoryName),
        ),
        body: Column(
          children: [
            // Info panel at the top
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isExpanded ? 120 : 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getCategoryColor(categoryName),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getCategoryBorderColor(categoryName),
                  width: 1,
                ),
              ),
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Petunjuk Pengerjaan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    if (_isExpanded) ...[
                      const Text(
                        '• Jawablah semua pertanyaan dengan jelas dan terperinci',
                        style: TextStyle(fontSize: 14),
                      ),
                      const Text(
                        '• Perhatikan jumlah kata minimum dan maksimum untuk setiap pertanyaan',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Kategori: $categoryName',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      const Text(
                        '• Jawaban otomatis tersimpan setiap 1 detik setelah Anda mengetik',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'Pertanyaan ${_currentPage + 1} dari ${widget.assignment.questions.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / widget.assignment.questions.length,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCategoryBorderColor(categoryName),
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),

            // Main content - PageView for questions
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  // Save the answer when changing pages
                  _saveCurrentAnswer();
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: widget.assignment.questions.length,
                itemBuilder: (context, index) {
                  final question = widget.assignment.questions[index];
                  final wordCount = _countWords(_textControllers[index].text);
                  final isUnderMinimum = wordCount < question.minWords;
                  final isOverMaximum = wordCount > question.maxWords;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category label
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(question.category),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _getCategoryBorderColor(question.category),
                            ),
                          ),
                          child: Text(
                            question.category,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Question text
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            question.question,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Hint (if available)
                        if (question.hint != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                                    SizedBox(width: 4),
                                    Text(
                                      'Petunjuk:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  question.hint!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Word count info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Jumlah kata: $wordCount',
                              style: TextStyle(
                                fontSize: 14,
                                color: isUnderMinimum || isOverMaximum
                                    ? Colors.red
                                    : Colors.black87,
                                fontWeight: isUnderMinimum || isOverMaximum
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              'Min: ${question.minWords}, Maks: ${question.maxWords}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Answer textarea
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isUnderMinimum || isOverMaximum
                                  ? Colors.red
                                  : Colors.grey.shade300,
                              width: isUnderMinimum || isOverMaximum ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _textControllers[index],
                            maxLines: null,
                            minLines: 10,
                            onChanged: (text) {
                              // Update word count
                              setState(() {});

                              // Auto-save after 1 second of inactivity
                              Timer(const Duration(seconds: 1), () {
                                if (_textControllers[index].text == text) {
                                  widget.onSaveAnswer(
                                    widget.assignment.id,
                                    question.id,
                                    text,
                                  );
                                }
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Tulis jawaban Anda di sini...',
                              contentPadding: const EdgeInsets.all(16),
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.white,
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        // Warning message for word count
                        if (isUnderMinimum)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Jawaban Anda belum mencapai jumlah kata minimum (${question.minWords}).',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          )
                        else if (isOverMaximum)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Jawaban Anda melebihi jumlah kata maksimum (${question.maxWords}).',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  ElevatedButton.icon(
                    onPressed: _currentPage > 0
                        ? () {
                      _saveCurrentAnswer();
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Sebelumnya'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                    ),
                  ),

                  // Navigation dots - FIX HERE - Wrap with Flexible to prevent overflow
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          widget.assignment.questions.length,
                              (index) => GestureDetector(
                            onTap: () {
                              _saveCurrentAnswer();
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index
                                    ? _getCategoryBorderColor(categoryName)
                                    : (_textControllers[index].text.isNotEmpty
                                    ? _getCategoryColor(categoryName)
                                    : Colors.grey.shade300),
                                border: Border.all(
                                  color: _currentPage == index
                                      ? _getCategoryBorderColor(categoryName)
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Next/Submit button
                  _currentPage < widget.assignment.questions.length - 1
                      ? ElevatedButton.icon(
                    onPressed: () {
                      _saveCurrentAnswer();
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Selanjutnya'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getCategoryBorderColor(categoryName),
                      foregroundColor: Colors.white,
                    ),
                  )
                      : ElevatedButton.icon(
                    onPressed: _confirmSubmission,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Kirim Tugas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add a class to manage essay assignments
class EssayAssignmentManager {
  // Singleton instance
  static final EssayAssignmentManager _instance = EssayAssignmentManager._internal();

  // Factory constructor to return the singleton instance
  factory EssayAssignmentManager() {
    return _instance;
  }

  // Private constructor for singleton pattern
  EssayAssignmentManager._internal();

  // Store for assignments data
  final Map<String, EssayAssignment> _assignments = {};

  // Get all assignments
  List<EssayAssignment> get assignments => _assignments.values.toList();

  // Load assignments (in a real app, this might involve API calls or database access)
  Future<List<EssayAssignment>> loadAssignments() async {
    // Simply return current assignments
    return _assignments.values.toList();
  }

  // Load assignments for a specific course
  Future<List<EssayAssignment>> loadAssignmentsForCourse(String courseId) async {
    // Filter assignments by courseId
    return _assignments.values
        .where((assignment) => assignment.courseId == courseId)
        .toList();
  }

  Future<List<String>> getCategories() async {
    // Get all assignments
    final allAssignments = _assignments.values.toList();

    // Extract unique categories from assignment questions
    final Set<String> uniqueCategories = {};

    for (var assignment in allAssignments) {
      if (assignment.questions.isNotEmpty) {
        // Assuming all questions in an assignment have the same category
        final category = assignment.questions.first.category;
        if (category != null && category.isNotEmpty) {
          uniqueCategories.add(category);
        }
      }
    }

    // Convert set to list and sort alphabetically
    final categories = uniqueCategories.toList()..sort();

    return categories;
  }

  // Get categories for a specific course
  Future<List<String>> getCategoriesForCourse(String courseId) async {
    // Filter assignments by courseId first
    final courseAssignments = _assignments.values
        .where((assignment) => assignment.courseId == courseId)
        .toList();

    // Extract unique categories from these filtered assignments
    final Set<String> uniqueCategories = {};

    for (var assignment in courseAssignments) {
      if (assignment.questions.isNotEmpty) {
        final category = assignment.questions.first.category;
        if (category != null && category.isNotEmpty) {
          uniqueCategories.add(category);
        }
      }
    }

    // Convert set to list and sort alphabetically
    final categories = uniqueCategories.toList()..sort();

    return categories;
  }

  // Get assignments for a specific course
  List<EssayAssignment> getAssignmentsForCourse(String courseId) {
    return _assignments.values
        .where((assignment) => assignment.courseId == courseId)
        .toList();
  }

  // Get assignments by category
  List<EssayAssignment> getAssignmentsByCategory(String category) {
    return _assignments.values
        .where((assignment) =>
    assignment.questions.isNotEmpty &&
        assignment.questions.first.category == category)
        .toList();
  }

  // Get assignments by category for a specific course
  List<EssayAssignment> getAssignmentsByCategoryForCourse(String category, String courseId) {
    return _assignments.values
        .where((assignment) =>
    assignment.courseId == courseId &&
        assignment.questions.isNotEmpty &&
        assignment.questions.first.category == category)
        .toList();
  }

  // Get a specific assignment
  EssayAssignment? getAssignment(String id) {
    return _assignments[id];
  }

  // Add an assignment
  void addAssignment(EssayAssignment assignment) {
    _assignments[assignment.id] = assignment;
    print('Essay assignment ${assignment.id} added successfully');
  }

  // Update an assignment
  void updateAssignment(EssayAssignment assignment) {
    _assignments[assignment.id] = assignment;
  }

  // Save an answer for a specific question
  void saveAnswer(String assignmentId, String questionId, String answer) {
    final assignment = _assignments[assignmentId];
    if (assignment != null) {
      // Find and update the question
      final updatedQuestions = assignment.questions.map((q) {
        if (q.id == questionId) {
          return q.copyWith(userAnswer: answer);
        }
        return q;
      }).toList();

      // Update the assignment with the new questions
      _assignments[assignmentId] = assignment.copyWith(questions: updatedQuestions);
      print('Answer saved for question $questionId in assignment $assignmentId');
    }
  }

  // Submit an assignment
  void submitAssignment(String assignmentId) {
    final assignment = _assignments[assignmentId];
    if (assignment != null) {
      _assignments[assignmentId] = assignment.copyWith(isCompleted: true);

      // Update the corresponding regular assignment in CourseManager
      // Assuming there's a reference to CourseManager available
      final courseManager = CourseManager();
      courseManager.markAssignmentAsCompleted(assignmentId);

      print('Assignment $assignmentId submitted successfully');

      // Calculate and print statistics
      _printAssignmentStats(assignmentId);
    }
  }

  // Get sorted assignments by due date
  List<EssayAssignment> getAssignmentsSortedByDueDate() {
    final sortedList = List<EssayAssignment>.from(_assignments.values);
    sortedList.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return sortedList;
  }

  // Get sorted assignments by due date for a specific course
  List<EssayAssignment> getAssignmentsSortedByDueDateForCourse(String courseId) {
    final filteredList = _assignments.values
        .where((assignment) => assignment.courseId == courseId)
        .toList();
    filteredList.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return filteredList;
  }

  // Get upcoming assignments (due in the next 7 days)
  List<EssayAssignment> getUpcomingAssignments() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return _assignments.values
        .where((assignment) =>
    !assignment.isCompleted &&
        assignment.dueDate.isAfter(now) &&
        assignment.dueDate.isBefore(nextWeek))
        .toList();
  }

  // Get upcoming assignments for a specific course (due in the next 7 days)
  List<EssayAssignment> getUpcomingAssignmentsForCourse(String courseId) {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return _assignments.values
        .where((assignment) =>
    assignment.courseId == courseId &&
        !assignment.isCompleted &&
        assignment.dueDate.isAfter(now) &&
        assignment.dueDate.isBefore(nextWeek))
        .toList();
  }

  // Check if all questions in an assignment are answered
  bool isAssignmentComplete(String assignmentId) {
    final assignment = _assignments[assignmentId];
    if (assignment == null) return false;

    return assignment.questions.every((q) =>
    q.userAnswer != null &&
        q.userAnswer!.isNotEmpty &&
        q.isAnswerValid());
  }

  // Calculate word count statistics for an assignment
  Map<String, dynamic> getAssignmentStats(String assignmentId) {
    final assignment = _assignments[assignmentId];
    if (assignment == null) {
      return {
        'totalWords': 0,
        'answeredQuestions': 0,
        'totalQuestions': 0,
        'completionPercentage': 0.0,
        'averageWordsPerQuestion': 0.0,
      };
    }

    int totalWords = 0;
    int answeredQuestions = 0;

    for (var question in assignment.questions) {
      if (question.userAnswer != null && question.userAnswer!.isNotEmpty) {
        totalWords += question.wordCount;
        answeredQuestions++;
      }
    }

    return {
      'totalWords': totalWords,
      'answeredQuestions': answeredQuestions,
      'totalQuestions': assignment.questions.length,
      'completionPercentage': assignment.questions.isEmpty
          ? 0.0
          : (answeredQuestions / assignment.questions.length) * 100,
      'averageWordsPerQuestion': answeredQuestions == 0
          ? 0.0
          : totalWords / answeredQuestions,
    };
  }

  // Print assignment statistics to console (for debugging)
  void _printAssignmentStats(String assignmentId) {
    final stats = getAssignmentStats(assignmentId);
    print('Assignment $assignmentId Statistics:');
    print('Total Words: ${stats['totalWords']}');
    print('Answered Questions: ${stats['answeredQuestions']}/${stats['totalQuestions']}');
    print('Completion: ${stats['completionPercentage'].toStringAsFixed(1)}%');
    print('Avg Words per Question: ${stats['averageWordsPerQuestion'].toStringAsFixed(1)}');
  }

  // Clear all assignments (for testing)
  void clearAssignments() {
    _assignments.clear();
  }

  // Generate sample assignments (for testing)
  void generateSampleAssignments() {
    final now = DateTime.now();

    // Define some categories
    final categories = [
      'Literasi Bahasa Indonesia',
      'Literasi Bahasa Inggris',
      'Penalaran Umum',
      'Penalaran Kuantitatif',
      'Penalaran Matematika'
    ];

    // Create sample assignments for each category
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      final assignmentId = 'essay_sample_${i + 1}';

      final assignment = EssayAssignment.withCategoryQuestions(
        id: assignmentId,
        title: 'Essay Assignment: $category',
        courseId: 'course_sample',
        courseName: 'Sample Course',
        dueDate: now.add(Duration(days: i + 1)),
        duration: 60, // 60 minutes
        category: category,
      );

      addAssignment(assignment);
    }
  }
}

// Widget to display a list of available essay assignments
class EssayAssignmentListScreen extends StatefulWidget {
  const EssayAssignmentListScreen({Key? key}) : super(key: key);

  @override
  State<EssayAssignmentListScreen> createState() => _EssayAssignmentListScreenState();
}

class _EssayAssignmentListScreenState extends State<EssayAssignmentListScreen> with SingleTickerProviderStateMixin {
  final EssayAssignmentManager _manager = EssayAssignmentManager();
  List<EssayAssignment> _assignments = [];
  List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    // Load all available categories
    final categories = await _manager.getCategories();

    setState(() {
      _categories = categories;
      _isLoading = false;
    });

    // Initialize tab controller after we know how many categories we have
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Load assignments for the first category
    if (_categories.isNotEmpty) {
      _loadAssignmentsForCategory(_categories.first);
    }
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      return;
    }
    // Load assignments for the selected category
    final selectedCategory = _categories[_tabController.index];
    _loadAssignmentsForCategory(selectedCategory);
  }

  Future<void> _loadAssignmentsForCategory(String category) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = category;
    });

    // Load assignments for this category
    final assignments = await _manager.getAssignmentsByCategory(category);

    setState(() {
      _assignments = assignments;
      _isLoading = false;
    });
  }

  // Handle saving answer
  void _handleSaveAnswer(String assignmentId, String questionId, String answer) {
    _manager.saveAnswer(assignmentId, questionId, answer);
  }

  // Handle assignment submission
  void _handleSubmitAssignment(String assignmentId) {
    _manager.submitAssignment(assignmentId);

    // Refresh the list to show updated status
    if (_selectedCategory != null) {
      _loadAssignmentsForCategory(_selectedCategory!);
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tugas berhasil dikumpulkan!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Essay Assignments'),
        bottom: _categories.isEmpty
            ? null
            : TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories
              .map((category) => Tab(
            text: category,
          ))
              .toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
          ? const Center(
        child: Text('Tidak ada kategori tugas essay yang tersedia.'),
      )
          : TabBarView(
        controller: _tabController,
        children: _categories.map((category) {
          return _buildCategoryAssignmentList();
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedCategory != null) {
            _loadAssignmentsForCategory(_selectedCategory!);
          } else {
            _loadCategories();
          }
        },
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildCategoryAssignmentList() {
    if (_assignments.isEmpty) {
      return const Center(
        child: Text('Tidak ada tugas essay untuk kategori ini.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _assignments.length,
      itemBuilder: (context, index) {
        final assignment = _assignments[index];
        final isOverdue = assignment.dueDate.isBefore(DateTime.now());

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: assignment.isCompleted || isOverdue
                ? null
                : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EssayAssignmentScreen(
                    assignment: assignment,
                    onSaveAnswer: _handleSaveAnswer,
                    onSubmit: () {
                      _handleSubmitAssignment(assignment.id);
                    },
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          assignment.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: assignment.isCompleted
                              ? Colors.green.shade100
                              : isOverdue
                              ? Colors.red.shade100
                              : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          assignment.isCompleted
                              ? 'Selesai'
                              : isOverdue
                              ? 'Terlambat'
                              : 'Aktif',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: assignment.isCompleted
                                ? Colors.green.shade800
                                : isOverdue
                                ? Colors.red.shade800
                                : Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    assignment.courseName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Durasi: ${assignment.duration} menit',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.fact_check,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${assignment.questions.length} Pertanyaan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        size: 16,
                        color: isOverdue ? Colors.red : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tenggat: ${DateFormat('dd MMM yyyy, HH:mm').format(assignment.dueDate)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isOverdue ? Colors.red : Colors.grey.shade600,
                          fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Kategori: ${assignment.questions.isNotEmpty ? assignment.questions.first.category : ""}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!assignment.isCompleted && !isOverdue)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EssayAssignmentScreen(
                              assignment: assignment,
                              onSaveAnswer: _handleSaveAnswer,
                              onSubmit: () {
                                _handleSubmitAssignment(assignment.id);
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      child: const Text('Mulai Mengerjakan'),
                    ),
                  if (assignment.isCompleted)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tugas ini telah Anda selesaikan.',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isOverdue && !assignment.isCompleted)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tenggat waktu telah terlewat. Anda tidak dapat mengerjakan tugas ini.',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Detailed screen for viewing completed assignments
class CompletedAssignmentDetailScreen extends StatelessWidget {
  final EssayAssignment assignment;

  const CompletedAssignmentDetailScreen({
    Key? key,
    required this.assignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(assignment.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Assignment info card
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.courseName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.event, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Dikumpulkan: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.fact_check, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${assignment.questions.length} Pertanyaan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Kategori: ${_getCategoryName()}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade800, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Tugas Selesai',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Assignment summary
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Jawaban',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildAnswerSummary(),
                ],
              ),
            ),
          ),

          // Questions and answers
          ...assignment.questions.map((question) => _buildQuestionCard(question)).toList(),
        ],
      ),
    );
  }

  String _getCategoryName() {
    // All questions should be from the same category in this assignment
    return assignment.questions.isNotEmpty
        ? assignment.questions.first.category
        : 'Tidak ada kategori';
  }

  Widget _buildAnswerSummary() {
    int answeredQuestions = 0;
    int validAnswers = 0;
    int totalWords = 0;

    for (var question in assignment.questions) {
      if (question.userAnswer != null && question.userAnswer!.isNotEmpty) {
        answeredQuestions++;
        if (question.isAnswerValid()) {
          validAnswers++;
        }
        totalWords += question.wordCount;
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Soal Dijawab:'),
            Text('$answeredQuestions dari ${assignment.questions.length}'),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Jawaban Valid:'),
            Text('$validAnswers dari ${assignment.questions.length}'),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total Kata:'),
            Text('$totalWords kata'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: assignment.questions.isEmpty
              ? 0.0
              : validAnswers / assignment.questions.length,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
              validAnswers == assignment.questions.length
                  ? Colors.green
                  : Colors.orange
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(EssayQuestion question) {
    final wordCount = question.wordCount;
    final isAnswerValid = question.isAnswerValid();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question number badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade800,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Soal ${assignment.questions.indexOf(question) + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    question.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Question text
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            // Question hint if provided
            if (question.hint != null && question.hint!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.blue.shade700, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Hint:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        question.hint!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Answer display
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Jawaban:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          isAnswerValid ? Icons.check_circle : Icons.warning,
                          size: 16,
                          color: isAnswerValid ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$wordCount kata',
                          style: TextStyle(
                            fontSize: 14,
                            color: isAnswerValid ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(Min: ${question.minWords}, Maks: ${question.maxWords})',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    question.userAnswer ?? 'Tidak ada jawaban',
                    style: TextStyle(
                      fontSize: 14,
                      color: question.userAnswer == null || question.userAnswer!.isEmpty
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                ),
                if (!isAnswerValid && wordCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      wordCount < question.minWords
                          ? 'Jawaban kurang dari jumlah kata minimum (${question.minWords}).'
                          : 'Jawaban melebihi jumlah kata maksimum (${question.maxWords}).',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Main app entry point
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Essay Assignment App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const EssayAssignmentListScreen(),
    );
  }
}