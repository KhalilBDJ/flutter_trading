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
  final String apiKey = '1TO1GFCDP5UW238V';
  final List<String> symbols = [
    'AI.PA', 'AIR.PA', 'ALO.PA', 'MT.AS', 'CS.PA',
  ];
  Map<String, double> stockPrices = {};
  final Map<String, String> symbolToName = {
    'AI.PA': 'AIR LIQUIDE',
    'AIR.PA': 'AIRBUS',
    'ALO.PA': 'ALSTOM',
    'MT.AS': 'ARCELORMITTAL SA',
    'CS.PA': 'AXA',
  };
  Map<String, Map<String, dynamic>> purchasedStocks = {};  // Ligne modifiée


  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _fetchStockPrices();
    _loadPurchasedStocks();
  }

  Future<void> _loadPurchasedStocks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('purchased_stocks');
    if (data != null) {
      purchasedStocks = Map<String, Map<String, dynamic>>.from(json.decode(data));  // Ligne modifiée
    }
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

  void _buyStock(String symbol, double price) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController quantityController = TextEditingController();
        return AlertDialog(
          title: Text('Acheter des actions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Prix par action: \$${price.toStringAsFixed(2)}'),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantité'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final quantity = int.tryParse(quantityController.text);
                if (quantity != null && quantity > 0) {
                  final totalCost = price * quantity;
                  if (balance >= totalCost) {
                    _updateBalance(totalCost, false);  // Soustraire de l'argent pour l'achat d'actions
                    _updatePurchasedStocks(symbol, quantity, price);  // Modifié ici : ajout de l'argument prix
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Solde insuffisant.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez entrer une quantité valide.')),
                  );
                }
              },
              child: Text('Acheter'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  void _updatePurchasedStocks(String symbol, int quantity, double price) {  // Méthode ajoutée/modifiée
    setState(() {
      final existingQuantity = (purchasedStocks[symbol] != null)
          ? purchasedStocks[symbol]!['quantity']
          : 0;
      purchasedStocks[symbol] = {
        'quantity': existingQuantity + quantity,
        'purchasePrice': price,
      };
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('purchased_stocks', json.encode(purchasedStocks));
    });
  }



  List<Widget> _widgetOptions(BuildContext context) {
    return <Widget>[
      stockPrices.isEmpty
          ? const CircularProgressIndicator()
          : ListView.builder(
        itemCount: stockPrices.length,
        itemBuilder: (context, index) {
          final symbol = stockPrices.keys.elementAt(index);
          final price = stockPrices[symbol];
          final companyName = symbolToName[symbol] ?? symbol;
          return ListTile(
            title: Text(companyName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('\$${price?.toStringAsFixed(2)}'),
                IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () => _buyStock(symbol, price!),
                ),
              ],
            ),
          );
        },
      ),
      purchasedStocks.isEmpty
          ? const Text('Aucune action achetée.')
          : ListView.builder(
        itemCount: purchasedStocks.length,
        itemBuilder: (context, index) {
          final symbol = purchasedStocks.keys.elementAt(index);
          final quantity = purchasedStocks[symbol]!['quantity'];
          final purchasePrice = purchasedStocks[symbol]!['purchasePrice'];
          final currentPrice = stockPrices[symbol];
          final priceDifference = (currentPrice! - purchasePrice) * quantity;
          final priceDifferenceString = priceDifference > 0 ? '+${priceDifference.toStringAsFixed(2)}' : priceDifference.toStringAsFixed(2);
          final color = priceDifference > 0 ? Colors.green : Colors.red;
          final companyName = symbolToName[symbol] ?? symbol;

          return ListTile(
            title: Text('$companyName ($quantity)'),
            trailing: Text(
              '(\$${currentPrice?.toStringAsFixed(2)}) ($priceDifferenceString)',
              style: TextStyle(color: color),
            ),
          );
        },
      ),

      //const Text('Cours des actions achetées'),
      Column(
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Montant à ajouter',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_amountController.text);
              if (amount != null && amount > 0) {
                _updateBalance(amount, true);  // Ajouter de l'argent
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Montant ajouté : $amount')),
                );
                _amountController.clear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez entrer un montant valide.')),
                );
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
      const Text('Page de personnalisation du thème'),
    ];
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateBalance(double amount, bool isAdding) {
    setState(() {
      balance = isAdding ? balance + amount : balance - amount;
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
