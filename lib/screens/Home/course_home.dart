import 'package:flutter/material.dart';
import 'package:ramysmart/screens/Home/widget/category_list.dart';
import 'package:ramysmart/screens/Home/widget/offers.dart';
import 'package:ramysmart/util/constants.dart';
import 'package:ramysmart/screens/Home/widget/featured_courses.dart';
import 'package:ramysmart/screens/Home/widget/cart.dart';
import 'package:ramysmart/screens/Home/widget/my_courses.dart';
import 'package:ramysmart/screens/Home/widget/wishlist.dart';
import 'package:ramysmart/screens/Home/widget/account_profile.dart';
import 'package:ramysmart/screens/Home/widget/notification_page.dart';
import 'package:ramysmart/screens/Home/widget/course_search.dart';
import 'package:ramysmart/screens/Home/widget/search_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseHome extends StatefulWidget {
  final bool showSNBTPopup; // Parameter untuk mengontrol tampilan popup SNBT
  final bool showSNBTFloatingIcon; // Parameter dari splash screen

  const CourseHome({
    super.key,
    this.showSNBTPopup = false,
    this.showSNBTFloatingIcon = true,
  });

  @override
  State<CourseHome> createState() => _CourseHomeState();
}

class _CourseHomeState extends State<CourseHome> {
  int _selectedIndex = 0;
  int currentQuestionIndex = 0;
  Map<int, String> userAnswers = {};
  bool isLoading = false;
  bool showSNBTDialog = false;
  bool showFloatingSNBTIcon = false;

  // Data soal kuesioner SNBT
  final List<Map<String, dynamic>> questions = [
    // Penalaran Umum
    {
      'category': 'Penalaran Umum',
      'question': 'Semua dokter membaca buku medis. Rina adalah seorang dokter. Maka Rina...',
      'options': ['Tidak suka membaca', 'Membaca buku medis', 'Adalah pasien', 'Tidak dapat disimpulkan'],
      'correct': 1,
    },
    {
      'category': 'Penalaran Umum',
      'question': 'Jika semua kucing memiliki kumis dan Luna adalah kucing, maka...',
      'options': ['Luna memiliki ekor', 'Luna bisa terbang', 'Luna memiliki kumis', 'Luna adalah manusia'],
      'correct': 2,
    },
    {
      'category': 'Penalaran Umum',
      'question': 'Ali lebih tinggi dari Budi. Budi lebih tinggi dari Ciko. Siapa paling pendek?',
      'options': ['Ali', 'Budi', 'Ciko', 'Tidak diketahui'],
      'correct': 2,
    },
    {
      'category': 'Penalaran Umum',
      'question': '"Semua burung dapat terbang" adalah...',
      'options': ['Fakta', 'Argumen lemah', 'Pernyataan benar mutlak', 'Hukum ilmiah'],
      'correct': 1,
    },

    // Penalaran Matematika
    {
      'category': 'Penalaran Matematika',
      'question': 'Pola: 2, 5, 10, 17, ... Angka selanjutnya adalah:',
      'options': ['26', '24', '22', '20'],
      'correct': 0,
    },
    {
      'category': 'Penalaran Matematika',
      'question': 'Jika 4x = 20, maka x =',
      'options': ['5', '4', '3', '6'],
      'correct': 0,
    },
    {
      'category': 'Penalaran Matematika',
      'question': 'Segitiga memiliki berapa jumlah sudut?',
      'options': ['360°', '180°', '90°', '270°'],
      'correct': 1,
    },
    {
      'category': 'Penalaran Matematika',
      'question': 'Jika jam sekarang pukul 9 dan ditambahkan 7 jam, maka jam menjadi:',
      'options': ['16', '4', '3', '6'],
      'correct': 0,
    },

    // Literasi Bahasa Indonesia
    {
      'category': 'Literasi Bahasa Indonesia',
      'question': 'Makna kata "efisien" adalah...',
      'options': ['Cepat', 'Praktis dan hemat sumber daya', 'Mahal', 'Tidak efektif'],
      'correct': 1,
    },
    {
      'category': 'Literasi Bahasa Indonesia',
      'question': 'Kalimat efektif adalah...',
      'options': ['Mengulang subjek dua kali', 'Menggunakan kata baku dan tidak boros kata', 'Panjang dan kompleks', 'Menggunakan bahasa sehari-hari saja'],
      'correct': 1,
    },
    {
      'category': 'Literasi Bahasa Indonesia',
      'question': 'Sinonim kata "mandiri" adalah...',
      'options': ['Egois', 'Sombong', 'Berdikari', 'Butuh bantuan'],
      'correct': 2,
    },
    {
      'category': 'Literasi Bahasa Indonesia',
      'question': 'Apa yang dimaksud dengan ide pokok paragraf?',
      'options': ['Kalimat penjelas', 'Kesimpulan', 'Gagasan utama dalam paragraf', 'Kata pertama'],
      'correct': 2,
    },

    // Literasi Bahasa Inggris
    {
      'category': 'Literasi Bahasa Inggris',
      'question': 'The opposite of "hot" is...',
      'options': ['Fire', 'Boil', 'Cold', 'Warm'],
      'correct': 2,
    },
    {
      'category': 'Literasi Bahasa Inggris',
      'question': 'They ___ watching a movie now.',
      'options': ['is', 'are', 'was', 'do'],
      'correct': 1,
    },
    {
      'category': 'Literasi Bahasa Inggris',
      'question': 'What is the correct form: "She ___ to school every day."',
      'options': ['go', 'goes', 'going', 'gone'],
      'correct': 1,
    },
    {
      'category': 'Literasi Bahasa Inggris',
      'question': 'Which sentence is grammatically correct?',
      'options': ['I goes to school', 'He play soccer', 'She eats breakfast', 'They is happy'],
      'correct': 2,
    },

    // Penalaran Kuantitatif
    {
      'category': 'Penalaran Kuantitatif',
      'question': 'Jika data: 4, 6, 8, maka rata-ratanya adalah:',
      'options': ['6', '7', '5', '8'],
      'correct': 0,
    },
    {
      'category': 'Penalaran Kuantitatif',
      'question': 'Grafik menunjukkan jumlah siswa selama 5 tahun. Tahun mana yang tertinggi?',
      'options': ['Tahun 1', 'Tahun 2', 'Tahun 3', 'Tahun 4'],
      'correct': 2,
    },
    {
      'category': 'Penalaran Kuantitatif',
      'question': 'Persentase dari 50 yang merupakan 10 adalah...',
      'options': ['10%', '20%', '5%', '50%'],
      'correct': 1,
    },
    {
      'category': 'Penalaran Kuantitatif',
      'question': 'Jika harga baju Rp50.000 dan diskon 20%, maka harga setelah diskon adalah...',
      'options': ['Rp45.000', 'Rp40.000', 'Rp30.000', 'Rp35.000'],
      'correct': 1,
    },
  ];

  // Pages
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // PERBAIKAN: Set default showFloatingSNBTIcon = true untuk user baru
    showFloatingSNBTIcon = true;

    // Initialize pages with navigation callbacks
    _pages = [
      _buildHomeContent(),
      MyCourses(
        key: const Key('my_courses'),
        onNavigateToHome: () {
          _onItemTapped(0);
        },
      ),
      const Cart(key: Key('cart')),
      Wishlist(
        key: const Key('wishlist'),
        onNavigateToHome: () {
          _onItemTapped(0);
        },
      ),
      AccountProfile(
        key: const Key('account'),
        onNavigateToHome: () {
          _onItemTapped(0);
        },
      ),
    ];

    // Load floating icon status (ini akan mengupdate showFloatingSNBTIcon berdasarkan SharedPreferences)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadFloatingIconStatus();
    });

    // Show SNBT popup if parameter true
    if (widget.showSNBTPopup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSNBTIntroDialog();
      });
    }

    // Debug: Print parameter values
    print('showSNBTPopup: ${widget.showSNBTPopup}');
    print('showSNBTFloatingIcon: ${widget.showSNBTFloatingIcon}');
  }

  // Load status floating icon dari SharedPreferences
  Future<void> _loadFloatingIconStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasCompletedSNBT = prefs.getBool('snbt_completed') ?? false;
    bool hasClosedIconPermanently = prefs.getBool('snbt_icon_closed_permanently') ?? false;

    setState(() {
      // PERBAIKAN: Tampilkan icon jika user belum menyelesaikan SNBT dan belum menutup permanen
      // Tidak bergantung pada parameter showSNBTFloatingIcon dari parent
      showFloatingSNBTIcon = !hasCompletedSNBT && !hasClosedIconPermanently;
    });

    print('Parameter showSNBTFloatingIcon: ${widget.showSNBTFloatingIcon}');
    print('hasCompletedSNBT: $hasCompletedSNBT');
    print('hasClosedIconPermanently: $hasClosedIconPermanently');
    print('Final showFloatingSNBTIcon: $showFloatingSNBTIcon');
  }

  // Simpan status floating icon ke SharedPreferences
  Future<void> _saveIconClosedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('snbt_icon_closed_permanently', true);
  }

  Future<void> _saveSNBTCompletedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('snbt_completed', true);
  }

  // Add this method to your _CourseHomeState class, around line 160 after _saveSNBTCompletedStatus()

  // Simpan status floating icon ke SharedPreferences
  Future<void> _saveFloatingIconStatus(bool showIcon) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('snbt_icon_visible', showIcon);
  }

// Also, you should update the _finishQuestionnaire method to properly save the completion status:

  void _finishQuestionnaire() async {
    setState(() {
      isLoading = true;
    });

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Menganalisis hasil...'),
          ],
        ),
      ),
    );

    // Simulate analysis time
    await Future.delayed(const Duration(seconds: 2));

    // Analisis hasil
    Map<String, Map<String, int>> categoryResults = _analyzeResults();

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    // Tampilkan hasil
    await _showResults(categoryResults);

    // Save SNBT completion status and hide floating icon setelah kuesioner selesai
    await _saveSNBTCompletedStatus();
    setState(() {
      showFloatingSNBTIcon = false;
      isLoading = false;
    });
  }

  Widget _buildFloatingSNBTIcon() {
    return Positioned(
      top: 120,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(35),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Main icon button
              Center(
                child: GestureDetector(
                  onTap: () {
                    _showSNBTConfirmationDialog(); // Panggil dialog konfirmasi
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/icon/snbt_icon.png',
                          width: 30,
                          height: 30,
                          color: Colors.white,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.quiz,
                              color: Colors.white,
                              size: 24,
                            );
                          },
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'SNBT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Close button
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () async {
                    // Show confirmation dialog
                    bool? shouldClose = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Tutup Kuesioner SNBT?'),
                        content: const Text(
                          'Apakah Anda yakin ingin menutup kuesioner SNBT? Icon ini tidak akan muncul lagi.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    );

                    if (shouldClose == true) {
                      setState(() {
                        showFloatingSNBTIcon = false;
                      });
                      await _saveIconClosedStatus();
                    }
                  },
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
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


  // Show intro dialog for SNBT
  void _showSNBTIntroDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Kuesioner SNBT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Selamat datang! Untuk memberikan rekomendasi kursus yang tepat, silakan isi kuesioner SNBT ini terlebih dahulu.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Set floating icon muncul ketika user memilih "Nanti Saja"
              setState(() {
                showFloatingSNBTIcon = true;
              });
            },
            child: const Text('Nanti Saja'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSNBTQuestionnaire();
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            child: const Text('Mulai Kuesioner'),
          ),
        ],
      ),
    );
  }


  void _showSNBTConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Konfirmasi Kuesioner SNBT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah Anda yakin ingin mengerjakan kuesioner SNBT ini? Kuesioner ini akan membantu kami memberikan rekomendasi kursus yang sesuai dengan kemampuan Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog dan kembali ke icon
            },
            child: const Text('Nanti Saja'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog konfirmasi
              _showSNBTQuestionnaire(); // Mulai kuesioner
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            child: const Text('Ya, Saya Yakin'),
          ),
        ],
      ),
    );
  }

  // Show SNBT questionnaire dialog
  void _showSNBTQuestionnaire() {
    // Reset jawaban dan index pertanyaan saat mulai kuesioner
    currentQuestionIndex = 0;
    userAnswers.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kuesioner SNBT',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                '${currentQuestionIndex + 1}/${questions.length}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / questions.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                ),
                const SizedBox(height: 20),

                // Category
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    questions[currentQuestionIndex]['category'],
                    style: TextStyle(
                      fontSize: 12,
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Question
                Text(
                  questions[currentQuestionIndex]['question'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),

                // Options
                Expanded(
                  child: ListView.builder(
                    itemCount: questions[currentQuestionIndex]['options'].length,
                    itemBuilder: (context, index) {
                      final option = questions[currentQuestionIndex]['options'][index];
                      final isSelected = userAnswers[currentQuestionIndex] == option;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            userAnswers[currentQuestionIndex] = option;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? kPrimaryColor.withOpacity(0.1) : Colors.white,
                            border: Border.all(
                              color: isSelected ? kPrimaryColor : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? kPrimaryColor : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? kPrimaryColor : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                )
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${String.fromCharCode(65 + index)}. $option',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected ? kPrimaryColor : Colors.black,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (currentQuestionIndex > 0)
              TextButton(
                onPressed: () {
                  setState(() {
                    currentQuestionIndex--;
                  });
                },
                child: const Text('Sebelumnya'),
              ),
            ElevatedButton(
              onPressed: userAnswers[currentQuestionIndex] != null
                  ? () {
                if (currentQuestionIndex == questions.length - 1) {
                  // Finish questionnaire
                  Navigator.pop(context);
                  _finishQuestionnaire();
                } else {
                  // Next question
                  setState(() {
                    currentQuestionIndex++;
                  });
                }
              }
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              child: Text(
                currentQuestionIndex == questions.length - 1 ? 'Selesai' : 'Selanjutnya',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Map<String, int>> _analyzeResults() {
    Map<String, Map<String, int>> categoryResults = {
      'Penalaran Umum': {'correct': 0, 'total': 0},
      'Penalaran Matematika': {'correct': 0, 'total': 0},
      'Literasi Bahasa Indonesia': {'correct': 0, 'total': 0},
      'Literasi Bahasa Inggris': {'correct': 0, 'total': 0},
      'Penalaran Kuantitatif': {'correct': 0, 'total': 0},
    };

    for (int i = 0; i < questions.length; i++) {
      String category = questions[i]['category'];

      // Fix: Handle potential typo in category name
      // Ada typo "Literasi Bahang Inggris" di salah satu soal, normalisasi ke "Literasi Bahasa Inggris"
      if (category == 'Literasi Bahang Inggris') {
        category = 'Literasi Bahasa Inggris';
      }

      // Check if category exists in categoryResults
      if (!categoryResults.containsKey(category)) {
        // Skip jika kategori tidak dikenali
        continue;
      }

      // Safe access to correct answer
      int correctIndex = questions[i]['correct'];
      List<String> options = List<String>.from(questions[i]['options']);

      // Validate correct index
      if (correctIndex < 0 || correctIndex >= options.length) {
        continue; // Skip jika index tidak valid
      }

      String correctAnswer = options[correctIndex];
      String? userAnswer = userAnswers[i];

      // Safe increment
      categoryResults[category]!['total'] = (categoryResults[category]!['total'] ?? 0) + 1;

      if (userAnswer != null && userAnswer == correctAnswer) {
        categoryResults[category]!['correct'] = (categoryResults[category]!['correct'] ?? 0) + 1;
      }
    }

    return categoryResults;
  }

  Future<void> _showResults(Map<String, Map<String, int>> results) async {
    List<String> weaknesses = [];

    results.forEach((category, scores) {
      double percentage = (scores['correct']! / scores['total']!) * 100;
      if (percentage < 75) { // Threshold untuk kelemahan
        weaknesses.add(category);
      }
    });

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Hasil Analisis SNBT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (weaknesses.isEmpty)
                const Text(
                  'Selamat! Anda memiliki pemahaman yang baik di semua kategori SNBT.',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                )
              else ...[
                const Text(
                  'Berdasarkan hasil kuesioner, Anda perlu meningkatkan kemampuan di:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...weaknesses.map((weakness) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          weakness,
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
              const SizedBox(height: 15),
              const Text(
                'Kami akan merekomendasikan kursus yang sesuai dengan kebutuhan Anda.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            child: const Text('Mulai Belajar'),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        // Header Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          decoration: const BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Avoid overflow
            children: [
              const SizedBox(height: 10),
              _buildHeader(),
              const SizedBox(height: 20),
              // Updated CourseSearch with proper search functionality
              CourseSearch(onSearch: (String query) {
                // Navigate to search results page when user submits a search
                if (query.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchResultsPage(
                        searchQuery: query,
                        onNavigateBack: () {
                          // Pop back to this screen
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                }
              }),
              const SizedBox(height: 10),
            ],
          ),
        ),
        // Make this section scrollable
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Offers(),
                  FeaturedCourses(key: const Key('featured_courses')),
                  CategoryList(key: const Key('category_list')),
                  // Add padding at bottom for scroll space
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  // Build Header widget with proper navigation functions
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Welcome Ramy",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Let's learn something new today!",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to NotificationPage with callback to return to Home tab
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationPage(
                      onNavigateToHome: () {
                        setState(() {
                          _selectedIndex = 0; // Ensure we're on the home tab when returning
                        });
                      },
                    ),
                  ),
                );
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  color: kOptionColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      const Icon(Icons.notifications, color: Colors.white),
                      Container(
                        height: 10,
                        width: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10,),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountProfile(
                        onNavigateToHome: () {
                          // Ensure we return to home tab
                          setState(() {
                            _selectedIndex = 0;
                          });
                        },
                      ),
                    ));
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  color: kOptionColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _debugIconStatus() {
    print('=== DEBUG ICON STATUS ===');
    print('widget.showSNBTPopup: ${widget.showSNBTPopup}');
    print('widget.showSNBTFloatingIcon: ${widget.showSNBTFloatingIcon}');
    print('showFloatingSNBTIcon (state): $showFloatingSNBTIcon');
    print('_selectedIndex: $_selectedIndex');
    print('========================');
  }

  @override
  Widget build(BuildContext context) {
    _debugIconStatus(); // Untuk debugging
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            _pages[_selectedIndex],

            // Floating SNBT Icon (hanya tampil di home tab dan ketika showFloatingSNBTIcon true)
            if (_selectedIndex == 0 && showFloatingSNBTIcon)
              _buildFloatingSNBTIcon(),
          ],
        ),
      ),
      // Bottom navigation bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 65, // Tingkatkan dari 60 ke 65 untuk memberikan ruang lebih
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              // My Courses
              _buildNavItem(1, Icons.book_outlined, Icons.book, 'My Courses'),
              // Spacer for FAB
              const SizedBox(width: 50),
              // Wishlist
              _buildNavItem(3, Icons.favorite_outline, Icons.favorite, 'Wishlist'),
              // Account
              _buildNavItem(4, Icons.person_outline, Icons.person, 'Account'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0097A7),
        elevation: 5,
        onPressed: () => _onItemTapped(2), // Navigate to Cart (index 2)
        child: Badge(
          isLabelVisible: true,
          label: const Text('3'),
          child: const Icon(
            Icons.shopping_cart,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Build navigation item
  Widget _buildNavItem(int index, IconData outlinedIcon, IconData filledIcon, String label) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4), // Kurangi padding dari 8 ke 4
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: isSelected ? kPrimaryColor : Colors.grey,
              size: 22, // Kurangi ukuran icon dari 24 ke 22
            ),
            const SizedBox(height: 2), // Kurangi spacing dari 4 ke 2
            Flexible( // Tambahkan Flexible wrapper untuk text
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? kPrimaryColor : Colors.grey,
                  fontSize: 10, // Kurangi font size dari 12 ke 10
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis, // Tambahkan overflow handling
                maxLines: 1, // Batasi ke 1 baris
              ),
            ),
          ],
        ),
      ),
    );
  }
}