import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'classes/User.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TextField(
              decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final user = User('username', 'password', 1000);  // Remplacer par les valeurs des champs de texte
                userProvider.logIn(user);
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Text('Connexion'),
            ),
          ],
        ),
      ),
    );
  }
}
