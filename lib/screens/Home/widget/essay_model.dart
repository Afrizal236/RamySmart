class EssayAssignment {
  final String id;
  final String title;
  final String courseId;
  final String courseName;
  final DateTime dueDate;
  final int duration; // in minutes
  final List<EssayQuestion> questions;
  final bool isCompleted;
  final bool? useFilteredQuestions; // Added to support the filtered questions feature

  EssayAssignment({
    required this.id,
    required this.title,
    required this.courseId,
    required this.courseName,
    required this.dueDate,
    required this.duration,
    required this.questions,
    this.isCompleted = false,
    this.useFilteredQuestions, // Optional parameter to determine if we should use filtered questions
  });

  // Static list of default questions
  static final List<EssayQuestion> _defaultQuestions = [
    // Literasi Bahasa Inggris
    EssayQuestion(
      id: 'eng1',
      category: 'Literasi Bahasa Inggris',
      question: 'Analyze how globalization has influenced the development and evolution of English as an international language. Discuss the positive and negative impacts on local cultures and languages.',
      minWords: 250,
      maxWords: 500,
      hint: 'Consider aspects such as business communication, cultural exchange, language preservation, and digital media.',
    ),
    EssayQuestion(
      id: 'eng2',
      category: 'Literasi Bahasa Inggris',
      question: 'Compare and contrast the use of digital technology in education before and after the COVID-19 pandemic. Discuss how these changes have affected learning outcomes, educational equity, and teaching methodologies.',
      minWords: 275,
      maxWords: 550,
      hint: 'Consider aspects such as access to technology, online learning platforms, student engagement, and the future of hybrid educational models.',
    ),
    EssayQuestion(
      id: 'eng3',
      category: 'Literasi Bahasa Inggris',
      question: 'Analyze the representation of gender and cultural diversity in contemporary English literature and media. How have these representations evolved over the past decade, and what impact do they have on societal attitudes?',
      minWords: 300,
      maxWords: 600,
      hint: 'Examine specific examples from bestselling novels, award-winning films, popular television series, and digital media platforms.',
    ),
    EssayQuestion(
      id: 'eng4',
      category: 'Literasi Bahasa Inggris',
      question: 'Discuss the impact of social media on written English language skills among young adults. Has the rise of platforms like Twitter, Instagram, and TikTok contributed to linguistic innovation or language degradation?',
      minWords: 250,
      maxWords: 500,
      hint: 'Consider aspects such as abbreviations, emoji usage, new vocabulary, grammar changes, and code-switching between formal and informal registers.',
    ),
    EssayQuestion(
      id: 'eng5',
      category: 'Literasi Bahasa Inggris',
      question: 'Examine the challenges and opportunities of multilingualism in an increasingly globalized workplace. How do English language skills intersect with cultural competence in international business contexts?',
      minWords: 300,
      maxWords: 550,
      hint: 'Consider aspects such as business negotiation, cross-cultural communication barriers, English as a lingua franca, and the value of linguistic diversity in global teams.',
    ),

    // Literasi Bahasa Indonesia
    EssayQuestion(
      id: 'ind1',
      category: 'Literasi Bahasa Indonesia',
      question: 'Jelaskan peran sastra kontemporer Indonesia dalam mengangkat isu-isu sosial dan politik dalam dua dekade terakhir. Berikan contoh karya sastra spesifik yang memiliki dampak signifikan terhadap diskursus publik.',
      minWords: 300,
      maxWords: 600,
      hint: 'Pertimbangkan karya dari penulis seperti Eka Kurniawan, Leila S. Chudori, atau Ayu Utami, serta respon masyarakat terhadap karya-karya tersebut.',
    ),
    EssayQuestion(
      id: 'ind2',
      category: 'Literasi Bahasa Indonesia',
      question: 'Analisis perkembangan jurnalisme digital di Indonesia dan dampaknya terhadap kualitas informasi yang diterima masyarakat. Bagaimana media daring telah mengubah cara masyarakat Indonesia mengonsumsi berita dalam dekade terakhir?',
      minWords: 275,
      maxWords: 550,
      hint: 'Pertimbangkan aspek kecepatan penyebaran informasi, fenomena clickbait, media sosial sebagai sumber berita, dan literasi media di kalangan masyarakat.',
    ),
    EssayQuestion(
      id: 'ind3',
      category: 'Literasi Bahasa Indonesia',
      question: 'Telaah perkembangan bahasa gaul dan bahasa alay dalam komunikasi digital di Indonesia. Bagaimana fenomena ini mempengaruhi perkembangan Bahasa Indonesia baku dan kemampuan literasi generasi muda?',
      minWords: 250,
      maxWords: 500,
      hint: 'Pertimbangkan contoh-contoh dari platform media sosial, dampak terhadap pembelajaran Bahasa Indonesia di sekolah, dan sikap Badan Bahasa terhadap fenomena ini.',
    ),
    EssayQuestion(
      id: 'ind4',
      category: 'Literasi Bahasa Indonesia',
      question: 'Bandingkan dan kontraskan gaya penulisan dalam karya sastra Indonesia pada masa kemerdekaan dengan karya sastra Indonesia kontemporer. Apakah ada pergeseran nilai, tema, atau struktur naratif yang signifikan?',
      minWords: 300,
      maxWords: 600,
      hint: 'Analisis karya-karya penulis seperti Pramoedya Ananta Toer dan Chairil Anwar dibandingkan dengan penulis kontemporer seperti Eka Kurniawan, Dee Lestari, atau Andrea Hirata.',
    ),
    EssayQuestion(
      id: 'ind5',
      category: 'Literasi Bahasa Indonesia',
      question: 'Evaluasi peran sastra daerah dalam memperkaya khasanah Bahasa Indonesia. Bagaimana tradisi lisan dan tulisan dari berbagai daerah di Indonesia berkontribusi terhadap identitas nasional dan perkembangan bahasa?',
      minWords: 275,
      maxWords: 550,
      hint: 'Bahas contoh spesifik seperti pantun Melayu, geguritan Jawa, cerita rakyat berbagai daerah, dan upaya pelestarian bahasa daerah melalui sastra.',
    ),

    // Penalaran Umum
    EssayQuestion(
      id: 'reas1',
      category: 'Penalaran Umum',
      question: 'Evaluasi hubungan antara kebebasan berekspresi di media sosial dan tanggung jawab individu. Bagaimana keseimbangan ideal antara kebebasan dan regulasi dapat dicapai dalam konteks era digital saat ini?',
      minWords: 275,
      maxWords: 550,
      hint: 'Pertimbangkan kasus-kasus kontroversial, dampak algoritma, penyebaran hoaks/misinformasi, dan nilai-nilai demokrasi.',
    ),
    EssayQuestion(
      id: 'reas2',
      category: 'Penalaran Umum',
      question: 'Diskusikan dilema etis yang muncul dalam pengembangan dan implementasi teknologi kecerdasan buatan (AI) dalam masyarakat modern. Bagaimana keseimbangan antara inovasi teknologi dan pertimbangan etis dapat dicapai?',
      minWords: 300,
      maxWords: 600,
      hint: 'Bahas aspek privasi data, potensi bias algoritma, dampak otomatisasi terhadap lapangan kerja, dan kerangka regulasi yang mungkin diperlukan.',
    ),
    EssayQuestion(
      id: 'reas3',
      category: 'Penalaran Umum',
      question: 'Analisis hubungan antara perubahan iklim, keamanan pangan, dan stabilitas politik global. Bagaimana ketiga aspek ini saling mempengaruhi, dan apa implikasinya bagi kebijakan internasional?',
      minWords: 275,
      maxWords: 550,
      hint: 'Pertimbangkan studi kasus dari berbagai wilayah geografis, migrasi akibat perubahan iklim, konflik sumber daya, dan upaya diplomasi internasional dalam mengatasi masalah ini.',
    ),
    EssayQuestion(
      id: 'reas4',
      category: 'Penalaran Umum',
      question: 'Evaluasi argumen yang mendukung dan menentang penerapan sistem kuota gender dalam posisi kepemimpinan politik dan bisnis. Bagaimana kebijakan semacam ini mempengaruhi kesetaraan, meritokrasi, dan performa organisasi?',
      minWords: 250,
      maxWords: 500,
      hint: 'Pertimbangkan data empiris dari negara-negara yang telah menerapkan kebijakan serupa, argumen filosofis tentang keadilan dan representasi, serta alternatif kebijakan yang mungkin ada.',
    ),
    EssayQuestion(
      id: 'reas5',
      category: 'Penalaran Umum',
      question: 'Telaah hubungan antara kebebasan pers, media sosial, dan kualitas demokrasi di era digital. Bagaimana sistem politik dapat memastikan integritas informasi sambil menjaga kebebasan berekspresi?',
      minWords: 300,
      maxWords: 600,
      hint: 'Analisis contoh-contoh dari berbagai negara dengan tingkat kebebasan pers yang berbeda, dampak disinformasi terhadap proses demokratis, dan tren regulasi media digital.',
    ),

    // Penalaran Kuantitatif
    EssayQuestion(
      id: 'quant1',
      category: 'Penalaran Kuantitatif',
      question: 'Analisis bagaimana data statistik dapat dimanipulasi untuk mendukung argumen yang berbeda dalam kebijakan publik. Gunakan studi kasus tentang pemanasan global atau kebijakan ekonomi untuk mengilustrasikan poin-poin Anda.',
      minWords: 250,
      maxWords: 500,
      hint: 'Bahas tentang sampling bias, korelasi vs kausalitas, penggunaan grafik yang menyesatkan, dan interpretasi data yang selektif.',
    ),
    EssayQuestion(
      id: 'quant2',
      category: 'Penalaran Kuantitatif',
      question: 'Jelaskan bagaimana analisis biaya-manfaat (cost-benefit analysis) dapat digunakan untuk mengevaluasi kebijakan publik di bidang lingkungan hidup. Ilustrasikan dengan contoh spesifik terkait pengelolaan sumber daya alam.',
      minWords: 250,
      maxWords: 500,
      hint: 'Pertimbangkan cara menghitung nilai ekonomi dari ekosistem, eksternalitas, discount rate untuk manfaat jangka panjang, dan keterbatasan pendekatan kuantitatif dalam valuasi lingkungan.',
    ),
    EssayQuestion(
      id: 'quant3',
      category: 'Penalaran Kuantitatif',
      question: 'Analisis bagaimana interpretasi data statistik dapat mempengaruhi kebijakan kesehatan masyarakat. Gunakan contoh dari kebijakan penanganan pandemi atau program vaksinasi untuk mengilustrasikan argumen Anda.',
      minWords: 275,
      maxWords: 550,
      hint: 'Bahas konsep-konsep seperti risiko relatif vs. risiko absolut, interval kepercayaan, pengukuran akurasi tes medis (sensitivitas dan spesifisitas), dan komunikasi risiko kepada masyarakat.',
    ),
    EssayQuestion(
      id: 'quant4',
      category: 'Penalaran Kuantitatif',
      question: 'Evaluasi efektivitas metode visualisasi data dalam komunikasi informasi kompleks kepada pemangku kebijakan dan masyarakat umum. Bagaimana desain grafis dapat mempengaruhi pemahaman dan pengambilan keputusan?',
      minWords: 250,
      maxWords: 500,
      hint: 'Diskusikan berbagai jenis grafik dan diagram, pertimbangan desain untuk menghindari bias persepsi, dan studi kasus tentang visualisasi data yang berhasil mengubah kebijakan atau perilaku masyarakat.',
    ),
    EssayQuestion(
      id: 'quant5',
      category: 'Penalaran Kuantitatif',
      question: 'Jelaskan bagaimana metodologi penelitian kuantitatif dapat digunakan untuk mengukur dan mengevaluasi efektivitas program pendidikan. Apa kekuatan dan batasan pendekatan berbasis data dalam penilaian hasil belajar?',
      minWords: 300,
      maxWords: 600,
      hint: 'Pertimbangkan desain eksperimental, validitas internal dan eksternal, pengukuran outcome jangka pendek vs. jangka panjang, dan integrasi metode kuantitatif dengan metode kualitatif.',
    ),

    // Penalaran Matematika
    EssayQuestion(
      id: 'math1',
      category: 'Penalaran Matematika',
      question: 'Hitung dan analisis total biaya optimal untuk masalah transportasi berikut: Sebuah perusahaan memiliki 3 pabrik dengan kapasitas produksi masing-masing 80, 60, dan 70 unit. Perusahaan harus mengirim ke 4 distributor dengan permintaan masing-masing 50, 40, 60, dan 60 unit. Biaya pengiriman per unit dari pabrik ke distributor diberikan dalam matriks berikut (dalam ribuan rupiah): [[5, 3, 6, 2], [4, 7, 9, 1], [3, 4, 8, 5]]. Tentukan alokasi pengiriman yang meminimalkan total biaya.',
      minWords: 250,
      maxWords: 500,
      hint: 'Gunakan metode transportasi seperti North-West Corner dan stepping stone untuk mencari solusi awal dan optimal. Tunjukkan perhitungan secara bertahap dan verifikasi bahwa semua batasan terpenuhi.',
    ),
    EssayQuestion(
      id: 'math2',
      category: 'Penalaran Matematika',
      question: 'Sebuah jaringan PERT/CPM proyek konstruksi memiliki aktivitas berikut dengan durasi (dalam hari): A(5), B(3), C(6), D(4), E(8), F(7), G(2), H(5). Ketergantungan antar aktivitas: A→B, A→C, B→D, B→E, C→F, D→G, E→G, F→G, G→H. Hitung jalur kritis, waktu penyelesaian minimum, dan total slack untuk setiap aktivitas. Jika aktivitas E harus ditunda 2 hari, bagaimana pengaruhnya terhadap waktu penyelesaian proyek?',
      minWords: 275,
      maxWords: 550,
      hint: 'Buat diagram jaringan, hitung ES, EF, LS, LF untuk setiap aktivitas, identifikasi jalur kritis, dan analisis dampak penundaan dengan perhitungan matematis detail.',
    ),
    EssayQuestion(
      id: 'math3',
      category: 'Penalaran Matematika',
      question: 'Menggunakan metode simpleks, selesaikan masalah pemrograman linear berikut: Maksimalkan Z = 5x + 7y + 3z dengan batasan: 2x + y + z ≤ 14; x + 2y + z ≤ 12; 2x + y + 2z ≤ 18; x, y, z ≥ 0. Hitung nilai optimal dari x, y, z dan nilai maksimum dari Z. Interpretasikan hasil solusi dalam konteks penggunaan sumber daya.',
      minWords: 300,
      maxWords: 600,
      hint: 'Ubah ke bentuk standar dengan variabel slack, buat tabel simpleks awal, lakukan iterasi sampai optimal, tunjukkan semua langkah perhitungan dan interpretasikan nilai variabel slack dalam konteks batasan sumber daya.',
    ),
    EssayQuestion(
      id: 'math4',
      category: 'Penalaran Matematika',
      question: 'Sebuah sistem antrian memiliki rata-rata kedatangan (λ) 15 pelanggan per jam dan rata-rata layanan (μ) 20 pelanggan per jam dengan 2 server paralel. Menggunakan model antrian M/M/2, hitung: probabilitas tidak ada pelanggan dalam sistem, jumlah rata-rata pelanggan dalam sistem dan antrian, waktu rata-rata pelanggan dalam sistem dan antrian, dan utilisasi server. Jika biaya menunggu pelanggan Rp50.000/jam dan biaya server Rp75.000/jam, tentukan jumlah server optimal.',
      minWords: 250,
      maxWords: 500,
      hint: 'Gunakan rumus model antrian M/M/s untuk menghitung semua parameter. Bandingkan total biaya operasional (biaya server + biaya menunggu) untuk berbagai jumlah server untuk menentukan konfigurasi optimal.',
    ),
    EssayQuestion(
      id: 'math5',
      category: 'Penalaran Matematika',
      question: 'Analisis numerik: Gunakan metode Newton-Raphson untuk menemukan akar persamaan f(x) = x³ - 4x² + 5x - 2 dengan nilai awal x₀ = 2. Hitung minimal 4 iterasi dengan ketelitian 5 angka desimal. Bandingkan dengan metode bisection pada interval [0,1] untuk 4 iterasi dan analisis kecepatan konvergensi kedua metode tersebut melalui perhitungan galat relatif.',
      minWords: 275,
      maxWords: 550,
      hint: 'Tunjukkan rumus umum metode Newton-Raphson dan bisection, hitung turunan f\'(x), lakukan iterasi langkah demi langkah dengan ketelitian tinggi, dan buat tabel perbandingan galat relatif untuk kedua metode.',
    ),
  ];

  factory EssayAssignment.withDefaultQuestions({
    required String id,
    required String title,
    required String courseId,
    required String courseName,
    required DateTime dueDate,
    required int duration,
    bool useFilteredQuestions = false, // Added parameter with default value
  }) {
    return EssayAssignment(
      id: id,
      title: title,
      courseId: courseId,
      courseName: courseName,
      dueDate: dueDate,
      duration: duration,
      questions: _defaultQuestions.map((q) => q.copyWith(id: '${id}_${q.id}')).toList(),
      useFilteredQuestions: useFilteredQuestions, // Add this parameter
    );
  }

  // New factory method for creating assignment with questions filtered by category
  factory EssayAssignment.withCategoryQuestions({
    required String id,
    required String title,
    required String courseId,
    required String courseName,
    required DateTime dueDate,
    required int duration,
    required String category,
    bool useFilteredQuestions = true, // Default to true for this factory
  }) {
    // Filter questions by category
    final categoryQuestions = _defaultQuestions
        .where((q) => q.category == category)
        .map((q) => q.copyWith(id: '${id}_${q.id}'))
        .toList();

    return EssayAssignment(
      id: id,
      title: title,
      courseId: courseId,
      courseName: courseName,
      dueDate: dueDate,
      duration: duration,
      questions: categoryQuestions,
      useFilteredQuestions: useFilteredQuestions, // Add this parameter
    );
  }

  // New factory method for creating an assignment with multiple categories
  // Each category will be represented by one question
  factory EssayAssignment.withMultipleCategories({
    required String id,
    required String title,
    required String courseId,
    required String courseName,
    required DateTime dueDate,
    required int duration,
    List<String>? categories, // Optional list of specific categories to include
  }) {
    // Use all categories if none specified
    final categoriesToUse = categories ?? [
      'Penalaran Matematika',
      'Penalaran Kuantitatif',
      'Penalaran Umum',
      'Literasi Bahasa Inggris',
      'Literasi Bahasa Indonesia',
    ];

    // Get one question per category
    final List<EssayQuestion> selectedQuestions = [];

    for (var category in categoriesToUse) {
      final categoryQuestions = _defaultQuestions
          .where((q) => q.category.toLowerCase() == category.toLowerCase())
          .toList();

      if (categoryQuestions.isNotEmpty) {
        // Add first question from each category
        selectedQuestions.add(categoryQuestions.first.copyWith(id: '${id}_${categoryQuestions.first.id}'));
      }
    }

    return EssayAssignment(
      id: id,
      title: title,
      courseId: courseId,
      courseName: courseName,
      dueDate: dueDate,
      duration: duration,
      questions: selectedQuestions,
      useFilteredQuestions: true, // This assignment type is always filtered
    );
  }

  EssayAssignment copyWith({
    String? id,
    String? title,
    String? courseId,
    String? courseName,
    DateTime? dueDate,
    int? duration,
    List<EssayQuestion>? questions,
    bool? isCompleted,
    bool? useFilteredQuestions,
  }) {
    return EssayAssignment(
      id: id ?? this.id,
      title: title ?? this.title,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      dueDate: dueDate ?? this.dueDate,
      duration: duration ?? this.duration,
      questions: questions ?? this.questions,
      isCompleted: isCompleted ?? this.isCompleted,
      useFilteredQuestions: useFilteredQuestions ?? this.useFilteredQuestions,
    );
  }

  int getRemainingTimeInSeconds() {
    return duration * 60; // Convert minutes to seconds
  }
}

class EssayQuestion {
  final String id;
  final String category;
  final String question;
  final int minWords;
  final int maxWords;
  final String? hint;
  final String? userAnswer;

  EssayQuestion({
    required this.id,
    required this.category,
    required this.question,
    required this.minWords,
    required this.maxWords,
    this.hint,
    this.userAnswer,
  });

  EssayQuestion copyWith({
    String? id,
    String? category,
    String? question,
    int? minWords,
    int? maxWords,
    String? hint,
    String? userAnswer,
  }) {
    return EssayQuestion(
      id: id ?? this.id,
      category: category ?? this.category,
      question: question ?? this.question,
      minWords: minWords ?? this.minWords,
      maxWords: maxWords ?? this.maxWords,
      hint: hint ?? this.hint,
      userAnswer: userAnswer ?? this.userAnswer,
    );
  }

  int get wordCount {
    if (userAnswer == null || userAnswer!.isEmpty) return 0;
    return userAnswer!.split(' ').where((word) => word.trim().isNotEmpty).length;
  }

  bool isAnswerValid() {
    return wordCount >= minWords && wordCount <= maxWords;
  }
}

// Create a simple model for essay assignment results
class EssayResult {
  final String assignmentId;
  final DateTime submittedDate;
  final Map<String, String> answers; // questionId -> answer
  final Map<String, int> scores; // questionId -> score
  final int totalScore;
  final String? feedback;

  EssayResult({
    required this.assignmentId,
    required this.submittedDate,
    required this.answers,
    required this.scores,
    required this.totalScore,
    this.feedback,
  });

  factory EssayResult.initial(String assignmentId) {
    return EssayResult(
      assignmentId: assignmentId,
      submittedDate: DateTime.now(),
      answers: {},
      scores: {},
      totalScore: 0,
    );
  }

  EssayResult copyWith({
    String? assignmentId,
    DateTime? submittedDate,
    Map<String, String>? answers,
    Map<String, int>? scores,
    int? totalScore,
    String? feedback,
  }) {
    return EssayResult(
      assignmentId: assignmentId ?? this.assignmentId,
      submittedDate: submittedDate ?? this.submittedDate,
      answers: answers ?? this.answers,
      scores: scores ?? this.scores,
      totalScore: totalScore ?? this.totalScore,
      feedback: feedback ?? this.feedback,
    );
  }
}