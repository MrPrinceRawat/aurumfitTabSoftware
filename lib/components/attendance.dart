import 'dart:ui';
import 'package:aurumfit/components/attendanceDetailed.dart';
import 'package:aurumfit/pages/search/showInfo.dart';
import 'package:flutter/material.dart';
import 'package:aurumfit/domians/usermanagement/serverRelated.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendanceWidget extends ConsumerStatefulWidget {
  const AttendanceWidget({Key? key}) : super(key: key);

  @override
  _AttendanceWidgetState createState() => _AttendanceWidgetState();
}

class _AttendanceWidgetState extends ConsumerState<AttendanceWidget> {
  var attendances = [];

  @override
  void initState() {
    super.initState();
    atten();
  }

  atten() async {
    var attendance = await getAttendances(ref, "");

    if (attendance["error"]) {
      print(attendance["message"]);
      return;
    }

    setState(() {
      attendances = attendance["message"]["data"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              atten();
            },
            child: ClipRRect(
                clipBehavior: Clip.antiAlias,
                child: BackdropFilter(
                    filter: new ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                    child: Container(
                      width: (MediaQuery.of(context).size.width) / 2,
                      height: MediaQuery.of(context).size.height / 1.7,
                      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                      decoration: BoxDecoration(
                          color: CupertinoColors.white.withOpacity(.5),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Attendances",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: CupertinoColors.darkBackgroundGray,
                                  fontFamily: "SFPro",
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              attendanceDetails(
                                                Data: attendances,
                                              )));
                                },
                                child: Text(
                                  "View All",
                                  style: TextStyle(
                                      color: CupertinoColors.link,
                                      fontSize: 15,
                                      fontFamily: "SFPro"),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Total: ${attendances.length}",
                            style: TextStyle(
                                color: CupertinoColors.darkBackgroundGray,
                                fontFamily: "SFPro"),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height:
                                (MediaQuery.of(context).size.height / 1.7) - 84,
                            child: attendances.length == 0
                                ? Center(
                                    child: Text(
                                    "No Attendances",
                                    style: TextStyle(
                                        color:
                                            CupertinoColors.darkBackgroundGray,
                                        fontFamily: "SFPro"),
                                  ))
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: attendances.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (context) =>
                                                      ShowInfo(
                                                        userid: attendances
                                                            .elementAt(
                                                                index)["user"],
                                                      )));
                                        },
                                        child: Container(
                                          // add a border bottom
                                          decoration: BoxDecoration(
                                              color: CupertinoColors.white
                                                  .withOpacity(.5),
                                              border: Border.all(
                                                  color: attendances.elementAt(
                                                                  index)[
                                                              "payment_status"] ==
                                                          "Paid"
                                                      ? CupertinoColors.systemGreen
                                                          .withOpacity(.8)
                                                      : attendances.elementAt(
                                                                      index)[
                                                                  "payment_status"] ==
                                                              "Pending"
                                                          ? CupertinoColors
                                                              .systemYellow
                                                              .withOpacity(.8)
                                                          : CupertinoColors
                                                              .systemRed
                                                              .withOpacity(.8),
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          margin: EdgeInsets.only(bottom: 10),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 12.0,
                                                bottom: 12.0,
                                                left: 10.0,
                                                right: 10.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  attendances
                                                      .elementAt(index)["user"],
                                                  softWrap: true,
                                                  overflow: TextOverflow.fade,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: CupertinoColors
                                                        .darkBackgroundGray,
                                                    fontFamily: "SFPro",
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      CupertinoIcons.clock,
                                                      color: CupertinoColors
                                                          .darkBackgroundGray,
                                                      size: 12,
                                                    ),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    Text(
                                                      attendances.elementAt(
                                                          index)["time"],
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: CupertinoColors
                                                              .darkBackgroundGray,
                                                          fontFamily: "SFPro"),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                          ),
                        ],
                      ),
                    ))),
          ),
        ],
      ),
    );
  }
}
