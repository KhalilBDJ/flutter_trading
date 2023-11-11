import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'InitialPage.dart';
import 'home_page.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<bool>(
          future: _checkInitialLaunch(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.data == true) {
              return InitialPage();
            }
            return const HomePage();
          },
        ),
        '/home': (context) => const HomePage(),
      },
    );
  }

  Future<bool> _checkInitialLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey('initialized');
  }
}

// 1TO1GFCDP5UW238V
