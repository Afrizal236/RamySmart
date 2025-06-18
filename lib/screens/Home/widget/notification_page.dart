import 'package:flutter/material.dart';
import 'package:ramysmart/util/constants.dart';

class NotificationPage extends StatelessWidget {
  // Make callback optional instead of required
  final Function()? onNavigateToHome;

  // Remove required and make it optional
  const NotificationPage({super.key, this.onNavigateToHome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          // Use standard navigation instead of custom handler
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Semua Notifikasi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView(
                children: [
                  _buildNotificationItem(
                    context,
                    title: "Kursus Baru Tersedia",
                    message: "Flutter untuk Pemula telah ditambahkan. Mulai belajar sekarang!",
                    time: "Baru saja",
                    isUnread: true,
                  ),
                  _buildNotificationItem(
                    context,
                    title: "Pengingat Pembelajaran",
                    message: "Sudah waktunya melanjutkan kursus Dart Programming Anda",
                    time: "2 jam yang lalu",
                    isUnread: true,
                  ),
                  _buildNotificationItem(
                    context,
                    title: "Penawaran Terbatas",
                    message: "Dapatkan diskon 30% untuk kursus premium bulan ini",
                    time: "Kemarin",
                    isUnread: false,
                  ),
                  _buildNotificationItem(
                    context,
                    title: "Tugas Baru",
                    message: "Ada tugas baru di kursus Flutter State Management",
                    time: "2 hari yang lalu",
                    isUnread: false,
                  ),
                  _buildNotificationItem(
                    context,
                    title: "Pencapaian Baru",
                    message: "Selamat! Anda telah menyelesaikan kursus dasar Flutter",
                    time: "3 hari yang lalu",
                    isUnread: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
      BuildContext context, {
        required String title,
        required String message,
        required String time,
        required bool isUnread,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUnread ? kOptionColor.withOpacity(0.8) : kOptionColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: isUnread ? Colors.blue : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          // Add logic to handle notification click
          // You might want to mark as read or navigate to related content
        },
      ),
    );
  }
}