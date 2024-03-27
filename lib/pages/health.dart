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
  int _getSteps = 0;

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
      var types = [HealthDataType.STEPS];

      // Define the start and end dates for the data you want to fetch
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      try {
        // Fetch health data
        List<HealthDataPoint> healthData =
            await health.getHealthDataFromTypes(midnight, now, types);

        setState(() {
          _healthDataList = healthData;
        });

        int? steps = await health.getTotalStepsInInterval(midnight, now);
        print('Total number of steps: $steps');

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
