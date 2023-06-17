import 'package:aurumfit/domians/usermanagement/user_management.dart';
import 'package:aurumfit/providers/auth/authprovider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

class AttendanceMonth extends ConsumerStatefulWidget {
  const AttendanceMonth(
      {Key? key, required this.month, required this.year, required this.userid})
      : super(key: key);

  final int month;
  final int year;
  final String userid;

  @override
  ConsumerState<AttendanceMonth> createState() => Attendance_MonthState();
}

class Attendance_MonthState extends ConsumerState<AttendanceMonth> {
  List dates = [];

  var month;
  var year;

  List attendance = [];

  @override
  void initState() {
    super.initState();
    // Get the dates from the data

    setState(() {
      month = widget.month;
      year = widget.year;
    });

    int currentMonthDaysCount = DateTime(year, month + 1, 0).day;

    // Pad with previous month's days until the first day of the week

    for (var i = 0; i < DateTime(year, month, 1).weekday - 1; i++) {
      dates.add(0);
    }

    for (var i = 0; i < currentMonthDaysCount; i++) {
      dates.add(DateTime(year, month, i + 1));
    }
    // Pad with next month's days until the last day of the week
    for (var i = 0;
        i < 7 - DateTime(year, month, currentMonthDaysCount).weekday;
        i++) {
      dates.add(0);
    }

    UserManagement(
            userid: widget.userid,
            token: ref.read(AuthTokenProvider.notifier).state)
        .getUserAttendance(month, year)
        .then((value) {
      setState(() {
        attendance = value;
      });
    });
  }

  Color selectColor(i) {
    if (dates[i] == 0) {
      return CupertinoColors.darkBackgroundGray;
    } else if (DateFormat("y-MM-dd").format(dates[i]) ==
        DateFormat("y-MM-dd").format(DateTime.now())) {
      return CupertinoColors.systemBlue;
    } else if (attendance.contains(DateFormat("y-MM-dd").format(dates[i]))) {
      return CupertinoColors.systemGreen;
    } else {
      return CupertinoColors.inactiveGray.darkColor;
    }
    return CupertinoColors.darkBackgroundGray;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('yMMMM').format(DateTime(year, month)),
              style: TextStyle(
                  color: CupertinoColors.inactiveGray,
                  fontSize: 16,
                  fontFamily: 'SFPro',
                  fontWeight: FontWeight.w500)),
          SizedBox(
              height: 140,
              child: GridView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: 1),
                  children: [
                    for (var i = 0; i < dates.length; i++)
                      Container(
                        decoration: BoxDecoration(
                            color: selectColor(i),
                            borderRadius: BorderRadius.circular(3)),
                      )
                  ])),
        ],
      ),
    );
  }
}
