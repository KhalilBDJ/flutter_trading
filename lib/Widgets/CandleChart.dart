import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../classes/CandleData.dart';

class CandleChart extends StatefulWidget {
  final Map<String, String> symbolToName;

  const CandleChart({
    Key? key,
    required this.symbolToName,
  }) : super(key: key);

  @override
  _CandleChartState createState() => _CandleChartState();
}

class _CandleChartState extends State<CandleChart> {
  String selectedPeriod = '1 Jour';
  String selectedSymbol = 'AI.PA';
  List<CandleData> candleData = [];

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    final prefs = await SharedPreferences.getInstance();
    final allData = prefs.getString('allTimeSeriesData');
    if (allData != null) {
      final dataTest = json.decode(allData);
      final data = dataTest[selectedSymbol];
      final endDate = DateTime.now();
      DateTime startDate = endDate;

      switch (selectedPeriod) {
        case '1 Jour':
          startDate = endDate.subtract(const Duration(days: 2));
          break;
        case '1 Semaine':
          startDate = endDate.subtract(const Duration(days: 8));
          break;
        case '1 Mois':
          startDate = DateTime(endDate.year, endDate.month - 1, endDate.day);
          break;
        case '3 Mois':
          startDate = DateTime(endDate.year, endDate.month - 3, endDate.day);
          break;
        case '6 Mois':
          startDate = DateTime(endDate.year, endDate.month - 6, endDate.day);
          break;
        case '1 An':
          startDate = DateTime(endDate.year - 1, endDate.month, endDate.day);
          break;
        case '3 Ans':
          startDate = DateTime(endDate.year - 3, endDate.month, endDate.day);
          break;
      }

      List<CandleData> chartData = [];
      data.forEach((dateString, value) {
        final date = DateTime.parse(dateString);
        if (date.isAfter(startDate) && date.isBefore(endDate)) {
          final open = double.parse(value['1. open']);
          final high = double.parse(value['2. high']);
          final low = double.parse(value['3. low']);
          final close = double.parse(value['4. close']);
          chartData.add(CandleData(date, open, high, low, close));
        }
      });

      setState(() {
        candleData = chartData;
      });
    }
  }

  Widget _buildPeriodSelector() {
    return DropdownButton<String>(
      value: selectedPeriod,
      items: <String>[
        '1 Jour',
        '1 Semaine',
        '1 Mois',
        '3 Mois',
        '6 Mois',
        '1 An',
        '3 Ans',
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedPeriod = newValue;
          });
          _loadChartData();
        }
      },
      dropdownColor: Colors.black,
    );
  }

  Widget _buildSymbolSelector() {
    return DropdownButton<String>(
      value: selectedSymbol,
      items: widget.symbolToName.keys
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(widget.symbolToName[value] ?? value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedSymbol = newValue;
          });
          _loadChartData();
        }
      },
      dropdownColor: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPeriodSelector(),
              _buildSymbolSelector(),
            ],
          ),
        ),
        Expanded(
          child: SfCartesianChart(
            series: <CandleSeries>[
              CandleSeries<CandleData, DateTime>(
                dataSource: candleData,
                xValueMapper: (CandleData data, _) => data.date,
                lowValueMapper: (CandleData data, _) => data.low,
                highValueMapper: (CandleData data, _) => data.high,
                openValueMapper: (CandleData data, _) => data.open,
                closeValueMapper: (CandleData data, _) => data.close,
                borderWidth: 2,
              ),
            ],
            primaryXAxis: DateTimeAxis(
              edgeLabelPlacement: EdgeLabelPlacement.shift,
              intervalType: DateTimeIntervalType.auto,
              majorGridLines: const MajorGridLines(width: 0),
              labelStyle: const TextStyle(color: Colors.white),
            ),
            primaryYAxis: NumericAxis(
              numberFormat: NumberFormat.simpleCurrency(decimalDigits: 2),
              labelStyle: const TextStyle(color: Colors.white),
            ),
            trackballBehavior: TrackballBehavior(
              enable: true,
              activationMode: ActivationMode.singleTap,
              lineType: TrackballLineType.vertical,
              tooltipSettings: const InteractiveTooltip(
                enable: true,
                textStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
