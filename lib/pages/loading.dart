// ReFocus App
// Load all Data such as time for apps, total screen time, and more
// Zaid Malick


import 'package:flutter/material.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:refocus_app/pages/home.dart';
import 'package:refocus_app/Pages/goal.dart';
import 'package:refocus_app/services/screen_time.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:refocus_app/services/app_data.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}


class _LoadingState extends State<Loading> with WidgetsBindingObserver {
  bool _isLoading = false;
  bool _hasCheckedPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndLoadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_hasCheckedPermission) {
      _checkAndLoadData();
      loadAppData();
    }
  }

  Future<void> _checkAndLoadData() async {
    if (_isLoading) return;
    _isLoading = true;

    bool? hasPermission = await UsageStats.checkUsagePermission();
    if (hasPermission == false) {
      // Optional: show a dialog to explain why permission is needed before redirecting
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Permission Required'),
          content: Text('Please grant usage access permission in settings.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

      await UsageStats.grantUsagePermission();

      _isLoading = false;
      return;  // Wait for user to come back and trigger didChangeAppLifecycleState
    }

    _hasCheckedPermission = true;

    ScreenTime screenTime = ScreenTime();
    Duration totalDuration = await screenTime.getTotalScreenTime();

    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('first_launch') ?? true;

    if (isFirstLaunch) {
      await prefs.setBool('first_launch', false);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GoalPage(totalScreenTime: totalDuration),
        ),
      );
    } else {
      int? goalSeconds = prefs.getInt('goal_time_seconds');
      Duration goalTime = Duration(seconds: goalSeconds ?? 7200);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(
            totalScreenTime: totalDuration,
            goalTime: goalTime,
          ),
        ),
      );
    }

    _isLoading = false;
  }

  void loadAppData() async {
    await Provider.of<AppData>(context, listen: false).loadApps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox(height: 20),
            ArcText(
              radius: 65,
              text: 'Re-Focus',
              startAngle: math.pi * 2,
              startAngleAlignment: StartAngleAlignment.center,
              stretchAngle: 2.4,
              placement: Placement.outside,
              direction: Direction.clockwise,
              textStyle: GoogleFonts.bebasNeue(
                fontSize: 45,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SpinKitRotatingCircle(
              color: Colors.blue[900],
              size: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}

