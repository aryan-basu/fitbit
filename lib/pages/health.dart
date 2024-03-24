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
  int _distance = 0;

  HealthFactory Health = HealthFactory();
  final activityRecognition = FlutterActivityRecognition.instance;
  @override
  void initState() {
    super.initState();
    _fetchHealthData();
  }

  Future<void> _fetchHealthData() async {
    var types = [
      HealthDataType.STEPS,
    ];
    // Define the start and end dates for the data you want to fetch
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    var permissions = [
      HealthDataAccess.READ,
    ];

    bool requested =
        await Health.requestAuthorization(types, permissions: permissions);

    if (requested) {
      if (isPermissionGrants()==true) {
        try {
          // Define the types of health data you want to fetch
          List<HealthDataType> types = [
            HealthDataType.STEPS,
            HealthDataType.BLOOD_GLUCOSE,
          ];
          int? steps;

          // Fetch health data
          List<HealthDataPoint> healthData =
              await Health.getHealthDataFromTypes(midnight, now, types);

          setState(() {
            _healthDataList = healthData;
          });
          steps = await Health.getTotalStepsInInterval(midnight, now);
          print('Total number of steps: $steps');

          setState(() {
            _getSteps = (steps == null) ? 0 : steps;
          });
          // setState(() {
          //   _healthDataList = healthData;
          // });
        } catch (e) {
          print('Error fetching health data: $e');
        }
      } else {
        print("Authorization not granted - error in authorization");
      }
    }
  }

  Future<bool> isPermissionGrants() async {
    // Check if the user has granted permission. If not, request permission.
    PermissionRequestResult reqResult;
    reqResult = await activityRecognition.checkPermission();
    if (reqResult == PermissionRequestResult.PERMANENTLY_DENIED) {
      print('Permission is permanently denied.');
      return false;
    } else if (reqResult == PermissionRequestResult.DENIED) {
      reqResult = await activityRecognition.requestPermission();
      if (reqResult != PermissionRequestResult.GRANTED) {
        print('Permission is denied.');
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      body: Center(
        child: Text(
          'Total step    {$_getSteps}',
          style: const TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}
