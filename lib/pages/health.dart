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
         HealthDataType.MOVE_MINUTES,
          HealthDataType.BODY_MASS_INDEX,
      ];

      // Define the start and end dates for the data you want to fetch
      final now = DateTime.now();

      final yesterday = now.subtract(Duration(hours: 1300));

      final midnight = DateTime(now.year, now.month, now.day);

      print('time of midnight is $midnight and day is $now');


    
      try {
        bool requested = await health.requestAuthorization(types);
         List<HealthDataPoint> RandomData =
            await health.getHealthDataFromTypes(
          midnight,
          now,
          [
              HealthDataType.BODY_MASS_INDEX,
          ],
        );
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
           print('Total workout $RandomData');
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
