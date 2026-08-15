import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartSection extends StatelessWidget {
  const ChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Revenue Analytics",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),

                  titlesData: const FlTitlesData(show: false),

                  borderData: FlBorderData(show: false),

                  lineBarsData: [

                    LineChartBarData(
                      isCurved: true,

                      color: Colors.blue,

                      barWidth: 4,

                      spots: const [

                        FlSpot(0, 2),

                        FlSpot(1, 3),

                        FlSpot(2, 5),

                        FlSpot(3, 4),

                        FlSpot(4, 6),

                        FlSpot(5, 7),

                        FlSpot(6, 9),

                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}