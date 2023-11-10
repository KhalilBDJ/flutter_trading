import 'package:flutter/material.dart';

class AddFundsWidget extends StatelessWidget {
  final TextEditingController amountController;
  final Function(double, bool) updateBalance;

  AddFundsWidget({Key? key, required this.amountController, required this.updateBalance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white),
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
            final amount = double.tryParse(amountController.text);
            if (amount != null && amount > 0) {
              updateBalance(amount, true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Montant ajouté : $amount')),
              );
              amountController.clear();
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
