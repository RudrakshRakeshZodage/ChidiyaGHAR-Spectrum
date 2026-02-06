import 'package:flutter/foundation.dart';

class HealthData {
  final String userName;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double calcium;
  final int steps;
  final double water;
  final double height; // in cm
  final double weight; // in kg
  final String email;
  final String phone;

  HealthData({
    this.userName = "John Doe",
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
    this.calcium = 0,
    this.steps = 0,
    this.water = 0,
    this.height = 170,
    this.weight = 70,
    this.email = "john.doe@example.com",
    this.phone = "+91 98765 43210",
  });

  HealthData copyWith({
    String? userName,
    double? calories,
    double? protein,
    double? carbs,
    double? fats,
    double? calcium,
    int? steps,
    double? water,
    double? height,
    double? weight,
    String? email,
    String? phone,
  }) {
    return HealthData(
      userName: userName ?? this.userName,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      calcium: calcium ?? this.calcium,
      steps: steps ?? this.steps,
      water: water ?? this.water,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}

class HealthService extends ChangeNotifier {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  HealthData _currentData = HealthData(
    userName: "John Doe",
    calories: 1240,
    protein: 45,
    carbs: 120,
    fats: 50,
    calcium: 400,
    steps: 6432,
    water: 1.2,
    height: 178,
    weight: 74,
    email: "john.doe@example.com",
    phone: "+91 98765 43210",
  );

  HealthData get currentData => _currentData;

  void updateProfile({String? name, double? height, double? weight, String? email, String? phone}) {
    _currentData = _currentData.copyWith(
      userName: name,
      height: height,
      weight: weight,
      email: email,
      phone: phone,
    );
    notifyListeners();
  }

  void addFood(double calories, double protein, double carbs, double fats, double calcium) {
    _currentData = _currentData.copyWith(
      calories: _currentData.calories + calories,
      protein: _currentData.protein + protein,
      carbs: _currentData.carbs + carbs,
      fats: _currentData.fats + fats,
      calcium: _currentData.calcium + calcium,
    );
    notifyListeners();
  }

  void addWater(double amount) {
    _currentData = _currentData.copyWith(water: _currentData.water + amount);
    notifyListeners();
  }

  void addSteps(int count) {
    _currentData = _currentData.copyWith(steps: _currentData.steps + count);
    notifyListeners();
  }
}
