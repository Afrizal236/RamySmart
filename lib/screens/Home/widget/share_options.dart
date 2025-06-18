import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import for WhatsApp icon
import 'featured_courses.dart';

// Share functionality for CourseDetailPage
class ShareOptions {
  // Method to show share options
  static void showShareOptions(BuildContext context, Course course) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share this course',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // WhatsApp
                  ShareOptionButton(
                    icon: FontAwesomeIcons.whatsapp, // Using FontAwesome for WhatsApp icon
                    color: Colors.green,
                    label: 'WhatsApp',
                    onTap: () {
                      _shareViaWhatsApp(course);
                      Navigator.pop(context);
                    },
                  ),

                  // Instagram
                  ShareOptionButton(
                    icon: Icons.camera_alt,
                    color: Colors.pink,
                    label: 'Instagram',
                    onTap: () {
                      _shareViaInstagram(course);
                      Navigator.pop(context);
                    },
                  ),

                  // Email
                  ShareOptionButton(
                    icon: Icons.email,
                    color: Colors.red,
                    label: 'Email',
                    onTap: () {
                      _shareViaEmail(course);
                      Navigator.pop(context);
                    },
                  ),

                  // Copy Link
                  ShareOptionButton(
                    icon: Icons.copy,
                    color: Colors.blue,
                    label: 'Copy Link',
                    onTap: () {
                      _copyLink(context, course);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Use share_plus to share with any available app
                  _shareWithAnyApp(course);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Share with other apps'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Generate share text
  static String _generateShareText(Course course) {
    return "Check out this amazing course: ${course.title}\n"
        "by ${course.provider}\n"
        "Price: \$${course.price.toStringAsFixed(1)}\n"
        "Rating: ${course.rating}\n\n"
        "Download our app to access this and more educational content!";
  }

  // Share via WhatsApp
  static void _shareViaWhatsApp(Course course) {
    final text = _generateShareText(course);
    // WhatsApp URL scheme
    final whatsappUrl = "whatsapp://send?text=${Uri.encodeComponent(text)}";
    launchUrl(Uri.parse(whatsappUrl));
  }

  // Share via Instagram
  static void _shareViaInstagram(Course course) {
    // Instagram doesn't have a direct share URL scheme for text
    // We can use the general share method which might open Instagram
    Share.share(_generateShareText(course));
  }

  // Share via Email
  static void _shareViaEmail(Course course) {
    final subject = "Check out this course: ${course.title}";
    final body = _generateShareText(course);
    final emailUrl = "mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}";
    launchUrl(Uri.parse(emailUrl));
  }

  // Copy link to clipboard
  static void _copyLink(BuildContext context, Course course) {
    // This would be your actual deep link in a real app
    final courseLink = "https://youreducationapp.com/course/${course.id}";

    // Using Clipboard from services package
    Clipboard.setData(ClipboardData(text: courseLink)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course link copied to clipboard!')),
      );
    });
  }

  // Share with any available app
  static void _shareWithAnyApp(Course course) {
    Share.share(_generateShareText(course));
  }
}

// Custom share option button
class ShareOptionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const ShareOptionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}