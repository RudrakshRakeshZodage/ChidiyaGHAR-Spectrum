import 'package:flutter/material.dart';

class UserData {
  final String name;
  final int age;
  final String gender;
  final String category;

  UserData({
    required this.name,
    required this.age,
    required this.gender,
    required this.category,
  });

  bool get isFemale => gender.toLowerCase() == 'female';
}

// Mock user data for demonstration
final mockUser = UserData(
  name: 'John Doe',
  age: 28,
  gender: 'Male',
  category: 'Working Professional',
);
