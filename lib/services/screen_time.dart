// Refocus App 
// Obtain Screen Time for the entire phone
// Zaid Malick

import 'package:usage_stats/usage_stats.dart';

class ScreenTime
{
   
  Future<Duration> getTotalScreenTime() async 
  {
    int totalScreenTime = 0; 
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    // Get total Screen Time
    List<UsageInfo> usageStats = 
      await UsageStats.queryUsageStats(startOfDay, now);

    for (UsageInfo info in usageStats){
      int? time = int.tryParse(info.totalTimeInForeground ?? '0') ?? 0;
      totalScreenTime += time;
    }

    Duration totalDuration = Duration(milliseconds: totalScreenTime);

    return totalDuration;
  }

}
