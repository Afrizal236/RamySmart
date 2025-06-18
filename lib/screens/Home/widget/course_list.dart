import 'package:flutter/material.dart';
import 'featured_courses.dart'; // Import to access Course model and existing courses

class CourseList extends StatefulWidget {
  final String selectedCategory;

  const CourseList({
    super.key,
    required this.selectedCategory,
  });

  @override
  State<CourseList> createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  late List<Course> filteredCourses;

  @override
  void initState() {
    super.initState();
    filterCourses();
  }

  @override
  void didUpdateWidget(CourseList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      filterCourses();
    }
  }

  void filterCourses() {
    if (widget.selectedCategory == 'All') {
      filteredCourses = allCourses;
    } else {
      filteredCourses = allCourses
          .where((course) => course.title.contains(widget.selectedCategory))
          .toList();
    }
    // Call setState to ensure UI updates
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "All Courses",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        if (filteredCourses.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Text(
                "No courses found for this category",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          )
        else
        // This is the key fix: wrap the ListView in a Container with a fixed height
          Container(
            height: 300, // Set a fixed height that works for your layout
            child: ListView.builder(
              // Don't use shrinkWrap: true since we have a fixed height container
              physics: const ClampingScrollPhysics(), // Allow scrolling
              itemCount: filteredCourses.length,
              itemBuilder: (context, index) {
                return CourseListItem(course: filteredCourses[index]);
              },
            ),
          ),
      ],
    );
  }
}

class CourseListItem extends StatelessWidget {
  final Course course;

  const CourseListItem({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailPage(course: course),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Course color and icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: course.cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  course.icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            // Course details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          course.provider,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          "${course.minutes} minutes",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.play_circle_outline, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          "${course.lessons} lessons",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Price and rating
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$${course.price.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                    ],
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

// Add 5 more courses to the existing featured courses
final List<Course> additionalCourses = [
  Course(
    id: '6',
    title: 'Literasi Bahasa Indonesia2',
    provider: 'Professor Ramy',
    rating: 4.8,
    price: 120.0,
    cardColor: Colors.purple.shade200,
    icon: Icons.auto_stories,
    description: 'Kursus lanjutan untuk meningkatkan keterampilan literasi bahasa Indonesia hingga tingkat mahir untuk kebutuhan akademik dan profesional.',
    youtubeUrl: 'https://youtu.be/Qi4GxYKOPy4?si=2PAR9i40cQQvnAUy',
    lessons: 8,
    minutes: 21,
    sections: [
      Section(
        title: 'Section 1 - Keterampilan Linguistik Lanjutan',
        isExpanded: true,
        lessons: [
          Lesson(title: 'Sintaksis dan Analisis Kalimat', duration: const Duration(minutes: 4, seconds: 0)),
          Lesson(title: 'Retorika dan Gaya Bahasa', duration: const Duration(minutes: 3, seconds: 15)),
        ],
      ),
      Section(
        title: 'Section 2 - Komposisi Akademik',
        lessons: [
          Lesson(title: 'Struktur Argumentasi Efektif', duration: const Duration(minutes: 3, seconds: 30)),
          Lesson(title: 'Analisis Wacana Kritis', duration: const Duration(minutes: 3, seconds: 45)),
          Lesson(title: 'Teknik Parafrase Akademik', duration: const Duration(minutes: 2, seconds: 0)),
        ],
      ),
      Section(
        title: 'Section 3 - Penelitian dan Publikasi',
        lessons: [
          Lesson(title: 'Metodologi Penelitian Linguistik', duration: const Duration(minutes: 2, seconds: 30)),
          Lesson(title: 'Sistem Sitasi Internasional', duration: const Duration(minutes: 1, seconds: 0)),
          Lesson(title: 'Penulisan Abstrak dan Kesimpulan', duration: const Duration(minutes: 1, seconds: 0)),
        ],
      ),
    ],
  ),
  Course(
    id: '7',
    title: 'Penalaran Matematika2',
    provider: 'Profesor Ramy',
    rating: 4.9,
    price: 150.0,
    cardColor: Colors.teal.shade200,
    icon: Icons.calculate,
    description: 'Kursus matematika tingkat lanjut yang mengintegrasikan berbagai konsep matematika untuk meningkatkan kemampuan pemecahan masalah secara komprehensif.',
    youtubeUrl: 'https://youtu.be/jJ2KdWDL-1g?si=oJYUqav57j9w9FHw',
    lessons: 4,
    minutes: 23,
    sections: [
      Section(
        title: 'Section 1 - Konsep Dasar Matematika',
        isExpanded: true,
        lessons: [
          Lesson(title: 'Teori Graph', duration: const Duration(minutes: 7, seconds: 30)),
          Lesson(title: 'Pengantar Kombinatorika', duration: const Duration(minutes: 7, seconds: 30)),
        ],
      ),
      Section(
        title: 'Section 2 - Aljabar Linear Dasar',
        lessons: [
          Lesson(title: 'Vektor dan Matriks', duration: const Duration(minutes: 8, seconds: 0)),
        ],
      ),
      Section(
        title: 'Section 3 - Implementasi Matematika',
        lessons: [
          Lesson(title: 'Aplikasi Matematika Diskrit', duration: const Duration(minutes: 7, seconds: 30)),
        ],
      ),
    ],
  ),
  Course(
    id: '8',
    title: 'Literasi Bahasa Inggris2',
    provider: 'Sir Ramy',
    rating: 4.7,
    price: 135.0,
    cardColor: Colors.blue.shade200,
    icon: Icons.menu_book,
    description: 'Kursus bahasa Inggris untuk keperluan profesional dan bisnis dengan fokus pada komunikasi efektif dalam konteks pekerjaan.',
    youtubeUrl: 'https://youtu.be/avfoS56-MFE?si=0m42tMUKuD90MbUe',
    lessons: 6,
    minutes: 27,
    sections: [
      Section(
        title: 'Section 1 - Komunikasi Profesional Lanjutan',
        isExpanded: true,
        lessons: [
          Lesson(title: 'Korespondensi Formal dan Informal', duration: const Duration(minutes: 3, seconds: 0)),
          Lesson(title: 'Penulisan Email Efektif', duration: const Duration(minutes: 6, seconds: 0)),
        ],
      ),
      Section(
        title: 'Section 2 - Literasi Akademik dan Penelitian',
        lessons: [
          Lesson(title: 'Analisis Teks Akademik', duration: const Duration(minutes: 4, seconds: 30)),
          Lesson(title: 'Teknik Penulisan Esai', duration: const Duration(minutes: 4, seconds: 30)),
        ],
      ),
      Section(
        title: 'Section 3 - Bahasa Inggris untuk Pengembangan Karir',
        lessons: [
          Lesson(title: 'Presentasi dan Public Speaking', duration: const Duration(minutes: 4, seconds: 30)),
          Lesson(title: 'Negosiasi dan Diskusi Profesional', duration: const Duration(minutes: 4, seconds: 30)),
        ],
      ),
    ],
  ),
  Course(
    id: '9',
    title: 'Penalaran Umum2',
    provider: 'Filsafat Ramy',
    rating: 4.6,
    price: 115.0,
    cardColor: Colors.green.shade200,
    icon: Icons.psychology,
    description: 'Kursus pemikiran kritis dan logika yang membantu mengembangkan kemampuan menganalisis argumen dan memecahkan masalah kompleks.',
    youtubeUrl: 'https://youtu.be/N3PamH9gnHA?si=nCNOS8DYeJ_8vP1x',
    lessons: 6,
    minutes: 19,
    sections: [
      Section(
        title: 'Section 1 - Dasar Logika',
        isExpanded: true,
        lessons: [
          Lesson(title: 'Proposisi dan Argumen', duration: const Duration(minutes: 3, seconds: 0)),
          Lesson(title: 'Falasi dan Kesalahan Logika', duration: const Duration(minutes: 3, seconds: 30)),
        ],
      ),
      Section(
        title: 'Section 2 - Aplikasi Pemikiran Kritis',
        lessons: [
          Lesson(title: 'Analisis Media dan Berita', duration: const Duration(minutes: 3, seconds: 0)),
          Lesson(title: 'Pengambilan Keputusan', duration: const Duration(minutes: 3, seconds: 0)),
        ],
      ),
      Section(
        title: 'Section 3 - Pemecahan Masalah',
        lessons: [
          Lesson(title: 'Logika Deduktif dan Induktif', duration: const Duration(minutes: 3, seconds: 0)),
          Lesson(title: 'Pemecahan Masalah Kompleks', duration: const Duration(minutes: 3, seconds: 30)),
        ],
      ),
    ],
  ),
  Course(
    id: '10',
    title: 'Penalaran Kuantitatif2',
    provider: 'Ahli Statistika Ramy',
    rating: 4.5,
    price: 125.0,
    cardColor: Colors.orange.shade200,
    icon: Icons.bar_chart,
    description: 'Kursus analisis data dan statistik untuk pengambilan keputusan berbasis data dengan aplikasi praktis dalam berbagai bidang.',
    youtubeUrl: 'https://youtu.be/Md3Edm9RCwE?si=-bgYn3b8u4zFyz4q',
    lessons: 22,
    minutes: 5.0,
    sections: [
      Section(
        title: 'Section 1 - Analisis Statistik Lanjutan',
        isExpanded: true,
        lessons: [
          Lesson(title: 'Statistik Inferensial', duration: const Duration(minutes: 3, seconds: 0)),
          Lesson(title: 'Distribusi Probabilitas Kompleks', duration: const Duration(minutes: 3, seconds: 0)),
        ],
      ),
      Section(
        title: 'Section 2 - Pemodelan Matematis',
        lessons: [
          Lesson(title: 'Analisis Regresi Multivariabel', duration: const Duration(minutes: 3, seconds: 0)),
          Lesson(title: 'Pemodelan Prediktif', duration: const Duration(minutes: 3, seconds: 0)),
        ],
      ),
      Section(
        title: 'Section 3 - Interpretasi dan Pengambilan Keputusan',
        lessons: [
          Lesson(title: 'Pengujian Hipotesis Lanjutan', duration: const Duration(minutes: 3, seconds: 0)),
          Lesson(title: 'Analisis Data untuk Pengambilan Keputusan', duration: const Duration(minutes: 3, seconds: 0)),
        ],
      ),
    ],
  ),
];

// Combine featured courses with additional courses
final List<Course> allCourses = [...featuredCoursesList, ...additionalCourses];