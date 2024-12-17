// lib/models/user_model.dart
import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String? _userId;

  String? get userId => _userId;

  void setUserId(String id) {
    _userId = id;
    notifyListeners();
  }
}
