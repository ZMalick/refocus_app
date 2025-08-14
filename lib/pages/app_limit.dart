// ReFocus App
// Limit page for App, user will limit their app of choice
// Zaid Malick

import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:intl/intl.dart';
import 'package:refocus_app/models/app_details.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class AppLimit extends StatefulWidget {
  final AppInfo application;
  final Duration totalScreenTime;
  final Duration goalTime;
  List<AppDetails>? appLimitList;
  AppLimit({
    super.key, 
    required this.application,
    required this.totalScreenTime,
    required this.goalTime,
    this.appLimitList,
    });

  @override
  State<AppLimit> createState() => _AppLimitState();
}

class _AppLimitState extends State<AppLimit> {

  UsageInfo? appUsageInfo;
  int openCount = 0;
  int lastOpenMillis = 0;  // store last open time in millis
  
  Future<void> _loadDataAndUsage() async {
    // Load saved open count and last open time from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    openCount = prefs.getInt('openCount_${widget.application.packageName}') ?? 0;
    lastOpenMillis = prefs.getInt('lastOpenMillis_${widget.application.packageName}') ?? 0;

    // Get current usage info
    await getUsage();
  }

  getUsage() async {
    DateTime endDate = new DateTime.now();
    DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);
    
    // query usage stats
    List<UsageInfo> usageStats = 
      await UsageStats.queryUsageStats(startDate, endDate);

    if(usageStats.isNotEmpty) {
      usageStats.forEach((element) {
        if(element.packageName == widget.application.packageName) {
          setState(() {
            appUsageInfo = element;
          });
        }
      });      
    }

    //print('VALUE INSIDE APP USAGE INFO ${appUsageInfo!.packageName}');

    if (appUsageInfo != null && appUsageInfo!.lastTimeUsed != null) {
      int currentLastUsedMillis = int.parse(appUsageInfo!.lastTimeUsed!);

      // If last used time differs from saved, increment open count & save new data
      if (currentLastUsedMillis != lastOpenMillis) {
        openCount++;
        lastOpenMillis = currentLastUsedMillis;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('openCount_${widget.application.packageName}', openCount);
        await prefs.setInt('lastOpenMillis_${widget.application.packageName}', lastOpenMillis);

        setState(() {}); 
      }
    }

    // query events
    // List<EventUsageInfo> events = 
    //   await UsageStats.queryEvents(startDate, endDate);
    
    // query eventStats API Level 28
    // List<EventInfo> eventStats = 
    //   await UsageStats.queryEventStats(startDate, endDate);
    
    // // query configurations
    // List<ConfigurationInfo> configurations = 
    //   await UsageStats.queryConfiguration(startDate, endDate);
    
    // // query aggregated usage statistics
    // Map<String, UsageInfo> queryAndAggregateUsageStats = 
    //   await UsageStats.queryAndAggregateUsageStats(startDate, endDate);

    // // query network usage statistics
    // List<NetworkInfo> networkInfos = 
    //   await UsageStats.queryNetworkUsageStats(startDate, endDate, networkType: NetworkType.all);
}

final TextEditingController hoursController = TextEditingController();
final TextEditingController minutesController = TextEditingController();
final TextEditingController openLimitController = TextEditingController();

void submitLimits() async {
  int hours = int.tryParse(hoursController.text) ?? 0;
  int minutes = int.tryParse(minutesController.text) ?? 0;
  int openLimit = int.tryParse(openLimitController.text) ?? 0;

  Duration screenTimeLimit = Duration(hours: hours, minutes: minutes);

  List<AppDetails> localList = widget.appLimitList ?? [];

  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('${widget.application.packageName}_screenLimit', screenTimeLimit.inSeconds);
  await prefs.setInt('${widget.application.packageName}_openLimit', openLimit);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Limits saved for ${widget.application.name}")),
  );

  final screenTimeUsed = Duration(milliseconds: int.parse(appUsageInfo?.totalTimeInForeground ?? '0'));

  // Create AppUsageLimit model
  AppDetails appLimitData = AppDetails(
    appName: widget.application.name,
    packageName: widget.application.packageName,
    screenTimeUsed: screenTimeUsed,
    screenTimeGoal: screenTimeLimit,
    opensUsed: openCount,
    openGoal: openLimit,
    appIcon: MemoryImage(widget.application.icon!),
  );

  final index = localList.indexWhere((limit) => limit.packageName == appLimitData.packageName);

  if (index >= 0) {
    localList[index] = appLimitData;
  } else {
    localList.add(appLimitData);
  }

  widget.appLimitList = localList;

  Navigator.pop(context, widget.appLimitList);

}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDataAndUsage();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      title: Text(widget.application.name),
    ),
    backgroundColor: Colors.white,
    body: Padding(
      padding: const EdgeInsets.all(24.0),
      child: appUsageInfo == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildUsageRow("Screen Time", 
                  "${(int.parse(appUsageInfo!.totalTimeInForeground!) / 1000 / 60).toStringAsFixed(2)} minutes"),
                const SizedBox(height: 16),
                _buildUsageRow("Last Opened",
                  DateFormat('dd-MM-yyyy HH:mm:ss').format(
                    DateTime.fromMillisecondsSinceEpoch(
                      int.parse(appUsageInfo!.lastTimeUsed!)
                    )
                  )),
                const SizedBox(height: 16),
                _buildUsageRow("Times Opened", openCount.toString()),
                const SizedBox(height: 40),
                Divider(),
                const SizedBox(height: 20),
                Text(
                  "Set Daily Limits",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: hoursController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Hours"),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: minutesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Minutes"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: openLimitController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Open Limit"),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: submitLimits,
                child: Text("Save Limits"),
                )
              ],
            ),
    ),
  );
}
}

Widget _buildUsageRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        "$label:",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    ],
  );
}