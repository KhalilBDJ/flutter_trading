import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'classes/User.dart';
import 'signup_page.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                // Vous devrez vérifier les identifiants avant de vous connecter.
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final user = User(username, password, 1000);
                userProvider.logIn(user);
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Text('Connexion'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage()),
                );
              },
              child: Text('S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}
