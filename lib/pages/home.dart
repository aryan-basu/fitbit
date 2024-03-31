import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'dart:async';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';

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

      try {
        bool requested = await health.requestAuthorization(types);
        List<HealthDataPoint> calories = await health.getHealthDataFromTypes(
          midnight,
          now,
          [
            HealthDataType.ACTIVE_ENERGY_BURNED,
          ],
        );
        calories.forEach((dataPoint) {
          // Check if the value is not null before adding
          if (dataPoint.value != null) {
            _getcalorie += double.parse(dataPoint.value.toString());
          }
        });
        totalActiveEnergyBurned = _getcalorie.ceil();
        List<HealthDataPoint> RandomData = await health.getHealthDataFromTypes(
          midnight,
          now,
          [
            HealthDataType.HEART_RATE,
          ],
        );
        print("data is$RandomData");
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

        DistanceData.forEach((dataPoint) {
          // Check if the value is not null before adding
          if (dataPoint.value != null) {
            _getdistance += double.parse(dataPoint.value.toString());
          }
        });
        distance = _getdistance.ceil();
        print('Total distance is $distance');
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
                height: MediaQuery.sizeOf(context).height * 0.05,
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
                  "You walked 72 min",
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: Colors.white,
        width: MediaQuery.sizeOf(context).width *
            0.90, // Adjust the width as needed
        height: MediaQuery.sizeOf(context).height * 0.22,
        padding: EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align children vertically centered
          children: [
            Column(
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
                  ), // Add the icon here
                  onPressed: () {
                    // Handle icon tap
                  },
                ),
              ],
            )
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
                  "400",
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
