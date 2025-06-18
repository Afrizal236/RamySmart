import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramysmart/screens/Home/widget/featured_courses.dart';
import 'assignment_model.dart';
import 'essay_model.dart';
import 'essay_assignment_screen.dart';

class CourseManager {
  // Singleton instance
  static final CourseManager _instance = CourseManager._internal();

  // Static set to track purchased course IDs
  static final Set<String> _purchasedCourseIds = {};

  // Factory constructor to return the singleton instance
  factory CourseManager() {
    return _instance;
  }

  // Private constructor for singleton pattern
  CourseManager._internal();

  // Static method to add a purchased course by ID
  static void markAsPurchasedStatically(String courseId) {
    _purchasedCourseIds.add(courseId);
  }

  // Static method to check if a course is purchased by ID
  static bool isPurchasedStatically(String courseId) {
    return _purchasedCourseIds.contains(courseId);
  }

  // Static method to get list of purchased courses
  static List<Course> getPurchasedCoursesStatically(List<Course> allCourses) {
    return allCourses.where((course) => isPurchasedStatically(course.id)).toList();
  }

  // Static method to reset purchases (for testing)
  static void resetPurchases() {
    _purchasedCourseIds.clear();
  }

  // List to store purchased courses
  final List<Course> _purchasedCourses = [];

  // List of assignments
  final List<Assignment> _assignments = [];

  // Getters
  List<Course> get purchasedCourses => List.unmodifiable(_purchasedCourses);
  List<Assignment> get assignments => _assignments;

  // Add a course to purchased courses if not already purchased
  void addCourse(Course course) {
    if (!_isCoursePurchased(course.id)) {
      _purchasedCourses.add(course);
      markAsPurchasedStatically(course.id); // Update static set as well
      // Generate assignments for this course
      _generateAssignmentsForCourse(course);
    }
  }

  // Add multiple courses at once
  void addCourses(List<Course> courses) {
    for (final course in courses) {
      addCourse(course);
    }
  }

  // Internal method to check if a course is purchased
  bool _isCoursePurchased(String courseId) {
    return _purchasedCourses.any((course) => course.id == courseId);
  }

  // Get all purchased courses
  List<Course> getPurchasedCourses() {
    return List.unmodifiable(_purchasedCourses);
  }

  // Purchase/enroll in a course (alias for addCourse for clarity)
  void purchaseCourse(Course course) {
    addCourse(course);
  }

  // For demo purposes, add some sample courses as purchased
  void addDemoPurchasedCourses() {
    // Add the first course as a demo purchase if list is empty
    if (_purchasedCourses.isEmpty && featuredCoursesList.isNotEmpty) {
      addCourse(featuredCoursesList[0]); // Literasi Bahasa Indonesia
    }
  }

  // Helper method to determine which categories are relevant for a course
  List<String> _getRelevantCategoriesForCourse(String courseTitle) {
    final List<String> relevantCategories = [];

    // Assign categories based on course title - matching the MCQ question generator categories
    if (courseTitle.contains('Bahasa Indonesia Tingkat Lanjut')) {
      relevantCategories.add('Literasi Bahasa Indonesia Lanjut');
      relevantCategories.add('Literasi Bahasa Indonesia');
    } else if (courseTitle.contains('Bahasa Indonesia')) {
      relevantCategories.add('Literasi Bahasa Indonesia');
    }

    if (courseTitle.contains('Bahasa Inggris Profesional')) {
      relevantCategories.add('Professional English Literacy');
      relevantCategories.add('Literasi Bahasa Inggris');
    } else if (courseTitle.contains('Bahasa Inggris') || courseTitle.contains('English')) {
      relevantCategories.add('Literasi Bahasa Inggris');
    }

    if (courseTitle.contains('Matematika Komprehensif')) {
      relevantCategories.add('Penalaran Matematika Komprehensif');
      relevantCategories.add('Penalaran Matematika');
    } else if (courseTitle.contains('Matematika') || courseTitle.contains('Math') ||
        courseTitle.contains('Aljabar') || courseTitle.contains('Geometri')) {
      relevantCategories.add('Penalaran Matematika');
    }

    if (courseTitle.contains('Kuantitatif Analitis')) {
      relevantCategories.add('Penalaran Kuantitatif Analitis');
      relevantCategories.add('Penalaran Kuantitatif');
    } else if (courseTitle.contains('Kuantitatif') || courseTitle.contains('Statistik') ||
        courseTitle.contains('Data')) {
      relevantCategories.add('Penalaran Kuantitatif');
    }

    if (courseTitle.contains('Logika Kritis')) {
      relevantCategories.add('Penalaran Logika Kritis');
      relevantCategories.add('Penalaran Umum');
    } else if (courseTitle.contains('Umum') || courseTitle.contains('Penalaran Umum') ||
        courseTitle.contains('Critical Thinking')) {
      relevantCategories.add('Penalaran Umum');
    }

    // If no specific category matches, add General Reasoning as default
    if (relevantCategories.isEmpty) {
      relevantCategories.add('Penalaran Umum');
    }

    return relevantCategories;
  }

  // Generate assignments for a specific course
  void _generateAssignmentsForCourse(Course course) {
    // Create a meaningful title based on the course
    String assignmentPrefix = '';
    if (course.title.contains('Bahasa Indonesia Tingkat Lanjut')) {
      assignmentPrefix = 'Latihan Soal Bahasa Indonesia Lanjut';
    } else if (course.title.contains('Bahasa Indonesia')) {
      assignmentPrefix = 'Latihan Soal Bahasa Indonesia';
    } else if (course.title.contains('Bahasa Inggris Profesional')) {
      assignmentPrefix = 'Professional English Practice';
    } else if (course.title.contains('Bahasa Inggris')) {
      assignmentPrefix = 'English Practice';
    } else if (course.title.contains('Matematika Komprehensif')) {
      assignmentPrefix = 'Kuis Matematika Komprehensif';
    } else if (course.title.contains('Matematika')) {
      assignmentPrefix = 'Kuis Matematika';
    } else if (course.title.contains('Kuantitatif Analitis')) {
      assignmentPrefix = 'Latihan Penalaran Kuantitatif Analitis';
    } else if (course.title.contains('Kuantitatif')) {
      assignmentPrefix = 'Latihan Penalaran Kuantitatif';
    } else if (course.title.contains('Logika Kritis')) {
      assignmentPrefix = 'Latihan Logika Kritis';
    } else if (course.title.contains('Umum')) {
      assignmentPrefix = 'Latihan Penalaran Umum';
    } else {
      assignmentPrefix = 'Latihan Soal';
    }

    // Generate MCQ assignment for the course
    final mcqAssignment = Assignment(
      id: 'assign_${course.id}_mcq',
      title: '$assignmentPrefix - Multiple Choice',
      courseId: course.id,
      courseName: course.title,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      questions: QuestionGenerator.generateQuestionsForCourse(course.id, course.title),
      isCompleted: false,
    );
    _assignments.add(mcqAssignment);

    // Get only relevant categories for this course
    final List<String> relevantCategories = _getRelevantCategoriesForCourse(course.title);

    // Map of all possible categories
    final allCategories = {
      'Literasi Bahasa Indonesia': 'ind',
      'Literasi Bahasa Inggris': 'eng',
      'Penalaran Umum': 'reas',
      'Penalaran Kuantitatif': 'quant',
      'Penalaran Matematika': 'math'
    };

    // Filter to only include relevant categories
    final filteredCategories = Map.fromEntries(
        allCategories.entries.where((entry) => relevantCategories.contains(entry.key))
    );

    // Create essay assignments only for relevant categories
    filteredCategories.forEach((categoryName, categoryPrefix) {
      // Create a unique ID for this category assignment
      final assignmentId = 'assign_${course.id}_${categoryPrefix}';

      // Create essay assignment using the withCategoryQuestions factory
      final essayAssignment = EssayAssignment.withCategoryQuestions(
        id: assignmentId,
        title: '$assignmentPrefix - $categoryName',
        courseId: course.id,
        courseName: course.title,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        duration: 90, // Default duration in minutes
        category: categoryName,
      );

      // Register this essay assignment with the EssayAssignmentManager
      EssayAssignmentManager().addAssignment(essayAssignment);

      // Also add a reference to our regular assignments list
      final regularAssignment = Assignment(
        id: assignmentId,
        title: '$assignmentPrefix - $categoryName',
        courseId: course.id,
        courseName: course.title,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        isCompleted: false,
      );
      _assignments.add(regularAssignment);
    });
  }

  // Get assignments for a specific course
  List<Assignment> getAssignmentsForCourse(String courseId) {
    return _assignments.where((assignment) => assignment.courseId == courseId).toList();
  }

  // Get all assignments sorted by due date
  List<Assignment> getAssignmentsSortedByDueDate() {
    final sortedList = List<Assignment>.from(_assignments);
    sortedList.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return sortedList;
  }

  // Get upcoming assignments (due in the next 7 days)
  List<Assignment> getUpcomingAssignments() {
    final now = DateTime.now();
    final nextWeek = DateTime(now.year, now.month, now.day + 7);

    return _assignments.where((assignment) =>
    !assignment.isCompleted &&
        assignment.dueDate.isAfter(now) &&
        assignment.dueDate.isBefore(nextWeek)).toList();
  }

  // Mark an assignment as completed
  void markAssignmentAsCompleted(String assignmentId) {
    final index = _assignments.indexWhere((assignment) => assignment.id == assignmentId);
    if (index != -1) {
      final updatedAssignment = _assignments[index].copyWith(isCompleted: true);
      _assignments[index] = updatedAssignment;
    }
  }

  // Save a user's answer to an MCQ question
  void saveUserAnswer(String assignmentId, String questionId, int selectedAnswerIndex) {
    final assignmentIndex = _assignments.indexWhere((a) => a.id == assignmentId);
    if (assignmentIndex != -1) {
      final assignment = _assignments[assignmentIndex];
      final questionIndex = assignment.questions.indexWhere((q) => q.id == questionId);

      if (questionIndex != -1) {
        // Update the selectedAnswerIndex
        assignment.questions[questionIndex].selectedAnswerIndex = selectedAnswerIndex;

        // Check if all questions have been answered
        final allAnswered = assignment.questions.every((q) => q.isAnswered);

        // If all questions answered, mark the assignment as complete
        if (allAnswered) {
          _assignments[assignmentIndex] = assignment.copyWith(isCompleted: true);
        }
      }
    }
  }

  // Calculate the score for an MCQ assignment (percentage correct)
  double calculateMcqScore(String assignmentId) {
    try {
      final assignment = _assignments.firstWhere((a) => a.id == assignmentId);

      if (assignment.questions.isEmpty) {
        return 0.0;
      }

      int correctAnswers = 0;
      int answeredQuestions = 0;

      for (var question in assignment.questions) {
        if (question.isAnswered) {
          answeredQuestions++;
          if (question.isCorrect) {
            correctAnswers++;
          }
        }
      }

      if (answeredQuestions == 0) {
        return 0.0;
      }

      return (correctAnswers / assignment.questions.length) * 100;
    } catch (e) {
      // Return 0 if assignment is not found
      return 0.0;
    }
  }

  // Remove a course from purchased courses
  void removeCourse(String courseId) {
    _purchasedCourses.removeWhere((course) => course.id == courseId);
    _assignments.removeWhere((assignment) => assignment.courseId == courseId);
    _purchasedCourseIds.remove(courseId); // Remove from static set too
  }

  // Clear all purchased courses (for testing)
  void clearPurchasedCourses() {
    _purchasedCourses.clear();
    _assignments.clear();
    _purchasedCourseIds.clear(); // Clear static set too
  }
}

// Provider version of the CourseManager
class CourseManagerProvider extends ChangeNotifier {
  // Reference to the singleton CourseManager
  final CourseManager _courseManager = CourseManager();

  // Method to mark a course as purchased
  void markAsPurchased(String courseId) {
    CourseManager.markAsPurchasedStatically(courseId);
    notifyListeners();
  }

  // Method to check if a course is purchased
  bool isPurchased(String courseId) {
    return CourseManager.isPurchasedStatically(courseId);
  }

  // Get list of purchased courses
  List<Course> getPurchasedCourses(List<Course> allCourses) {
    return CourseManager.getPurchasedCoursesStatically(allCourses);
  }

  // Add a course to purchased courses
  void addCourse(Course course) {
    _courseManager.addCourse(course);
    notifyListeners();
  }

  // Purchase/enroll in a course
  void purchaseCourse(Course course) {
    _courseManager.purchaseCourse(course);
    notifyListeners();
  }

  // Get assignments for a specific course
  List<Assignment> getAssignmentsForCourse(String courseId) {
    return _courseManager.getAssignmentsForCourse(courseId);
  }

  // Get upcoming assignments
  List<Assignment> getUpcomingAssignments() {
    return _courseManager.getUpcomingAssignments();
  }

  // Mark an assignment as completed
  void markAssignmentAsCompleted(String assignmentId) {
    _courseManager.markAssignmentAsCompleted(assignmentId);
    notifyListeners();
  }

  // Save user answer to an MCQ question
  void saveUserAnswer(String assignmentId, String questionId, int selectedAnswerIndex) {
    _courseManager.saveUserAnswer(assignmentId, questionId, selectedAnswerIndex);
    notifyListeners();
  }

  // Calculate MCQ score
  double calculateMcqScore(String assignmentId) {
    return _courseManager.calculateMcqScore(assignmentId);
  }

  // Remove a course
  void removeCourse(String courseId) {
    _courseManager.removeCourse(courseId);
    notifyListeners();
  }

  // Clear all purchased courses
  void clearPurchasedCourses() {
    _courseManager.clearPurchasedCourses();
    notifyListeners();
  }
}

// Tombol navigasi ke EssayAssignmentScreen (bisa dipakai di UI mana pun)
class EssayNavButton extends StatelessWidget {
  const EssayNavButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final manager = EssayAssignmentManager();
        final assignments = await manager.loadAssignments();
        if (assignments.isNotEmpty) {
          final essay = assignments.first;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EssayAssignmentScreen(
                assignment: essay,
                onSaveAnswer: manager.saveAnswer,
                onSubmit: () {
                  manager.submitAssignment(essay.id);
                },
              ),
            ),
          );
        } else {
          // Handle case when there are no assignments
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tidak ada tugas esai yang tersedia")),
          );
        }
      },
      child: const Text("Latihan Essay"),
    );
  }
}