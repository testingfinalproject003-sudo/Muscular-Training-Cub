import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }

  Stream<UserModel?> streamUser(String uid) {
    return _firestoreService.streamUser(uid).map((user) {
      _user = user;
      notifyListeners();
      return user;
    });
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}