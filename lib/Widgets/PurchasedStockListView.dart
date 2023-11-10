import 'package:flutter/material.dart';

class PurchasedStockListView extends StatelessWidget {
  final Map<String, Map<String, dynamic>> purchasedStocks;
  final Map<String, double> stockPrices;
  final Map<String, String> symbolToName;
  final Function(String, double) onSellStock;

  const PurchasedStockListView({
    Key? key,
    required this.purchasedStocks,
    required this.stockPrices,
    required this.symbolToName,
    required this.onSellStock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return purchasedStocks.isEmpty
        ? const Text('Aucune action achetée.',
        style: TextStyle(color: Colors.white))
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
              (currentPrice - purchasePrice!) * quantity!;
          final priceDifferenceString = priceDifference > 0
              ? '+${priceDifference.toStringAsFixed(2)}'
              : priceDifference.toStringAsFixed(2);
          final color = priceDifference >= 0 ? Colors.green : Colors.red;
          final companyName = symbolToName[symbol] ?? symbol;
          return ListTile(
            leading: const Icon(Icons.sell, color: Colors.green),
            title: Text('$companyName ($quantity)',
                style: const TextStyle(color: Colors.white)),
            trailing: Text(
              '(\$${currentPrice.toStringAsFixed(2)}) ($priceDifferenceString)',
              style: TextStyle(color: color),
            ),
            onTap: () => onSellStock(symbol, currentPrice),
          );
        } else {
          return const ListTile(
            title: Text('Information non disponible'),
          );
        }
      },
    );
  }
}
