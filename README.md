# RamySmart - E-Learning Platform

Aplikasi pembelajaran online yang komprehensif dengan fitur kalkulator terintegrasi, sistem kursus, tugas interaktif, dan manajemen pembelajaran yang lengkap.

## Fitur Utama

### 📚 Sistem E-Learning
- **Katalog Kursus**: Berbagai mata pelajaran dengan rating dan review
- **Video Pembelajaran**: Integrasi YouTube Player untuk konten multimedia
- **Progress Tracking**: Pelacakan kemajuan belajar real-time
- **Kategori Pembelajaran**: 
  - Literasi Bahasa Indonesia
  - Penalaran Matematika
  - Literasi Bahasa Inggris
  - Penalaran Umum
  - Penalaran Kuantitatif

### 📝 Sistem Tugas & Evaluasi
- **MCQ (Multiple Choice Questions)**: Tugas pilihan ganda interaktif
- **Essay Assignments**: Tugas essay dengan word counter dan validasi
- **Auto-grading**: Sistem penilaian otomatis
- **Timer System**: Batas waktu pengerjaan dengan countdown
- **Progress Tracking**: Pelacakan penyelesaian tugas

### 🛒 E-Commerce Features
- **Shopping Cart**: Keranjang belanja untuk kursus
- **Wishlist**: Daftar keinginan untuk kursus favorit
- **Purchase System**: Sistem pembelian dengan berbagai metode pembayaran
- **Promo Codes**: Sistem kode promo dan diskon

### 👤 Manajemen Pengguna
- **Profile Management**: Kelola profil dengan foto dan informasi personal
- **Firebase Integration**: Autentikasi dan sinkronisasi data
- **Local Database**: SQLite untuk penyimpanan offline
- **Notification System**: Sistem notifikasi real-time

## Arsitektur Aplikasi

### Struktur Direktori
```
lib/
├── main.dart                           # Entry point aplikasi
├── screens/
│   └── Home/
│       ├── course_home.dart           # Halaman utama kursus
│       └── widget/
│           ├── account_profile.dart    # Profil pengguna
│           ├── assignment_model.dart   # Model tugas
│           ├── cart.dart              # Keranjang belanja
│           ├── course_detail_page.dart # Detail kursus
│           ├── course_list.dart       # Daftar kursus
│           ├── course_manager.dart    # Manager kursus
│           ├── essay_assignment_screen.dart # Layar tugas essay
│           ├── featured_courses.dart  # Kursus unggulan
│           ├── main_screen.dart       # Layar utama
│           ├── my_courses.dart        # Kursus saya
│           ├── notification_page.dart # Halaman notifikasi
│           └── wishlist.dart          # Daftar keinginan
└── util/
    └── constants.dart                 # Konstanta aplikasi
```

### Teknologi & Dependencies

#### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0                    # HTTP requests
  youtube_player_flutter: ^8.1.2  # YouTube integration
  image_picker: ^1.0.4           # Image selection
  path_provider: ^2.1.1          # File system access
  path: ^1.8.3                   # Path manipulation
  sqflite: ^2.3.0               # Local database
  provider: ^6.0.5               # State management
  intl: ^0.18.1                  # Internationalization
```

#### Firebase Integration
```yaml
  firebase_core: ^2.15.1
  firebase_auth: ^4.7.3
  cloud_firestore: ^4.8.5
```

## Instalasi & Setup

### Prasyarat
- Flutter SDK 3.0.0+
- Dart SDK 3.0.0+
- Android Studio / VS Code
- Firebase Project (untuk autentikasi)

### Langkah Instalasi

1. **Clone Repository**
```bash
git clone [repository-url]
cd ramysmart
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Firebase Setup**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase
flutterfire configure
```

4. **Database Setup**
- Aplikasi menggunakan SQLite untuk local storage
- Database akan dibuat otomatis saat pertama kali berjalan

5. **Run Application**
```bash
flutter run
```

## Fitur Detail

### Sistem Pembelajaran
- **Course Progress**: Tracking progress video dan tugas
- **Section Management**: Organisasi konten dalam section
- **Video Integration**: YouTube player terintegrasi
- **Offline Access**: Beberapa fitur tersedia offline

### Assignment System
- **MCQ Generator**: Generator soal otomatis berdasarkan kategori
- **Essay Evaluation**: Validasi jumlah kata dan format
- **Timer Management**: Countdown timer untuk setiap tugas
- **Auto-save**: Penyimpanan jawaban otomatis

### E-Commerce Integration
- **Multi-course Purchase**: Beli beberapa kursus sekaligus
- **Payment Methods**: Kartu kredit, PayPal, transfer bank
- **Order Management**: Tracking pembelian dan riwayat
- **Discount System**: Kode promo dan sistem diskon

## Konfigurasi

### Environment Variables
```dart
// constants.dart
const String API_BASE_URL = 'https://api.mathjs.org/v4/';
const Color kPrimaryColor = Color(0xFF0097A7);
const Color kOptionColor = Color(0xFF00695C);
```

### Database Schema

#### User Profile
```sql
CREATE TABLE user_profiles (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  image_path TEXT
);
```

#### Course Progress
```sql
CREATE TABLE course_progress (
  id INTEGER PRIMARY KEY,
  course_id TEXT NOT NULL,
  lesson_id TEXT NOT NULL,
  completed BOOLEAN DEFAULT FALSE,
  progress_percentage REAL DEFAULT 0.0
);
```

## API Integration

### MathJS API
```dart
// Contoh penggunaan
final response = await http.get(
  Uri.parse('https://api.mathjs.org/v4/?expr=${expression}'),
  headers: {
    'User-Agent': 'RamySmart-App/1.0',
    'Accept': 'application/json',
  },
);
```

### YouTube API
```dart
// YouTube Player Integration
YoutubePlayerController(
  initialVideoId: videoId,
  flags: const YoutubePlayerFlags(
    autoPlay: false,
    mute: false,
  ),
);
```

## State Management

### Provider Pattern
```dart
// Course Manager Provider
class CourseManagerProvider extends ChangeNotifier {
  void purchaseCourse(Course course) {
    _courseManager.purchaseCourse(course);
    notifyListeners();
  }
}
```

### Singleton Pattern
```dart
// Course Manager Singleton
class CourseManager {
  static final CourseManager _instance = CourseManager._internal();
  factory CourseManager() => _instance;
}
```

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

### Widget Tests
```dart
testWidgets('Calculator basic operation test', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  // Test implementation
});
```

## Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web
```

## Performance Optimization

### Lazy Loading
- Implementasi lazy loading untuk daftar kursus
- Image caching untuk thumbnail kursus
- Progressive loading untuk video content

### Memory Management
- Dispose controllers yang tidak digunakan
- Optimize widget rebuilds dengan const constructors
- Use efficient data structures

### Network Optimization
- HTTP caching untuk API responses
- Compress images sebelum upload
- Implement retry logic untuk network failures

## Security

### Data Protection
- Enkripsi data sensitif di local storage
- Secure HTTP communications (HTTPS only)
- Input validation dan sanitization

### Authentication
- Firebase Authentication integration
- Secure token management
- Session timeout handling

## Monitoring & Analytics

### Error Tracking
```dart
// Firebase Crashlytics integration
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  fatal: false,
);
```

### Performance Monitoring
- Firebase Performance Monitoring
- Custom metrics untuk user engagement
- Network performance tracking

## Troubleshooting

### Common Issues

**1. YouTube Player Not Working**
- Pastikan internet connection
- Check YouTube video availability
- Verify API keys

**2. Calculator API Timeout**
- Aplikasi akan otomatis fallback ke local calculation
- Check network connectivity
- Verify MathJS API status

**3. Database Migration Issues**
```bash
flutter clean
flutter pub get
```

**4. Build Errors**
- Update Flutter SDK: `flutter upgrade`
- Clean build cache: `flutter clean`
- Reset pub cache: `flutter pub cache repair`

## Contributing

### Development Guidelines
1. Fork repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Follow Flutter/Dart style guidelines
4. Write unit tests untuk fitur baru
5. Update documentation
6. Submit pull request

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable names
- Add comments untuk logic kompleks
- Implement proper error handling

## Roadmap & Future Features

### Phase 1 (Current)
- ✅ Basic calculator functionality
- ✅ Course management system
- ✅ Assignment system (MCQ & Essay)
- ✅ User profile management

### Phase 2 (Planned)
- [ ] Advanced analytics dashboard
- [ ] Social learning features
- [ ] Offline video download
- [ ] Advanced search filters
- [ ] Push notifications

### Phase 3 (Future)
- [ ] AI-powered course recommendations
- [ ] Live streaming classes
- [ ] Gamification system
- [ ] Multi-language support
- [ ] Advanced reporting system

## License

```
MIT License

Copyright (c) 2024 RamySmart

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

## Support & Contact

### Technical Support
- **Email**: ramydiaman@gmail.com

## Acknowledgments

- **Flutter Team**: Framework yang luar biasa
- **MathJS**: API perhitungan matematika
- **YouTube**: Platform video pembelajaran
- **Firebase**: Backend services
- **Community Contributors**: Semua kontributor yang telah membantu

---

## Quick Start Guide

```bash
# Clone dan setup
git clone [repo-url]
cd ramysmart
flutter pub get

# Run aplikasi
flutter run

# Build untuk production
flutter build apk --release
```

⭐ **Star repository ini jika membantu Anda!**

---

*Dibuat dengan ❤️ oleh Tim RamySmart*
