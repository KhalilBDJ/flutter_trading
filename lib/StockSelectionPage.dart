import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StockSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sélection d\'actions'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Choisissez une action à acheter:',
            ),
            // Vous pouvez lister des actions ici
            ElevatedButton(
              onPressed: () {
                // Ajoutez le code pour acheter des actions
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Text('Acheter'),
            ),
          ],
        ),
      ),
    );
  }
}
