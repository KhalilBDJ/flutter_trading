import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  double balance = 0.0;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      balance = prefs.getDouble('amount') ?? 0.0;
    });
  }

  static List<Widget> _widgetOptions(
      BuildContext context, TextEditingController amountController, double balance, Function updateBalance) {
    return <Widget>[
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
                updateBalance(amount);
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
      Text('Réglages'),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateBalance(double amount) {
    setState(() {
      balance += amount;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setDouble('amount', balance);
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
              'Solde actuel: \$${balance.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _widgetOptions(context, _amountController, balance, _updateBalance).elementAt(_selectedIndex),
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
