// lib/models/doctor.dart
// import 'package:flutter/material.dart';
// REMOVED: import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // FIX: Removed unused import if it was present
// REMOVED: import 'package:flutter_svg/flutter_svg.dart'; // FIX: Removed unused import if it was present

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String? imageUrl;
  final double rating;
  final String? experience;
  final String? bio;
  final String? availableTime;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    this.imageUrl,
    required this.rating,
    this.experience,
    this.bio,
    this.availableTime,
  });
}
