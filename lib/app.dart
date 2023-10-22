import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'classes/User.dart';
import 'home_page.dart';
import 'login.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Portefeuille',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',  // Définir la route initiale
      routes: {
        '/': (context) => Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            if (userProvider.user == null) {
              return LoginPage();
            } else {
              return HomePage();
            }
          },
        ),
        '/home': (context) => HomePage(),  // Définir la route '/home' pour HomePage
      },
    );
  }
}
