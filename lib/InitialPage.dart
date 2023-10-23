import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  void saveData(BuildContext context) async {
    final name = nameController.text;
    final amount = double.tryParse(amountController.text);
    if (name.isNotEmpty && amount != null && amount > 0) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('initialized', true);
      await prefs.setString('name', name);
      await prefs.setDouble('amount', amount);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez fournir des informations valides.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenue')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nom')),
            TextField(controller: amountController, decoration: InputDecoration(labelText: 'Montant initial')),
            ElevatedButton(onPressed: () => saveData(context), child: Text('Commencer')),
          ],
        ),
      ),
    );
  }
}
