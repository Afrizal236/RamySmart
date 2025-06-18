// snbt_questionnaire.dart
// File ini bisa dihapus atau dijadikan standalone page jika masih diperlukan untuk akses terpisah
import 'package:flutter/material.dart';
import 'package:ramysmart/util/constants.dart';
import 'package:ramysmart/util/route_name.dart';

class SNBTQuestionnaire extends StatelessWidget {
  const SNBTQuestionnaire({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SNBT Questionnaire'),
        backgroundColor: kPrimaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.quiz,
                size: 80,
                color: kPrimaryColor,
              ),
              const SizedBox(height: 20),
              const Text(
                'Kuesioner SNBT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Kuesioner SNBT sekarang terintegrasi dengan halaman Home.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteNames.courseHome,
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  'Ke Halaman Home',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}