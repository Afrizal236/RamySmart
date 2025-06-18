import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Class untuk menginisialisasi Firebase
class FirebaseConfig {
  static Future<void> init() async {
    await Firebase.initializeApp();
  }

  // Mendapatkan instance Firestore
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // Mendapatkan referensi koleksi kursus
  static CollectionReference get coursesCollection =>
      FirebaseFirestore.instance.collection('courses');
}