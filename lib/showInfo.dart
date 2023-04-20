import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:aurumfit/BLOC/authHandler.dart';
import 'package:aurumfit/BLOC/serverRelated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aurumfit/dynamicPayment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

class ShowInfo extends StatefulWidget {
  const ShowInfo({Key? key, required this.userid}) : super(key: key);

  final String userid;

  @override
  _ShowInfoState createState() => _ShowInfoState();
}

class _ShowInfoState extends State<ShowInfo> {
  final ScrollController scrollController = ScrollController();
  late Future myFuture;
  var _loading = false;
  var attendance_loading = false;
  var paymentHistoryLoading = false;
  var paymentHistory = [];
  var expanded = true;
  var userid = "";
  var membershipStatusCheck = false;
  var _image;
  var username = TextEditingController();
  var password = TextEditingController();
  var attendancebtn = "Mark Attendance";
  var amount = TextEditingController();
  var dueDate = TextEditingController();
  var user = null;

  void PrintReciptCopy(data) async {
    setState(() {
      _loading = true;
    });
    var url = 'https://backend.aurum.fitness/api/getOrderId/';
    var response = await http.post(Uri.parse(url),
        body: json.encode({
          'userid': widget.userid,
        }),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token 38bc32c9730b26e11b45f640aaef804c00c0c325",
        });
    var OI = json.decode(response.body);
    var orderid = OI['orderId'];
    var vpa = OI['vpa'];
    if (data.checkIfAnyIsNull()) {
      setState(() {
        _loading = false;
      });
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text("Failed"),
              content: Text("Printing Failed"),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.pop(_);
                  },
                ),
                CupertinoDialogAction(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.pop(_);
                  },
                )
              ],
            );
          });
    } else {
      Map dataToSend = {
        "name": data.name,
        "number": data.Phone_number,
        "price": data.amount_paid,
        "paymentmode": vpa != Null ? "UPI($vpa)" : "Cash",
        "plan": data.Membership_type + "(${data.Membership_duration} months)",
        "months": data.Membership_duration,
        "invoiceno": orderid,
        "subtotal": data.Total_Payable_Amount
      };
      await PrintGlobal(dataToSend).then((status) {
        if (!status) {
          showCupertinoDialog(
              context: context,
              builder: (_) {
                return CupertinoAlertDialog(
                  title: Text("Failed"),
                  content: Text("Printing Failed: No IP Found"),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text("Ok"),
                      onPressed: () {
                        Navigator.pop(_);
                      },
                    )
                  ],
                );
              });
        }
      });
      await markAsPrinted(orderid);
    }
    setState(() {
      _loading = false;
    });
  }

  void loadPaymentHistory() async {
    var url = 'https://backend.aurum.fitness/api/getPaymentHistoryStaff/';
    var response = await http.post(Uri.parse(url),
        body: json.encode({
          'name': widget.userid,
        }),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token 38bc32c9730b26e11b45f640aaef804c00c0c325",
        });
    var data = json.decode(response.body);
    print(data);
    if (data.length > 0) {
      showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * .8,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                  color: CupertinoColors.systemGroupedBackground,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment History",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        // return Column(
                        //   children: [
                        //     Material(
                        //       child: ListTile(
                        //         tileColor: CupertinoColors.white,
                        //         title: Text(
                        //           data[index]["type"],
                        //         ),
                        //         subtitle: Text(
                        //           data[index]["date"],
                        //         ),
                        //         trailing: Text(
                        //           "₹ " + data[index]["amount"],
                        //         ),
                        //       ),
                        //     ),
                        //     Padding(
                        //       padding: const EdgeInsets.only(
                        //         left: 50,
                        //         right: 15,
                        //       ),
                        //       child: Divider(
                        //         color: Colors.grey,
                        //       ),
                        //     )
                        //   ],
                        // );
                        return StatefulBuilder(
                          builder: ((context, StateSetter expande) {
                            return GestureDetector(
                              onTap: (() {
                                expande(() {
                                  expanded = expanded ? false : true;
                                });
                              }),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 50,
                                  height: expanded
                                      ? MediaQuery.of(context).size.height / 10
                                      : MediaQuery.of(context).size.height / 6,
                                  decoration: BoxDecoration(
                                      color:
                                          CupertinoColors.lightBackgroundGray,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0),
                                    child: Row(children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0, right: 20),
                                        child: Text(
                                          data[index]["months"],
                                          style: TextStyle(
                                              fontFamily: 'SFPro',
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                              color: data[index]
                                                          ["additional_info"]
                                                      ["bill_printed"]
                                                  ? CupertinoColors.systemGreen
                                                  : CupertinoColors
                                                      .inactiveGray),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.76,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(data[index]["type"],
                                                        style: TextStyle(
                                                          fontFamily: 'SFPro',
                                                          fontSize: 18,
                                                        )),
                                                    Text(data[index]["date"],
                                                        style: TextStyle(
                                                            fontFamily: 'SFPro',
                                                            fontSize: 16,
                                                            color: CupertinoColors
                                                                .inactiveGray)),
                                                  ],
                                                ),
                                                Text(
                                                    "₹" + data[index]["amount"],
                                                    style: TextStyle(
                                                      fontFamily: 'SFPro',
                                                      fontSize: 18,
                                                    )),
                                              ],
                                            ),
                                          ),
                                          expanded
                                              ? SizedBox(
                                                  height: 0,
                                                )
                                              : SizedBox(
                                                  height: 15,
                                                ),
                                          expanded
                                              ? SizedBox(height: 0)
                                              : Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.76,
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      top: BorderSide(
                                                          width: 1.0,
                                                          color: CupertinoColors
                                                              .darkBackgroundGray),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  data[index][
                                                                          "additional_info"]
                                                                      ["VPA"],
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'SFPro',
                                                                      fontSize:
                                                                          16,
                                                                      color: CupertinoColors
                                                                          .inactiveGray)),
                                                              Text(
                                                                  "#" +
                                                                      data[index]
                                                                              [
                                                                              "id"]
                                                                          .toString(),
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'SFPro',
                                                                      fontSize:
                                                                          16,
                                                                      color: CupertinoColors
                                                                          .inactiveGray)),
                                                            ],
                                                          ),
                                                          Text(
                                                              "₹" +
                                                                  data[index]["additional_info"]
                                                                          [
                                                                          "subtotal"]
                                                                      .toString(),
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'SFPro',
                                                                  fontSize: 16,
                                                                  color: CupertinoColors
                                                                      .inactiveGray)),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                )
                                        ],
                                      ),
                                    ]),
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                      itemCount: data.length,
                    ),
                  ),
                ],
              ),
            );
          });
    }
    setState(() {
      paymentHistoryLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    myFuture = getUser(widget.userid);
    setState(() {
      userid = widget.userid;
    });
  }

  handleImageChange() async {
    var image =
        await ImagePicker.platform.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = image;
      });
      var response = await FileUploadHandler(
          userid, image.path, "38bc32c9730b26e11b45f640aaef804c00c0c325");

      if (response['error']) {
        showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
                  title: Text("Error"),
                  content: Text(response['message']),
                  actions: [
                    CupertinoDialogAction(
                      child: Text("Ok"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ));
      } else {
        showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
                  title: Text("Success"),
                  content: Text(response['message']),
                  actions: [
                    CupertinoDialogAction(
                      child: Text("Ok"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ));
      }
    }
  }

  sendNotification(data) async {
    await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
              title: Text("Send Payment Notification"),
              content: Column(
                children: [
                  CupertinoFormRow(
                    child: CupertinoTextFormFieldRow(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(213, 255, 255, 255),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      placeholder: "Due Amount",
                      controller: amount,
                    ),
                  ),
                  CupertinoFormRow(
                    child: CupertinoTextFormFieldRow(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(213, 255, 255, 255),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      placeholder: "Due Date",
                      controller: dueDate,
                    ),
                  ),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                    child: Text("Yes"),
                    onPressed: () async {
                      Navigator.pop(context);
                    }),
                CupertinoDialogAction(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.pop(context);
                    return;
                  },
                )
              ],
            ));
    var response = await sendPaymentNotification(
        userid,
        data.name,
        data.Phone_number,
        amount.text,
        dueDate.text,
        "38bc32c9730b26e11b45f640aaef804c00c0c325");
    if (response['error']) {
      showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: Text("Error"),
                content: Text(response['message']),
                actions: [
                  CupertinoDialogAction(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ));
    } else {
      showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: Text("Success"),
                content: Text(response['message']),
                actions: [
                  CupertinoDialogAction(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.black,
        child: FutureBuilder(
            future: myFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CupertinoActivityIndicator(),
                );
              } else if (snapshot.hasData) {
                return CustomScrollView(slivers: [
                  SliverAppBar(
                    leading: CupertinoButton(
                      child: Icon(
                        CupertinoIcons.back,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    actions: [
                      CupertinoButton(
                        child: Icon(
                          CupertinoIcons.bell,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          sendNotification(snapshot.data);
                        },
                      ),
                      CupertinoButton(
                        child: Icon(
                          CupertinoIcons.camera,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          handleImageChange();
                        },
                      ),
                    ],
                    backgroundColor: Color.fromARGB(255, 41, 41, 41),
                    expandedHeight: 300,
                    floating: true,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(snapshot.data!.name ?? "Name",
                          style: TextStyle(
                              fontFamily: 'SFPro',
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      background: CachedNetworkImage(
                        imageUrl: "https://backend.aurum.fitness" +
                            snapshot.data!.profilePic,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CupertinoActivityIndicator(),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                  SliverList(
                      delegate:
                          SliverChildBuilderDelegate((BuildContext ctx, index) {
                    return Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(top: 30),
                      child: Column(
                        children: [
                          (!snapshot.data.active)
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons
                                          .exclamationmark_circle_fill,
                                      color: CupertinoColors.white,
                                    ),
                                    Text("Inactive User",
                                        style: TextStyle(
                                          color: CupertinoColors.white,
                                          decoration: TextDecoration.none,
                                          fontSize: 20,
                                        ))
                                  ],
                                )
                              : SizedBox(),
                          snapshot.data.membershipStatus
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons
                                          .exclamationmark_triangle_fill,
                                      color: CupertinoColors.systemRed,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text("Membership Expired",
                                        style: TextStyle(
                                          fontFamily: 'SFPro',
                                          // color: CupertinoColors.black,
                                          decoration: TextDecoration.none,
                                          fontSize: 16,
                                        )),
                                  ],
                                )
                              : SizedBox(),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          CupertinoFormSection.insetGrouped(
                              // backgroundColor:
                              //     CupertinoColors.lightBackgroundGray,
                              header: Text(
                                'User Info',
                                style: TextStyle(
                                    fontFamily: 'SFPro',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600),
                              ),
                              children: [
                                CupertinoFormRow(
                                  prefix: Text(
                                    'Name: ',
                                    style: TextStyle(
                                        fontFamily: 'SFPro',
                                        fontWeight: FontWeight.w500),
                                  ),
                                  child: CupertinoTextFormFieldRow(
                                    textAlign: TextAlign.left,
                                    controller: TextEditingController(
                                        text: snapshot.data.name),
                                  ),
                                ),
                                CupertinoFormRow(
                                  prefix: Text(
                                    'Phone: ',
                                    style: TextStyle(
                                        fontFamily: 'SFPro',
                                        fontWeight: FontWeight.w500),
                                  ),
                                  child: CupertinoTextFormFieldRow(
                                    textAlign: TextAlign.left,
                                    controller: TextEditingController(
                                        text: snapshot.data.Phone_number),
                                  ),
                                ),
                                CupertinoFormRow(
                                  prefix: Text(
                                    'Address: ',
                                    style: TextStyle(
                                        fontFamily: 'SFPro',
                                        fontWeight: FontWeight.w500),
                                  ),
                                  child: CupertinoTextFormFieldRow(
                                    textAlign: TextAlign.left,
                                    controller: TextEditingController(
                                        text: snapshot.data!.Address),
                                  ),
                                ),
                              ]),
                          CupertinoFormSection.insetGrouped(
                              // backgroundColor:
                              //     CupertinoColors.lightBackgroundGray,
                              header: Text(
                                'Membership Info',
                                style: TextStyle(
                                    fontFamily: 'SFPro',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600),
                              ),
                              children: [
                                CupertinoFormRow(
                                  prefix: Text(
                                    'Membership Type: ',
                                    style: TextStyle(
                                        fontFamily: 'SFPro',
                                        fontWeight: FontWeight.w500),
                                  ),
                                  child: CupertinoTextFormFieldRow(
                                    textAlign: TextAlign.left,
                                    controller: TextEditingController(
                                        text: snapshot.data!.Membership_type),
                                  ),
                                ),
                                CupertinoFormRow(
                                  prefix: Text(
                                    'Total Payable Amount: ',
                                    style: TextStyle(
                                        fontFamily: 'SFPro',
                                        fontWeight: FontWeight.w500),
                                  ),
                                  child: CupertinoTextFormFieldRow(
                                    textAlign: TextAlign.left,
                                    controller: TextEditingController(
                                        text: snapshot
                                            .data!.Total_Payable_Amount
                                            .toString()),
                                  ),
                                ),
                                CupertinoFormRow(
                                  prefix: Text(
                                    'Amount Paid: ',
                                    style: TextStyle(
                                        fontFamily: 'SFPro',
                                        fontWeight: FontWeight.w500),
                                  ),
                                  child: CupertinoTextFormFieldRow(
                                    textAlign: TextAlign.left,
                                    controller: TextEditingController(
                                        text: snapshot.data!.amount_paid
                                            .toString()),
                                  ),
                                ),
                                CupertinoFormRow(
                                  prefix: Text(
                                    'Membership Duration: ',
                                    style: TextStyle(
                                        fontFamily: 'SFPro',
                                        fontWeight: FontWeight.w500),
                                  ),
                                  child: CupertinoTextFormFieldRow(
                                    textAlign: TextAlign.left,
                                    controller: TextEditingController(
                                        text: snapshot.data!.Membership_duration
                                            .toString()),
                                  ),
                                ),
                                CupertinoFormRow(
                                  prefix: Text(
                                    'Membership Starting From: ',
                                    style: TextStyle(
                                        fontFamily: 'SFPro',
                                        fontWeight: FontWeight.w500),
                                  ),
                                  child: CupertinoTextFormFieldRow(
                                    textAlign: TextAlign.left,
                                    controller: TextEditingController(
                                        text: snapshot
                                            .data!.Membership_start_date),
                                  ),
                                ),
                              ]),
                          SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: CupertinoButton.filled(
                                // make the colour white
                                child: Row(
                                  // 2 elements to denote mark attendance and loading indicator
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: attendance_loading != true
                                      ? snapshot.data!.attendanceStatus
                                          ? [
                                              Icon(
                                                CupertinoIcons.checkmark_alt,
                                                color: CupertinoColors.white,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Marked",
                                                style: TextStyle(
                                                    fontFamily: 'SFPro',
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w400,
                                                    color: CupertinoColors.white
                                                        .withOpacity(.8)),
                                              ),
                                            ]
                                          : [
                                              Icon(CupertinoIcons.checkmark_alt,
                                                  color: CupertinoColors.white),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                attendancebtn,
                                                style: TextStyle(
                                                    fontFamily: 'SFPro',
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w400,
                                                    color: CupertinoColors.white
                                                        .withOpacity(.8)),
                                              ),
                                            ]
                                      : [CupertinoActivityIndicator()],
                                ),
                                onPressed: snapshot.data!.attendanceStatus
                                    ? null
                                    : () async {
                                        setState(() {
                                          attendance_loading = true;
                                        });
                                        var status = await markUserAttendance(
                                            userid,
                                            "38bc32c9730b26e11b45f640aaef804c00c0c325");
                                        setState(() {
                                          attendance_loading = false;
                                        });
                                        if (status["error"]) {
                                          showCupertinoDialog(
                                              context: context,
                                              builder: (context) {
                                                return CupertinoAlertDialog(
                                                  title: Text("Error"),
                                                  content:
                                                      Text(status["message"]),
                                                  actions: [
                                                    CupertinoDialogAction(
                                                      child: Text("Ok"),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    )
                                                  ],
                                                );
                                              });
                                        } else {
                                          setState(() {
                                            attendancebtn = "Marked";
                                          });
                                        }
                                      }),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          CupertinoFormSection.insetGrouped(
                            // backgroundColor:
                            //     CupertinoColors.lightBackgroundGray,
                            children: [
                              CupertinoButton(
                                  padding: EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Print Recipt Copy",
                                        style: TextStyle(
                                            fontFamily: 'SFPro',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                            color: CupertinoColors.systemBlue
                                                .withOpacity(.8)),
                                      ),
                                      _loading == true
                                          ? CupertinoActivityIndicator()
                                          : Container(),
                                    ],
                                  ),
                                  onPressed: () {
                                    PrintReciptCopy(snapshot.data);
                                  }),
                              CupertinoButton(
                                  padding: EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Accept Payment",
                                        style: TextStyle(
                                            fontFamily: 'SFPro',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) => DynamicQrCode(
                                                  userid: widget.userid,
                                                )));
                                  }),
                              CupertinoButton(
                                  padding: EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Show Payment History",
                                        style: TextStyle(
                                            fontFamily: 'SFPro',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Spacer(),
                                      paymentHistoryLoading
                                          ? CupertinoActivityIndicator()
                                          : SizedBox()
                                    ],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      paymentHistoryLoading = true;
                                    });
                                    loadPaymentHistory();
                                  }),
                              CupertinoButton(
                                  padding: EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Send Payment Notification",
                                        style: TextStyle(
                                            fontFamily: 'SFPro',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400),
                                      )
                                    ],
                                  ),
                                  onPressed: () {
                                    sendNotification(snapshot.data);
                                  }),
                            ],
                          ),
                          SizedBox(
                            height: 60,
                          ),
                        ],
                      ),
                    );
                  }, childCount: 1))
                ]);
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error'),
                );
              }
              return Center(
                child: CupertinoActivityIndicator(),
              );
            }));
  }

  Future<User> getUser(userid) async {
    // var url = Uri.parse("http://127.0.0.1:8000/auth/getUserInfoStaff/");
    var url = Uri.parse("https://backend.aurum.fitness/auth/getUserInfoStaff/");
    try {
      var response = await http.post(url, body: {
        'userid': userid
      }, headers: {
        "Authorization": "Token 38bc32c9730b26e11b45f640aaef804c00c0c325",
      });
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (!responseData["active"]) {
          showCupertinoDialog(
              context: context,
              builder: (_) {
                return CupertinoAlertDialog(
                  content: Text("Inactive User"),
                  title: Icon(
                    CupertinoIcons.exclamationmark_circle,
                    size: 50,
                    color: CupertinoColors.systemRed,
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: Text("Ok"),
                      onPressed: () {
                        Navigator.pop(_);
                      },
                    )
                  ],
                );
              });
        }
        return User(
            responseData["name"],
            userid,
            responseData["address"],
            responseData["phone"],
            responseData["plan"],
            responseData["totalPayableAmount"],
            responseData["alreadyPaid"],
            responseData["duration"] != "None"
                ? (int.parse(responseData["duration"]) / 30).toStringAsFixed(0)
                : "0",
            responseData["startingFrom"],
            responseData["active"],
            responseData["membershipStatus"],
            responseData["attendanceStatus"],
            responseData["pfp"]);
      } else {
        print("failed");
        throw Exception('Failed to load post');
      }
    } catch (e) {
      print(e);
    }
    return User(null, null, null, null, null, null, null, null, null, true,
        false, false, "/media/ntf.png");
  }
}

class User {
  final String? name;
  final String? Address;
  final String? Membership_type;
  final String? Phone_number;
  final int? Total_Payable_Amount;
  final int? amount_paid;
  final String? Membership_duration;
  final String? Membership_start_date;
  final String? userid;
  final bool? active;
  final bool membershipStatus;
  final String? profilePic;
  final bool? attendanceStatus;

  User(
      this.name,
      this.userid,
      this.Address,
      this.Phone_number,
      this.Membership_type,
      this.Total_Payable_Amount,
      this.amount_paid,
      this.Membership_duration,
      this.Membership_start_date,
      this.active,
      this.membershipStatus,
      this.attendanceStatus,
      this.profilePic);

  bool checkIfAnyIsNull() {
    return [
      name,
      Address,
      Phone_number,
      Membership_type,
      Total_Payable_Amount,
      amount_paid,
      Membership_duration,
      Membership_start_date,
      active,
      membershipStatus,
      attendanceStatus,
    ].contains(null);
  }
}
