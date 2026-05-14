import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/bmi_calculator.dart';
import '../core/utils/calorie_calculator.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService firestoreService = FirestoreService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _checkAuthState();
  }

  void _checkAuthState() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        _isLoggedIn = true;
        await _loadUserData(firebaseUser.uid);
      } else {
        _isLoggedIn = false;
        _user = null;
        notifyListeners();
      }
    });
  }
Future<void> refreshAuthState() async {
  _setLoading(true);
  try {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      _isLoggedIn = true;
      await _loadUserData(firebaseUser.uid);
    }
  } catch (e) {
    _error = e.toString();
  }
  _setLoading(false);
}



  Future<void> _loadUserData(String uid) async {
    _setLoading(true);
    try {
      UserModel? userData = await _authService.getUserData(uid);
      if (userData != null) {
        _user = userData;
        await _cacheUserData(userData);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required double height,
    required double weight,
    required int age,
    required String gender,
    required String fitnessGoal,
  }) async {
    _setLoading(true);
    try {
      UserModel? newUser = await _authService.signUp(
        name: name,
        email: email,
        password: password,
        height: height,
        weight: weight,
        age: age,
        gender: gender,
        fitnessGoal: fitnessGoal,
      );
      
      if (newUser != null) {
        _user = newUser;
        _isLoggedIn = true;
        await _cacheUserData(newUser);
        _error = null;
      }
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      UserModel? userData = await _authService.signIn(
        email: email,
        password: password,
      );
      
      if (userData != null) {
        _user = userData;
        _isLoggedIn = true;
        await _cacheUserData(userData);
        _error = null;
      }
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _user = null;
      _isLoggedIn = false;
      _error = null;
      await _clearCache();
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    _setLoading(true);
    try {
      // Recalculate BMI and TDEE if weight/height changed
      if (updatedUser.weight != _user?.weight || updatedUser.height != _user?.height) {
        double bmi = BMICalculator.calculateBMI(updatedUser.weight, updatedUser.height);
        String bmiCategory = BMICalculator.getBMICategory(bmi);
        double bmr = CalorieCalculator.calculateBMR(
          updatedUser.weight, updatedUser.height, updatedUser.age, updatedUser.gender,
        );
        double dailyCalorieGoal = CalorieCalculator.calculateTDEE(bmr, updatedUser.fitnessGoal);
        
        updatedUser = updatedUser.copyWith(
          bmi: bmi,
          bmiCategory: bmiCategory,
          dailyCalorieGoal: dailyCalorieGoal,
          updatedAt: DateTime.now(),
        );
      }

      await _authService.updateUserData(updatedUser);
      _user = updatedUser;
      await _cacheUserData(updatedUser);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

 Future<void> _cacheUserData(UserModel user) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);
  await prefs.setString('cachedUserId', user.uid);
}

  Future<void> _clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefIsLoggedIn, false);
    await prefs.remove(AppConstants.prefUserData);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}