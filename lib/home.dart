import 'dart:ui';

import 'package:aurumfit/BLOC/serverRelated.dart';
import 'package:aurumfit/CFD.dart';
import 'package:aurumfit/UI/attendance.dart';
import 'package:aurumfit/dynamicPayment.dart';
import 'package:aurumfit/search.dart';
import 'package:aurumfit/utility.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      backgroundColor: CupertinoColors.white,
      tabBar: CupertinoTabBar(
        backgroundColor: Color(0xCCCCCCCC),
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: ('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: ('Search'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.printer),
            label: ('Utility'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: ('Settings'),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) {
                return CupertinoPageScaffold(
                  child: HomeScreen(),
                );
              },
            );
            break;
          case 1:
            return CupertinoTabView(
              builder: (context) {
                return Search();
              },
            );
            break;
          case 2:
            return CupertinoTabView(
              builder: (context) {
                return Utility();
              },
            );
            break;
          case 3:
            return CupertinoTabView(
              builder: (context) {
                return CFD();
              },
            );
            break;
          default:
            return CupertinoTabView(
              builder: (context) {
                return CupertinoPageScaffold(
                  child: HomeScreen(),
                );
              },
            );
        }
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Color> gradientColors = [
    Color.fromARGB(255, 19, 14, 16),
    Color.fromARGB(255, 70, 59, 66),
  ];

  var attendances = [];
  var expired_memberships = [];

  @override
  void initState() {
    super.initState();
    getAtten();
  }

  get_expired_memberships() async {
    var expired_memberships = await getExpiredMemberships();

    if (expired_memberships["error"]) {
      print(expired_memberships["message"]);
      return;
    }

    setState(() {
      expired_memberships = expired_memberships["message"]["members"];
    });
    print(expired_memberships);
  }

  getAtten() async {
    var attendance = await getAttendancesCount();

    if (attendance["error"]) {
      print(attendance["message"]);
      return;
    }

    setState(() {
      attendances = attendance["message"]["attendance"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: Colors.blueGrey[50],
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: new DecorationImage(
              image: new ExactAssetImage('assets/home.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
              child: Column(children: [
            Container(
              margin: EdgeInsets.only(top: 40),
              height: MediaQuery.of(context).size.height / 4,
              child: ClipRect(
                clipBehavior: Clip.hardEdge,
                child: BackdropFilter(
                  filter: new ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 20,
                    height: MediaQuery.of(context).size.height / 4,
                    padding: EdgeInsets.all(0),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                        color: CupertinoColors.white.withOpacity(.5),
                        borderRadius: BorderRadius.circular(20)),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: false,
                        ),
                        titlesData: FlTitlesData(
                          show: false,
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        minX: 0,
                        minY: 0,
                        maxY: 100,
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              // FlSpot(0, 3),
                              // FlSpot(2.6, 2),
                              // FlSpot(4.9, 5),
                              // FlSpot(6.8, 3.1),
                              // FlSpot(8, 4),
                              // FlSpot(9.5, 3),
                              // FlSpot(11, 4),
                              // loop through the attendances and add the data
                              for (var i = 0; i < attendances.length; i++)
                                FlSpot(i.toDouble(),
                                    attendances[i]["count"].toDouble()),
                            ],
                            isCurved: true,
                            colors: gradientColors,
                            barWidth: 5,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: false,
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              colors: gradientColors
                                  .map((color) => color.withOpacity(0.3))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                get_expired_memberships();
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 4,
                padding: EdgeInsets.only(top: 20),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ClipRect(
                      clipBehavior: Clip.hardEdge,
                      child: BackdropFilter(
                        filter:
                            new ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2,
                          height: MediaQuery.of(context).size.height / 4,
                          decoration: BoxDecoration(
                              color: CupertinoColors.white.withOpacity(.5),
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Expired Membership",
                                  style: TextStyle(
                                      color: CupertinoColors.darkBackgroundGray,
                                      fontFamily: "SFPro"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (() {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => DynamicQrCode()));
                      }),
                      child: ClipRect(
                        child: BackdropFilter(
                          filter:
                              new ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.5,
                            height: MediaQuery.of(context).size.height / 4,
                            decoration: BoxDecoration(
                                color: CupertinoColors.white.withOpacity(.5),
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Make Qr Code",
                                        style: TextStyle(
                                            color: CupertinoColors
                                                .darkBackgroundGray,
                                            fontFamily: "SFPro"),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    CupertinoIcons.qrcode_viewfinder,
                                    color: Color.fromARGB(190, 255, 255, 255),
                                    size: 130,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            AttendanceWidget()
          ])),
        ));
  }
}

class ChartTextStyle {}

class attendanceData {
  attendanceData(this.x, this.y);
  final String x;
  final double y;
}
