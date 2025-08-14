// ReFocus App
// App Main File
// Zaid Malick

import 'package:flutter/material.dart';
import 'package:refocus_app/pages/loading.dart';
import 'package:provider/provider.dart';
import 'package:refocus_app/services/app_data.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (_) => AppData(),
    child: const MyApp()
  )
  );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Re-Focus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Loading(),  // Just show Loading screen first
    );
  }
}


