// ReFocus App
// Show the Intro Page and obtain the Goal for the user
// Zaid Malick


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:refocus_app/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalPage extends StatefulWidget {
  final Duration totalScreenTime;
  const GoalPage({super.key, required this.totalScreenTime});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  List<String> messages = [
    "Hello, welcome to Re-Focus.",
    "Here we help you reduce screen time.",
    "Gain back control, one minute at a time.",
  ];

  int currentMessageIndex = 0;
  bool showGoalInput = false;
  Timer? messageTimer;

  final TextEditingController hoursController = TextEditingController();
  final TextEditingController minutesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    startMessageSequence();
  }

  void startMessageSequence() {
    messageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        currentMessageIndex++;
      });

      if (currentMessageIndex >= messages.length) {
        messageTimer?.cancel();
        setState(() {
          showGoalInput = true;
        });
      }
    });
  }

  void submitGoal() async {
    int hours = int.tryParse(hoursController.text) ?? 0;
    int minutes = int.tryParse(minutesController.text) ?? 0;
    Duration goal = Duration(hours: hours, minutes: minutes);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('goal_time_seconds', goal.inSeconds);

    await prefs.setBool('firstLaunch', false);

    Navigator.pushReplacement(
     context,
      MaterialPageRoute(
        builder: (context) => Home(
          totalScreenTime: widget.totalScreenTime,
          goalTime: goal,
      ),
    ),
  );
}

  @override
  void dispose() {
    messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? message = currentMessageIndex < messages.length
        ? messages[currentMessageIndex]
        : null;
   
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (message != null) ...[
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22),
                ),
              ],
              if (showGoalInput) ...[
                const SizedBox(height: 40),
                const Text(
                  "Set your daily screen time goal",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: hoursController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Hours"),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: minutesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Minutes"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: submitGoal,
                  child: const Text("Continue"),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
