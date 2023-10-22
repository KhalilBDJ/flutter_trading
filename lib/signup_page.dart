import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'classes/User.dart';

class SignupPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inscription'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final username = usernameController.text;
                final password = passwordController.text;
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final user = User(username, password, 1000);
                userProvider.logIn(user);  // Utilisez la même méthode logIn pour insérer l'utilisateur dans la base de données.
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Text('S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}
