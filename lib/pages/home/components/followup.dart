import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FollowUp_widget extends StatelessWidget {
  const FollowUp_widget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() {
        Navigator.push(context,
            CupertinoPageRoute(builder: (context) => AttendanceFollowUpPage()));
      }),
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 4,
              decoration: BoxDecoration(
                  color: CupertinoColors.white.withOpacity(.5),
                  borderRadius: BorderRadius.circular(20)),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Follow Ups",
                      style: TextStyle(
                          fontFamily: "SFPro",
                          letterSpacing: 1,
                          color: Color.fromARGB(128, 0, 0, 0),
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      CupertinoIcons.arrow_up_right_square_fill,
                      size: 20,
                      color: Color.fromARGB(128, 0, 0, 0),
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }
}

class AttendanceFollowUpPage extends ConsumerStatefulWidget {
  const AttendanceFollowUpPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AttendanceFollowUpPageState();
}

class _AttendanceFollowUpPageState
    extends ConsumerState<AttendanceFollowUpPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          "Attendance Follow Up",
          style: TextStyle(
              fontFamily: "SFPro",
              letterSpacing: 1,
              fontWeight: FontWeight.w500),
        ),
      ),
      child: SafeArea(
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            // child: Column(
            //   children: [
            //     ListView(
            //       scrollDirection: Axis.horizontal,
            //       shrinkWrap: true,
            //       children: [
            //         Text(
            //           "Filter: ",
            //           style: TextStyle(
            //               fontFamily: "SFPro",
            //               letterSpacing: 1,
            //               fontWeight: FontWeight.w500),
            //         ),
            //         SizedBox(
            //           width: 10,
            //         ),
            //         //MultiSelectChipField
            //       ],
            //     )
            //   ],
            // )
            child: Text("Coming Soon",
                style: TextStyle(
                    fontFamily: "SFPro",
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500))),
      ),
    );
  }
}
