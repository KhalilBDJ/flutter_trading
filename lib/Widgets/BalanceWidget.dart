import 'package:flutter/material.dart';

class BalanceWidget extends StatelessWidget {
  final double balance;

  const BalanceWidget({Key? key, required this.balance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Solde actuel: \$${balance.toStringAsFixed(2)}',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
