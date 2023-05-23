import 'dart:convert';
import 'package:aurumfit/domians/payments/Invoice.dart';
import 'package:aurumfit/domians/payments/models/Invoice.dart';
import 'package:aurumfit/domians/usermanagement/serverRelated.dart';
import 'package:aurumfit/domians/usermanagement/user_management.dart';
import 'package:aurumfit/pages/search/components/InvoiceBlock.dart';
import 'package:aurumfit/pages/search/components/paymentHistory.dart';
import 'package:aurumfit/providers/auth/authprovider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../payments/dynamicPayment.dart';

class ShowInfo extends ConsumerStatefulWidget {
  const ShowInfo({Key? key, required this.userid}) : super(key: key);

  final String userid;

  @override
  _ShowInfoState createState() => _ShowInfoState();
}

class _ShowInfoState extends ConsumerState<ShowInfo> {
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
  String token = "";
  late UserManagement usermanagement;

  Future loadPaymentHistory() async {
    var url = 'https://backend.aurum.fitness/api/getPaymentHistoryStaff/';
    var response = await http.post(Uri.parse(url),
        body: json.encode({
          'name': widget.userid,
        }),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        });
    var data = json.decode(response.body);
    if (data["error"]) {
      throw Exception(data["message"]);
    }
    if (data.length > 0) {
      data = data["data"];
      return data;
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    token = ref.read(AuthTokenProvider.notifier).state;
    usermanagement = UserManagement(userid: widget.userid);
    myFuture = usermanagement.getUserInfo(token);
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
      var response = await FileUploadHandler(userid, image.path, token);

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
        userid, data.name, data.Phone_number, amount.text, dueDate.text, token);
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
                          CupertinoIcons.qrcode_viewfinder,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => DynamicQrCode(
                                        userid: userid,
                                      )));
                        },
                      ),
                      CupertinoButton(
                        child: Icon(
                          CupertinoIcons.ellipsis_circle,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          // Open a drop dow menu
                          showCupertinoModalPopup(
                              context: context,
                              builder: (context) => CupertinoActionSheet(
                                    title: Text("Options"),
                                    actions: [
                                      CupertinoActionSheetAction(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          handleImageChange();
                                        },
                                        child: Text("Change Profile Picture"),
                                      ),
                                      CupertinoActionSheetAction(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          sendNotification(snapshot.data);
                                        },
                                        child:
                                            Text("Send Payment Notification"),
                                      ),
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Cancel"),
                                    ),
                                  ));
                        },
                      )
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
                    print(snapshot.data);
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
                                    'Username: ',
                                    style: TextStyle(
                                        fontFamily: 'SFPro',
                                        fontWeight: FontWeight.w500),
                                  ),
                                  child: CupertinoTextFormFieldRow(
                                    textAlign: TextAlign.left,
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: snapshot.data.userid),
                                  ),
                                ),
                                CupertinoFormRow(
                                  prefix: Text(
                                    'Name: ',
                                    style: TextStyle(
                                        fontFamily: 'SFPro',
                                        fontWeight: FontWeight.w500),
                                  ),
                                  child: CupertinoTextFormFieldRow(
                                    textAlign: TextAlign.left,
                                    readOnly: true,
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
                                    readOnly: true,
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
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: snapshot.data!.Address),
                                  ),
                                ),
                                CupertinoFormRow(
                                  prefix: Text(
                                    'Date of Birth: ',
                                    style: TextStyle(
                                        fontFamily: 'SFPro',
                                        fontWeight: FontWeight.w500),
                                  ),
                                  child: CupertinoTextFormFieldRow(
                                    textAlign: TextAlign.left,
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: snapshot.data!.dob),
                                  ),
                                ),
                                CupertinoFormRow(
                                  prefix: Text(
                                    'Gender: ',
                                    style: TextStyle(
                                        fontFamily: 'SFPro',
                                        fontWeight: FontWeight.w500),
                                  ),
                                  child: CupertinoTextFormFieldRow(
                                    textAlign: TextAlign.left,
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: snapshot.data!.gender),
                                  ),
                                ),
                              ]),
                          SizedBox(
                            height: 20,
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
                                            userid, token);
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
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              children: [
                                Text(
                                  "Invoices",
                                  style: TextStyle(
                                      fontFamily: 'SFPro',
                                      fontSize: 20,
                                      color: Color.fromARGB(217, 255, 255, 255),
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          FutureBuilder(
                              future: Invoice(userid: userid).getInvoice(token),
                              builder: (context,
                                  AsyncSnapshot<InvoiceModel> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(
                                    width:
                                        MediaQuery.of(context).size.width * .9,
                                    height:
                                        MediaQuery.of(context).size.height * .3,
                                    child: Center(
                                      child: CupertinoActivityIndicator(),
                                    ),
                                  );
                                } else if (snapshot.hasData) {
                                  return InvoiceBlock(
                                      userid: userid,
                                      token: token,
                                      invoice: snapshot.data);
                                } else if (snapshot.hasError) {
                                  print(snapshot.error);
                                  return Container(
                                    width:
                                        MediaQuery.of(context).size.width * .9,
                                    height:
                                        MediaQuery.of(context).size.height * .3,
                                    child: Center(
                                      child: Text('Error'),
                                    ),
                                  );
                                }
                                return Container(
                                  width: MediaQuery.of(context).size.width * .9,
                                  height:
                                      MediaQuery.of(context).size.height * .3,
                                  child: Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                );
                              }),
                          SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Text(
                                  "Payment History",
                                  style: TextStyle(
                                      fontFamily: 'SFPro',
                                      fontSize: 20,
                                      color: Color.fromARGB(217, 255, 255, 255),
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          FutureBuilder(
                              future: loadPaymentHistory(),
                              builder: (context, AsyncSnapshot snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(
                                    width:
                                        MediaQuery.of(context).size.width * .9,
                                    height:
                                        MediaQuery.of(context).size.height * .3,
                                    child: Center(
                                      child: CupertinoActivityIndicator(),
                                    ),
                                  );
                                } else if (snapshot.hasData) {
                                  return PaymentHistoryBlock(
                                      data: snapshot.data);
                                } else if (snapshot.hasError) {
                                  print(snapshot.error);
                                  return Container(
                                    width:
                                        MediaQuery.of(context).size.width * .9,
                                    height:
                                        MediaQuery.of(context).size.height * .3,
                                    child: Center(
                                      child: Text('Error'),
                                    ),
                                  );
                                }
                                return Container(
                                  width: MediaQuery.of(context).size.width * .9,
                                  height:
                                      MediaQuery.of(context).size.height * .3,
                                  child: Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                );
                              }),
                          SizedBox(
                            height: 50,
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
}
