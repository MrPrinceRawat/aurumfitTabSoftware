import 'dart:ui';
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
    var attendance = await getAttendances(ref);

    if (attendance["error"]) {
      print(attendance["message"]);
      return;
    }

    setState(() {
      attendances = attendance["message"]["members"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: GestureDetector(
            onTap: () {
              atten();
            },
            child: ClipRect(
                clipBehavior: Clip.hardEdge,
                child: BackdropFilter(
                    filter: new ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                    child: Container(
                      width: (MediaQuery.of(context).size.width) / 2,
                      height: MediaQuery.of(context).size.height / 4,
                      padding: EdgeInsets.only(top: 10, left: 20, right: 10),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          color: CupertinoColors.white.withOpacity(.5),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Attendances",
                            style: TextStyle(
                                color: CupertinoColors.darkBackgroundGray,
                                fontFamily: "SFPro"),
                          ),
                          Text(
                            "Total: ${attendances.length}",
                            style: TextStyle(
                                color: CupertinoColors.darkBackgroundGray,
                                fontFamily: "SFPro"),
                          ),
                          Container(
                            height:
                                (MediaQuery.of(context).size.height / 4) - 60,
                            padding: EdgeInsets.only(top: 3, right: 10),
                            margin: EdgeInsets.only(top: 10),
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
                                      return Container(
                                        // add a border bottom
                                        decoration: BoxDecoration(
                                            color: CupertinoColors.white
                                                .withOpacity(.5),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        margin: EdgeInsets.only(bottom: 10),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                attendances[index],
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: CupertinoColors
                                                        .darkBackgroundGray,
                                                    fontFamily: "SFPro"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                          ),
                        ],
                      ),
                    ))),
          ),
        ),
      ],
    );
  }
}
