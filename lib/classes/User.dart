import 'package:flutter/material.dart';

class User {
  final String username;
  final String password;

  User(this.username, this.password);
}

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void logIn(User user) {
    _user = user;
    notifyListeners();
  }

  void logOut() {
    _user = null;
    notifyListeners();
  }
}
