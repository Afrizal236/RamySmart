import 'dart:math';

// Model data untuk Assignment (Tugas)
class Assignment {
  final String id;
  final String title;
  final String courseId;
  final String courseName;
  final DateTime dueDate;
  final bool isCompleted;
  final List<McqQuestion> questions;
  final int duration; // Duration in minutes
  final int passingScore; // Minimum score to pass the assignment (0-100)

  Assignment({
    required this.id,
    required this.title,
    required this.courseId,
    required this.courseName,
    required this.dueDate,
    this.isCompleted = false,
    this.questions = const [],
    this.duration = 60, // Default 60 minutes
    this.passingScore = 70, // Default passing score is 70%
  });

  // Method to create a copy with a modified isCompleted status
  Assignment copyWith({
    bool? isCompleted,
    List<McqQuestion>? questions,
    int? duration,
    int? passingScore,
  }) {
    return Assignment(
      id: id,
      title: title,
      courseId: courseId,
      courseName: courseName,
      dueDate: dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      questions: questions ?? this.questions,
      duration: duration ?? this.duration,
      passingScore: passingScore ?? this.passingScore,
    );
  }

  // Factory method to create an assignment with auto-generated questions
  factory Assignment.withQuestions({
    required String id,
    required String title,
    required String courseId,
    required String courseName,
    required DateTime dueDate,
    bool isCompleted = false,
    int questionCount = 10,
    int duration = 60,
    int passingScore = 70,
  }) {
    // Generate questions based on course type
    List<McqQuestion> questions = QuestionGenerator.generateQuestionsForCourse(
      courseId,
      courseName,
      count: questionCount,
    );

    return Assignment(
      id: id,
      title: title,
      courseId: courseId,
      courseName: courseName,
      dueDate: dueDate,
      isCompleted: isCompleted,
      questions: questions,
      duration: duration,
      passingScore: passingScore,
    );
  }

  // Calculate the current score if the assignment has been attempted
  double calculateScore() {
    if (questions.isEmpty) return 0;

    int answeredCorrectly = questions.where((q) => q.isAnswered && q.isCorrect).length;
    return (answeredCorrectly / questions.length) * 100;
  }

  // Check if all questions have been answered
  bool get isFullyAnswered => questions.every((q) => q.isAnswered);

  // Check if the user has passed the assignment
  bool get isPassed => calculateScore() >= passingScore;

  // Calculate time remaining in seconds from now
  int getRemainingTimeInSeconds() {
    final now = DateTime.now();
    if (dueDate.isAfter(now)) {
      return dueDate.difference(now).inSeconds;
    }
    return 0;
  }
}

// Model data untuk Multiple Choice Question
class McqQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  int? selectedAnswerIndex; // The user's selected answer, null if not answered
  final String? explanation; // Optional explanation of the correct answer

  McqQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.selectedAnswerIndex,
    this.explanation,
  });

  // Create a copy of the question with updated selected answer
  McqQuestion copyWith({int? selectedAnswerIndex}) {
    return McqQuestion(
      id: id,
      question: question,
      options: options,
      correctAnswerIndex: correctAnswerIndex,
      selectedAnswerIndex: selectedAnswerIndex ?? this.selectedAnswerIndex,
      explanation: explanation,
    );
  }

  // Check if the selected answer is correct
  bool get isCorrect => selectedAnswerIndex == correctAnswerIndex;

  // Check if the question has been answered
  bool get isAnswered => selectedAnswerIndex != null;
}

// Helper class to generate questions for assignments based on course type
class QuestionGenerator {
  // Generate MCQ questions based on course ID and title
  static List<McqQuestion> generateQuestionsForCourse(
      String courseId,
      String courseTitle,
      {int count = 10}
      ) {
    // Get the appropriate question pool
    List<McqQuestion> questionPool;

    if (courseTitle.contains('Bahasa Indonesia2')) {
      questionPool = _generateBahasaIndonesiaTingkatLanjutQuestions(courseId);
    } else if (courseTitle.contains('Bahasa Indonesia')) {
      questionPool = _generateBahasaIndonesiaQuestions(courseId);
    } else if (courseTitle.contains('Bahasa Inggris2')) {
      questionPool = _generateBahasaInggrisProfessionalQuestions(courseId);
    } else if (courseTitle.contains('Bahasa Inggris')) {
      questionPool = _generateBahasaInggrisQuestions(courseId);
    } else if (courseTitle.contains('Matematika2')) {
      questionPool = _generateMatematikaKomprehensifQuestions(courseId);
    } else if (courseTitle.contains('Matematika')) {
      questionPool = _generateMatematikaQuestions(courseId);
    } else if (courseTitle.contains('Kuantitatif2')) {
      questionPool = _generatePenalaranKuantitatifAnalitisQuestions(courseId);
    } else if (courseTitle.contains('Kuantitatif')) {
      questionPool = _generateKuantitatifQuestions(courseId);
    } else if (courseTitle.contains('Umum2')) {
      questionPool = _generatePenalaranUmumLogikaQuestions(courseId);
    } else if (courseTitle.contains('Umum')) {
      questionPool = _generatePenalaranUmumQuestions(courseId);
    } else {
      questionPool = _generateGenericQuestions(courseId);
    }

    // Return requested number of questions, or all if pool is smaller
    if (questionPool.length <= count) {
      return questionPool;
    }

    // Shuffle and take the requested number
    questionPool.shuffle(Random());
    return questionPool.take(count).toList();
  }


  static List<McqQuestion> _generateBahasaInggrisQuestions(String courseId) {
    return [
      McqQuestion(
        id: '${courseId}_q1',
        question: 'Which of the following is the correct use of present perfect tense?',
        options: [
          'I am going to school yesterday',
          'I have been to London three times',
          'I will go to the market tomorrow',
          'I am going to the cinema now',
        ],
        correctAnswerIndex: 1,
        explanation: 'Present perfect tense uses "have/has" + past participle to describe experiences or actions that happened at an unspecified time in the past.',
      ),
      McqQuestion(
        id: '${courseId}_q2',
        question: 'Choose the correct sentence:',
        options: [
          'She dont like coffee',
          'She doesn\'t likes coffee',
          'She doesn\'t like coffee',
          'She not like coffee',
        ],
        correctAnswerIndex: 2,
        explanation: 'In negative present simple with third person singular, we use "doesn\'t" followed by the base form of the verb (without -s).',
      ),
      McqQuestion(
        id: '${courseId}_q3',
        question: 'Which word is an adverb?',
        options: [
          'Quick',
          'Quickly',
          'Quickness',
          'Quicken',
        ],
        correctAnswerIndex: 1,
        explanation: 'Adverbs often end in -ly and modify verbs, adjectives, or other adverbs. "Quickly" is an adverb that describes how an action is performed.',
      ),
      McqQuestion(
        id: '${courseId}_q4',
        question: 'What is the passive voice of "They are building a new hospital"?',
        options: [
          'A new hospital is built by them',
          'A new hospital was built by them',
          'A new hospital is being built by them',
          'A new hospital has been built by them',
        ],
        correctAnswerIndex: 2,
        explanation: 'To form the passive voice, we use the appropriate form of "be" + past participle. Since the original sentence is in present continuous, we use "is being" + past participle.',
      ),
      McqQuestion(
        id: '${courseId}_q5',
        question: 'Which sentence contains a gerund?',
        options: [
          'I like to swim',
          'She enjoys swimming',
          'He will swim tomorrow',
          'They swam yesterday',
        ],
        correctAnswerIndex: 1,
        explanation: 'A gerund is a verb form ending in -ing used as a noun. In "She enjoys swimming", the word "swimming" is a gerund functioning as the object of the verb "enjoys".',
      ),
      McqQuestion(
        id: '${courseId}_q6',
        question: 'Which of the following is a correct conditional sentence (second conditional)?',
        options: [
          'If it rains, I will take an umbrella',
          'If I won the lottery, I would buy a house',
          'If I had studied harder, I would have passed the exam',
          'If she comes, I am happy',
        ],
        correctAnswerIndex: 1,
        explanation: 'The second conditional uses the structure: "If + past simple, would + infinitive" to talk about imaginary or hypothetical situations in the present or future.',
      ),
      McqQuestion(
        id: '${courseId}_q7',
        question: 'Choose the correct reported speech for "I am tired," she said.',
        options: [
          'She said that she was tired',
          'She said that she is tired',
          'She said that I am tired',
          'She said that I was tired',
        ],
        correctAnswerIndex: 0,
        explanation: 'In reported speech, when the reporting verb is in the past tense, the present tense "am" changes to "was" and pronouns change from first to third person.',
      ),
      McqQuestion(
        id: '${courseId}_q8',
        question: 'What is the comparative form of "good"?',
        options: [
          'Gooder',
          'Better',
          'More good',
          'Best',
        ],
        correctAnswerIndex: 1,
        explanation: '"Good" is an irregular adjective. Its comparative form is "better" and its superlative form is "best".',
      ),
      McqQuestion(
        id: '${courseId}_q9',
        question: 'Choose the sentence with the correct use of articles:',
        options: [
          'I saw a elephant at the zoo',
          'She is best student in the class',
          'He bought an umbrella for the rainy season',
          'We visited an university last year',
        ],
        correctAnswerIndex: 2,
        explanation: 'We use "an" before words that begin with a vowel sound and "a" before words that begin with a consonant sound. "The" is used for specific nouns.',
      ),
      McqQuestion(
        id: '${courseId}_q10',
        question: 'Which sentence contains a phrasal verb?',
        options: [
          'She walked across the street',
          'He looked up the word in the dictionary',
          'They ate dinner quickly',
          'We drove to the mall',
        ],
        correctAnswerIndex: 1,
        explanation: 'A phrasal verb consists of a verb and a preposition or adverb that creates a meaning different from the original verb. "Look up" means to search for information, which is different from simply "looking".',
      ),
    ];
  }

// Generate questions for Matematika courses
  static List<McqQuestion> _generateMatematikaQuestions(String courseId) {
    return [
      McqQuestion(
        id: '${courseId}_q1',
        question: 'Jika x + 3 = 8, maka nilai x adalah:',
        options: ['3', '5', '8', '11'],
        correctAnswerIndex: 1,
        explanation: 'x + 3 = 8 → x = 8 - 3 = 5',
      ),
      McqQuestion(
        id: '${courseId}_q2',
        question: 'Hasil dari 3x² - 2x + 5 untuk x = 2 adalah:',
        options: ['9', '11', '13', '15'],
        correctAnswerIndex: 2,
        explanation: '3(2)² - 2(2) + 5 = 3(4) - 4 + 5 = 12 - 4 + 5 = 13',
      ),
      McqQuestion(
        id: '${courseId}_q3',
        question: 'Jika a : b = 2 : 3 dan b : c = 4 : 5, maka a : c =',
        options: ['8 : 15', '2 : 5', '8 : 5', '6 : 5'],
        correctAnswerIndex: 0,
        explanation: 'a : b = 2 : 3 berarti a = 2k dan b = 3k. b : c = 4 : 5 berarti b = 4m dan c = 5m. Karena b = 3k = 4m, maka k = 4m/3. Sehingga a = 2k = 2(4m/3) = 8m/3. Jadi a : c = 8m/3 : 5m = 8 : 15.',
      ),
      McqQuestion(
        id: '${courseId}_q4',
        question: 'Faktor dari x² - 9 adalah:',
        options: [
          '(x - 3)(x - 3)',
          '(x - 3)(x + 3)',
          '(x + 3)(x + 3)',
          '(x - 9)(x + 1)',
        ],
        correctAnswerIndex: 1,
        explanation: 'x² - 9 = x² - 3² = (x - 3)(x + 3). Ini adalah bentuk selisih kuadrat.',
      ),
      McqQuestion(
        id: '${courseId}_q5',
        question: 'Luas lingkaran dengan jari-jari 7 cm adalah:',
        options: [
          '49π cm²',
          '14π cm²',
          '21π cm²',
          '154 cm²',
        ],
        correctAnswerIndex: 0,
        explanation: 'Luas lingkaran = πr² = π(7)² = 49π cm²',
      ),
      McqQuestion(
        id: '${courseId}_q6',
        question: 'Persamaan garis yang melalui titik (2, 3) dan (4, 7) adalah:',
        options: [
          'y = 2x - 1',
          'y = 2x + 1',
          'y = 2x - 2',
          'y = 2x',
        ],
        correctAnswerIndex: 0,
        explanation: 'Gradien m = (y₂ - y₁)/(x₂ - x₁) = (7 - 3)/(4 - 2) = 4/2 = 2. Menggunakan persamaan y - y₁ = m(x - x₁), kita dapatkan y - 3 = 2(x - 2) → y - 3 = 2x - 4 → y = 2x - 1',
      ),
      McqQuestion(
        id: '${courseId}_q7',
        question: 'Jika log₂ x = 3, maka nilai x adalah:',
        options: ['6', '8', '9', '16'],
        correctAnswerIndex: 1,
        explanation: 'log₂ x = 3 berarti 2³ = x, sehingga x = 8',
      ),
      McqQuestion(
        id: '${courseId}_q8',
        question: 'Turunan dari f(x) = x³ + 2x² - 5x + 1 adalah:',
        options: [
          'f\'(x) = 3x² + 4x - 5',
          'f\'(x) = 3x² + 2x - 5',
          'f\'(x) = 3x² + 4x - 1',
          'f\'(x) = x² + 4x - 5',
        ],
        correctAnswerIndex: 0,
        explanation: 'f\'(x) = 3x² + 4x - 5 (turunan dari x³ adalah 3x², turunan dari 2x² adalah 4x, turunan dari -5x adalah -5, dan turunan dari konstanta 1 adalah 0)',
      ),
      McqQuestion(
        id: '${courseId}_q9',
        question: 'Jika sin(x) = 0.5, maka nilai x yang mungkin adalah:',
        options: [
          '30° atau 150°',
          '45° atau 135°',
          '60° atau 120°',
          '90° atau 270°',
        ],
        correctAnswerIndex: 0,
        explanation: 'Jika sin(x) = 0.5, maka x = 30° atau x = 150° (karena sin(30°) = sin(150°) = 0.5)',
      ),
      McqQuestion(
        id: '${courseId}_q10',
        question: 'Nilai dari lim_{x→0} (sin x)/x adalah:',
        options: [
          '0',
          '1',
          '∞',
          'Tidak terdefinisi',
        ],
        correctAnswerIndex: 1,
        explanation: 'lim_{x→0} (sin x)/x = 1 adalah hasil yang sudah diketahui dalam kalkulus.',
      ),
    ];
  }

// Generate questions for Penalaran Kuantitatif courses
  static List<McqQuestion> _generateKuantitatifQuestions(String courseId) {
    return [
      McqQuestion(
        id: '${courseId}_q1',
        question: 'Jika 25% dari suatu bilangan adalah 20, maka bilangan tersebut adalah:',
        options: ['5', '40', '80', '100'],
        correctAnswerIndex: 2,
        explanation: 'Misalkan bilangan tersebut x, maka 25% × x = 20 → x = 20 ÷ 0.25 = 80',
      ),
      McqQuestion(
        id: '${courseId}_q2',
        question: 'Sebuah toko memberikan diskon 20% untuk semua barang. Jika harga setelah diskon adalah Rp160.000, berapa harga asli barang tersebut?',
        options: [
          'Rp180.000',
          'Rp192.000',
          'Rp200.000',
          'Rp240.000',
        ],
        correctAnswerIndex: 2,
        explanation: 'Misalkan harga asli = x. Maka x - 20% × x = 160.000 → 80% × x = 160.000 → x = 160.000 ÷ 0.8 = 200.000',
      ),
      McqQuestion(
        id: '${courseId}_q3',
        question: 'Jika 4 orang menyelesaikan pekerjaan dalam 6 hari, berapa lama waktu yang dibutuhkan 3 orang untuk menyelesaikan pekerjaan yang sama?',
        options: [
          '4,5 hari',
          '8 hari',
          '9 hari',
          '12 hari',
        ],
        correctAnswerIndex: 1,
        explanation: 'Waktu berbanding terbalik dengan jumlah pekerja. Jadi, 6 × 4 / 3 = 8 hari',
      ),
      McqQuestion(
        id: '${courseId}_q4',
        question: 'Jika mobil A dapat menempuh jarak 240 km dengan 15 liter bensin, berapa liter bensin yang dibutuhkan untuk menempuh jarak 320 km?',
        options: [
          '20 liter',
          '22 liter',
          '24 liter',
          '26 liter',
        ],
        correctAnswerIndex: 0,
        explanation: 'Bensin berbanding lurus dengan jarak. Perbandingan: 15/240 = x/320 → x = 15 × 320 / 240 = 20 liter',
      ),
      McqQuestion(
        id: '${courseId}_q5',
        question: 'Jika 3 kg apel dan 2 kg jeruk harganya Rp65.000, sedangkan 2 kg apel dan 3 kg jeruk harganya Rp55.000, berapa harga 1 kg apel?',
        options: [
          'Rp10.000',
          'Rp15.000',
          'Rp20.000',
          'Rp25.000',
        ],
        correctAnswerIndex: 1,
        explanation: 'Misalkan harga 1 kg apel = x dan harga 1 kg jeruk = y. Maka: 3x + 2y = 65.000 dan 2x + 3y = 55.000. Dari persamaan kedua: 2x = 55.000 - 3y. Substitusi ke persamaan pertama: 3x + 2y = 65.000 → 3(55.000 - 3y)/2 + 2y = 65.000 → 165.000 - 9y + 4y = 130.000 → 165.000 - 5y = 130.000 → -5y = -35.000 → y = 7.000. Substitusi nilai y ke 2x + 3y = 55.000: 2x + 3(7.000) = 55.000 → 2x + 21.000 = 55.000 → 2x = 34.000 → x = 17.000. Jadi harga 1 kg apel adalah Rp17.000 (bukan pilihan). Cek kembali: 3(15.000) + 2(10.000) = 45.000 + 20.000 = 65.000. Maka harga 1 kg apel adalah Rp15.000.',
      ),
      McqQuestion(
        id: '${courseId}_q6',
        question: 'Perbandingan uang Ali dan Budi adalah 3 : 4. Jika jumlah uang mereka Rp210.000, berapa selisih uang mereka?',
        options: [
          'Rp30.000',
          'Rp40.000',
          'Rp50.000',
          'Rp60.000',
        ],
        correctAnswerIndex: 0,
        explanation: 'Misalkan perbandingan = 3x : 4x, maka 3x + 4x = 210.000 → 7x = 210.000 → x = 30.000. Jadi uang Ali = 3 × 30.000 = 90.000 dan uang Budi = 4 × 30.000 = 120.000. Selisih = 120.000 - 90.000 = 30.000',
      ),
      McqQuestion(
        id: '${courseId}_q7',
        question: 'Sebuah mobil melaju dengan kecepatan 60 km/jam. Berapa kecepatan mobil tersebut dalam meter per detik?',
        options: [
          '16,67 m/detik',
          '20 m/detik',
          '36 m/detik',
          '60 m/detik',
        ],
        correctAnswerIndex: 0,
        explanation: '60 km/jam = 60 × 1000 / 3600 = 16,67 m/detik',
      ),
      McqQuestion(
        id: '${courseId}_q8',
        question: 'Anton dapat menyelesaikan sebuah proyek dalam 12 hari, sedangkan Budi dapat menyelesaikannya dalam 8 hari. Jika mereka bekerja bersama, berapa hari yang diperlukan untuk menyelesaikan proyek tersebut?',
        options: [
          '4 hari',
          '4,8 hari',
          '5 hari',
          '6 hari',
        ],
        correctAnswerIndex: 1,
        explanation: 'Bagian pekerjaan yang diselesaikan Anton dalam 1 hari = 1/12. Bagian pekerjaan yang diselesaikan Budi dalam 1 hari = 1/8. Jika bekerja bersama, dalam 1 hari mereka menyelesaikan 1/12 + 1/8 = (2+3)/24 = 5/24 bagian pekerjaan. Waktu yang diperlukan = 1 / (5/24) = 24/5 = 4,8 hari',
      ),
      McqQuestion(
        id: '${courseId}_q9',
        question: 'Sebuah tangki air dapat diisi penuh dalam 4 jam menggunakan pipa A, atau dalam 6 jam menggunakan pipa B. Jika kedua pipa digunakan bersama, berapa lama waktu yang diperlukan untuk mengisi tangki tersebut?',
        options: [
          '2 jam',
          '2,4 jam',
          '3 jam',
          '5 jam',
        ],
        correctAnswerIndex: 1,
        explanation: 'Bagian tangki yang diisi pipa A dalam 1 jam = 1/4. Bagian tangki yang diisi pipa B dalam 1 jam = 1/6. Jika keduanya digunakan, dalam 1 jam mereka mengisi 1/4 + 1/6 = (3+2)/12 = 5/12 bagian tangki. Waktu yang diperlukan = 1 / (5/12) = 12/5 = 2,4 jam',
      ),
      McqQuestion(
        id: '${courseId}_q10',
        question: 'Jika seorang pedagang mendapatkan keuntungan 25% dari harga beli, berapa persen keuntungan tersebut dari harga jual?',
        options: [
          '20%',
          '25%',
          '30%',
          '40%',
        ],
        correctAnswerIndex: 0,
        explanation: 'Misalkan harga beli = 100. Keuntungan = 25% × 100 = 25. Harga jual = 100 + 25 = 125. Persen keuntungan dari harga jual = (25/125) × 100% = 20%',
      ),
    ];
  }

// Generate questions for Penalaran Umum courses
  static List<McqQuestion> _generatePenalaranUmumQuestions(String courseId) {
    return [
      McqQuestion(
        id: '${courseId}_q1',
        question: 'Jika semua kucing adalah hewan, dan beberapa hewan adalah mamalia, maka:',
        options: [
          'Semua kucing adalah mamalia',
          'Beberapa kucing adalah mamalia',
          'Semua mamalia adalah kucing',
          'Tidak ada kucing yang mamalia',
        ],
        correctAnswerIndex: 1,
        explanation: 'Dari premis yang diberikan, kita hanya bisa menyimpulkan bahwa beberapa kucing mungkin mamalia, tidak bisa memastikan semua kucing adalah mamalia.',
      ),
      McqQuestion(
        id: '${courseId}_q2',
        question: 'Manakah dari pernyataan berikut yang merupakan kesimpulan logis dari: "Jika hujan, maka jalanan basah" dan "Jalanan tidak basah"?',
        options: [
          'Hujan',
          'Tidak hujan',
          'Jalanan kering',
          'Hujan atau tidak hujan',
        ],
        correctAnswerIndex: 1,
        explanation: 'Ini adalah contoh modus tollens: Jika P maka Q, tidak Q, maka tidak P. Jika hujan maka jalanan basah, jalanan tidak basah, maka tidak hujan.',
      ),
      McqQuestion(
        id: '${courseId}_q3',
        question: 'Lima orang (A, B, C, D, dan E) berdiri dalam satu baris. Jika A di sebelah B, B di sebelah C, C di sebelah D, dan D di sebelah E, maka berapa banyak kemungkinan urutan berdiri mereka?',
        options: [
          '1',
          '2',
          '5',
          '120',
        ],
        correctAnswerIndex: 1,
        explanation: 'Karena setiap orang harus berdiri di sebelah orang yang ditentukan, maka urutan yang mungkin hanya ada 2: ABCDE atau EDCBA.',
      ),
      McqQuestion(
        id: '${courseId}_q4',
        question: 'Jika tidak semua politisi jujur dan semua politisi ambisius, maka:',
        options: [
          'Semua politisi tidak jujur',
          'Beberapa politisi jujur dan ambisius',
          'Beberapa politisi tidak jujur dan ambisius',
          'Tidak ada politisi yang jujur',
        ],
        correctAnswerIndex: 2,
        explanation: 'Jika tidak semua politisi jujur, berarti beberapa politisi tidak jujur. Dan jika semua politisi ambisius, maka beberapa politisi tidak jujur dan ambisius.',
      ),
      McqQuestion(
        id: '${courseId}_q5',
        question: 'Dalam sebuah kontes, peserta A mendapat peringkat lebih tinggi dari B, C mendapat peringkat lebih tinggi dari D, B mendapat peringkat lebih tinggi dari C. Siapa yang mendapat peringkat terendah?',
        options: [
          'A',
          'B',
          'C',
          'D',
        ],
        correctAnswerIndex: 3,
        explanation: 'Dari informasi yang diberikan, urutan peringkat adalah A > B > C > D. Jadi D mendapat peringkat terendah.',
      ),
      McqQuestion(
        id: '${courseId}_q6',
        question: 'Jika saya pergi ke toko, saya akan membeli buku. Jika saya membeli buku, saya akan membaca malam ini. Saya tidak membaca malam ini. Manakah kesimpulan yang benar?',
        options: [
          'Saya pergi ke toko',
          'Saya tidak pergi ke toko',
          'Saya membeli buku',
          'Saya tidak membeli buku dan saya pergi ke toko',
        ],
        correctAnswerIndex: 1,
        explanation: 'Ini adalah rantai modus tollens. Jika P maka Q, jika Q maka R, tidak R, maka tidak Q, dan karena tidak Q maka tidak P. Jadi, saya tidak membeli buku dan saya tidak pergi ke toko.',
      ),
      McqQuestion(
        id: '${courseId}_q7',
        question: 'Semua mahasiswa di kelas ini suka matematika. Beberapa orang yang suka matematika juga suka fisika. Manakah kesimpulan yang benar?',
        options: [
          'Semua mahasiswa di kelas ini suka fisika',
          'Beberapa mahasiswa di kelas ini mungkin suka fisika',
          'Tidak ada mahasiswa di kelas ini yang suka fisika',
          'Semua orang yang suka fisika ada di kelas ini',
        ],
        correctAnswerIndex: 1,
        explanation: 'Dari premis yang diberikan, kita hanya bisa menyimpulkan bahwa beberapa mahasiswa di kelas ini mungkin suka fisika, karena beberapa orang yang suka matematika (yang mencakup semua mahasiswa di kelas) juga suka fisika.',
      ),
      McqQuestion(
        id: '${courseId}_q8',
        question: 'Jika diketahui dua kata berikut: \'BUKU\' dan \'KUBU\'. Manakah pola yang benar untuk dua kata tersebut?',
        options: [
          'Kata kedua adalah kebalikan dari kata pertama',
          'Kata kedua adalah rotasi dari kata pertama',
          'Huruf pertama pada kata pertama menjadi huruf terakhir pada kata kedua',
          'Kedua kata memiliki huruf yang sama tetapi dengan urutan berbeda',
        ],
        correctAnswerIndex: 3,
        explanation: 'Kedua kata terdiri dari huruf yang sama (B, U, K, U) tetapi dengan urutan yang berbeda.',
      ),
      McqQuestion(
        id: '${courseId}_q9',
        question: 'Jika setiap burung dapat terbang, dan beberapa hewan dapat terbang, maka:',
        options: [
          'Semua burung adalah hewan',
          'Beberapa hewan adalah burung',
          'Semua hewan adalah burung',
          'Tidak ada hewan yang burung',
        ],
        correctAnswerIndex: 1,
        explanation: 'Jika setiap burung dapat terbang dan beberapa hewan dapat terbang, kita bisa menyimpulkan bahwa beberapa hewan adalah burung.',
      ),
      McqQuestion(
        id: '${courseId}_q10',
        question: 'Jika dalam sekelompok orang, 20 orang suka teh, 15 orang suka kopi, dan 10 orang suka keduanya, berapa banyak orang dalam kelompok tersebut?',
        options: [
          '25 orang',
          '30 orang',
          '35 orang',
          '45 orang',
        ],
        correctAnswerIndex: 0,
        explanation: 'Menggunakan prinsip inklusi-eksklusi: Total = (Suka teh) + (Suka kopi) - (Suka keduanya) = 20 + 15 - 10 = 25 orang',
      ),
    ];
  }

// Generate questions for Literasi Bahasa Indonesia courses
  static List<McqQuestion> _generateBahasaIndonesiaQuestions(String courseId) {
    return [
      McqQuestion(
        id: '${courseId}_q1',
        question: 'Kalimat berikut yang menggunakan kata baku adalah:',
        options: [
          'Dia telah merubah penampilannya sejak bulan lalu',
          'Kami akan memproses ijin usaha Anda',
          'Pemerintah sedang membangun infrastruktur di daerah tersebut',
          'Apakah kamu sudah menginstal aplikasi itu?',
        ],
        correctAnswerIndex: 2,
        explanation: 'Kata baku adalah kata yang sesuai dengan kaidah bahasa Indonesia. "Infrastruktur" adalah kata baku, sedangkan bentuk tidak baku dari kata-kata lainnya adalah: "merubah" (baku: mengubah), "ijin" (baku: izin), dan "menginstal" (baku: memasang/menginstalasi).',
      ),
      McqQuestion(
        id: '${courseId}_q2',
        question: 'Kalimat berikut yang menggunakan huruf kapital dengan benar adalah:',
        options: [
          'Dia berasal dari suku Jawa dan tinggal di kota yogyakarta',
          'Kami sedang belajar Bahasa indonesia di sekolah',
          'Bulan Ramadhan adalah bulan suci bagi umat Islam',
          'Presiden joko widodo akan mengunjungi provinsi Bali',
        ],
        correctAnswerIndex: 2,
        explanation: 'Huruf kapital digunakan pada awal kalimat, nama orang, nama geografis, nama hari besar keagamaan, dan sebagainya. "Ramadhan" dan "Islam" ditulis dengan huruf kapital karena merupakan nama bulan suci dan nama agama.',
      ),
      McqQuestion(
        id: '${courseId}_q3',
        question: 'Manakah makna denotatif dari kata "bintang"?',
        options: [
          'Orang yang terkenal karena prestasinya',
          'Simbol kejayaan dan keberhasilan',
          'Benda langit yang memancarkan cahaya sendiri',
          'Penanda kualitas suatu hotel',
        ],
        correctAnswerIndex: 2,
        explanation: 'Makna denotatif adalah makna yang sebenarnya atau harfiah. Makna denotatif dari kata "bintang" adalah benda langit yang memancarkan cahaya sendiri. Pilihan lain merupakan makna konotatif atau kiasan.',
      ),
      McqQuestion(
        id: '${courseId}_q4',
        question: 'Kalimat berikut yang menggunakan tanda baca dengan tepat adalah:',
        options: [
          'Ayah bertanya, kemana kamu akan pergi?',
          'Ibu membeli bawang, wortel, kentang dan cabai.',
          'Dia berkata bahwa, "Saya akan datang besok."',
          'Menurut penelitian, polusi udara dapat menyebabkan masalah pernapasan.',
        ],
        correctAnswerIndex: 3,
        explanation: 'Tanda koma (,) digunakan untuk memisahkan kata atau kalimat dengan kata penghubung. Pada pilihan D, tanda koma digunakan dengan tepat setelah kata "penelitian" sebagai keterangan.',
      ),
      McqQuestion(
        id: '${courseId}_q5',
        question: 'Identifikasi jenis majas pada kalimat: "Suaranya merdu bagaikan nyanyian burung di pagi hari."',
        options: [
          'Metafora',
          'Personifikasi',
          'Simile',
          'Hiperbola',
        ],
        correctAnswerIndex: 2,
        explanation: 'Majas simile adalah majas perbandingan yang menggunakan kata penghubung seperti "seperti", "bagaikan", "bak", dll. Kalimat tersebut membandingkan suara yang merdu dengan nyanyian burung menggunakan kata "bagaikan".',
      ),
      McqQuestion(
        id: '${courseId}_q6',
        question: 'Manakah kalimat yang menggunakan kata penghubung (konjungsi) dengan tepat?',
        options: [
          'Walaupun hujan lebat, tetapi acara tetap dilaksanakan',
          'Karena dia sakit, sehingga tidak dapat hadir',
          'Dia tidak datang kemarin karena ada keperluan mendadak',
          'Dia tidak hanya pandai menyanyi tetapi juga dia pandai menari',
        ],
        correctAnswerIndex: 2,
        explanation: 'Kata penghubung (konjungsi) digunakan untuk menghubungkan kata, frasa, atau klausa. Pada pilihan C, kata penghubung "karena" digunakan dengan tepat. Pilihan lain menggunakan kata penghubung ganda yang tidak tepat.',
      ),
      McqQuestion(
        id: '${courseId}_q7',
        question: 'Apa bentuk aktif dari kalimat pasif: "Buku itu sedang dibaca oleh Ani"?',
        options: [
          'Ani membaca buku itu',
          'Ani sedang membaca buku itu',
          'Buku itu dibaca Ani',
          'Buku itu untuk dibaca Ani',
        ],
        correctAnswerIndex: 1,
        explanation: 'Kalimat aktif adalah kalimat yang subjeknya melakukan tindakan. Bentuk aktif dari "Buku itu sedang dibaca oleh Ani" adalah "Ani sedang membaca buku itu", di mana "Ani" sebagai subjek yang melakukan tindakan "membaca".',
      ),
      McqQuestion(
        id: '${courseId}_q8',
        question: 'Berikut ini yang bukan merupakan ciri teks argumentasi adalah:',
        options: [
          'Mengandung fakta dan data sebagai bukti',
          'Memaparkan pendapat atau ide dengan alasan',
          'Bertujuan untuk memengaruhi pembaca',
          'Disampaikan dengan gaya bahasa yang figuratif dan emosional',
        ],
        correctAnswerIndex: 3,
        explanation: 'Teks argumentasi bersifat logis dan objektif, tidak menggunakan gaya bahasa figuratif dan emosional yang lebih cocok untuk teks narasi atau puisi. Teks argumentasi menggunakan fakta, data, dan pemikiran logis untuk meyakinkan pembaca.',
      ),
      McqQuestion(
        id: '${courseId}_q9',
        question: 'Imbuhan "pe-an" pada kata "pembelajaran" membentuk kata benda yang bermakna:',
        options: [
          'Orang yang melakukan',
          'Proses atau kegiatan',
          'Alat untuk melakukan',
          'Hasil dari perbuatan',
        ],
        correctAnswerIndex: 1,
        explanation: 'Imbuhan "pe-an" pada kata "pembelajaran" membentuk kata benda yang bermakna proses atau kegiatan, yaitu proses belajar atau kegiatan belajar.',
      ),
      McqQuestion(
        id: '${courseId}_q10',
        question: 'Manakah penggunaan istilah yang tepat dalam kalimat berikut?',
        options: [
          'Mereka akan mengadakan workshop besok untuk meningkatkan skill karyawan',
          'Saya sangat happy karena berhasil menyelesaikan deadline tepat waktu',
          'Para peserta pelatihan mengikuti lokakarya dengan antusias',
          'Kita perlu mengupgrade sistem komputer untuk meningkatkan performance',
        ],
        correctAnswerIndex: 2,
        explanation: 'Penggunaan istilah yang tepat dalam Bahasa Indonesia adalah menggunakan padanan kata dalam Bahasa Indonesia jika memang ada, seperti "lokakarya" untuk "workshop". Pilihan lain menggunakan kata serapan yang sebenarnya sudah memiliki padanan dalam Bahasa Indonesia.',
      ),
    ];
  }

  // 1. Literasi Bahasa Indonesia Tingkat Lanjut
  static List<McqQuestion> _generateBahasaIndonesiaTingkatLanjutQuestions(String courseId) {
    return [
      McqQuestion(
        id: 'indo_lanjut_q1',
        question: 'Manakah dari berikut ini yang termasuk ragam bahasa baku?',
        options: [
          'Gue udah ngeberesin tugas kemarin',
          'Mereka lagi ngerjain proyek bareng',
          'Pemerintah telah menerapkan kebijakan tersebut',
          'Aku pengen banget pergi ke sana',
        ],
        correctAnswerIndex: 2,
        explanation: 'Kalimat "Pemerintah telah menerapkan kebijakan tersebut" menggunakan ragam bahasa baku dengan pilihan kata yang sesuai dengan kaidah bahasa Indonesia baku.',
      ),
      McqQuestion(
        id: 'indo_lanjut_q2',
        question: 'Perhatikan paragraf berikut: "Pemanasan global menjadi isu yang semakin penting. Suhu bumi terus meningkat. Ini mengakibatkan mencairnya es di kutub. Oleh karena itu, permukaan air laut naik." Paragraf tersebut termasuk jenis:',
        options: [
          'Paragraf deduktif',
          'Paragraf induktif',
          'Paragraf campuran',
          'Paragraf deskriptif',
        ],
        correctAnswerIndex: 0,
        explanation: 'Paragraf deduktif menyajikan gagasan utama di awal paragraf (kalimat pertama), kemudian diikuti dengan kalimat-kalimat penjelas.',
      ),
      McqQuestion(
        id: 'indo_lanjut_q3',
        question: 'Manakah kalimat yang menggunakan konjungsi majemuk dengan tepat?',
        options: [
          'Baik dia maupun saya tidak hadir kemarin.',
          'Walaupun hujan, tetapi acara tetap dilaksanakan.',
          'Karena sakit, sehingga dia tidak masuk sekolah.',
          'Tidak hanya cerdas, tetapi dia juga dan rajin.',
        ],
        correctAnswerIndex: 0,
        explanation: 'Konjungsi majemuk "baik... maupun..." digunakan dengan tepat dalam kalimat "Baik dia maupun saya tidak hadir kemarin."',
      ),
      McqQuestion(
        id: 'indo_lanjut_q4',
        question: 'Dalam struktur karya ilmiah, bagian yang menyajikan analisis data dan pembahasan temuan adalah:',
        options: [
          'Pendahuluan',
          'Tinjauan Pustaka',
          'Metodologi',
          'Hasil dan Pembahasan',
        ],
        correctAnswerIndex: 3,
        explanation: 'Bagian "Hasil dan Pembahasan" dalam karya ilmiah merupakan bagian yang menyajikan analisis data dan pembahasan temuan penelitian.',
      ),
      McqQuestion(
        id: 'indo_lanjut_q5',
        question: 'Dalam penulisan karya ilmiah, manakah cara pengutipan langsung yang benar?',
        options: [
          'Menurut Budi (2022) bahwa pendidikan karakter sangat penting untuk diterapkan di sekolah.',
          'Budi berpendapat bahwa "pendidikan karakter sangat penting untuk diterapkan di sekolah" (2022:45).',
          '"Pendidikan karakter sangat penting untuk diterapkan di sekolah" (Budi, 2022:45).',
          'Budi (2022) mengatakan pendidikan karakter sangat penting untuk diterapkan di sekolah.',
        ],
        correctAnswerIndex: 2,
        explanation: 'Pengutipan langsung yang benar menggunakan tanda kutip dan mencantumkan nama penulis, tahun publikasi, dan nomor halaman di dalam tanda kurung.',
      ),
      McqQuestion(
        id: 'indo_lanjut_q6',
        question: 'Analisis wacana kritis berfokus pada:',
        options: [
          'Struktur gramatikal teks',
          'Hubungan antar kalimat dalam paragraf',
          'Hubungan kekuasaan dan ideologi dalam penggunaan bahasa',
          'Makna kata dalam konteks budaya',
        ],
        correctAnswerIndex: 2,
        explanation: 'Analisis wacana kritis berfokus pada bagaimana bahasa digunakan untuk mengekspresikan, mempertahankan, atau menantang hubungan kekuasaan dan ideologi dalam masyarakat.',
      ),
      McqQuestion(
        id: 'indo_lanjut_q7',
        question: 'Perhatikan kalimat berikut: "Walaupun hujan deras, mereka tetap pergi berkemah." Kalimat tersebut termasuk kalimat:',
        options: [
          'Majemuk setara',
          'Majemuk bertingkat',
          'Majemuk campuran',
          'Tunggal',
        ],
        correctAnswerIndex: 1,
        explanation: 'Kalimat majemuk bertingkat adalah kalimat yang terdiri dari induk kalimat dan anak kalimat, ditandai dengan penggunaan konjungsi subordinatif seperti "walaupun".',
      ),
      McqQuestion(
        id: 'indo_lanjut_q8',
        question: 'Dalam paragraf argumentatif, bagian yang berisi pernyataan posisi penulis terhadap suatu isu disebut:',
        options: [
          'Premis',
          'Tesis',
          'Argumen',
          'Konklusi',
        ],
        correctAnswerIndex: 1,
        explanation: 'Tesis adalah pernyataan yang menyatakan posisi atau pandangan penulis terhadap suatu isu yang akan dibahas dalam paragraf argumentatif.',
      ),
      McqQuestion(
        id: 'indo_lanjut_q9',
        question: 'Manakah dari berikut ini yang BUKAN merupakan ciri-ciri paragraf yang baik?',
        options: [
          'Kesatuan (unity)',
          'Kepaduan (coherence)',
          'Kelengkapan',
          'Pengulangan ide yang sama',
        ],
        correctAnswerIndex: 3,
        explanation: 'Pengulangan ide yang sama bukan merupakan ciri paragraf yang baik karena dapat membuat paragraf menjadi tidak efektif dan membosankan.',
      ),
      McqQuestion(
        id: 'indo_lanjut_q10',
        question: 'Dalam penulisan ilmiah, daftar pustaka disusun berdasarkan:',
        options: [
          'Urutan kemunculan dalam teks',
          'Abjad nama penulis',
          'Tahun publikasi',
          'Relevansi dengan topik',
        ],
        correctAnswerIndex: 1,
        explanation: 'Dalam penulisan ilmiah, daftar pustaka umumnya disusun berdasarkan abjad nama penulis (nama keluarga untuk penulis asing).',
      ),
    ];
  }

// 2. Penalaran Matematika Komprehensif
  static List<McqQuestion> _generateMatematikaKomprehensifQuestions(String courseId) {
    return [
      McqQuestion(
        id: 'mat_komp_q1',
        question: 'Dalam teori graf, derajat sebuah vertex adalah:',
        options: [
          'Jumlah edge yang terhubung ke vertex tersebut',
          'Jumlah vertex dalam graf',
          'Panjang jalur terpendek dari vertex tersebut ke vertex lainnya',
          'Jumlah sirkuit yang melewati vertex tersebut',
        ],
        correctAnswerIndex: 0,
        explanation: 'Derajat sebuah vertex dalam teori graf adalah jumlah edge (sisi) yang terhubung ke vertex tersebut.',
      ),
      McqQuestion(
        id: 'mat_komp_q2',
        question: 'Berapa banyak cara menyusun 5 orang dalam sebuah barisan?',
        options: [
          '5',
          '10',
          '120',
          '25',
        ],
        correctAnswerIndex: 2,
        explanation: 'Jumlah cara menyusun n orang dalam barisan adalah n! (faktorial n). Untuk n = 5, maka 5! = 5×4×3×2×1 = 120.',
      ),
      McqQuestion(
        id: 'mat_komp_q3',
        question: 'Dalam teori bilangan, bilangan yang dapat ditulis sebagai hasil kali dua bilangan bulat positif lainnya (selain 1 dan dirinya sendiri) disebut:',
        options: [
          'Bilangan prima',
          'Bilangan komposit',
          'Bilangan rasional',
          'Bilangan irasional',
        ],
        correctAnswerIndex: 1,
        explanation: 'Bilangan komposit adalah bilangan yang dapat ditulis sebagai hasil kali dua bilangan bulat positif lainnya selain 1 dan dirinya sendiri.',
      ),
      McqQuestion(
        id: 'mat_komp_q4',
        question: 'Determinan matriks A = [[3, 1], [2, 4]] adalah:',
        options: [
          '10',
          '12',
          '11',
          '14',
        ],
        correctAnswerIndex: 0,
        explanation: 'Determinan matriks 2×2 dihitung dengan rumus ad - bc. Untuk matriks A = [[3, 1], [2, 4]], determinannya adalah 3×4 - 1×2 = 12 - 2 = 10.',
      ),
      McqQuestion(
        id: 'mat_komp_q5',
        question: 'Jika T: R² → R² adalah transformasi linear yang memutar setiap vektor 90° berlawanan arah jarum jam, matriks yang merepresentasikan T adalah:',
        options: [
          '[[0, -1], [1, 0]]',
          '[[0, 1], [-1, 0]]',
          '[[1, 0], [0, -1]]',
          '[[-1, 0], [0, 1]]',
        ],
        correctAnswerIndex: 0,
        explanation: 'Transformasi rotasi 90° berlawanan arah jarum jam memetakan (x, y) ke (-y, x), sehingga matriks transformasinya adalah [[0, -1], [1, 0]].',
      ),
      McqQuestion(
        id: 'mat_komp_q6',
        question: 'Sistem persamaan linear yang memiliki solusi tak hingga banyaknya adalah sistem yang:',
        options: [
          'Memiliki determinan matriks koefisien = 0 dan rank matriks koefisien = rank matriks augmented',
          'Memiliki determinan matriks koefisien ≠ 0',
          'Memiliki determinan matriks koefisien = 0 dan rank matriks koefisien ≠ rank matriks augmented',
          'Memiliki jumlah persamaan lebih banyak dari jumlah variabel',
        ],
        correctAnswerIndex: 0,
        explanation: 'Sistem persamaan linear memiliki solusi tak hingga banyaknya jika determinan matriks koefisien = 0 (sistem homogen) dan rank matriks koefisien sama dengan rank matriks augmented.',
      ),
      McqQuestion(
        id: 'mat_komp_q7',
        question: 'Berapa banyak subhimpunan yang dapat dibentuk dari himpunan {1, 2, 3, 4, 5}?',
        options: [
          '10',
          '32',
          '25',
          '120',
        ],
        correctAnswerIndex: 1,
        explanation: 'Jumlah subhimpunan dari himpunan dengan n elemen adalah 2^n. Untuk n = 5, maka jumlah subhimpunannya adalah 2^5 = 32.',
      ),
      McqQuestion(
        id: 'mat_komp_q8',
        question: 'Dalam graf berarah, indegree sebuah vertex adalah:',
        options: [
          'Jumlah edge yang keluar dari vertex tersebut',
          'Jumlah edge yang masuk ke vertex tersebut',
          'Jumlah vertex yang terhubung langsung dengan vertex tersebut',
          'Jumlah sirkuit yang melewati vertex tersebut',
        ],
        correctAnswerIndex: 1,
        explanation: 'Indegree sebuah vertex dalam graf berarah adalah jumlah edge (sisi) yang masuk ke vertex tersebut.',
      ),
      McqQuestion(
        id: 'mat_komp_q9',
        question: 'Jika A dan B adalah matriks ukuran m×n dan n×p, maka hasil perkalian AB memiliki ukuran:',
        options: [
          'm×n',
          'n×p',
          'm×p',
          'p×m',
        ],
        correctAnswerIndex: 2,
        explanation: 'Jika A adalah matriks berukuran m×n dan B adalah matriks berukuran n×p, maka hasil perkalian AB memiliki ukuran m×p.',
      ),
      McqQuestion(
        id: 'mat_komp_q10',
        question: 'Koefisien binomial C(n,k) menyatakan:',
        options: [
          'Jumlah cara memilih k objek dari n objek tanpa memperhatikan urutan',
          'Jumlah cara memilih k objek dari n objek dengan memperhatikan urutan',
          'Jumlah cara menyusun n objek',
          'Jumlah cara membagi n objek menjadi k kelompok',
        ],
        correctAnswerIndex: 0,
        explanation: 'Koefisien binomial C(n,k) menyatakan jumlah cara memilih k objek dari n objek yang tersedia tanpa memperhatikan urutan pemilihan.',
      ),
    ];
  }

// 3. Literasi Bahasa Inggris Profesional
  static List<McqQuestion> _generateBahasaInggrisProfessionalQuestions(String courseId) {
    return [
      McqQuestion(
        id: 'ing_prof_q1',
        question: 'Which of the following is the most appropriate opening for a formal business email?',
        options: [
          'Hey there,',
          'Dear Sir/Madam,',
          'What\'s up?',
          'Hi folks,',
        ],
        correctAnswerIndex: 1,
        explanation: '"Dear Sir/Madam," is the most appropriate and formal opening for a business email when you don\'t know the recipient\'s name.',
      ),
      McqQuestion(
        id: 'ing_prof_q2',
        question: 'In business presentations, the "rule of three" refers to:',
        options: [
          'Limiting presentations to three minutes',
          'Presenting information in groups of three for better retention',
          'Having three presenters for complex topics',
          'Using three visual aids in each slide',
        ],
        correctAnswerIndex: 1,
        explanation: 'The "rule of three" in presentations refers to organizing information in groups of three, which is found to be more memorable and effective for audience retention.',
      ),
      McqQuestion(
        id: 'ing_prof_q3',
        question: 'Which phrase is most appropriate for politely refusing a request in a professional setting?',
        options: [
          'No way, that\'s impossible.',
          'I\'m afraid that won\'t be possible at this time.',
          'I can\'t do that.',
          'You\'re asking too much.',
        ],
        correctAnswerIndex: 1,
        explanation: '"I\'m afraid that won\'t be possible at this time" is a polite and professional way to refuse a request while maintaining good relationships.',
      ),
      McqQuestion(
        id: 'ing_prof_q4',
        question: 'In technical documentation, what does API stand for?',
        options: [
          'Applied Programming Interface',
          'Application Protocol Internet',
          'Application Programming Interface',
          'Advanced Programming Implementation',
        ],
        correctAnswerIndex: 2,
        explanation: 'API stands for Application Programming Interface, which is a set of rules that allows one software application to interact with another.',
      ),
      McqQuestion(
        id: 'ing_prof_q5',
        question: 'Which of the following is NOT typically included in a technical report?',
        options: [
          'Executive Summary',
          'Methodology',
          'Personal opinions of the author',
          'Conclusions and Recommendations',
        ],
        correctAnswerIndex: 2,
        explanation: 'Technical reports should be objective and data-driven. Personal opinions of the author are typically not included unless specifically requested or relevant to the analysis.',
      ),
      McqQuestion(
        id: 'ing_prof_q6',
        question: 'Which sentence uses the passive voice correctly in a business context?',
        options: [
          'The team leader presented the quarterly results.',
          'The quarterly results presented by the team leader.',
          'The quarterly results were presented by the team leader.',
          'The team leader presenting the quarterly results.',
        ],
        correctAnswerIndex: 2,
        explanation: '"The quarterly results were presented by the team leader" correctly uses the passive voice, which is often used in business writing to emphasize the action or result rather than the actor.',
      ),
      McqQuestion(
        id: 'ing_prof_q7',
        question: 'In project communication, a "stakeholder" refers to:',
        options: [
          'Only the project manager',
          'Any person or organization that has a vested interest in the project',
          'Only the clients who pay for the project',
          'Only the team members working on the project',
        ],
        correctAnswerIndex: 1,
        explanation: 'A stakeholder in project management refers to any person, group, or organization that has a vested interest in the project, its activities, or its outcomes.',
      ),
      McqQuestion(
        id: 'ing_prof_q8',
        question: 'Which of the following phrases is most appropriate for making a suggestion in a business meeting?',
        options: [
          'You need to consider this approach.',
          'Have you thought about trying this approach?',
          'You should definitely do it this way.',
          'This is the only way to solve the problem.',
        ],
        correctAnswerIndex: 1,
        explanation: '"Have you thought about trying this approach?" is a polite and non-imposing way to make a suggestion in a professional setting.',
      ),
      McqQuestion(
        id: 'ing_prof_q9',
        question: 'In business English, what does ROI stand for?',
        options: [
          'Rate Of Inflation',
          'Return On Investment',
          'Risk Of Involvement',
          'Record Of Inventory',
        ],
        correctAnswerIndex: 1,
        explanation: 'ROI stands for Return On Investment, a performance measure used to evaluate the efficiency or profitability of an investment.',
      ),
      McqQuestion(
        id: 'ing_prof_q10',
        question: 'When writing a formal business proposal, which tense is most commonly used?',
        options: [
          'Past tense',
          'Future perfect tense',
          'Present tense',
          'Past perfect tense',
        ],
        correctAnswerIndex: 2,
        explanation: 'The present tense is most commonly used in formal business proposals as it conveys immediacy and certainty about the proposed actions and solutions.',
      ),
    ];
  }

// 4. Penalaran Umum dan Logika Kritis
  static List<McqQuestion> _generatePenalaranUmumLogikaQuestions(String courseId) {
    return [
      McqQuestion(
        id: 'logika_q1',
        question: 'Manakah dari berikut ini yang merupakan proposisi?',
        options: [
          'Apakah hari ini hujan?',
          'Tolong ambilkan buku itu.',
          'Jakarta adalah ibukota Indonesia.',
          'Semoga kamu sukses!',
        ],
        correctAnswerIndex: 2,
        explanation: 'Proposisi adalah pernyataan yang dapat bernilai benar atau salah. "Jakarta adalah ibukota Indonesia" adalah pernyataan yang dapat diverifikasi kebenarannya, sedangkan pilihan lain adalah pertanyaan, perintah, dan harapan.',
      ),
      McqQuestion(
        id: 'logika_q2',
        question: 'Fallasi "Ad Hominem" terjadi ketika:',
        options: [
          'Menyerang pribadi lawan debat, bukan argumennya',
          'Membuat generalisasi yang terlalu luas',
          'Menggunakan otoritas yang tidak relevan',
          'Menarik kesimpulan tanpa bukti yang cukup',
        ],
        correctAnswerIndex: 0,
        explanation: 'Fallasi "Ad Hominem" (terhadap orangnya) terjadi ketika seseorang menyerang karakter, motif, atau ciri pribadi lawan debat, bukan membahas kekuatan argumennya.',
      ),
      McqQuestion(
        id: 'logika_q3',
        question: 'Dalam logika deduktif, jika premis-premisnya benar dan bentuk argumennya valid, maka:',
        options: [
          'Kesimpulannya mungkin benar',
          'Kesimpulannya pasti benar',
          'Premisnya mungkin salah',
          'Tidak ada hubungan antara premis dan kesimpulan',
        ],
        correctAnswerIndex: 1,
        explanation: 'Dalam logika deduktif, jika premis-premisnya benar dan bentuk argumennya valid, maka kesimpulannya pasti benar. Ini adalah ciri khas penalaran deduktif.',
      ),
      McqQuestion(
        id: 'logika_q4',
        question: 'Perhatikan argumen berikut: "Semua mamalia bernapas dengan paru-paru. Ikan paus adalah mamalia. Jadi, ikan paus bernapas dengan paru-paru." Argumen ini merupakan contoh:',
        options: [
          'Penalaran induktif',
          'Penalaran deduktif',
          'Analogi',
          'Fallasi genetik',
        ],
        correctAnswerIndex: 1,
        explanation: 'Argumen tersebut adalah contoh penalaran deduktif, di mana kesimpulan ditarik secara logis dari premis-premis yang ada menggunakan silogisme.',
      ),
      McqQuestion(
        id: 'logika_q5',
        question: 'Media massa sering menggunakan teknik framing untuk:',
        options: [
          'Menyajikan berita secara objektif',
          'Menekankan aspek tertentu dari suatu isu untuk memengaruhi interpretasi audiens',
          'Mencegah penyebaran berita palsu',
          'Menjaga privasi narasumber',
        ],
        correctAnswerIndex: 1,
        explanation: 'Framing dalam media massa adalah teknik untuk menekankan aspek tertentu dari suatu isu dan mengabaikan aspek lainnya, sehingga dapat memengaruhi bagaimana audiens menginterpretasikan berita tersebut.',
      ),
      McqQuestion(
        id: 'logika_q6',
        question: 'Dalam pengambilan keputusan rasional, tahap apa yang harus dilakukan setelah mengidentifikasi masalah?',
        options: [
          'Mengevaluasi alternatif solusi',
          'Mengidentifikasi alternatif solusi',
          'Memilih solusi terbaik',
          'Menerapkan solusi',
        ],
        correctAnswerIndex: 1,
        explanation: 'Setelah mengidentifikasi masalah, langkah berikutnya dalam pengambilan keputusan rasional adalah mengidentifikasi berbagai alternatif solusi yang mungkin dilakukan.',
      ),
      McqQuestion(
        id: 'logika_q7',
        question: 'Heuristik dalam pemecahan masalah adalah:',
        options: [
          'Metode pemecahan masalah yang selalu menghasilkan solusi yang tepat',
          'Strategi informal untuk mempercepat proses menemukan solusi',
          'Teknik untuk menghindari bias kognitif',
          'Metode untuk menganalisis argumen logis',
        ],
        correctAnswerIndex: 1,
        explanation: 'Heuristik adalah strategi informal atau aturan praktis yang digunakan untuk mempercepat proses menemukan solusi, meski tidak selalu menjamin solusi optimal.',
      ),
      McqQuestion(
        id: 'logika_q8',
        question: 'Jika p→q (jika p maka q) dan ~q (bukan q), maka dengan modus tollens kita dapat menyimpulkan:',
        options: [
          'p',
          '~p',
          'q',
          'p dan q',
        ],
        correctAnswerIndex: 1,
        explanation: 'Modus tollens adalah aturan inferensi yang menyatakan bahwa jika p→q dan ~q, maka ~p. Ini adalah penerapan dari contrapositive dalam logika.',
      ),
      McqQuestion(
        id: 'logika_q9',
        question: 'Bias konfirmasi adalah kecenderungan untuk:',
        options: [
          'Mengubah pendapat ketika dihadapkan dengan bukti baru',
          'Mencari dan menginterpretasikan informasi yang mendukung keyakinan yang sudah ada',
          'Menolak semua informasi baru',
          'Selalu mempertimbangkan berbagai sudut pandang secara objektif',
        ],
        correctAnswerIndex: 1,
        explanation: 'Bias konfirmasi adalah kecenderungan kognitif untuk mencari, menginterpretasikan, dan mengingat informasi yang mendukung keyakinan, ekspektasi, atau hipotesis yang sudah ada.',
      ),
      McqQuestion(
        id: 'logika_q10',
        question: 'Dalam memecahkan masalah kompleks, pendekatan yang memecah masalah menjadi komponen-komponen lebih kecil disebut:',
        options: [
          'Generalisasi',
          'Induksi',
          'Dekomposisi',
          'Sintesis',
        ],
        correctAnswerIndex: 2,
        explanation: 'Dekomposisi adalah pendekatan pemecahan masalah di mana masalah kompleks dipecah menjadi komponen-komponen yang lebih kecil dan lebih mudah diselesaikan.',
      ),
    ];
  }

// 5. Penalaran Kuantitatif Analitis
  static List<McqQuestion> _generatePenalaranKuantitatifAnalitisQuestions(String courseId) {
    return [
      McqQuestion(
        id: '${courseId}_q1',
        question: 'Dari data berikut: 3, 7, 8, 5, 12, 9, 6, nilai median adalah:',
        options: [
          '7',
          '7,5',
          '8',
          '6',
        ],
        correctAnswerIndex: 0,
        explanation: 'Setelah diurutkan: 3, 5, 6, 7, 8, 9, 12. Median adalah nilai tengah, yaitu 7.',
      ),
      McqQuestion(
        id: '${courseId}_q2',
        question: 'Jika X dan Y adalah variabel acak independen, maka nilai harapan (expected value) dari X + Y adalah:',
        options: [
          'E(X) - E(Y)',
          'E(X) × E(Y)',
          'E(X) + E(Y)',
          'E(X) / E(Y)',
        ],
        correctAnswerIndex: 2,
        explanation: 'Untuk variabel acak independen X dan Y, nilai harapan (expected value) dari X + Y adalah E(X) + E(Y).',
      ),
      McqQuestion(
        id: '${courseId}_q3',
        question: 'Dalam distribusi normal standar, sekitar berapa persen data yang berada dalam rentang ±2 standar deviasi dari mean?',
        options: [
          '68%',
          '95%',
          '99%',
          '50%',
        ],
        correctAnswerIndex: 1,
        explanation: 'Dalam distribusi normal, sekitar 95% data berada dalam rentang ±2 standar deviasi dari mean.',
      ),
      McqQuestion(
        id: '${courseId}_q4',
        question: 'Dalam analisis regresi linear, koefisien determinasi (R²) mengukur:',
        options: [
          'Kekuatan hubungan linear antara dua variabel',
          'Proporsi variasi dalam variabel dependen yang dapat dijelaskan oleh variabel independen',
          'Slope dari garis regresi',
          'Intercept dari garis regresi',
        ],
        correctAnswerIndex: 1,
        explanation: 'Koefisien determinasi (R²) mengukur proporsi variasi dalam variabel dependen yang dapat dijelaskan oleh variabel independen dalam model regresi.',
      ),
      McqQuestion(
        id: '${courseId}_q5',
        question: 'Hipotesis nol dalam pengujian statistik adalah:',
        options: [
          'Hipotesis yang ingin dibuktikan oleh peneliti',
          'Hipotesis yang menyatakan tidak ada efek atau perbedaan',
          'Hipotesis yang menyatakan ada efek atau perbedaan',
          'Hipotesis alternatif',
        ],
        correctAnswerIndex: 1,
        explanation: 'Hipotesis nol (H₀) adalah hipotesis yang menyatakan tidak ada efek, tidak ada perbedaan, atau tidak ada hubungan antara variabel yang diteliti.',
      ),
      McqQuestion(
        id: '${courseId}_q6',
        question: 'Dalam uji hipotesis, kesalahan Tipe I terjadi ketika:',
        options: [
          'Menolak hipotesis nol yang sebenarnya benar',
          'Menerima hipotesis nol yang sebenarnya salah',
          'Menolak hipotesis alternatif yang sebenarnya benar',
          'Menerima hipotesis alternatif yang sebenarnya salah',
        ],
        correctAnswerIndex: 0,
        explanation: 'Kesalahan Tipe I (false positive) terjadi ketika kita menolak hipotesis nol (H₀) yang sebenarnya benar. Tingkat signifikansi α mengontrol probabilitas terjadinya kesalahan ini.',
      ),
      McqQuestion(
        id: '${courseId}_q7',
        question: 'Jika nilai p-value dalam uji statistik adalah 0.03 dan tingkat signifikansi (α) adalah 0.05, maka kesimpulannya adalah:',
        options: [
          'Gagal menolak hipotesis nol',
          'Menolak hipotesis nol',
          'Menerima hipotesis alternatif sepenuhnya',
          'Tidak dapat disimpulkan',
        ],
        correctAnswerIndex: 1,
        explanation: 'Karena p-value (0.03) < α (0.05), maka kita menolak hipotesis nol. Artinya, terdapat bukti statistik yang cukup untuk mendukung hipotesis alternatif.',
      ),
      McqQuestion(
        id: '${courseId}_q8',
        question: 'Dalam analisis varians (ANOVA), nilai F-ratio yang besar menunjukkan:',
        options: [
          'Variasi dalam kelompok lebih besar daripada variasi antar kelompok',
          'Variasi antar kelompok lebih besar daripada variasi dalam kelompok',
          'Tidak ada perbedaan signifikan antar kelompok',
          'Data tidak terdistribusi normal',
        ],
        correctAnswerIndex: 1,
        explanation: 'Nilai F-ratio yang besar dalam ANOVA menunjukkan bahwa variasi antar kelompok lebih besar dibandingkan dengan variasi dalam kelompok, yang mengindikasikan adanya perbedaan signifikan antar kelompok.',
      ),
      McqQuestion(
        id: '${courseId}_q9',
        question: 'Jika dua peristiwa A dan B adalah saling eksklusif, maka:',
        options: [
          'P(A dan B) = P(A) × P(B)',
          'P(A atau B) = P(A) + P(B)',
          'P(A | B) = P(A)',
          'P(A atau B) = P(A) + P(B) - P(A dan B)',
        ],
        correctAnswerIndex: 1,
        explanation: 'Jika dua peristiwa A dan B saling eksklusif (tidak dapat terjadi bersamaan), maka P(A dan B) = 0, sehingga P(A atau B) = P(A) + P(B).',
      ),
      McqQuestion(
        id: '${courseId}_q10',
        question: 'Dalam analisis deret waktu (time series), trend menunjukkan:',
        options: [
          'Pola variasi jangka pendek',
          'Pola musiman yang berulang',
          'Pola pergerakan jangka panjang data',
          'Komponen acak dalam data',
        ],
        correctAnswerIndex: 2,
        explanation: 'Trend dalam analisis deret waktu menunjukkan pola pergerakan jangka panjang data, baik itu kecenderungan naik, turun, atau stabil selama periode waktu tertentu.',
      ),
    ];
  }
  // Generate generic questions for any other course type
  static List<McqQuestion> _generateGenericQuestions(String courseId) {
    return [
      McqQuestion(
        id: '${courseId}_q1',
        question: 'Apa tujuan utama dari pembelajaran?',
        options: [
          'Mendapatkan nilai bagus',
          'Memperoleh pengetahuan dan keterampilan',
          'Mendapatkan pekerjaan',
          'Menghafal informasi',
        ],
        correctAnswerIndex: 1,
        explanation: 'Tujuan utama pembelajaran adalah memperoleh pengetahuan dan keterampilan yang dapat digunakan dalam kehidupan.',
      ),
      // Add more questions...
    ];
  }

  // Method to create custom questions
  static List<McqQuestion> createCustomQuestions(String courseId, List<Map<String, dynamic>> questionData) {
    List<McqQuestion> customQuestions = [];

    for (var data in questionData) {
      customQuestions.add(
          McqQuestion(
            id: '${courseId}_custom_${customQuestions.length + 1}',
            question: data['question'],
            options: List<String>.from(data['options']),
            correctAnswerIndex: data['correctIndex'],
            explanation: data['explanation'],
          )
      );
    }

    return customQuestions;
  }
}

// Demo/Sample class to generate assignment data
class AssignmentRepository {
  // Generate a sample assignment
  static Assignment createSampleAssignment({
    required String courseId,
    required String courseName,
    String? title,
    DateTime? dueDate,
  }) {
    return Assignment.withQuestions(
      id: 'assign_${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Quiz $courseName',
      courseId: courseId,
      courseName: courseName,
      dueDate: dueDate ?? DateTime.now().add(const Duration(days: 7)),
      questionCount: 10,
      duration: 45,
    );
  }

  // Create a batch of sample assignments for testing
  static List<Assignment> generateSampleAssignments() {
    final now = DateTime.now();

    return [
      createSampleAssignment(
        courseId: 'course1',
        courseName: 'Bahasa Indonesia',
        title: 'Quiz Mingguan Bahasa Indonesia',
        dueDate: now.add(const Duration(days: 3)),
      ),
      createSampleAssignment(
        courseId: 'course2',
        courseName: 'Bahasa Inggris',
        title: 'English Grammar Test',
        dueDate: now.add(const Duration(days: 5)),
      ),
      createSampleAssignment(
        courseId: 'course3',
        courseName: 'Matematika Dasar',
        title: 'Latihan Soal Aljabar',
        dueDate: now.add(const Duration(days: 2)),
      ),
      createSampleAssignment(
        courseId: 'course4',
        courseName: 'Penalaran Kuantitatif',
        title: 'Ujian Tengah Semester',
        dueDate: now.add(const Duration(hours: 36)),
      ),
      createSampleAssignment(
        courseId: 'course5',
        courseName: 'Penalaran Umum',
        title: 'Latihan Logika',
        dueDate: now.add(const Duration(days: 1)),
      ),
      createSampleAssignment(
        courseId: 'course6',
        courseName: 'Bahasa Indonesia2',
        title: 'Ujian Tengah Semester',
        dueDate: now.add(const Duration(days: 1)),
      ),
      createSampleAssignment(
        courseId: 'course7',
        courseName: 'Matematika2',
        title: 'Ujian Akhir Semester',
        dueDate: now.add(const Duration(days: 4)),
      ),
      createSampleAssignment(
        courseId: 'course8',
        courseName: 'Bahasa Inggris2',
        title: 'Ujian Akhir Semester',
        dueDate: now.add(const Duration(days: 2)),
      ),
      createSampleAssignment(
        courseId: 'course9',
        courseName: 'Umum2',
        title: 'Ujian Tengah Semester',
        dueDate: now.add(const Duration(days: 36)),
      ),
      createSampleAssignment(
        courseId: 'course10',
        courseName: 'Kuantitatif2',
        title: 'Ujian Akhir Semester',
        dueDate: now.add(const Duration(days: 3)),
      ),
    ];
  }
}