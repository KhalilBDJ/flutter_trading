import 'package:flutter/material.dart';

class HomePageWidget extends StatelessWidget {
  final double balance;
  final int selectedIndex;
  final List<Widget> widgetOptions;
  final Function(int) onItemTapped;

  const HomePageWidget({
    Key? key,
    required this.balance,
    required this.selectedIndex,
    required this.widgetOptions,
    required this.onItemTapped,
  }) : super(key: key);

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
              child: widgetOptions.elementAt(selectedIndex),
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
            backgroundColor: selectedIndex == 0 ? Colors.grey : Colors.black,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.show_chart),
            label: 'Bourse',
            backgroundColor: selectedIndex == 1 ? Colors.grey : Colors.black,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'Profil',
            backgroundColor: selectedIndex == 2 ? Colors.grey : Colors.black,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: 'Réglages',
            backgroundColor: selectedIndex == 3 ? Colors.grey : Colors.black,
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.green[300],
        unselectedItemColor: Colors.green[700],
        onTap: onItemTapped,
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
