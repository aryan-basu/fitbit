import 'dart:ffi';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'dart:async';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';

class HealthDataPage extends StatefulWidget {
  @override
  _HealthDataPageState createState() => _HealthDataPageState();
}

class _HealthDataPageState extends State<HealthDataPage> {
  List<HealthDataPoint> _healthDataList = [];
  List<HealthDataPoint> _DistanceDataList = [];
  int _getSteps = 0;
  double distance = 0.0;
  double totalActiveEnergyBurned = 0.0;
  double weight = 0.0;

  HealthFactory health = HealthFactory();
  final activityRecognition = FlutterActivityRecognition.instance;

  @override
  void initState() {
    super.initState();
    _fetchHealthData();
  }
  String _getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }
  Future<void> _fetchHealthData() async {
    // Check if permission is granted
    if (await _isPermissionGranted()) {
      // Define the types of health data you want to fetch
      var types = [
        HealthDataType.STEPS,
        HealthDataType.WEIGHT,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.HEIGHT,
        HealthDataType.DISTANCE_DELTA,
        HealthDataType.WORKOUT,
        HealthDataType.HEART_RATE,
         HealthDataType.MOVE_MINUTES,
          HealthDataType.BODY_MASS_INDEX,
      ];

      // Define the start and end dates for the data you want to fetch
      final now = DateTime.now();

      final yesterday = now.subtract(Duration(hours: 1300));

      final midnight = DateTime(now.year, now.month, now.day);

      print('time of midnight is $midnight and day is $now');

           try {
        // Request authorization for health data types
        bool requested = await health.requestAuthorization(types);

        // Fetch steps data for the entire week
        Map<String, int> weeklySteps = {};

        // Iterate over each day of the week
        for (int i = 0; i < 7; i++) {
          DateTime date = midnight.subtract(Duration(days: i));
          int? steps = await health.getTotalStepsInInterval(
              DateTime(date.year, date.month, date.day),
              DateTime(date.year, date.month, date.day, 23, 59, 59));

          // Store steps data for the day in the map
          weeklySteps[_getDayOfWeek(date)] = steps ?? 0;
        }

        // Print the weekly steps data
        print('Weekly Steps: $weeklySteps');
        setState(() {
          _getSteps = weeklySteps[now.weekday.toString()] ?? 0;
        });
      } catch (e) {
        print('Error fetching health data: $e');
      }
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
        int totalMoveMinutes = 0;
        moveMinutesData.forEach((dataPoint) {
          if (dataPoint.value != null) {
            totalMoveMinutes += int.parse(dataPoint.value.toString());
          }
        });

        print('Total move minutes: $totalMoveMinutes');
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
            distance += double.parse(dataPoint.value.toString());
          }
        });

        print('Total distance is $distance');
         
      } catch (e) {
        print('Error fetching health data: $e');
      }

//for fetching calorie data
      try {
        // Fetch health data
        bool requested = await health.requestAuthorization(types);

        List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
          midnight,
          now,
          [
            HealthDataType.ACTIVE_ENERGY_BURNED,
          ],
        );
        _healthDataList.clear();
        setState(() {
          _healthDataList = healthData;
        });

        _healthDataList = HealthFactory.removeDuplicates(_healthDataList);
        _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

        // print the results
        _healthDataList.forEach((dataPoint) {
          // Check if the value is not null before adding
          if (dataPoint.value != null) {
            totalActiveEnergyBurned += double.parse(dataPoint.value.toString());
          }
        });
        // for (var dataPoint in healthData) {
        //   totalActiveEnergyBurned += dataPoint.value!;
        // }

        int? steps = await health.getTotalStepsInInterval(midnight, now);
        print('Total number of steps: $steps');
        print('health is $totalActiveEnergyBurned');

        setState(() {
          _getSteps = steps ?? 0;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _fetchHealthData,
              child: Text('Fetch Data'),
            ),
            SizedBox(height: 20),
            Text('Total Steps: $_getSteps'),
            // Display other health data as needed
          ],
        ),
      ),
    );
  }
}
