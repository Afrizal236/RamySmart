import 'package:flutter/material.dart';
import 'package:ramysmart/util/constants.dart';
import 'package:ramysmart/screens/home/widget/account_profile.dart';
import 'package:ramysmart/screens/home/widget/notification_page.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationPage(
                      // Provide the required callback
                      onNavigateToHome: () {
                        // Navigate back to home or refresh home state
                        // You can customize this based on your needs
                        Navigator.popUntil(context, (route) => route.isFirst);
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
                  MaterialPageRoute(builder: (context) => const AccountProfile()),
                );
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
}