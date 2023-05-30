import 'package:aurumfit/domians/usermanagement/serverRelated.dart';
import 'package:aurumfit/pages/search/showInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class attendanceDetails extends ConsumerStatefulWidget {
  const attendanceDetails({Key? key, required this.Data}) : super(key: key);

  final Data;

  @override
  ConsumerState<attendanceDetails> createState() => _attendanceDetailsState();
}

class _attendanceDetailsState extends ConsumerState<attendanceDetails> {
  // Todays date as default date
  DateTime selectedDate = DateTime.now();
  List<DateTime> dates = [];
  ScrollController _scrollController = ScrollController();
  double widthfactor = 0;
  bool _isloading = false;
  List attendance = [];

  @override
  void initState() {
    super.initState();
    // append all the dates of this month
    for (var i = 1; i <= 31; i++) {
      dates.add(DateTime(DateTime.now().year, DateTime.now().month, i));
    }

    setState(() {
      attendance = widget.Data;
    });

    // set width factor

    Future.delayed(Duration(milliseconds: 200), () {
      _scrollToCurrentDate();
    });
  }

  atten(date) async {
    setState(() {
      this.attendance = [];
      _isloading = true;
    });
    var attendance = await getAttendances(
        ref, DateFormat("yyyy-MM-dd").format(date).toString());

    if (attendance["error"]) {
      print(attendance["message"]);
      setState(() {
        this.attendance = [];
        _isloading = false;
      });
      return;
    }

    setState(() {
      this.attendance = attendance["message"]["users"];
      _isloading = false;
    });
  }

  _scrollToCurrentDate() async {
    _scrollController.animateTo(
      (50 + (MediaQuery.of(context).size.width.toInt() - 350) / 12) *
          (DateTime.now().day + 2),
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  // Function to pick date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2031),
    );
    if (pickedDate != null && pickedDate != selectedDate)
      setState(() {
        selectedDate = pickedDate;
      });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Attendance Details"),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 20,
              ),
              Text(
                "Attendance",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SFPro'),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 50,
                child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: dates.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = dates[index];
                          });
                          atten(dates[index]);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  (MediaQuery.of(context).size.width.toInt() -
                                          350) /
                                      12),
                          child: Container(
                            width: 50,
                            decoration: BoxDecoration(
                                color: dates[index].day == selectedDate.day
                                    ? CupertinoColors.activeBlue.darkColor
                                    : Colors.transparent,
                                border: Border.all(
                                    color: dates[index].day == selectedDate.day
                                        ? Colors.transparent
                                        : CupertinoColors
                                            .inactiveGray.darkColor,
                                    width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  dates[index].day.toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'SFPro'),
                                ),
                                Text(
                                  DateFormat('EEE').format(dates[index]),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'SFPro'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              SizedBox(
                height: 20,
              ),
              Divider(
                color: CupertinoColors.inactiveGray.darkColor,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Attendance Details",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SFPro'),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Date: ${DateFormat('dd-MM-yyyy').format(selectedDate)}",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.inactiveGray.darkColor,
                        fontFamily: 'SFPro'),
                  ),
                  GestureDetector(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: Text(
                      "Change Date",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.activeBlue.darkColor,
                          fontFamily: 'SFPro'),
                    ),
                  ),
                ],
              ),
              Text(
                "Total Attendance: ${attendance.length}",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.inactiveGray.darkColor,
                    fontFamily: 'SFPro'),
              ),
              SizedBox(
                height: 10,
              ),
              _isloading
                  ? Center(
                      child: CupertinoActivityIndicator(),
                    )
                  : attendance.length == 0
                      ? Center(
                          child: Text(
                            "No Attendance Found",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.inactiveGray.darkColor,
                                fontFamily: 'SFPro'),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: attendance.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => ShowInfo(
                                              userid: attendance
                                                  .elementAt(index)["user"],
                                            )));
                              },
                              child: Container(
                                // add a border bottom
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: attendance.elementAt(
                                                    index)["payment_status"] ==
                                                "Paid"
                                            ? CupertinoColors.systemGreen
                                                .withOpacity(.8)
                                            : attendance.elementAt(index)[
                                                        "payment_status"] ==
                                                    "Pending"
                                                ? CupertinoColors.systemYellow
                                                    .withOpacity(.8)
                                                : CupertinoColors.systemRed
                                                    .withOpacity(.8),
                                        width: 2),
                                    borderRadius: BorderRadius.circular(15)),
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
                                        attendance.elementAt(index)["user"],
                                        softWrap: true,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: CupertinoColors.white,
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
                                            color: CupertinoColors.inactiveGray,
                                            size: 12,
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            attendance.elementAt(index)["time"],
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: CupertinoColors
                                                    .inactiveGray,
                                                fontFamily: "SFPro"),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          })
            ]),
          ),
        ),
      ),
    );
  }
}
