import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'classes/stock.dart';
import 'classes/User.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? soldeInitial = 1000.0;
  int _selectedIndex = 0;
  final TextEditingController _amountController = TextEditingController();

  static List<Widget> _widgetOptions(BuildContext context, TextEditingController amountController, _HomePageState state) => <Widget>[
    Text('Page d\'accueil'),
    Text('Cours de la bourse'),
    Column(
      children: [
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Montant à ajouter',
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(amountController.text);
            if (amount != null && amount > 0) {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              userProvider.updateBalance(amount);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Montant ajouté : $amount')),
              );
              amountController.clear();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Veuillez entrer un montant valide.')),
              );
            }
          },
          child: Text('Ajouter'),
        ),
      ],
    ),
    Column(
      children: [
        ElevatedButton(
          onPressed: () {
            final userProvider = Provider.of<UserProvider>(context, listen: false);
            userProvider.logOut();
            Navigator.pushReplacementNamed(context, '/');
          },
          child: Text('Déconnexion'),
        ),
      ],
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Solde actuel: \$${soldeInitial?.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _widgetOptions(context, _amountController, this).elementAt(_selectedIndex),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Bourse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Réglages',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
