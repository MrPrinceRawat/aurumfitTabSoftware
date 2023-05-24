import 'package:aurumfit/pages/search/components/month.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class UserAttendance extends StatefulWidget {
  const UserAttendance({Key? key, required this.userid}) : super(key: key);

  final userid;

  @override
  State<UserAttendance> createState() => _UserAttendanceState();
}

class _UserAttendanceState extends State<UserAttendance> {
  List<DateTime> dates = [];
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Get the dates from the data

    int currentMonthDaysCount =
        DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;

    for (var i = 0; i < currentMonthDaysCount; i++) {
      dates.add(DateTime(DateTime.now().year, DateTime.now().month, i + 1));
    }
    scrollToLast();
  }

  scrollToLast() async {
    Future.delayed(Duration(milliseconds: 500), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 160,
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        // Create a grid with thats shows current month as boxes with week days on left and month days on top
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              height: 140,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Mon",
                      style: TextStyle(
                          color: Color(0xffAFAFAF),
                          fontSize: 12,
                          fontFamily: 'SFPro',
                          fontWeight: FontWeight.w500)),
                  Text("Tue",
                      style: TextStyle(
                          color: Color(0xffAFAFAF),
                          fontSize: 12,
                          fontFamily: 'SFPro',
                          fontWeight: FontWeight.w500)),
                  Text("Wed",
                      style: TextStyle(
                          color: Color(0xffAFAFAF),
                          fontSize: 12,
                          fontFamily: 'SFPro',
                          fontWeight: FontWeight.w500)),
                  Text("Thu",
                      style: TextStyle(
                          color: Color(0xffAFAFAF),
                          fontSize: 12,
                          fontFamily: 'SFPro',
                          fontWeight: FontWeight.w500)),
                  Text("Fri",
                      style: TextStyle(
                          color: Color(0xffAFAFAF),
                          fontSize: 12,
                          fontFamily: 'SFPro',
                          fontWeight: FontWeight.w500)),
                  Text("Sat",
                      style: TextStyle(
                          color: Color(0xffAFAFAF),
                          fontSize: 12,
                          fontFamily: 'SFPro',
                          fontWeight: FontWeight.w500)),
                  Text("Sun",
                      style: TextStyle(
                          color: Color(0xffAFAFAF),
                          fontSize: 12,
                          fontFamily: 'SFPro',
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            SizedBox(
              width: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 110,
              height: 160,
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: 6,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return AttendanceMonth(
                      // Calucate the month back from current month
                      month: DateTime(DateTime.now().year,
                              DateTime.now().month - (6 - index) + 1)
                          .month,
                      year: DateTime(DateTime.now().year,
                              DateTime.now().month - (6 - index) + 1)
                          .year,
                      userid: widget.userid,
                    );
                  }),
            )
          ],
        ));
  }
}
