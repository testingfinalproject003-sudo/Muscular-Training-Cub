import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/utils/bmi_calculator.dart';
import '../core/utils/calorie_calculator.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
    required double height,
    required double weight,
    required int age,
    required String gender,
    required String fitnessGoal,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user == null) return null;

      // Calculate BMI and TDEE
      double bmi = BMICalculator.calculateBMI(weight, height);
      String bmiCategory = BMICalculator.getBMICategory(bmi);
      double bmr = CalorieCalculator.calculateBMR(weight, height, age, gender);
      double dailyCalorieGoal = CalorieCalculator.calculateTDEE(bmr, fitnessGoal);

      UserModel userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        height: height,
        weight: weight,
        age: age,
        gender: gender,
        fitnessGoal: fitnessGoal,
        bmi: bmi,
        bmiCategory: bmiCategory,
        dailyCalorieGoal: dailyCalorieGoal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toJson());
      
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toJson());
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}