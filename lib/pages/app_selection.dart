// ReFocus App
// Show a list of the apps that the user has on their phone and allow them to select one to limit
// Zaid Malick

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refocus_app/services/app_data.dart';
import 'package:refocus_app/pages/app_limit.dart';
import 'package:refocus_app/models/app_details.dart';

class SelectApp extends StatelessWidget {
  final Duration totalScreenTime;
  final Duration goalTime;
  final List<AppDetails>? appLimitList;

  const SelectApp({
    super.key,
    required this.totalScreenTime,
    required this.goalTime,
    this.appLimitList,
  });

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppData>(context);
    final List<AppDetails> _appLimitList = appLimitList ?? [];

    // Load apps if not loaded yet
    if (appProvider.apps.isEmpty && !appProvider.isLoading) {
      appProvider.loadApps();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select App"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _appLimitList);
          },
        ),
      ),
      body: appProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: appProvider.apps.length,
              itemBuilder: (context, index) {
                final app = appProvider.apps[index];
                return ListTile(
                  leading: app.icon != null
                      ? Image.memory(app.icon!, width: 40, height: 40)
                      : const Icon(Icons.apps),
                  title: Text(app.name, overflow: TextOverflow.ellipsis),
                  subtitle: Text(app.packageName, overflow: TextOverflow.ellipsis),
                  onTap: () async {
                    final updatedList = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AppLimit(
                          totalScreenTime: totalScreenTime,
                          goalTime: goalTime,
                          application: app,
                          appLimitList: appLimitList,
                        ),
                      ),
                    );
                    if (updatedList != null) {
                     // _appLimitList.clear();
                      _appLimitList.addAll(updatedList);
                      print(_appLimitList);
                    }
                  },
                );
              },
            ),
    );
  }
}
