// ReFocus App
// App Home Page - Contains the list of limited apps, total screen time, goal and more
// Zaid Malick

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refocus_app/models/app_details.dart';
import 'package:refocus_app/pages/change_goal.dart';
import 'package:refocus_app/services/screen_time.dart';
import 'package:refocus_app/pages/app_selection.dart';
import 'package:refocus_app/widgets/progress_bar.dart';
import 'package:refocus_app/widgets/pie_chart_sample_3.dart';
import 'package:refocus_app/widgets/app_usage_row.dart';
import 'package:provider/provider.dart';
import 'package:refocus_app/services/app_data.dart';

class Home extends StatefulWidget {
  final Duration totalScreenTime;
  Duration goalTime;
  List<AppDetails>? appLimitList;
  Home({
    super.key, 
    required this.totalScreenTime,
    required this.goalTime,
    this.appLimitList,
    });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {

  int touchedIndex = 0;
  String selectedOption = 'Today'; // For Drop Down Menu
  Duration _currentScreenTime = Duration.zero;
  //List<AppUsageLimit> appLimits = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentScreenTime = widget.totalScreenTime;
    _refreshScreenTime();
    
    final appData = Provider.of<AppData>(context, listen: false);
    appData.loadApps().then((_) => appData.convertToAppDetails());

  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshScreenTime();
    }
  }

  void _refreshScreenTime() async {
    final screenTimeService = ScreenTime();
    Duration updatedScreenTime = await screenTimeService.getTotalScreenTime();

    setState(() {
      _currentScreenTime = updatedScreenTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //----------------------App Bar--------------------------
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text('Focus-Guard',),
          titleTextStyle: GoogleFonts.bebasNeue(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2.5,
            ),
        actions: [
          PopupMenuButton(
            onSelected:(String value) async {
              if(value == 'Change Goal')
              {
                final newGoal = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SetGoalPage(currentGoal: widget.goalTime),
                  ),
                );
                if (newGoal != null && newGoal is Duration) {
                  setState(() {
                    widget.goalTime = newGoal; // Update UI instantly
                  });
                }
              }
              setState(() {
                selectedOption = value;
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context){
              return ['Profile', 'Change Goal' ,'Settings'].map((String choice)
              {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            }
          )
        ],
      ),
      //----------------------------------------------------
      //---------------------Top Portion of Body------------
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                ProgressSection(
                  totalScreenTime: _currentScreenTime,
                  goalTime: widget.goalTime,
                ),
                //---------------------------------------------------
                //-------------------Middle Portion of Body----------
                Container(
                  width: 350,
                  padding: EdgeInsets.all(14),
                  margin: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                      ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 70,
                            child: Text(
                              'Apps',
                              style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                                ), 
                              ),
                          ),
                          SizedBox(
                            width: 70,
                            child: Text(
                              'Opens',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                                ), 
                              ),
                          ),
                          SizedBox(
                            width: 110,
                            child: Text(
                              'Time Limit',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                                ), 
                              ),
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                      ),
                      SizedBox(height: 5),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 100,
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          trackVisibility: true,
                          child: ListView(
                            shrinkWrap: true,
                            children: (widget.appLimitList ?? []).map((limit) {
                              return AppUsageRow(
                                appIcon: limit.appIcon,
                                appName: limit.appName,
                                opens: '${limit.opensUsed}/${limit.openGoal}',
                                timeUsed: '${(limit.screenTimeUsed.inMinutes / 60).toStringAsFixed(1)}/${(limit.screenTimeGoal.inMinutes / 60).toStringAsFixed(1)}',
                              );
                            }).toList(),
                                                ),
                        ),
                      ),
                      /*...(widget.appLimitList ?? []).map((limit) {
                      return AppUsageRow(
                        appIcon: limit.appIcon,
                        appName: limit.appName,
                        opens: '${limit.opensUsed}/${limit.openGoal}',
                        timeUsed: '${(limit.screenTimeUsed.inMinutes / 60).toStringAsFixed(1)}/${(limit.screenTimeGoal.inMinutes / 60).toStringAsFixed(1)}',
                        );
                      }).toList(),*/
                    ],
                  )
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final updatedList = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SelectApp(
                        totalScreenTime: widget.totalScreenTime, 
                        goalTime: widget.goalTime,
                        appLimitList: widget.appLimitList,
                      ))
                    );
                    if (updatedList != null) {
                      setState(() {
                      widget.appLimitList = updatedList;
                  });
                }
                  },
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                    ),
                  label: Text(
                    'Add Apps to Limit',
                    style: GoogleFonts.poppins(
                      fontSize:16,
                      color: Colors.white,
                      ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.blue[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  //---------------------------------------------------------
                  SizedBox(height: 20),
                  //---------------------End Portion-------------------------
                  const Divider(thickness: 2, indent: 20, endIndent: 20),
                  SizedBox(height: 10),
                  Text(
                    'Your Most Used Apps',
                     style: GoogleFonts.poppins(
                      fontSize:20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationThickness: 2,    
                      ),
                    ),
                  SizedBox(
                    height: 225,
                    child: AspectRatio(
                      aspectRatio: 1.0, 
                      child: Container(
                        color: Colors.grey[25],
                        margin: const EdgeInsets.all(20.0),
                        child: PieChartSample3(),
                    ),
                  ),
                ), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}

