import 'package:flutter/material.dart';
import 'classes/stock.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? soldeInitial = 1000.0;
  int _selectedIndex = 0;
  List<Stock> stocks = [
    Stock(name: "Tesla", category: "Automobile", quantity: 5),
    Stock(name: "McDonald's", category: "Restauration", quantity: 3),
  ];

  static List<Widget> _widgetOptions = <Widget>[
    Text('Page d\'accueil'),
    Text('Cours de la bourse'),
    Text('Profil'),
    Text('Réglages'),
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
              child: _widgetOptions.elementAt(_selectedIndex),
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
  void _buyStock() {
    // Logique d'achat d'actions
  }

  void _sellStock() {
    // Logique de vente d'actions
  }
}



