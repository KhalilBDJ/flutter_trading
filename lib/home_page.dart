import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'classes/CandleData.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  double balance = 0.0;
  final TextEditingController _amountController = TextEditingController();
  final String apiKey = '1TO1GFCDP5UW238V';
  late AnimationController _animationController;
  late Animation<double> _animation;
  String selectedTimeRange = '1W'; // Par défaut une semaine
  List<CandleData> candleData = [];

  Map<String, double> stockPrices = {};
  final Map<String, String> symbolToName = {
    'AI.PA': 'AIR LIQUIDE',
    'AIR.PA': 'AIRBUS',
    'ALO.PA': 'ALSTOM',
    'MT.AS': 'ARCELORMITTAL SA',
    'CS.PA': 'AXA',
  };
  Map<String, Map<String, dynamic>> purchasedStocks = {}; // Ligne modifiée

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _fetchStockPrices();
    _loadPurchasedStocks();
    _loadChartData('1W');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000), // Durée de l'animation
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 0).animate(_animationController)
      ..addListener(() {
        setState(() {
          balance = _animation.value;
        });
      });
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPurchasedStocks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('purchased_stocks');
    if (data != null) {
      purchasedStocks = Map<String, Map<String, dynamic>>.from(
          json.decode(data)); // Ligne modifiée
    }
  }

  Future<void> _loadChartData() async {
    final prefs = await SharedPreferences.getInstance();

    // Tentative de chargement des données de série temporelle depuis le cache
    final cachedTimeSeriesData = prefs.getString('timeSeriesData');

    if (cachedTimeSeriesData != null) {
      // Les données existent dans le cache, on les décode
      final timeSeriesData = json.decode(cachedTimeSeriesData) as Map<String, dynamic>;

      // Préparation de la structure des données pour le graphique
      List<CandleData> candleData = [];

      // Ici, nous itérons à travers les données de séries temporelles
      // en supposant que 'timeSeriesData' est structurée avec des symboles d'actions comme clés
      // et des listes de données historiques comme valeurs
      for (String symbol in timeSeriesData.keys) {
        final symbolData = timeSeriesData[symbol];

        // Convertir les données en une forme utilisable par le graphique
        // Nous supposons que 'ChartData' est une classe qui représente les données de votre graphique
        for (String date in symbolData.keys) {
          final dayData = symbolData[date];
          final open = double.parse(dayData['1. open']);
          final high = double.parse(dayData['2. high']);
          final low = double.parse(dayData['3. low']);
          final close = double.parse(dayData['4. close']);
          // Création d'une instance de ChartData pour chaque jour
          candleData.add(CandleData(date, open, high, low, close));
        }
      }

      // Mettre à jour l'état pour afficher les données dans le graphique
      setState(() {
        // Vous pouvez avoir un état 'candleData' défini dans votre Stateful Widget
        // pour stocker les données et ensuite les utiliser dans un Widget graphique
        this.candleData = candleData;
      });
    } else {
      // S'il n'y a pas de données en cache, vous pourriez vouloir appeler une autre méthode
      // pour charger les données depuis une source externe ou afficher un message à l'utilisateur
      // Par exemple :
      // _fetchStockPrices();
    }
  }

  SfCartesianChart _buildCandleChart() {
    return SfCartesianChart(
      series: <CandleSeries>[
        CandleSeries<CandleData, String>(
          dataSource: candleData,
          xValueMapper: (CandleData sales, _) => sales.date,
          lowValueMapper: (CandleData sales, _) => sales.low,
          highValueMapper: (CandleData sales, _) => sales.high,
          openValueMapper: (CandleData sales, _) => sales.open,
          closeValueMapper: (CandleData sales, _) => sales.close,
        ),
      ],
    );
  }

  Widget _buildTimeRangeSelector() {
    return DropdownButton<String>(
      value: selectedTimeRange,
      items: <String>['1D', '1W', '1M', '3M', '6M', '1Y', '3Y']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedTimeRange = newValue!;
          _loadChartData(selectedTimeRange);
        });
      },
    );
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      balance = prefs.getDouble('amount') ?? 0.0;
    });
  }

  Future<void> _fetchStockPrices() async {
    final prefs = await SharedPreferences.getInstance();

    // Vérifiez si la date du dernier fetch est aujourd'hui
    final lastFetchDate = prefs.getString('lastFetchDate');
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastFetchDate != null && lastFetchDate == today) {
      // Chargez les données en cache au lieu de faire un nouvel appel à l'API
      final cachedData = prefs.getString('cachedStockPrices');
      if (cachedData != null) {
        final data = json.decode(cachedData);
        setState(() {
          stockPrices = data;
        });
        return;
      }
    }

    // Créez un objet pour stocker les données de la série temporelle
    Map<String, dynamic> timeSeriesData = {};

    // Si les données ne sont pas en cache ou sont périmées, faites un nouvel appel
    for (String symbol in symbolToName.keys) {
      final response = await http.get(
        Uri.parse(
            'https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=$symbol&apikey=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Obtenez les données de TIME_SERIES_DAILY pour le dernier jour de trading disponible
        if (data['Time Series (Daily)'] != null) {
          final latestData = data['Time Series (Daily)'][today];
          if (latestData != null) {
            final closePrice = double.parse(latestData['4. close']);
            setState(() {
              stockPrices[symbol] = closePrice;
            });
            // Ajoutez toutes les données de la série temporelle pour ce symbole
            timeSeriesData[symbol] = data['Time Series (Daily)'];
          }
        }
      }
    }
    // Sauvegardez les nouvelles données de prix de fermeture et les données de série temporelle dans le cache
    await prefs.setString('cachedStockPrices', json.encode(stockPrices));
    await prefs.setString('timeSeriesData', json.encode(timeSeriesData)); // Sauvegarde des données pour les chandeliers
    await prefs.setString('lastFetchDate', today);
  }


  void _buyStock(String symbol, double price) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController quantityController =
            TextEditingController();
        return AlertDialog(
          title: const Text('Acheter des actions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Prix par action: \$${price.toStringAsFixed(2)}'),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantité'),
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
                    _updateBalance(totalCost,
                        false); // Soustraire de l'argent pour l'achat d'actions
                    _updatePurchasedStocks(
                        symbol, quantity, price); //  ajout de l'argument prix
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Solde insuffisant.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Veuillez entrer une quantité valide.')),
                  );
                }
              },
              child: const Text('Acheter'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  void _updatePurchasedStocks(String symbol, int quantity, double price) {
    // Méthode ajoutée/modifiée
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
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () => _buyStock(symbol, price!),
                      ),
                    ],
                  ),
                );
              },
            ),
      purchasedStocks.isEmpty
          ? const Text('Aucune action achetée.', style: TextStyle(color: Colors.green))
          : ListView.builder(
              itemCount: purchasedStocks.length,
              itemBuilder: (context, index) {
                final symbol = purchasedStocks.keys.elementAt(index);
                final stockInfo = purchasedStocks[symbol];
                final currentPrice = stockPrices[symbol];

                if (stockInfo != null && currentPrice != null) {
                  final quantity = stockInfo['quantity'];
                  final purchasePrice = stockInfo['purchasePrice'];
                  final priceDifference =
                      (currentPrice - purchasePrice) * quantity;
                  final priceDifferenceString = priceDifference > 0
                      ? '+${priceDifference.toStringAsFixed(2)}'
                      : priceDifference.toStringAsFixed(2);
                  final color = priceDifference > 0 ? Colors.green : Colors.red;
                  final companyName = symbolToName[symbol] ?? symbol;

                  return ListTile(
                    title: Text('$companyName ($quantity)'),
                    trailing: Text(
                      '(\$${currentPrice.toStringAsFixed(2)}) ($priceDifferenceString)',
                      style: TextStyle(color: color),
                    ),
                  );
                } else {
                  // Handle the case when stockInfo or currentPrice is null
                  return const ListTile(
                    title: Text('Information non disponible'),
                  );
                }
              },
            ),

      //const Text('Cours des actions achetées'),
      Column(
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Montant à ajouter',
              labelStyle: TextStyle(color: Colors.green), // Pour rendre le texte en vert
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white), // Pour rendre la ligne en dessous blanche
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white), // Pour rendre la ligne en dessous blanche lors de la mise au point
              ),
            ),
          ),
          const SizedBox(height: 10.0),  // Pour espacer le bouton un peu plus bas
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_amountController.text);
              if (amount != null && amount > 0) {
                _updateBalance(amount, true); // Ajouter de l'argent
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Montant ajouté : $amount')),
                );
                _amountController.clear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Veuillez entrer un montant valide.')),
                );
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
      _buildTimeRangeSelector(),
      Expanded(
        child: _buildCandleChart(),
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateBalance(double amount, bool isAdding) {
    final startBalance = balance;
    final endBalance = isAdding ? balance + amount : balance - amount;

    _animation = Tween<double>(begin: startBalance, end: endBalance).animate(_animationController);

    _animationController.reset(); // Reset l'animation avant de la démarrer
    _animationController.forward();

    SharedPreferences.getInstance().then((prefs) {
      prefs.setDouble('amount', endBalance);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('Tradet', style: TextStyle(color: Colors.green)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Solde actuel: \$${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _widgetOptions(context).elementAt(_selectedIndex),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Accueil',
            backgroundColor: _selectedIndex == 0 ? Colors.grey : Colors.black,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.show_chart),
            label: 'Bourse',
            backgroundColor: _selectedIndex == 1 ? Colors.grey : Colors.black,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'Profil',
            backgroundColor: _selectedIndex == 2 ? Colors.grey : Colors.black,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: 'Réglages',
            backgroundColor: _selectedIndex == 3 ? Colors.grey : Colors.black,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[300],
        unselectedItemColor: Colors.green[700],
        onTap: _onItemTapped,
        selectedIconTheme: IconThemeData(
          color: Colors.green[300],
        ),
        unselectedIconTheme: IconThemeData(
          color: Colors.green[700],
        ),
        selectedLabelStyle: TextStyle(
          color: Colors.green[300],
        ),
        unselectedLabelStyle: TextStyle(
          color: Colors.green[700],
        ),
      ),
    );
  }
}
