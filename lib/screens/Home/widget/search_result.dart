import 'package:flutter/material.dart';
import 'package:ramysmart/util/constants.dart';
import 'featured_courses.dart';
import 'course_list.dart';

class SearchResultsPage extends StatefulWidget {
  final String searchQuery;
  final Function() onNavigateBack;

  const SearchResultsPage({
    super.key, // Updated to use super.key
    required this.searchQuery,
    required this.onNavigateBack,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  // Combined course data from both lists
  late List<Course> allCourses;
  late List<Course> filteredCourses;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Combine the course lists from featuredCoursesList and additionalCourses
    allCourses = [...featuredCoursesList, ...additionalCourses];

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _filterCourses();
    });
  }

  void _filterCourses() {
    final query = widget.searchQuery.toLowerCase();
    setState(() {
      filteredCourses = allCourses.where((course) {
        final title = course.title.toLowerCase();
        final provider = course.provider.toLowerCase();
        final description = course.description.toLowerCase();

        return title.contains(query) ||
            provider.contains(query) ||
            description.contains(query);
      }).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Replace WillPopScope with PopScope (newer API)
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        widget.onNavigateBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          elevation: 0,
          title: Text(
            'Search: ${widget.searchQuery}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => widget.onNavigateBack(),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
            : filteredCourses.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No courses found for "${widget.searchQuery}"',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Found ${filteredCourses.length} results',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = filteredCourses[index];
                    return _buildCourseCard(course);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to course detail page - fixed by passing the course object
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailPage(course: course),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course icon with background color
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: course.cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    course.icon,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course title
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Instructor
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 4),
                        Text(
                          course.provider,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Course stats
                    Row(
                      children: [
                        Icon(Icons.play_lesson, size: 16, color: Colors.orange[700]),
                        const SizedBox(width: 4),
                        Text(
                          '${course.lessons} lessons · ${course.minutes} min',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Rating and price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, size: 18, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${course.rating}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '\$${course.price}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}