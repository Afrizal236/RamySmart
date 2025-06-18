import 'package:flutter/material.dart';
import 'wishlist_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:ramysmart/screens/Home/widget/cart.dart';
import 'wishlist.dart';
import 'purchase_course.dart';
import 'course_manager.dart';
import 'share_options.dart';

List<Course> globalCartItems = [
  featuredCoursesList[0], // Adding Literasi Bahasa Indonesia as example
  featuredCoursesList[2], // Adding Literasi Bahasa Inggris as example
];
// First, let's update the FeaturedCourses class to navigate to the detail page
class FeaturedCourses extends StatelessWidget {
  const FeaturedCourses({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Courses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to see all courses
                },
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featuredCoursesList.length,
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            itemBuilder: (context, index) {
              final course = featuredCoursesList[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to course detail page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseDetailPage(course: course),
                    ),
                  );
                },
                child: CourseCard(course: course),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Updated Course model class with additional fields
class Course {
  final String id;
  final String title;
  final String provider;
  final double rating;
  final double price;
  final Color cardColor;
  final IconData icon;
  final String description;
  final String youtubeUrl;
  final int lessons;
  final double minutes;
  final List<Section> sections;

  Course({
    required this.id,
    required this.title,
    required this.provider,
    required this.rating,
    required this.price,
    required this.cardColor,
    required this.icon,
    this.description = '',
    this.youtubeUrl = '',
    this.lessons = 15,
    this.minutes = 2.5,
    this.sections = const [],
  });

  // Helper method to get YouTube video ID from URL
  String? get youtubeVideoId {
    if (youtubeUrl.isEmpty) return null;
    return YoutubePlayer.convertUrlToId(youtubeUrl);
  }
}

// Section model for course content
class Section {
  final String title;
  final List<Lesson> lessons;
  final bool isExpanded;

  Section({
    required this.title,
    required this.lessons,
    this.isExpanded = false,
  });
}

// Lesson model for section content
// First, update the Lesson model in featured_courses.dart to include a "watched" field
class Lesson {
  final String title;
  final Duration duration;
  final String? youtubeUrl;
  bool watched;  // Add this field to track if the lesson has been watched

  Lesson({
    required this.title,
    required this.duration,
    this.youtubeUrl,
    this.watched = false,  // Default to false (not watched)
  });

  // Helper method to get YouTube video ID from URL
  String? get youtubeVideoId {
    if (youtubeUrl == null || youtubeUrl!.isEmpty) return null;
    return YoutubePlayer.convertUrlToId(youtubeUrl!);
  }
}

// Next, add a new class in course_manager.dart to track user progress
class UserProgress {
  // Map to track progress by courseId
  static final Map<String, Map<String, bool>> _watchedLessons = {};

  // Method to mark a lesson as watched
  static void markLessonAsWatched(String courseId, String lessonId, bool isWatched) {
    if (!_watchedLessons.containsKey(courseId)) {
      _watchedLessons[courseId] = {};
    }
    _watchedLessons[courseId]![lessonId] = isWatched;
  }

  // Method to check if a lesson is watched
  static bool isLessonWatched(String courseId, String lessonId) {
    if (!_watchedLessons.containsKey(courseId)) {
      return false;
    }
    return _watchedLessons[courseId]![lessonId] ?? false;
  }

  // Calculate progress percentage for a course
  static double getCourseProgress(String courseId, List<Section> sections) {
    // Count total lessons in the course
    int totalLessons = 0;
    int watchedLessons = 0;

    for (var section in sections) {
      for (var lesson in section.lessons) {
        totalLessons++;
        // Use lessonId as section.title + lesson.title for uniqueness
        String lessonId = "${section.title}_${lesson.title}";
        if (isLessonWatched(courseId, lessonId)) {
          watchedLessons++;
        }
      }
    }

    if (totalLessons == 0) return 0.0;
    return watchedLessons / totalLessons;
  }
}

// Updated list of featured courses with additional data
final List<Course> featuredCoursesList = [
  Course(
    id: '1',
    title: 'Literasi Bahasa Indonesia',
    provider: 'Guru Ramy',
    rating: 5.0,
    price: 100.0,
    cardColor: Colors.purple.shade100,
    icon: Icons.auto_stories,  // Mengubah ikon menjadi buku cerita
    description: 'Course ini membantu peserta meningkatkan keterampilan membaca, menulis, dan memahami kaidah Bahasa Indonesia dengan interaktif dan mudah dipahami.',
    youtubeUrl: 'https://youtu.be/ApjX8x5j75w?si=0_c7kpQ23phPr_1k',
    lessons: 15,
    minutes: 15,
    sections: [
      Section(
        title: 'Section 1 - Pengenalan Unsur Kalimat',
        isExpanded: true,
        lessons: [
          Lesson(title: 'Mengenal Kalimat SPOK', duration: const Duration(minutes: 2, seconds: 0), youtubeUrl: 'https://youtu.be/ApjX8x5j75w?si=0_c7kpQ23phPr_1k'),
          Lesson(title: 'Fungsi dan Ciri Subjek', duration: const Duration(minutes: 3, seconds: 0)),
        ],
      ),
      Section(
        title: 'Section 2 - Fungsi Predikat dan Objek',
        lessons: [
          Lesson(title: 'Menentukan Fungsi Predikat', duration: const Duration(minutes: 3, seconds: 0), youtubeUrl: 'https://youtu.be/video_unsur_kalimat'),
          Lesson(title: 'Objek dan Pelengkap dalam Kalimat', duration: const Duration(minutes: 3, seconds: 0)),
        ],
      ),
      Section(
        title: 'Section 3 - Keterangan dan Aplikasi SNBT',
        lessons: [
          Lesson(title: 'Jenis-jenis Keterangan', duration: const Duration(minutes: 2, seconds: 0)),
          Lesson(title: 'Latihan Soal SPOK untuk SNBT 2023', duration: const Duration(minutes: 2, seconds: 0)),
        ],
      ),
    ],
  ),

  Course(
    id: '2',
    title: 'Penalaran Matematika',
    provider: 'Guru Ramy',
    rating: 4.2,
    price: 100.0,
    cardColor: Colors.teal.shade100,
    icon: Icons.psychology,  // Mengubah ikon menjadi psychology untuk mewakili proses berpikir
    description: 'Course ini melatih logika dan pemecahan masalah matematika melalui konsep dan strategi berpikir yang sistematis.',
    youtubeUrl: 'https://youtu.be/Ho-Ce2JQZ_A?si=KMj0Vr6lyRaDkyIk',
    lessons: 15,
    minutes: 17,
    sections: [
      Section(
        title: 'Section 1 - Dasar-Dasar Berpikir Logis',
        isExpanded: true,
        lessons: [
          Lesson(title: 'Pengenalan Penalaran Matematika', duration: const Duration(minutes: 1, seconds: 45), youtubeUrl: 'https://youtu.be/Ho-Ce2JQZ_A?si=KMj0Vr6lyRaDkyIk'),
          Lesson(title: 'Konsep Dasar Logika', duration: const Duration(minutes: 3, seconds: 30)),
          Lesson(title: 'Pola Pikir Matematis', duration: const Duration(minutes: 2, seconds: 45)),
        ],
      ),
      Section(
        title: 'Section 2 - Aljabar dan Bilangan',
        lessons: [
          Lesson(title: 'Pola Bilangan', duration: const Duration(minutes: 3, seconds: 0)),
          Lesson(title: 'Operasi Bilangan', duration: const Duration(minutes: 3, seconds: 0)),
        ],
      ),
      Section(
        title: 'Section 3 - Aplikasi Praktis',
        lessons: [
          Lesson(title: 'Strategi Pemecahan Masalah', duration: const Duration(minutes: 3, seconds: 0)),
          Lesson(title: 'Analisis Data Sederhana', duration: const Duration(minutes: 0, seconds: 0)), // Placeholder, tidak dihitung dalam total durasi
        ],
      ),
    ],
  ),
  // Rest of the courses remain the same
  Course(
    id: '3',
    title: 'Literasi Bahasa Inggris',
    provider: 'Guru Ramy',
    rating: 4.5,
    price: 95.0,
    cardColor: Colors.blue.shade100,
    icon: Icons.menu_book,  // Mengubah ikon menjadi buku terbuka
    description: 'Course ini membantu peserta meningkatkan keterampilan membaca, menulis, dan memahami bahasa Inggris secara efektif dan interaktif.',
    youtubeUrl: 'https://youtu.be/S9qKTn58Bxc?si=ZPNLanO8Syca3mgw',
    lessons: 18,
    minutes: 21,
    sections: [
      Section(
        title: 'Section 1 - Basic English Skills',
        isExpanded: true,
        lessons: [
          Lesson(title: 'Introduction to English Literacy', duration: const Duration(minutes: 1, seconds: 30), youtubeUrl: 'https://youtu.be/S9qKTn58Bxc?si=ZPNLanO8Syca3mgw'),
          Lesson(title: 'Reading Comprehension Basics', duration: const Duration(minutes: 3, seconds: 0)),
          Lesson(title: 'Vocabulary Building', duration: const Duration(minutes: 2, seconds: 30)),
        ],
      ),
      Section(
        title: 'Section 2 - Intermediate English',
        lessons: [
          Lesson(title: 'Grammar Fundamentals', duration: const Duration(minutes: 4, seconds: 0)),
          Lesson(title: 'Writing Effective Sentences', duration: const Duration(minutes: 3, seconds: 0)),
        ],
      ),
      Section(
        title: 'Section 3 - Advanced English Practice',
        lessons: [
          Lesson(title: 'English Pronunciation', duration: const Duration(minutes: 3, seconds: 30)),
          Lesson(title: 'Conversation Skills', duration: const Duration(minutes: 3, seconds: 30)),
        ],
      ),
    ],
  ),
  Course(
    id: '4',
    title: 'Penalaran Umum',
    provider: 'Guru Ramy',
    rating: 4.7,
    price: 110.0,
    cardColor: Colors.green.shade100,
    icon: Icons.psychology, // Ganti dari Icons.science ke Icons.psychology
    description: 'Course ini melatih kemampuan berpikir logis, analitis, dan kritis untuk memecahkan berbagai masalah secara sistematis.',
    youtubeUrl: 'https://youtu.be/TlLPnIiAb7U?si=ZXmf3Cia0YpYfZe_',
    lessons: 20,
    minutes: 23,
    sections: [
      Section(
        title: 'Section 1 - Konsep Dasar',
        isExpanded: true,
        lessons: [
          Lesson(title: 'Dasar-Dasar Berpikir Kritis', duration: const Duration(minutes: 2, seconds: 30), youtubeUrl: 'https://youtu.be/TlLPnIiAb7U?si=ZXmf3Cia0YpYfZe_'),
          Lesson(title: 'Metode Berpikir Logis', duration: const Duration(minutes: 4, seconds: 0)),
          Lesson(title: 'Identifikasi Masalah', duration: const Duration(minutes: 1, seconds: 15)),
        ],
      ),
      Section(
        title: 'Section 2 - Teknik Analisis',
        lessons: [
          Lesson(title: 'Analisis Sebab-Akibat', duration: const Duration(minutes: 3, seconds: 45)),
          Lesson(title: 'Pola dan Relasi', duration: const Duration(minutes: 3, seconds: 0)),
        ],
      ),
      Section(
        title: 'Section 3 - Penerapan Penalaran',
        lessons: [
          Lesson(title: 'Argumentasi dan Pembuktian', duration: const Duration(minutes: 4, seconds: 0)),
          Lesson(title: 'Studi Kasus Penalaran', duration: const Duration(minutes: 2, seconds: 0)),
          Lesson(title: 'Evaluasi Penalaran', duration: const Duration(minutes: 2, seconds: 30)),
        ],
      ),
    ],
  ),
  Course(
    id: '5',
    title: 'Penalaran Kuantitatif',
    provider: 'Guru Ramy',
    rating: 4.6,
    price: 105.0,
    cardColor: Colors.orange.shade100,
    icon: Icons.functions,
    description: 'Course ini mengasah keterampilan analisis data, perhitungan numerik, dan pemecahan masalah menggunakan konsep matematika.',
    youtubeUrl: 'https://youtu.be/rV8PjZ57P5k?si=kJPYOaievCwvw1iG',
    lessons: 16,
    minutes: 14,
    sections: [
      Section(
        title: 'Section 1 - Konsep Fundamental',
        isExpanded: true,
        lessons: [
          Lesson(title: 'Prinsip Dasar Matematika Logis', duration: const Duration(minutes: 1, seconds: 30), youtubeUrl: 'https://youtu.be/rV8PjZ57P5k?si=kJPYOaievCwvw1iG'),
          Lesson(title: 'Angka dan Operasi Dasar', duration: const Duration(minutes: 2, seconds: 0)),
        ],
      ),
      Section(
        title: 'Section 2 - Visualisasi Data',
        lessons: [
          Lesson(title: 'Penyajian Data Numerik', duration: const Duration(minutes: 2, seconds: 15)),
          Lesson(title: 'Interpretasi Grafik dan Tabel', duration: const Duration(minutes: 2, seconds: 45)),
        ],
      ),
      Section(
        title: 'Section 3 - Analisis Kuantitatif',
        lessons: [
          Lesson(title: 'Analisis Statistik Dasar', duration: const Duration(minutes: 2, seconds: 0)),
          Lesson(title: 'Perhitungan Probabilitas', duration: const Duration(minutes: 1, seconds: 45)),
          Lesson(title: 'Aplikasi Penalaran Kuantitatif', duration: const Duration(minutes: 1, seconds: 45)),
        ],
      ),
    ],
  ),
];

// Course card widget - Keep your existing implementation
class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course card header with image and title
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              color: course.cardColor,
            ),
            child: Stack(
              children: [
                // Course icon positioned at left
                Positioned(
                  left: 16,
                  top: 16,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: Colors.white,
                        child: Center(
                          child: Icon(course.icon, color: course.cardColor, size: 24),
                        ),
                      ),
                    ),
                  ),
                ),
                // Course title
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Course details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Provider and rating
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        course.provider,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Rating
                Row(
                  children: [
                    Text(
                      course.rating.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const Spacer(),
                    // Price
                    Text(
                      '\$${course.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Updated Video Preview Widget with YouTube player
class VideoPreview extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const VideoPreview({
    Key? key,
    required this.course,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: double.infinity,
        color: course.cardColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Play button overlay
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 40,
                color: Colors.blue,
              ),
            ),
            const Positioned(
              bottom: 16,
              left: 16,
              child: Text(
                "Preview this course",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Course Detail Page Implementation
// Course Detail Page Implementation
class CourseDetailPage extends StatefulWidget {
  final Course course;

  const CourseDetailPage({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final WishlistProvider _wishlistProvider = WishlistProvider();
  bool showFullDescription = false;
  late List<Section> sections;
  late YoutubePlayerController? _youtubeController;
  bool _isYoutubePlayerVisible = false;
  bool _isPurchased = false;

  @override
  void initState() {
    super.initState();
    sections = List.from(widget.course.sections);

    // Initialize YouTube controller if video ID is available
    final videoId = widget.course.youtubeVideoId;
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    } else {
      _youtubeController = null;
    }

    // Check if course is purchased from CourseManager
    _checkPurchaseStatus();
  }

  // Method to check purchase status from CourseManager
  void _checkPurchaseStatus() {
    setState(() {
      // Use the static method to check if the course is purchased
      _isPurchased = CourseManager.isPurchasedStatically(widget.course.id);
    });
  }

  @override
  void dispose() {
    // Dispose YouTube controller when widget is disposed
    _youtubeController?.dispose();
    super.dispose();
  }

  void toggleSection(int index) {
    setState(() {
      for (int i = 0; i < sections.length; i++) {
        if (i == index) {
          sections[i] = Section(
            title: sections[i].title,
            lessons: sections[i].lessons,
            isExpanded: !sections[i].isExpanded,
          );
        } else {
          sections[i] = Section(
            title: sections[i].title,
            lessons: sections[i].lessons,
            isExpanded: false,
          );
        }
      }
    });
  }

  void _toggleYoutubePlayer() {
    setState(() {
      _isYoutubePlayerVisible = !_isYoutubePlayerVisible;
    });
  }

  void _playLessonVideo(Lesson lesson) {
    if (!_isPurchased) {
      _showPurchaseRequiredDialog();
      return;
    }

    final videoId = lesson.youtubeVideoId;
    if (videoId != null && _youtubeController != null) {
      _youtubeController!.load(videoId);
      if (!_isYoutubePlayerVisible) {
        _toggleYoutubePlayer();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video available for this lesson')),
      );
    }
  }

  // Method to show purchase required dialog
  void _showPurchaseRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Purchase Required'),
          content: const Text('You need to purchase this course to access the video content.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Navigate to purchase page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PurchaseCoursePage(
                      courses: [widget.course],
                      totalPrice: widget.course.price,
                      onPurchaseComplete: () {
                        // Set the course as purchased when they return
                        setState(() {
                          _isPurchased = true;
                          // Also update the CourseManager to maintain purchase state
                          CourseManager.markAsPurchasedStatically(widget.course.id);
                        });

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${widget.course.title} purchased successfully! You can now access all content.')),
                        );
                      },
                    ),
                  ),
                );
              },
              child: const Text('Purchase Now'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check purchase status each time the page is built
    _checkPurchaseStatus();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // YouTube player if visible
              if (_isYoutubePlayerVisible && _youtubeController != null)
                Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: YoutubePlayer(
                        controller: _youtubeController!,
                        showVideoProgressIndicator: true,
                        aspectRatio: 16 / 9,
                        progressIndicatorColor: Colors.blue,
                        progressColors: const ProgressBarColors(
                          playedColor: Colors.blue,
                          handleColor: Colors.blueAccent,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _toggleYoutubePlayer,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
              // Video Preview
                Stack(
                  children: [
                    VideoPreview(
                      course: widget.course,
                      onTap: () {
                        if (widget.course.youtubeVideoId != null) {
                          if (_isPurchased) {
                            _toggleYoutubePlayer();
                          } else {
                            _showPurchaseRequiredDialog();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No video available for this course')),
                          );
                        }
                      },
                    ),

                    // Back, Share and Cart buttons
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {
                                // Show share options bottom sheet
                                ShareOptions.showShareOptions(context, widget.course);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.shopping_cart),
                              onPressed: () {
                                // Check if the course is already in the cart
                                bool alreadyInCart = globalCartItems.any((item) => item.id == widget.course.id);
                                if (!alreadyInCart) {
                                  // Add course to cart
                                  globalCartItems.add(widget.course);
                                }
                                // Navigate to the Cart page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Cart(key: const Key('cart')),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add a "Premium" badge ONLY if not purchased
                    if (!_isPurchased)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Premium",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

              // Course Title and Provider
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.course.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _wishlistProvider.isInWishlist(widget.course.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _wishlistProvider.isInWishlist(widget.course.id)
                                ? Colors.red
                                : null,
                          ),
                          onPressed: () {
                            setState(() {
                              _wishlistProvider.toggleWishlist(widget.course);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _wishlistProvider.isInWishlist(widget.course.id)
                                      ? '${widget.course.title} added to wishlist'
                                      : '${widget.course.title} removed from wishlist',
                                ),
                                action: _wishlistProvider.isInWishlist(widget.course.id)
                                    ? SnackBarAction(
                                  label: 'View Wishlist',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Wishlist(),
                                      ),
                                    );
                                  },
                                )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // Provider
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          widget.course.provider,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Course stats (lessons, duration, rating)
                    Row(
                      children: [
                        const Icon(Icons.play_circle_outline, size: 16),
                        const SizedBox(width: 4),
                        Text('${widget.course.lessons} Lessons'),
                        const SizedBox(width: 16),
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 4),
                        Text('${widget.course.minutes} Minutes'),
                        const SizedBox(width: 16),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${widget.course.rating}'),
                      ],
                    ),

                    // Show a "Purchased" indicator when the course is purchased
                    if (_isPurchased)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                "Purchased",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Course Description
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          showFullDescription
                              ? widget.course.description
                              : widget.course.description.length > 100
                              ? '${widget.course.description.substring(0, 100)}...'
                              : widget.course.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        if (widget.course.description.length > 100)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                showFullDescription = !showFullDescription;
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 20),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              showFullDescription ? 'Show less' : 'Show more',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Course Content Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Course Content',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '(${sections.length} Sections)',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Course Content Sections
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final section = sections[index];
                  return Column(
                    children: [
                      // Section header
                      InkWell(
                        onTap: () => toggleSection(index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                section.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: section.isExpanded ? Colors.blue : Colors.black87,
                                ),
                              ),
                              Icon(
                                section.isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: section.isExpanded ? Colors.blue : Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Section lessons (expandable)
                      if (section.isExpanded)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: section.lessons.length,
                          itemBuilder: (context, lessonIndex) {
                            final lesson = section.lessons[lessonIndex];
                            return ListTile(
                              leading: Icon(
                                Icons.play_circle_outline,
                                color: _isPurchased ? Colors.blue : Colors.grey,
                              ),
                              title: Text(
                                lesson.title,
                                style: TextStyle(
                                  color: _isPurchased ? Colors.black : Colors.black54,
                                ),
                              ),
                              subtitle: Text(
                                '${lesson.duration.inMinutes.toString().padLeft(2, '0')}:${(lesson.duration.inSeconds % 60).toString().padLeft(2, '0')} mins',
                              ),
                              trailing: _isPurchased ? null : const Icon(Icons.lock, size: 16, color: Colors.grey),
                              onTap: () {
                                if (!_isPurchased) {
                                  _showPurchaseRequiredDialog();
                                } else {
                                  // Play the video if available
                                  _playLessonVideo(lesson);
                                }
                              },
                            );
                          },
                        ),
                      const Divider(),
                    ],
                  );
                },
              ),

              // Price and Purchase Buttons - Hide when course is purchased
              if (!_isPurchased)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        '\$${widget.course.price.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // Check if the course is already in the cart
                          bool alreadyInCart = globalCartItems.any((item) => item.id == widget.course.id);

                          if (!alreadyInCart) {
                            // Add to cart
                            globalCartItems.add(widget.course);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${widget.course.title} added to cart!'),
                                action: SnackBarAction(
                                  label: 'View',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Cart(key: const Key('cart')),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          } else {
                            // Course is already in cart
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${widget.course.title} is already in your cart'),
                                action: SnackBarAction(
                                  label: 'View Cart',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Cart(key: const Key('cart')),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Add to Cart'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to purchase page with a list containing this single course
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PurchaseCoursePage(
                                courses: [widget.course],  // Pass as a list
                                totalPrice: widget.course.price,  // Pass the price of this single course
                                onPurchaseComplete: () {
                                  // Set the course as purchased when they return
                                  setState(() {
                                    _isPurchased = true;
                                    // Update CourseManager
                                    CourseManager.markAsPurchasedStatically(widget.course.id);
                                  });

                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${widget.course.title} purchased successfully! You can now access all content.')),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Buy'),
                      ),
                    ],
                  ),
                )
              else
              // Show "Watch Now" button when the course is purchased
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text('Watch Course'),
                      onPressed: () {
                        if (widget.course.youtubeVideoId != null && _youtubeController != null) {
                          // Reset to the main course video
                          _youtubeController!.load(widget.course.youtubeVideoId!);
                          if (!_isYoutubePlayerVisible) {
                            _toggleYoutubePlayer();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No video available for this course')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}