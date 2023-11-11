import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddFundsWidget extends StatefulWidget {
  final TextEditingController amountController;
  final Function(double, bool) updateBalance;
  Map<String, double> stockPrices = {};


  AddFundsWidget({
    Key? key,
    required this.amountController,
    required this.updateBalance,
    required this.stockPrices
  }) : super(key: key);

  @override
  _AddFundsWidgetState createState() => _AddFundsWidgetState();
}

class _AddFundsWidgetState extends State<AddFundsWidget> {
  Map<String, Map<String, dynamic>> purchasedStocks = {};
  double walletValue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  Future<void> _loadStockData() async {
    final prefs = await SharedPreferences.getInstance();
    final purchasedStocksData = prefs.getString('purchased_stocks');

    if (purchasedStocksData != null) {
      setState(() {
        purchasedStocks = Map<String, Map<String, dynamic>>.from(json.decode(purchasedStocksData));
        walletValue = _getWalletValue();
      });
    }
  }

  double _getWalletValue() {
    double totalValue = 0.0;
    purchasedStocks.forEach((symbol, stockData) {
      final currentPrice = widget.stockPrices[symbol] ?? 0.0;
      final quantity = stockData['quantity'] ?? 0;
      totalValue += currentPrice * quantity;
    });
    return totalValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Valeur du portefeuille: \$${walletValue.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white, fontSize: 16.0),
        ),
        TextField(
          controller: widget.amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Montant à ajouter',
            labelStyle: TextStyle(color: Colors.green),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(widget.amountController.text);
            if (amount != null && amount > 0) {
              widget.updateBalance(amount, true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Montant ajouté : $amount')),
              );
              widget.amountController.clear();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veuillez entrer un montant valide.')),
              );
            }
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}
