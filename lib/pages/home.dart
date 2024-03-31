import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'dart:async';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

// Define data structure for a bar group
class DataItem {
  final String dayOfWeek;
  final double steps;

  DataItem({required this.dayOfWeek, required this.steps});
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isPlaying = false;
  int Steps = 0;
  int distance = 0;
  int totalActiveEnergyBurned = 0;
  int weight = 0;
  int yesterdaycalorie = 0;
 int moveminutes=0;
  final List<DataItem> _myData = [
    DataItem(dayOfWeek: 'Mon', steps: 5000),
    DataItem(dayOfWeek: 'Tue', steps: 6000),
    DataItem(dayOfWeek: 'Wed', steps: 7000),
    DataItem(dayOfWeek: 'Thu', steps: 8000),
    DataItem(dayOfWeek: 'Fri', steps: 9000),
    DataItem(dayOfWeek: 'Sat', steps: 10000),
    DataItem(dayOfWeek: 'Sun', steps: 11000),
  ];
  HealthFactory health = HealthFactory();
  final activityRecognition = FlutterActivityRecognition.instance;
  @override
  void initState() {
    super.initState();
    _fetchHealthData();
  }

  Future<void> _fetchHealthData() async {
    if (await _isPermissionGranted()) {
      // Define the types of health data you want to fetch
      var types = [
        HealthDataType.STEPS,
        HealthDataType.WEIGHT,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.HEIGHT,
        HealthDataType.DISTANCE_DELTA,
        HealthDataType.WORKOUT,
        HealthDataType.MOVE_MINUTES,
        HealthDataType.BODY_MASS_INDEX,
      ];
      // Define the start and end dates for the data you want to fetch
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      double _getdistance = 0.0;
      double _getcalorie = 0.0;
      double _getyesterdaycalorie = 0.0;
    

try {
        // Request authorization for health data types
        bool requested = await health.requestAuthorization(types);

        // Fetch MOVE_MINUTES data
        List<HealthDataPoint> moveMinutesData =
            await health.getHealthDataFromTypes(
          midnight,
          now,
          [HealthDataType.MOVE_MINUTES],
        );

        // Calculate total move minutes
        // int totalMoveMinutes = 0;
        moveMinutesData.forEach((dataPoint) {
          if (dataPoint.value != null) {
            moveminutes += int.parse(dataPoint.value.toString());
          }
        });

        print('Total move minutes: $moveminutes');
      } catch (e) {
        print('Error fetching health data: $e');
      }
         try {
        bool requested = await health.requestAuthorization(types);

        List<HealthDataPoint> DistanceData =
            await health.getHealthDataFromTypes(
          midnight,
          now,
          [
            HealthDataType.DISTANCE_DELTA,
          ],
        );

        DistanceData.forEach((dataPoint) {
          // Check if the value is not null before adding
          if (dataPoint.value != null) {
             _getdistance += double.parse(dataPoint.value.toString());
          }
        });
      distance = _getdistance.ceil();
        print('Total distance is $distance');
        // print('Total distance is $distance');
      } catch (e) {
        print('Error fetching health data: $e');
      }
      try {
        bool requested = await health.requestAuthorization(types);
        List<HealthDataPoint> calories = await health.getHealthDataFromTypes(
          midnight.subtract(Duration(days: 1)),
          midnight,
          [
            HealthDataType.ACTIVE_ENERGY_BURNED,
          ],
        );
        List<HealthDataPoint> yescalories = await health.getHealthDataFromTypes(
          midnight,
          now,
          [
            HealthDataType.ACTIVE_ENERGY_BURNED,
          ],
        );
        yescalories.forEach((dataPoint) {
          // Check if the value is not null before adding
          if (dataPoint.value != null) {
            _getyesterdaycalorie += double.parse(dataPoint.value.toString());
          }
        });

        calories.forEach((dataPoint) {
          // Check if the value is not null before adding
          if (dataPoint.value != null) {
            _getcalorie += double.parse(dataPoint.value.toString());
          }
        });
        totalActiveEnergyBurned = _getcalorie.ceil();
        yesterdaycalorie = _getyesterdaycalorie.ceil();
   
        int? _getsteps = await health.getTotalStepsInInterval(midnight, now);
        setState(() {
          Steps = _getsteps ?? 0;
        });
        List<HealthDataPoint> DistanceData =
            await health.getHealthDataFromTypes(
          midnight,
          now,
          [
            HealthDataType.DISTANCE_DELTA,
          ],
        );
        print("distance is $DistanceData");
        DistanceData.forEach((dataPoint) {
          // Check if the value is not null before adding
          if (dataPoint.value != null) {
            _getdistance += double.parse(dataPoint.value.toString());
          }
        });
        // distance = _getdistance.ceil();
        // print('Total distance is $distance');
        print('Total calorie $totalActiveEnergyBurned');
        print('Total steps $Steps');
      } catch (e) {
        print('Error fetching health data: $e');
      }
    } else {
      print('Permission not granted');
    }
  }

  Future<bool> _isPermissionGranted() async {
    // Check if the user has granted permission
    PermissionRequestResult reqResult =
        await activityRecognition.checkPermission();

    if (reqResult == PermissionRequestResult.GRANTED) {
      return true;
    } else {
      // Request permission if not granted
      reqResult = await activityRecognition.requestPermission();
      return reqResult == PermissionRequestResult.GRANTED;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildUI(),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.pinkAccent,
              onPressed: () {
                setState(() {
                  isPlaying = !isPlaying;
                });
                // Add onPressed action for the play button
              },
              child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUI() {
    return SizedBox(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.04,
              ),
              _ProfileHeader(),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.02,
              ),
              _Steps(),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.05,
              ),
              _dailydata(),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.02,
              ),
              _graphdata(),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.02,
              ),
              _streakdata(),
            ]));
  }

  Widget _ProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(
        5.0,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.account_circle_sharp,
                  size: 38, // Adjust the size of the icon
                  color: Colors.grey[900], // Set the color of the icon
                  semanticLabel:
                      'Account', // Add a semantic label for accessibility
                ), // Add the icon here
                onPressed: () {
                  // Handle icon tap
                },
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.grey[900],
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Text(
                    "Time   02:47:12",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _Steps() {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Steps",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                "$Steps",
                style: const TextStyle(
                  fontSize: 55,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.0,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _dailydata() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: Colors.pinkAccent,
        width: MediaQuery.sizeOf(context).width *
            0.90, // Adjust the width as needed
        height: MediaQuery.sizeOf(context).height * 0.20,
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "You walked $moveminutes min",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2.0),
                )
              ],
            ),
            Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Text(
                          "Distance",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Calories",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Points",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text(
                            "$distance m",
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text(
                            "$totalActiveEnergyBurned",
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(
                            "987",
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _graphdata() {
    // Calculate the maximum steps
    double maxSteps = _myData.map((item) => item.steps).reduce(max);
    // Add an additional 3k to the maximum steps
    maxSteps += 3000;

    // Define a function to generate bar data
    List<BarChartGroupData> generateBarData() {
      List<BarChartGroupData> data = [];
      // Add invisible bar for whitespace at the beginning
      data.add(
        BarChartGroupData(
          x: -1,
          barRods: [
            BarChartRodData(
              y: 0,
              width: 15,
              colors: [Colors.transparent],
            ),
          ],
        ),
      );
      for (var i = 0; i < _myData.length; i++) {
        data.add(
          BarChartGroupData(
            x: i, // Use the index as x-value
            barRods: [
              BarChartRodData(
                y: _myData[i].steps, // Steps for the day
                width: 15,
                colors: [Colors.pinkAccent],
              ),
            ],
          ),
        );
      }
      // Add extra white space to the right of the last bar
      data.add(
        BarChartGroupData(
          x: _myData.length + 1,
          barRods: [
            BarChartRodData(
              y: 0, // Invisible bar
              width: 15,
              colors: [Colors.transparent], // Transparent color
            ),
          ],
        ),
      );
      return data;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: Colors.white,
        width: MediaQuery.sizeOf(context).width *
            0.90, // Adjust the width as needed
        height: MediaQuery.sizeOf(context).height * 0.27,
        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Week's Activity",
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.bar_chart_outlined,
                        size: 38, // Adjust the size of the icon
                        color: Colors.pinkAccent, // Set the color of the icon
                        semanticLabel:
                            'Account', // Add a semantic label for accessibility
                      ),
                      onPressed: () {
                        // Handle icon tap
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 0.1), // Add space between the two rows
            Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: SizedBox(
                      height: 140, // Set a specific height for the chart
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
                          barGroups: generateBarData(),
                          titlesData: FlTitlesData(
                            bottomTitles: SideTitles(
                              showTitles: true,
                              getTextStyles: (value) => const TextStyle(
                                color: Colors.black,
                                fontSize:
                                    12, // Reduced font size for day labels
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
                                if (value >= 0 && value < _myData.length) {
                                  return weekdays[value.toInt()];
                                } else {
                                  return ''; // No label for the extra white space
                                }
                              },
                            ),
                            leftTitles: SideTitles(
                              showTitles: true,
                              getTextStyles: (value) => const TextStyle(
                                color: Colors.black,
                                fontSize:
                                    12, // Reduced font size for step labels
                              ),
                              margin: 10,
                              interval: 3000, // Set interval to 3000 (3k)
                              reservedSize:
                                  40, // Adjust reserved size to fit labels
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
                // Add more widgets if needed
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _streakdata() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: Colors.grey[900],
        width: MediaQuery.sizeOf(context).width *
            0.90, // Adjust the width as needed
        height: MediaQuery.sizeOf(context).height * 0.19,
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Yesterday's Calories",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2.0),
                ),
                Text(
                  "$yesterdaycalorie",
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0),
                ),
              ],
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Streak",
                    style: TextStyle(
                      fontSize: 16, // Set font size for the first row
                      fontWeight:
                          FontWeight.normal, // Optional: Set font weight
                      // Add any other style properties as needed
                    ),
                  ),
                  Text(
                    "24 🔥",
                    style: TextStyle(
                      fontSize: 20, // Set font size for the second row
                      fontWeight: FontWeight.bold, // Optional: Set font weight
                      // Add any other style properties as needed
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
