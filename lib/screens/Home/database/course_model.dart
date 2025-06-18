import 'package:flutter/material.dart';
import 'dart:core';

// Model untuk Course
class Course {
  final String id;
  final String title;
  final String provider;
  final double rating;
  final double price;
  final Color cardColor;
  final IconData icon;
  final String description;
  final String youtubeUrl;
  final int lessons;
  final double minutes;
  final List<Section> sections;

  Course({
    required this.id,
    required this.title,
    required this.provider,
    required this.rating,
    required this.price,
    required this.cardColor,
    required this.icon,
    required this.description,
    required this.youtubeUrl,
    required this.lessons,
    required this.minutes,
    required this.sections,
  });
}

// Model untuk Section
class Section {
  final String title;
  final List<Lesson> lessons;
  bool isExpanded;

  Section({
    required this.title,
    required this.lessons,
    this.isExpanded = false,
  });
}

// Model untuk Lesson
class Lesson {
  final String title;
  final Duration duration;
  final String? youtubeUrl;

  Lesson({
    required this.title,
    required this.duration,
    this.youtubeUrl,
  });
}