// ReFocus App
// Obtain All of the App information from the phone
// Zaid Malick

import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:refocus_app/models/app_details.dart';
import 'package:usage_stats/usage_stats.dart';

class AppData extends ChangeNotifier {
  List<AppInfo> _apps = [];
  List<AppDetails> appDetails = [];
  bool _isLoading = false;

  List<AppInfo> get apps => _apps;
  bool get isLoading => _isLoading;

  Future<void> loadApps() async {
    _isLoading = true;
    notifyListeners();

    List<AppInfo> installedApps = await InstalledApps.getInstalledApps(false, true);
    _apps = installedApps;

    convertToAppDetails();

    _isLoading = false;
    notifyListeners();
  }

   void convertToAppDetails() async {
      DateTime endDate = DateTime.now();
      DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);

      List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startDate, endDate);

      appDetails = _apps.map((app) {
        final match = usageStats.firstWhere(
          (u) => u.packageName == app.packageName,
          orElse: () => UsageInfo(packageName: app.packageName, totalTimeInForeground: '0'),
        );

        return AppDetails(
          appName: app.name,
          packageName: app.packageName,
          screenTimeUsed: Duration(milliseconds: int.parse(match.totalTimeInForeground!)),
          screenTimeGoal: Duration.zero,
          opensUsed: 0,
          openGoal: 0,
          appIcon: MemoryImage(app.icon!),
        );
      }).toList();

      notifyListeners();
  }

  List<AppDetails> get top5Apps {
    final sorted = [...appDetails];
    sorted.sort((a, b) => b.screenTimeUsed.compareTo(a.screenTimeUsed));
    return sorted.take(5).toList();
  }

}