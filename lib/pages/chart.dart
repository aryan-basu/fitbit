import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

// Define data structure for a bar group
class DataItem {
  final String dayOfWeek;
  final double steps;

  DataItem({required this.dayOfWeek, required this.steps});
}

class Chart extends StatelessWidget {
  Chart({Key? key}) : super(key: key);

  // Generate dummy data to feed the chart
  final List<DataItem> _myData = [
    DataItem(dayOfWeek: 'Mon', steps: 5000),
    DataItem(dayOfWeek: 'Tue', steps: 6000),
    DataItem(dayOfWeek: 'Wed', steps: 7000),
    DataItem(dayOfWeek: 'Thu', steps: 8000),
    DataItem(dayOfWeek: 'Fri', steps: 9000),
    DataItem(dayOfWeek: 'Sat', steps: 10000),
    DataItem(dayOfWeek: 'Sun', steps: 11000),
  ];

  @override
  Widget build(BuildContext context) {
    // Calculate the maximum steps
    double maxSteps = _myData.map((item) => item.steps).reduce(max);
    // Add an additional 3k to the maximum steps
    maxSteps += 3000;

    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.all(10), // Reduced padding for a smaller graph
        child: Container(
          color: Colors.white,
          child: SizedBox(
            height: 250, // Set a specific height for the chart
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(
                  border: const Border(
                    top: BorderSide.none,
                    right: BorderSide.none,
                    left: BorderSide(width: 1),
                    bottom: BorderSide(width: 1),
                  ),
                ),
                maxY: maxSteps, // Set the maximum value for y-axis
                groupsSpace: 10,
                barGroups: _myData
                    .asMap()
                    .entries
                    .map(
                      (entry) => BarChartGroupData(
                        x: entry.key, // Use the index as x-value
                        barRods: [
                          BarChartRodData(
                            y: entry.value.steps, // Steps for the day
                            width: 15,
                            colors: [Colors.amber],
                          ),
                        ],
                      ),
                    )
                    .toList(),
                titlesData: FlTitlesData(
                  bottomTitles: SideTitles(
                    showTitles: true,
                    getTextStyles: (value) => const TextStyle(
                      color: Colors.black,
                      fontSize: 12, // Reduced font size for day labels
                    ),
                    margin: 10,
                    getTitles: (double value) {
                      final weekdays = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun'
                      ];
                      return weekdays[value.toInt()];
                    },
                  ),
                  leftTitles: SideTitles(
                    showTitles: true,
                    getTextStyles: (value) => const TextStyle(
                      color: Colors.black,
                      fontSize: 12, // Reduced font size for step labels
                    ),
                    margin: 10,
                    interval: 3000, // Set interval to 3000 (3k)
                    reservedSize: 40, // Adjust reserved size to fit labels
                    getTitles: (double value) {
                      return '${(value ~/ 1000).toInt()}k'; // Divide by 1000 to convert to k
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
