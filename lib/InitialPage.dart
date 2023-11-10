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
        const SnackBar(content: Text('Veuillez fournir des informations valides.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = ThemeData(
      brightness: Brightness.dark, // Fond sombre
      primaryColor: Colors.black,
      hintColor: Colors.greenAccent,
      textTheme: const TextTheme(
        headline1: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold, color: Colors.white),
        subtitle1: TextStyle(fontSize: 18.0, color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always, // étiquettes flottantes
        labelStyle: TextStyle(color: Colors.greenAccent),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.greenAccent),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: Colors.greenAccent,
          onPrimary: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(title: const Text('Bienvenue dans Tradet')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Entrez vos détails', style: theme.textTheme.headline1),
              const SizedBox(height: 32.0),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Montant initial'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () => saveData(context),
                child: Text("C'est parti", style: theme.textTheme.subtitle1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
