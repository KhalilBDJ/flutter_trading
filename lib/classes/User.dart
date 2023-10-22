import 'package:flutter/material.dart';
class User {
  final String username;
  final String password;
  double balance;

  User(this.username, this.password, this.balance);
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

  void updateBalance(double amount) {
    if (_user != null) {
      _user!.balance += amount;
      notifyListeners();
    }
  }
}

