import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../classes/CandleData.dart';

class CandleChart extends StatelessWidget {
  final List<CandleData> candleData;
  final String selectedPeriod;
  final String selectedSymbol;
  final Map<String, String> symbolToName;
  final Function(String) onPeriodChanged;
  final Function(String) onSymbolChanged;

  const CandleChart({
    Key? key,
    required this.candleData,
    required this.selectedPeriod,
    required this.selectedSymbol,
    required this.symbolToName,
    required this.onPeriodChanged,
    required this.onSymbolChanged,
  }) : super(key: key);

  Widget _buildPeriodSelector() {
    return DropdownButton<String>(
      value: selectedPeriod,
      items: <String>['1D', '1W', '1M', '3M', '6M', '1Y', '3Y']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onPeriodChanged(newValue);
        }
      },
      dropdownColor: Colors.black,
    );
  }

  Widget _buildSymbolSelector() {
    return DropdownButton<String>(
      value: selectedSymbol,
      items: symbolToName.keys
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(symbolToName[value] ?? value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onSymbolChanged(newValue);
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
              labelStyle: TextStyle(color: Colors.white),
            ),
            primaryYAxis: NumericAxis(
              numberFormat: NumberFormat.simpleCurrency(decimalDigits: 2),
              labelStyle: TextStyle(color: Colors.white),
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
