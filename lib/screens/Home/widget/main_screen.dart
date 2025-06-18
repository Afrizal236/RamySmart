import 'package:flutter/material.dart';
import 'package:ramysmart/screens/Home/course_home.dart';
import 'package:ramysmart/screens/Home/widget/cart.dart';
import 'package:ramysmart/screens/Home/widget/my_courses.dart';
import 'package:ramysmart/util/constants.dart';
import 'package:ramysmart/screens/Home/widget/wishlist.dart'; // Import Wishlist page
import 'package:ramysmart/screens/Home/widget/account_profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of pages to display
  final List<Widget> _pages = [
    const CourseHome(),
    const MyCourses(key: Key('my_courses')),
    const Cart(key: Key('cart')),
    const Wishlist(key: Key('wishlist')), // Use actual Wishlist widget
    const AccountProfile(key: Key('account')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      // Bottom navigation bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 60,
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
          label: const Text('2'), // This can be dynamic based on cart item count
          child: const Icon(
            Icons.shopping_cart,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? kPrimaryColor : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? kPrimaryColor : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}