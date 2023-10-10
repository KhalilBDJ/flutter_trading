import 'package:flutter/material.dart';
import 'classes/stock.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? soldeInitial = 1000.0;
  List<Stock> stocks = [
    Stock(name: "Tesla", category: "Automobile", quantity: 5),
    Stock(name: "McDonald's", category: "Restauration", quantity: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion de Portefeuille'),
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
              child: ListView.builder(
                itemCount: stocks.length,
                itemBuilder: (context, index) {
                  final stock = stocks[index];
                  return ListTile(
                    title: Text(stock.name),
                    subtitle: Text(stock.category),
                    trailing: Text('${stock.quantity}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _buyStock,
              child: Text("Acheter des actions"),
            ),
            ElevatedButton(
              onPressed: _sellStock,
              child: Text("Vendre des actions"),
            ),
          ],
        ),
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
