import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'classes/stock.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? soldeInitial;
  String firstName = "Magrows";
  String lastName = "Beat";
  int touchedIndex = -1;
  List<Stock> stocks = [
    Stock(name: "Tesla", category: "Automobile", quantity: 5),
    Stock(name: "McDonald's", category: "Restauration", quantity: 3),
    // Ajoutez d'autres stocks ici
  ];

  @override
  Widget build(BuildContext context) {
    Map<String, int> categoriesCount = _getCategoriesCount();

    return Scaffold(
      appBar: AppBar(
        title: Text(' Portefeuille'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CreditCardWidget(
              cardNumber: "9485 4848 4938 8888",
              expiryDate: "12/25",
              cardHolderName: '$firstName $lastName',
              cvvCode: "123",
              showBackView: false, onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
            ),
            SizedBox(height: 20),
            Text('Solde actuel: $soldeInitial'),
            SizedBox(height: 20),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(categoriesCount),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                    touchCallback: (pieTouchResponse) {
                      setState(() {
                        if (pieTouchResponse.touchInput is FlLongPressEndTouchInput ||
                            pieTouchResponse.touchInput is FlPanEndTouchInput) {
                          touchedIndex = -1;
                        } else if (pieTouchResponse.touchInput is FlTouchStart ||
                            pieTouchResponse.touchInput is FlTouchMove) {
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        }
                      });
                    },
                  ),
                ),
                ),
              ),
            ),
            ..._buildLegend(categoriesCount),
          ],
        ),
      ),
    );
  }

  Map<String, int> _getCategoriesCount() {
    Map<String, int> categoriesCount = {};

    for (var stock in stocks) {
      if (categoriesCount.containsKey(stock.category)) {
        categoriesCount[stock.category] = categoriesCount[stock.category]! + stock.quantity;
      } else {
        categoriesCount[stock.category] = stock.quantity;
      }
    }

    return categoriesCount;
  }

  List<Widget> _buildLegend(Map<String, int> categoriesCount) {
    return categoriesCount.keys.map((category) {
      final color = _getCategoryColor(category);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              color: color,
            ),
            SizedBox(width: 8),
            Text(category),
          ],
        ),
      );
    }).toList();
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, int> categoriesCount) {
    List<PieChartSectionData> sections = [];
    int index = 0;

    categoriesCount.forEach((category, count) {
      final isTouched = index == touchedIndex;
      final double fontSize = isTouched ? 25 : 16;
      final double radius = isTouched ? 60 : 50;
      sections.add(
        PieChartSectionData(
          color: _getCategoryColor(category),
          value: count.toDouble(),
          title: '',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
          ),
        ),
      );
      index++;
    });

    return sections;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Automobile':
        return Colors.red;
      case 'Restauration':
        return Colors.blue;
    // Ajoutez d'autres catégories et couleurs ici
      default:
        return Colors.grey;
    }
  }
}
