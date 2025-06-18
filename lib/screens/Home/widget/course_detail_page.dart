import 'package:flutter/material.dart';
import 'package:ramysmart/util/constants.dart';
import 'featured_courses.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseId;
  final List<Course> coursesList;

  const CourseDetailPage({
    Key? key,
    required this.courseId,
    required this.coursesList,
  }) : super(key: key);

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  late Course courseData;
  bool isLoading = true;
  bool isInCart = false;
  bool isInWishlist = false;

  @override
  void initState() {
    super.initState();
    _loadCourseData();
  }

  void _loadCourseData() {
    // Find the course in the provided list
    Future.delayed(const Duration(milliseconds: 800), () {
      final course = widget.coursesList.firstWhere(
            (course) => course.id == widget.courseId,
        orElse: () => throw Exception('Course not found'),
      );

      setState(() {
        courseData = course;
        isLoading = false;
        // Simulate that course 1 is in cart and course 2 is in wishlist
        isInCart = widget.courseId == '1';
        isInWishlist = widget.courseId == '2';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildInstructorInfo(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildLessons(),
                  const SizedBox(height: 24),
                  _buildFeatures(),
                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: isLoading ? null : _buildBottomButtons(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: courseData.cardColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          courseData.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: courseData.cardColor),
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 70,
              child: IconButton(
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  setState(() {
                    isInWishlist = !isInWishlist;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isInWishlist
                            ? 'Added to wishlist'
                            : 'Removed from wishlist',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            // Share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sharing course...'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Chip(
              label: Text(
                _getCategoryFromTitle(courseData.title),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: courseData.cardColor,
            ),
            Row(
              children: [
                const Icon(Icons.people, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${courseData.lessons * 20} students', // Using lessons * 20 as an approximation
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 4),
                Text(
                  '${courseData.rating}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    // View reviews
                  },
                  child: const Text('View Reviews'),
                ),
              ],
            ),
            Text(
              'Updated May 2025',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInstructorInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: courseData.cardColor.withOpacity(0.5),
          child: Icon(courseData.icon, size: 32, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseData.provider,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Expert Instructor',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            // View instructor profile
          },
          child: const Text('View Profile'),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About This Course',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          courseData.description,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLessons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Course Content',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...courseData.sections.expand((section) => [
          ListTile(
            title: Text(
              section.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            contentPadding: EdgeInsets.zero,
            trailing: Icon(
              section.isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: kPrimaryColor,
            ),
          ),
          if (section.isExpanded)
            ...List.generate(
              section.lessons.length,
                  (index) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: courseData.cardColor,
                  radius: 14,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(section.lessons[index].title),
                subtitle: Text(
                  '${section.lessons[index].duration.inMinutes}:${section.lessons[index].duration.inSeconds % 60 < 10 ? '0' : ''}${section.lessons[index].duration.inSeconds % 60} mins',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                trailing: section.lessons[index].youtubeUrl != null
                    ? const Icon(Icons.play_circle_outline,
                    color: kPrimaryColor)
                    : null,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
          const Divider(),
        ]),
      ],
    );
  }

  Widget _buildFeatures() {
    // Define standard features since these aren't in the Course model
    List<String> features = [
      '24/7 access to course materials',
      'Interactive quizzes and assignments',
      'Live sessions with instructor',
      'Certificate of completion',
      'Mobile-friendly learning',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What You\'ll Get',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(
          features.length,
              (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: courseData.cardColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    features[index],
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '\$${courseData.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: courseData.cardColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isInCart ? Colors.grey : courseData.cardColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() {
                  isInCart = !isInCart;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isInCart ? 'Added to cart' : 'Removed from cart',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Text(
                isInCart ? 'REMOVE FROM CART' : 'ADD TO CART',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get category from title
  String _getCategoryFromTitle(String title) {
    if (title.contains('Literasi Bahasa Indonesia')) {
      return 'Literasi Bahasa Indonesia';
    } else if (title.contains('Penalaran Matematika')) {
      return 'Penalaran Matematika';
    } else if (title.contains('English') || title.contains('Bahasa Inggris') || title.contains('LitBig')) {
      return 'Literasi Bahasa Inggris';
    } else if (title.contains('Penalaran Umum') || title.contains('PU')) {
      return 'Penalaran Umum';
    } else if (title.contains('Penalaran Kuantitatif') || title.contains('PK')) {
      return 'Penalaran Kuantitatif';
    } else if (title.contains('LitBin')) {
      return 'Literasi Bahasa Indonesia';
    } else if (title.contains('PM')) {
      return 'Penalaran Matematika';
    }
    // Default
    return title;
  }
}