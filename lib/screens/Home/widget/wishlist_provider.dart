import 'package:flutter/material.dart';
import 'package:ramysmart/screens/Home/widget/featured_courses.dart';

class WishlistProvider extends ChangeNotifier {
  // Singleton pattern
  static final WishlistProvider _instance = WishlistProvider._internal();

  factory WishlistProvider() {
    return _instance;
  }

  WishlistProvider._internal();

  // List to keep track of courses in wishlist
  final List<Course> _wishlistCourses = [];

  // Getter for wishlist courses
  List<Course> get wishlistCourses => _wishlistCourses;

  // Method to check if a course is in wishlist
  bool isInWishlist(String id) {
    return _wishlistCourses.any((course) => course.id == id);
  }

  // Add a course to wishlist
  void addToWishlist(Course course) {
    if (!isInWishlist(course.id)) {
      _wishlistCourses.add(course);
      notifyListeners();
    }
  }

  // Remove a course from wishlist
  void removeFromWishlist(String id) {
    _wishlistCourses.removeWhere((course) => course.id == id);
    notifyListeners();
  }

  // Toggle wishlist status
  void toggleWishlist(Course course) {
    if (isInWishlist(course.id)) {
      removeFromWishlist(course.id);
    } else {
      addToWishlist(course);
    }
  }
}