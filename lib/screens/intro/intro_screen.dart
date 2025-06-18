import 'package:flutter/material.dart';
import 'package:ramysmart/util/constants.dart';
import 'package:ramysmart/util/route_name.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/intro/intro.jpg"),
          const SizedBox(
            height: 30,
          ),
          Text(
            "Grow Your Skills",
            style: TextStyle(fontSize: 25, color: Colors.grey.shade900),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Choose your favorite course & start learning",
            style: TextStyle(fontSize: 17, color: Colors.grey.shade500),
          ),
          const SizedBox(
            height: 50,
          ),
          ElevatedButton(
            onPressed: () {
              // Untuk pengguna baru yang ingin langsung mendaftar
              Navigator.pushNamed(context, RouteNames.signup);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                )
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: Text("Getting Started",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Tambahkan opsi login untuk pengguna yang sudah memiliki akun
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.login);
                },
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}