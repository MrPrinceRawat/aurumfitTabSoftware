import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

class createSubscription extends StatefulWidget {
  const createSubscription({Key? key}) : super(key: key);

  @override
  _createSubscriptionState createState() => _createSubscriptionState();
}

class _createSubscriptionState extends State<createSubscription> {
  bool _loading = false;
  List users = [];
  String? _userid;
  var name = TextEditingController();
  var phone = TextEditingController();
  var email = TextEditingController();
  var dateTostart;
  var date = TextEditingController();
  var plan;

  getUserInfo(_userid) async {
    setState(() {
      _loading = true;
    });
    Uri url = Uri.parse("https://backend.aurum.fitness/auth/getUserInfoStaff/");
    try {
      final http.Response response = await http.post(url, body: {
        "userid": _userid,
      }, headers: {
        "Authorization": "Token 38bc32c9730b26e11b45f640aaef804c00c0c325",
      });
      final Map<String, dynamic> responseData = json.decode(response.body);

      print(responseData);
      setState(() {
        phone.text = responseData["phone"];
        name.text = responseData["name"];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print(e);
    }
  }

  Future<void> findUser(entered) async {
    var url = Uri.parse('https://backend.aurum.fitnessss/auth/getUser/');
    var response = await http.post(url, body: {
      'name': entered
    }, headers: {
      "Authorization": "Token 38bc32c9730b26e11b45f640aaef804c00c0c325",
    });
    print((response.body));
    setState(() {
      users = jsonDecode(response.body);
    });
  }

  Future<void> createSubscriptionLink() async {
    setState(() {
      _loading = true;
    });
    var plans = ["Lite"];
    var ids = [
      "plan_IyU0IuMBpfoFD5",
      "plan_IvYPc0zp1LGc08",
      "plan_IyU17RvJCEtFWs",
      "plan_IyU0q6jctukWlY"
    ];
    var dataToPass = json.encode({
      'plan_id': ids[plan],
      "total_count": 12,
      "notes": {
        "user": _userid,
        "plan": plans[0],
      },
      'customer_notify': 1,
      "notify_info": {
        "notify_phone": phone.text,
        "notify_email": email.text,
      }
    });
    var dataToPassWithDate = json.encode({
      'plan_id': ids[plan],
      "total_count": 12,
      "notes": {
        "user": _userid,
        "plan": plans[0],
      },
      'customer_notify': 1,
      "start_at": dateTostart,
      "notify_info": {
        "notify_phone": phone.text,
        "notify_email": email.text,
      }
    });
    var url = Uri.parse('https://api.razorpay.com/v1/subscriptions');

    var response = await http.post(url,
        body: dateTostart != null ? dataToPass : dataToPassWithDate,
        headers: {
          "Authorization":
              "Basic cnpwX2xpdmVfYzlEUlJKdzdqNjJ1R0c6WllpdDhkSHpLbUxkbjJUbllwdVEwVXls",
          'Content-Type': 'application/json',
        });
    var data = json.decode(response.body);

    if (data["status"] == "created") {
      showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: Text("Subscription Created"),
                content:
                    Text("Your subscription has been created successfully"),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ));
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => WebView(
                    initialUrl: data["short_url"],
                    javascriptMode: JavascriptMode.unrestricted,
                  )));
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.black,
        navigationBar: CupertinoNavigationBar(
          middle: Text('Create Subscription'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text('Done'),
            onPressed: plan != null
                ? () {
                    createSubscriptionLink();
                  }
                : null,
          ),
        ),
        child: _loading
            ? Container(
                child: Center(
                child: CupertinoActivityIndicator(
                  radius: 20,
                ),
              ))
            : Container(
                child: ListView(
                  children: [
                    CupertinoFormSection.insetGrouped(
                        backgroundColor: CupertinoColors.black,
                        margin: EdgeInsets.only(
                            top: 40, left: 20, right: 20, bottom: 20),
                        children: [
                          CupertinoFormRow(
                            prefix: Text('User ID: '),
                            child: CupertinoTextFormFieldRow(
                              onChanged: (value) {
                                findUser(value);
                              },
                            ),
                          ),
                          Container(
                              height: users.length == 0 ? 0 : 150,
                              child: ListView(
                                children: [
                                  for (var i in users)
                                    CupertinoButton(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(left: 100),
                                      child: Text(i),
                                      onPressed: () {
                                        setState(() {
                                          _userid = i;
                                          users = [];
                                          getUserInfo(i);
                                        });
                                      },
                                    )
                                ],
                              )),
                        ]),
                    CupertinoFormSection.insetGrouped(
                        backgroundColor: CupertinoColors.black,
                        header: Text('User Details'),
                        children: [
                          CupertinoFormRow(
                            prefix: Text('Name'),
                            child: CupertinoTextFormFieldRow(
                              controller: name,
                              placeholder: 'Enter Name',
                            ),
                          ),
                          CupertinoFormRow(
                            prefix: Text('Phone'),
                            child: CupertinoTextFormFieldRow(
                              controller: phone,
                              placeholder: 'Enter Phone',
                            ),
                          ),
                          CupertinoFormRow(
                            prefix: Text('Email'),
                            child: CupertinoTextFormFieldRow(
                              controller: email,
                              placeholder: 'Enter Email',
                            ),
                          ),
                        ]),
                    SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text("Plan",
                          style: TextStyle(
                              fontSize: 25,
                              color: CupertinoColors.white.withOpacity(.8))),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          plan = 0;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                            left: 20, right: 20, top: 20, bottom: 10),
                        padding: EdgeInsets.all(30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text("Monthly"), Text("₹500")],
                        ),
                        decoration: BoxDecoration(
                          color: plan == 0
                              ? CupertinoColors.white
                              : CupertinoColors.white.withOpacity(.8),
                          borderRadius: BorderRadius.circular(20),
                          border: plan == 0
                              ? Border.all(
                                  color: CupertinoColors.systemBlue,
                                  width: 3,
                                )
                              : null,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          plan = 1;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        padding: EdgeInsets.all(30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text("Monthly"), Text("₹600")],
                        ),
                        decoration: BoxDecoration(
                          color: plan == 1
                              ? CupertinoColors.white
                              : CupertinoColors.white.withOpacity(.8),
                          borderRadius: BorderRadius.circular(20),
                          border: plan == 1
                              ? Border.all(
                                  color: CupertinoColors.systemBlue,
                                  width: 3,
                                )
                              : null,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          plan = 2;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        padding: EdgeInsets.all(30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text("Quaterly"), Text("₹1300")],
                        ),
                        decoration: BoxDecoration(
                          color: plan == 2
                              ? CupertinoColors.white
                              : CupertinoColors.white.withOpacity(.8),
                          borderRadius: BorderRadius.circular(20),
                          border: plan == 2
                              ? Border.all(
                                  color: CupertinoColors.systemBlue,
                                  width: 3,
                                )
                              : null,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          plan = 3;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        padding: EdgeInsets.all(30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text("Quaterly"), Text("₹1500")],
                        ),
                        decoration: BoxDecoration(
                          color: plan == 3
                              ? CupertinoColors.white
                              : CupertinoColors.white.withOpacity(.8),
                          borderRadius: BorderRadius.circular(20),
                          border: plan == 3
                              ? Border.all(
                                  color: CupertinoColors.systemBlue,
                                  width: 3,
                                )
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: CupertinoTextField(
                        controller: date,
                        // enabled: false,
                        prefix: Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                        ),
                        placeholder: 'Select Date',
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'SFPro',
                            letterSpacing: 1,
                            color: Colors.white),
                        onTap: () {
                          showCupertinoModalPopup(
                              context: context,
                              builder: (context) {
                                return Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.6,
                                  child: CupertinoDatePicker(
                                    backgroundColor: Colors.white,
                                    mode: CupertinoDatePickerMode.dateAndTime,
                                    initialDateTime: DateTime.now(),
                                    onDateTimeChanged: (DateTime newDateTime) {
                                      setState(() {
                                        dateTostart =
                                            newDateTime.millisecondsSinceEpoch;
                                      });
                                    },
                                  ),
                                );
                              });
                        },
                        decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(color: Colors.white, width: 1))),
                      ),
                    ),
                  ],
                ),
              ));
  }
}
