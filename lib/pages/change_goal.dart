import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetGoalPage extends StatefulWidget {
  final Duration? currentGoal;
  const SetGoalPage({super.key, this.currentGoal});

  @override
  State<SetGoalPage> createState() => _SetGoalPageState();
}

class _SetGoalPageState extends State<SetGoalPage> {
  final TextEditingController hoursController = TextEditingController();
  final TextEditingController minutesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.currentGoal != null) {
      hoursController.text = widget.currentGoal!.inHours.toString();
      minutesController.text = 
        (widget.currentGoal!.inMinutes % 60).toString();
    }
  }

  void submitGoal() async {
    int hours = int.tryParse(hoursController.text) ?? 0;
    int minutes = int.tryParse(minutesController.text) ?? 0;
    Duration goal = Duration(hours: hours, minutes: minutes);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('goal_time_seconds', goal.inSeconds);

    Navigator.pop(context, goal); // Return the new goal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Goal")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Set your daily screen time goal"),
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
              child: const Text("Save Goal"),
            )
          ],
        ),
      ),
    );
  }
}
