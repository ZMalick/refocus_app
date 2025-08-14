// ReFocus App
// Convert app information into app details such as the name, icon and more
// Zaid Malick

import 'package:flutter/material.dart';

class AppDetails {
  final String appName;
  final String packageName;
  Duration screenTimeUsed;
  final Duration screenTimeGoal;
  final int opensUsed;
  final int openGoal;
  final ImageProvider appIcon;

  AppDetails({
    required this.appName,
    required this.packageName,
    required this.screenTimeUsed,
    required this.screenTimeGoal,
    required this.opensUsed,
    required this.openGoal,
    required this.appIcon,
  });
}