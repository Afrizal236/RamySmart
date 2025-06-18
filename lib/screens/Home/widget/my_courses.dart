import 'package:flutter/material.dart';
import 'package:ramysmart/screens/Home/widget/featured_courses.dart';
import 'course_manager.dart'; // Import CourseManager
import 'assignment_model.dart'; // Import Assignment model
import 'MCQ_Assignment_Page.dart'; // Import the MCQ Assignment Page
import 'essay_assignment_screen.dart';
import'essay_model.dart';


class MyCourses extends StatefulWidget {
  // Add a callback for navigation
  final VoidCallback? onNavigateToHome;

  const MyCourses({super.key, this.onNavigateToHome});

  @override
  State<MyCourses> createState() => _MyCoursesState();
}

class _MyCoursesState extends State<MyCourses> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // List of purchased courses from CourseManager
  late List<Course> myCourses;
  // List of assignments from CourseManager
  late List<Assignment> myAssignments;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Get purchased courses from CourseManager
    myCourses = CourseManager().purchasedCourses;
    // Get assignments from CourseManager
    myAssignments = CourseManager().assignments;
    // If no courses have been purchased yet, add some sample courses for demonstration
    if (myCourses.isEmpty) {
      _addSampleCourses();
    }

    // Add post-frame callback to refresh data after navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  // Refresh all data from CourseManager
  void _refreshData() {
    setState(() {
      // Refresh course and assignment lists
      myCourses = CourseManager().purchasedCourses;
      myAssignments = CourseManager().assignments;
    });
  }

  // Add some sample courses for demonstration purposes
  void _addSampleCourses() {
    final courseManager = CourseManager();

    // Add sample courses if none exist
    if (courseManager.purchasedCourses.isEmpty) {
      // Sample courses (using courses from FeaturedCourses)
      final sampleCourses = [
        Course(
            id: '1',
            title: 'Bahasa Indonesia - UTBK',
            lessons: 12,
            minutes: 6,
            price: 299000,
            rating: 4.7,
            provider: 'Tim Edutech',
            description: 'Kursus persiapan UTBK untuk mata pelajaran Bahasa Indonesia',
            cardColor: Colors.blue,
            icon: Icons.book
        ),
        Course(
            id: '2',
            title: 'Matematika Dasar - UTBK',
            lessons: 18,
            minutes: 10,
            price: 349000,
            rating: 4.8,
            provider: 'Tim Edutech',
            description: 'Kursus persiapan UTBK untuk mata pelajaran Matematika Dasar',
            cardColor: Colors.green,
            icon: Icons.calculate
        ),
      ];

      // Add sample courses to CourseManager
      courseManager.addCourses(sampleCourses);

      // Add sample MCQ assignments
      final sampleAssignments = [
        Assignment(
          id: 'mcq1',
          title: 'Quiz Bahasa Indonesia - Kosakata',
          courseId: '1',
          courseName: 'Bahasa Indonesia - UTBK',
          dueDate: DateTime.now().add(const Duration(days: 3)),
          questions: QuestionGenerator.generateQuestionsForCourse('1', 'Bahasa Indonesia'),
        ),
        Assignment(
          id: 'mcq2',
          title: 'Quiz Matematika Dasar - Aljabar',
          courseId: '2',
          courseName: 'Matematika Dasar - UTBK',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          questions: QuestionGenerator.generateQuestionsForCourse('2', 'Matematika'),
        ),
      ];

      // Refresh lists
      setState(() {
        myCourses = courseManager.purchasedCourses;
        myAssignments = courseManager.assignments;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleAssignmentCompletion(String assignmentId) {
    setState(() {
      final assignmentIndex = myAssignments.indexWhere(
              (assignment) => assignment.id == assignmentId);

      if (assignmentIndex != -1) {
        // Toggle completion status
        final isCompleted = !myAssignments[assignmentIndex].isCompleted;

        // Use CourseManager to update the assignment
        if (isCompleted) {
          CourseManager().markAssignmentAsCompleted(assignmentId);
        } else {
          // If we need to un-complete an assignment, we would need to add this method to CourseManager
          // For now, we'll just update our local list
          myAssignments[assignmentIndex] = myAssignments[assignmentIndex].copyWith(
              isCompleted: isCompleted
          );
        }

        // Refresh assignments from CourseManager
        myAssignments = CourseManager().assignments;
      }
    });
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return 'Terlambat';
    } else if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Besok';
    } else {
      return '${difference} hari lagi';
    }
  }

  // Navigation to MCQ Assignment Page
  void _navigateToMcqAssignment(Assignment assignment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => McqAssignmentPage(assignment: assignment),
      ),
    ).then((result) {
      // Refresh data when returning from the MCQ page
      // This ensures any changes (like completion status) are reflected
      if (result == true) {
        _refreshData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Add a leading back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onNavigateToHome != null) {
              // Use the callback if provided
              widget.onNavigateToHome!();
            } else {
              // Fallback to direct navigation if no callback
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'My Courses',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(
              icon: Icon(Icons.book),
              text: 'Kursus',
            ),
            Tab(
              icon: Icon(Icons.assignment),
              text: 'Tugas',
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshData();
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            // Courses Tab
            _buildCoursesTab(),
            // Assignments Tab
            _buildAssignmentsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesTab() {
    return myCourses.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.book_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'You haven\'t purchased any courses yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (widget.onNavigateToHome != null) {
                widget.onNavigateToHome!();
              } else {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Explore Courses'),
          ),
        ],
      ),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myCourses.length,
      itemBuilder: (context, index) {
        final course = myCourses[index];
        // Calculate a dynamic progress value based on the course index
        final progressValue = ((index % 3) + 1) * 0.25;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailPage(course: course),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Header
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: course.cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(
                          course.icon,
                          color: Colors.white,
                          size: 40
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              course.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              course.provider,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Course Progress
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progress',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${(progressValue * 100).toInt()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: Colors.grey.shade200,
                          minHeight: 8,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.play_circle_outline, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${course.lessons} Lessons',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${course.minutes} Minutes',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.assignment, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${myAssignments.where((a) => a.courseId == course.id).length} Tugas',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseDetailPage(course: course),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        child: const Text('Continue Learning'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssignmentsTab() {
    if (myAssignments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No assignments yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final pendingAssignments = myAssignments.where((a) => !a.isCompleted).toList();
    final completedAssignments = myAssignments.where((a) => a.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Upcoming assignments section
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Tugas yang akan datang',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Upcoming assignments list
        if (pendingAssignments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'Tidak ada tugas yang akan datang',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingAssignments.length,
            itemBuilder: (context, index) {
              final assignment = pendingAssignments[index];
              // Find the course for this assignment
              final course = myCourses.firstWhere(
                    (c) => c.id == assignment.courseId,
                orElse: () => Course(
                    id: '0',
                    title: 'Unknown Course',
                    lessons: 0,
                    minutes: 0,
                    price: 0,
                    rating: 0,
                    provider: 'Unknown',
                    description: 'Course not found',
                    cardColor: Colors.grey,
                    icon: Icons.book
                ),
              );

              // Show if the assignment has MCQ questions
              final hasMcq = assignment.questions.isNotEmpty;

              // Check if this is a category-specific essay assignment
              final isEssay = assignment.id.contains('_ind') ||
                  assignment.id.contains('_eng') ||
                  assignment.id.contains('_reas') ||
                  assignment.id.contains('_quant') ||
                  assignment.id.contains('_math');

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  onTap: () async {
                    // For MCQ assignments, navigate to the McqAssignmentPage
                    if (hasMcq) {
                      _navigateToMcqAssignment(assignment);
                    }
                    // For category-specific essay assignments
                    else if (isEssay) {
                      final manager = EssayAssignmentManager();
                      final essayAssignment = manager.getAssignment(assignment.id);

                      if (essayAssignment != null) {
                        // Navigate to EssayAssignmentScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EssayAssignmentScreen(
                              assignment: essayAssignment,
                              onSaveAnswer: (assignmentId, questionId, answer) {
                                manager.saveAnswer(assignmentId, questionId, answer);
                              },
                              onSubmit: () {
                                manager.submitAssignment(essayAssignment.id);
                                _refreshData(); // Refresh view after submit
                              },
                            ),
                          ),
                        );
                      } else {
                        // Essay assignment not found - this shouldn't happen with our new implementation
                        String category = '';

                        if (assignment.id.contains('_ind')) category = 'Literasi Bahasa Indonesia';
                        else if (assignment.id.contains('_eng')) category = 'Literasi Bahasa Inggris';
                        else if (assignment.id.contains('_reas')) category = 'Penalaran Umum';
                        else if (assignment.id.contains('_quant')) category = 'Penalaran Kuantitatif';
                        else if (assignment.id.contains('_math')) category = 'Penalaran Matematika';

                        // Create a new assignment with the specific category
                        final newEssayAssignment = EssayAssignment.withCategoryQuestions(
                          id: assignment.id,
                          title: assignment.title,
                          courseId: assignment.courseId,
                          courseName: assignment.courseName,
                          dueDate: assignment.dueDate,
                          duration: 90, // default duration
                          category: category,
                        );

                        manager.addAssignment(newEssayAssignment);

                        // Navigate to EssayAssignmentScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EssayAssignmentScreen(
                              assignment: newEssayAssignment,
                              onSaveAnswer: (assignmentId, questionId, answer) {
                                manager.saveAnswer(assignmentId, questionId, answer);
                              },
                              onSubmit: () {
                                manager.submitAssignment(newEssayAssignment.id);
                                _refreshData(); // Refresh view after submit
                              },
                            ),
                          ),
                        );
                      }
                    }
                    // Fallback for other assignment types
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tipe tugas tidak dikenali')),
                      );
                    }
                  },
                  leading: CircleAvatar(
                    backgroundColor: course.cardColor,
                    child: Icon(
                      hasMcq ? Icons.quiz : Icons.assignment,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    assignment.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.courseName,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: assignment.dueDate.difference(DateTime.now()).inDays < 2
                                ? Colors.red
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Batas waktu: ${_formatDueDate(assignment.dueDate)}',
                            style: TextStyle(
                              color: assignment.dueDate.difference(DateTime.now()).inDays < 2
                                  ? Colors.red
                                  : Colors.grey,
                              fontWeight: assignment.dueDate.difference(DateTime.now()).inDays < 2
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      if (hasMcq)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${assignment.questions.length} pertanyaan',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (isEssay)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Essay Assignment',
                            style: TextStyle(
                              color: Colors.purple.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Checkbox(
                    value: assignment.isCompleted,
                    onChanged: (_) {
                      _toggleAssignmentCompletion(assignment.id);
                    },
                  ),
                ),
              );
            },
          ),

        const SizedBox(height: 16),

        // Completed assignments section
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Tugas selesai',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Completed assignments list
        if (completedAssignments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'Belum ada tugas yang selesai',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: completedAssignments.length,
            itemBuilder: (context, index) {
              final assignment = completedAssignments[index];
              final course = myCourses.firstWhere(
                    (c) => c.id == assignment.courseId,
                orElse: () => Course(
                    id: '0',
                    title: 'Unknown Course',
                    lessons: 0,
                    minutes: 0,
                    price: 0,
                    rating: 0,
                    provider: 'Unknown',
                    description: 'Course not found',
                    cardColor: Colors.grey,
                    icon: Icons.book
                ),
              );

              // Check if this was an MCQ assignment
              final hasMcq = assignment.questions.isNotEmpty;

              // Check if this is a category-specific essay assignment
              final isEssay = assignment.id.contains('_ind') ||
                  assignment.id.contains('_eng') ||
                  assignment.id.contains('_reas') ||
                  assignment.id.contains('_quant') ||
                  assignment.id.contains('_math');

              // If it's an MCQ assignment, calculate the score
              String? scoreText;
              if (hasMcq) {
                final score = CourseManager().calculateMcqScore(assignment.id);
                scoreText = 'Skor: ${score.toInt()}%';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                  ),
                  title: Text(
                    assignment.title,
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.courseName,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (scoreText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            scoreText,
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isEssay)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Essay Completed',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Checkbox(
                    value: assignment.isCompleted,
                    onChanged: (_) {
                      _toggleAssignmentCompletion(assignment.id);
                    },
                  ),
                  onTap: () {
                    // For completed MCQ assignments, still navigate to the results view
                    if (hasMcq) {
                      _navigateToMcqAssignment(assignment);
                    }
                    // For completed essay assignments
                    else if (isEssay) {
                      final essayAssignment = EssayAssignmentManager().getAssignment(assignment.id);
                      if (essayAssignment != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EssayAssignmentScreen(
                              assignment: essayAssignment,
                              onSaveAnswer: (assignmentId, questionId, answer) {
                                EssayAssignmentManager().saveAnswer(assignmentId, questionId, answer);
                              },
                              onSubmit: () {
                                // Already completed, so no need to submit again
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tugas ini sudah selesai')),
                                );
                              },
                            ),
                          ),
                        );
                      }
                    }
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Melihat hasil: ${assignment.title}'),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
