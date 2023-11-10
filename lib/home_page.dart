import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'Widgets/AddFundsWidget.dart';
import 'Widgets/CandleChart.dart';
import 'Widgets/Footers.dart';
import 'Widgets/PurchasedStockListView.dart';
import 'Widgets/StockListView.dart';
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
  final String apiKey = 'EZDQ7J9K887K78PJ'; //1TO1GFCDP5UW238V    EZDQ7J9K887K78PJ  IE4H61S0VOHDBQJ7
  late AnimationController _animationController;
  late Animation<double> _animation;
  String selectedPeriod = '1W'; // Valeur par défaut pour la période
  String selectedSymbol = 'AI.PA'; // Valeur par défaut pour l'action

  List<CandleData> candleData = [];

  Map<String, double> stockPrices = {};
  final Map<String, String> symbolToName = {
    'AI.PA': 'AIR LIQUIDE',
    'AIR.PA': 'AIRBUS',
    'ALO.PA': 'ALSTOM',
    'MT.AS': 'ARCELORMITTAL SA',
    'CS.PA': 'AXA',
  };
  Map<String, Map<String, dynamic>> purchasedStocks = {};
  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _fetchStockPrices();
    _loadPurchasedStocks();

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
          json.decode(data));
    }
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      balance = prefs.getDouble('amount') ?? 0.0;
    });
  }

  Future<void> _fetchStockPrices() async {
    final prefs = await SharedPreferences.getInstance();
    final lastFetchDate = prefs.getString('lastFetchDate');
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastFetchDate == today) {
      final cachedData = prefs.getString('allTimeSeriesData');
      if (cachedData != null) {
        final allData = json.decode(cachedData) as Map<String, dynamic>;
        setState(() {
          stockPrices = allData.map((symbol, dynamic symbolData) {
            final dateData = symbolData as Map<String, dynamic>;
            final latestDate = dateData.keys.first; // Assuming the first key is the latest date
            final priceData = dateData[latestDate] as Map<String, dynamic>;
            final closePrice = double.tryParse(priceData['4. close'].toString()) ?? 0.0;
            return MapEntry(symbol, closePrice);
          });
        });
        return;
      }
    }

    Map<String, dynamic> allTimeSeriesData = {};

    for (String symbol in symbolToName.keys) {
      final response = await http.get(
        Uri.parse('https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=$symbol&apikey=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        allTimeSeriesData[symbol] = data['Time Series (Daily)'];
        if (data['Time Series (Daily)'] != null) {
          final dailyData = data['Time Series (Daily)'];
          final latestDate = dailyData.keys.first;
          final latestData = dailyData[latestDate];
          final closePrice = double.parse(latestData['4. close']);
          setState(() {
            stockPrices[symbol] = closePrice;
          });
        }
      }
    }

    await prefs.setString('allTimeSeriesData', json.encode(allTimeSeriesData));
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


  List<Widget> _widgetOptions(BuildContext context) {
    return <Widget>[
      StockListView(stockPrices: stockPrices, symbolToName: symbolToName, buyStock: _buyStock),
      PurchasedStockListView(purchasedStocks: purchasedStocks, stockPrices: stockPrices, symbolToName: symbolToName,onSellStock: _sellStock),
      AddFundsWidget(amountController: _amountController, updateBalance: _updateBalance),
      CandleChart(symbolToName: symbolToName),
    ];
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }



  @override
  Widget build(BuildContext context) {
    return HomePageWidget(
      balance: balance,
      selectedIndex: _selectedIndex,
      widgetOptions: _widgetOptions(context),
      onItemTapped: _onItemTapped,
    );
  }


  void _sellStock(String symbol, double currentPrice) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController quantityController = TextEditingController();
        return AlertDialog(
          title: Text('Vendre des actions de $symbol'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Prix actuel par action: \$${currentPrice.toStringAsFixed(2)}'),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantité à vendre'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final quantityToSell = int.tryParse(quantityController.text);
                if (quantityToSell != null && quantityToSell > 0 && purchasedStocks[symbol] != null) {
                  final existingQuantity = purchasedStocks[symbol]!['quantity'];
                  if (quantityToSell <= existingQuantity) {
                    final profit = stockPrices[symbol]! * quantityToSell;
                    _updateBalance(profit, true);
                    _updatePurchasedStocksAfterSale(symbol, quantityToSell);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Quantité de vente invalide.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez entrer une quantité valide.')),
                  );
                }
              },
              child: const Text('Vendre'),
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

  void _updateBalance(double amount, bool isAdding) {
    final startBalance = balance;
    final endBalance = isAdding ? balance + amount : balance - amount;

    _animation = Tween<double>(begin: startBalance, end: endBalance).animate(_animationController);

    _animationController.reset();
    _animationController.forward();

    SharedPreferences.getInstance().then((prefs) {
      prefs.setDouble('amount', endBalance);
    });
  }

  void _updatePurchasedStocksAfterSale(String symbol, int quantitySold) {
    setState(() {
      final existingQuantity = purchasedStocks[symbol]!['quantity'];
      if (existingQuantity - quantitySold > 0) {
        purchasedStocks[symbol]!['quantity'] -= quantitySold;
      } else {
        purchasedStocks.remove(symbol);
      }
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('purchased_stocks', json.encode(purchasedStocks));
    });
  }

  void _updatePurchasedStocks(String symbol, int quantity, double price) {
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

}
