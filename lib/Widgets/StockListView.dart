import 'package:flutter/material.dart';

class StockListView extends StatelessWidget {
  final Map<String, double> stockPrices;
  final Map<String, String> symbolToName;
  final Function(String, double) buyStock;

  const StockListView({super.key, required this.stockPrices, required this.symbolToName, required this.buyStock});

  @override
  Widget build(BuildContext context) {
    return stockPrices.isEmpty
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
                onPressed: () => buyStock(symbol, price!),
              ),
            ],
          ),
        );
      },
    );
  }
}
