import 'package:flutter/material.dart';
import 'database.dart';

class User {
  final String username;
  final String password;
  double balance;

  User(this.username, this.password, this.balance);

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnUsername: username,
      DatabaseHelper.columnPassword: password,
      DatabaseHelper.columnBalance: balance,
    };
  }
}

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void logIn(User user) async {
    final dbHelper = DatabaseHelper.instance;
    final userMap = user.toMap();
    await dbHelper.insertUser(userMap);
    _user = user;
    notifyListeners();
  }

  void logOut() {
    _user = null;
    notifyListeners();
  }

  void updateBalance(double amount) async {
    if (_user != null) {
      final dbHelper = DatabaseHelper.instance;
      final newBalance = _user!.balance + amount;
      await dbHelper.updateUser(_user!.username, newBalance);
      _user!.balance = newBalance;
      notifyListeners();
    }
  }
}
