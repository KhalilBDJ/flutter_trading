import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  double balance = 0.0;
  final TextEditingController _amountController = TextEditingController();
  final String apiKey = '1TO1GFCDP5UW238V';  // Remplacez par votre clé API
  final List<String> symbols = [
    'AI.PA', 'AIR.PA', 'ALO.PA', 'MT.AS', 'CS.PA',
    //... Ajoutez plus de symboles si nécessaire
  ];
  Map<String, double> stockPrices = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _fetchStockPrices();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      balance = prefs.getDouble('amount') ?? 0.0;
    });
  }

  Future<void> _fetchStockPrices() async {
    for (String symbol in symbols) {
      final response = await http.get(
        Uri.parse('https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Global Quote'] != null) {
          final price = double.parse(data['Global Quote']['05. price']);
          setState(() {
            stockPrices[symbol] = price;
          });
        }
      }
    }
  }

  List<Widget> _widgetOptions(BuildContext context) {
    return <Widget>[
      stockPrices.isEmpty
          ? CircularProgressIndicator()
          : ListView.builder(
        itemCount: stockPrices.length,
        itemBuilder: (context, index) {
          final symbol = stockPrices.keys.elementAt(index);
          final price = stockPrices[symbol];
          return ListTile(
            title: Text(symbol),
            trailing: Text('\$${price?.toStringAsFixed(2)}'),
          );
        },
      ),
      Text('Cours des actions achetées'),
      Column(
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Montant à ajouter',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_amountController.text);
              if (amount != null && amount > 0) {
                _updateBalance(amount);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Montant ajouté : $amount')),
                );
                _amountController.clear();
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
      Text('Page de personnalisation du thème'),
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
              child: _widgetOptions(context).elementAt(_selectedIndex),
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
