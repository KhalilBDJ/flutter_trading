import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FooterWidget extends StatefulWidget {
  final double balance;
  final int selectedIndex;
  final List<Widget> widgetOptions;
  final Function(int) onItemTapped;

  const FooterWidget({
    Key? key,
    required this.balance,
    required this.selectedIndex,
    required this.widgetOptions,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  _FooterWidgetState createState() => _FooterWidgetState();
}

class _FooterWidgetState extends State<FooterWidget> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text('Tradet : $userName', style: TextStyle(color: Colors.green)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Solde actuel: \$${widget.balance.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: widget.widgetOptions.elementAt(widget.selectedIndex),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
            backgroundColor: widget.selectedIndex == 0 ? Colors.grey : Colors.black,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_outlined),
            label: 'Possessions',
            backgroundColor: widget.selectedIndex == 1 ? Colors.grey : Colors.black,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet),
            label: 'Porte-feuille',
            backgroundColor: widget.selectedIndex == 2 ? Colors.grey : Colors.black,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.show_chart),
            label: 'Bourse',
            backgroundColor: widget.selectedIndex == 3 ? Colors.grey : Colors.black,
          ),
        ],
        currentIndex: widget.selectedIndex,
        selectedItemColor: Colors.green[300],
        unselectedItemColor: Colors.green[700],
        onTap: widget.onItemTapped,
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
