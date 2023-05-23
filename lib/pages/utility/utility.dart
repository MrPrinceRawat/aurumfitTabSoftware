import 'dart:convert';

import 'package:aurumfit/pages/utility/PrintRecipt.dart';
import 'package:aurumfit/pages/payments/Subscription.dart';
import 'package:aurumfit/components/galary.dart';
import 'package:aurumfit/pages/payments/dynamicPayment.dart';
import 'package:aurumfit/pages/utility/printInvoice.dart';
import 'package:aurumfit/pages/utility/tokenQR.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

class Utility extends StatefulWidget {
  const Utility({Key? key}) : super(key: key);

  @override
  _UtilityState createState() => _UtilityState();
}

class _UtilityState extends State<Utility> {
  bool _showAppbar = true;
  ScrollController _scrollBottomBarController = new ScrollController();
  bool isScrollingDown = false;
  var WEIGHT = TextEditingController();
  var HEIGHT = TextEditingController();
  var AGE = TextEditingController();
  var GENDER = TextEditingController();
  var PUSHUPS = TextEditingController();
  var PULLUPS = TextEditingController();
  var BURPEES = TextEditingController();
  var CHEST = TextEditingController();
  var BICEP = TextEditingController();
  var user = TextEditingController();
  var userId = new TextEditingController();
  List users = [];

  double AFS = 0;

  bool _loading = false;

  bool _show = true;

  @override
  void initState() {
    super.initState();
    myScroll();
  }

  @override
  void dispose() {
    _scrollBottomBarController.removeListener(() {});
    super.dispose();
  }

  Future<void> findUser(entered) async {
    // Make a POST request to aurumfitnesscommunicator.ml to get the user list
    var url = Uri.parse('https://backend.aurum.fitness/auth/getUser/');
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

  void showBottomBar() {
    setState(() {
      _show = true;
    });
  }

  void hideBottomBar() {
    setState(() {
      _show = false;
    });
  }

  void myScroll() async {
    _scrollBottomBarController.addListener(() {
      if (_scrollBottomBarController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showAppbar = false;
          hideBottomBar();
        }
      }
      if (_scrollBottomBarController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showAppbar = true;
          showBottomBar();
        }
      }
    });
  }

  void calculateAFS() async {
    var BMI = (double.parse(WEIGHT.text) /
            (double.parse(HEIGHT.text) * double.parse(HEIGHT.text))) *
        10000;
    var BodyFat = (0.503 * double.parse(AGE.text) +
            (10.689 * double.parse(GENDER.text) +
                (3.172 * BMI) -
                (0.026 * (BMI * BMI)) +
                (0.181 * BMI * double.parse(GENDER.text)) -
                (0.02 * BMI * double.parse(AGE.text)) -
                (0.005 * (BMI * BMI) * double.parse(GENDER.text)) +
                (0.0002 * (BMI * BMI) * double.parse(AGE.text)))) -
        44.988;

    if (BMI >= 20) {
      BMI = 40 - BMI;
    }
    BMI = double.parse((BMI.round() / 10).toString());
    BodyFat = double.parse((BodyFat.round() / 10).toString());
    var AFS = BMI +
        (double.parse(CHEST.text) * double.parse(BICEP.text)) / 100 -
        BodyFat +
        (double.parse(PULLUPS.text) +
                double.parse(PUSHUPS.text) +
                double.parse(BURPEES.text)) /
            10;
    AFS = double.parse(AFS.toStringAsFixed(2));
    print(AFS);
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("Your AFS is $AFS"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
    await http
        .post(
          Uri.parse("https://backend.aurum.fitness/api/setAFS/"),
          body: json.encode({
            "user": userId.text,
            "AFS": AFS,
            "Weight": WEIGHT.text,
            "Height": HEIGHT.text,
            "Age": AGE.text,
            "Pushups": PUSHUPS.text,
            "PullUps": PULLUPS.text,
            "Burpees": BURPEES.text,
            "Chest": CHEST.text,
            "Bicep": BICEP.text,
          }),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Token 38bc32c9730b26e11b45f640aaef804c00c0c325",
          },
        )
        .then((value) => json.decode(value.body))
        .then((value) => () {
              print(value);
              if (value["status"] != "Done") {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text(value["status"]),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text("Close"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    });
              }
            });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.black,
        child: SafeArea(
          child: ListView(
            controller: _scrollBottomBarController,
            padding: EdgeInsets.only(left: 30, right: 30, top: 16),
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.06,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 40),
                child: Text(
                  "Utility",
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                      fontFamily: 'SFPro',
                      letterSpacing: 1.5),
                ),
              ),
              Container(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withOpacity(.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.only(top: 20),
                  child: Material(
                    color: Colors.transparent,
                    child: CupertinoFormSection.insetGrouped(
                      margin: EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.transparent,
                      children: [
                        ListTile(
                          contentPadding:
                              EdgeInsets.only(left: 30, right: 30, bottom: 10),
                          leading: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Color(0xff2ca3c7),
                                border: Border.fromBorderSide(BorderSide(
                                    color: Color(0xff2ca3c7), width: 2)),
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(
                              CupertinoIcons.creditcard,
                              color: Color(0xffffffff),
                            ),
                          ),
                          title: Text(
                            "Billing",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: CupertinoColors.white.withOpacity(.6),
                                fontFamily: 'SFPro'),
                          ),
                          trailing: Icon(
                            CupertinoIcons.right_chevron,
                            color: Color(0xffdedede),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => PrintRecipt()));
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.only(
                              left: 30, right: 30, bottom: 10, top: 10),
                          leading: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Color(0xff2ca3c7),
                                border: Border.fromBorderSide(BorderSide(
                                    color: Color(0xff2ca3c7), width: 2)),
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(
                              CupertinoIcons.circle_grid_hex_fill,
                              color: Color(0xffffffff),
                            ),
                          ),
                          title: Text(
                            "Gallary",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: CupertinoColors.white.withOpacity(.6),
                                fontFamily: 'SFPro'),
                          ),
                          trailing: Icon(
                            CupertinoIcons.right_chevron,
                            color: Color(0xffdedede),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => Galary()));
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.only(
                              left: 30, right: 30, bottom: 10, top: 10),
                          leading: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Color(0xff2ca3c7),
                                border: Border.fromBorderSide(BorderSide(
                                    color: Color(0xff2ca3c7), width: 2)),
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(
                              CupertinoIcons.printer,
                              color: Color(0xffffffff),
                            ),
                          ),
                          title: Text(
                            "Print Invoice",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: CupertinoColors.white.withOpacity(.6),
                                fontFamily: 'SFPro'),
                          ),
                          trailing: Icon(
                            CupertinoIcons.right_chevron,
                            color: Color.fromRGBO(225, 225, 225, 1),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => printInvoice()));
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.only(
                              left: 30, right: 30, top: 10, bottom: 10),
                          leading: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Color(0xff2ca3c7),
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(
                              CupertinoIcons.qrcode_viewfinder,
                              color: Color(0xffffffff),
                            ),
                          ),
                          title: Text(
                            "Generate Qr Code",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: CupertinoColors.white.withOpacity(.6),
                                fontFamily: 'SFPro'),
                          ),
                          trailing: Icon(
                            CupertinoIcons.right_chevron,
                            color: Color(0xffdedede),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => DynamicQrCode()));
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.only(
                              left: 30, right: 30, top: 10, bottom: 10),
                          leading: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Color(0xff2ca3c7),
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(
                              CupertinoIcons.creditcard,
                              color: Color(0xffffffff),
                            ),
                          ),
                          title: Text(
                            "Create a Subscription",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: CupertinoColors.white.withOpacity(.6),
                                fontFamily: 'SFPro'),
                          ),
                          trailing: Icon(
                            CupertinoIcons.right_chevron,
                            color: Color(0xffdedede),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        createSubscription()));
                          },
                        ),
                        ListTile(
                          contentPadding:
                              EdgeInsets.only(left: 30, right: 30, top: 10),
                          leading: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Color(0xff2ca3c7),
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(
                              CupertinoIcons.qrcode,
                              color: Color(0xffffffff),
                            ),
                          ),
                          title: Text(
                            "Token QR Code",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: CupertinoColors.white.withOpacity(.6),
                                fontFamily: 'SFPro'),
                          ),
                          trailing: Icon(
                            CupertinoIcons.right_chevron,
                            color: Color(0xffdedede),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => TokenQR()));
                          },
                        ),
                        ListTile(
                          contentPadding:
                              EdgeInsets.only(left: 30, right: 30, top: 10),
                          leading: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Color(0xff2ca3c7),
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(
                              CupertinoIcons.heart_solid,
                              color: Color(0xffffffff),
                            ),
                          ),
                          title: Text(
                            "Calculate AFS",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: CupertinoColors.white.withOpacity(.6),
                                fontFamily: 'SFPro'),
                          ),
                          trailing: Icon(
                            CupertinoIcons.right_chevron,
                            color: Color(0xffdedede),
                          ),
                          onTap: () {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.height * .8,
                                    padding: EdgeInsets.all(30),
                                    decoration: BoxDecoration(
                                        color: CupertinoColors
                                            .systemGroupedBackground,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20))),
                                    child: ListView(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(CupertinoIcons.heart,
                                                size: 70),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Text("Calculate AFS",
                                                style: TextStyle(
                                                    color:
                                                        CupertinoColors.black,
                                                    fontSize: 35,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            CupertinoFormSection.insetGrouped(
                                                children: [
                                                  CupertinoFormRow(
                                                      prefix: Text(
                                                        'User ID',
                                                        style: TextStyle(
                                                            fontFamily: 'SFPro',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      child:
                                                          CupertinoTextFormFieldRow(
                                                        controller: userId,
                                                        onChanged: (value) {
                                                          findUser(value);
                                                        },
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return "Please enter Username";
                                                          }
                                                          return null;
                                                        },
                                                      )),
                                                ]),
                                            Container(
                                                height:
                                                    users.length == 0 ? 0 : 150,
                                                decoration: BoxDecoration(
                                                    color: Color(0xffffffff),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                margin: EdgeInsets.only(
                                                    top: 0,
                                                    left: 20,
                                                    right: 20,
                                                    bottom: 0),
                                                child: ListView(
                                                  children: [
                                                    for (var i in users)
                                                      CupertinoButton(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 100),
                                                        child: Text(i),
                                                        onPressed: () {
                                                          setState(() {
                                                            userId.value =
                                                                TextEditingValue(
                                                                    text: i);
                                                            users = [];
                                                          });
                                                        },
                                                      )
                                                  ],
                                                )),
                                            CupertinoFormSection.insetGrouped(
                                                header: Text(
                                                  'Basic Info',
                                                  style: TextStyle(
                                                      fontFamily: 'SFPro',
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                children: [
                                                  CupertinoFormRow(
                                                      prefix: Text(
                                                        'Weight',
                                                        style: TextStyle(
                                                            fontFamily: 'SFPro',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      child:
                                                          CupertinoTextFormFieldRow(
                                                        controller: WEIGHT,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return "Please enter weight";
                                                          }
                                                          return null;
                                                        },
                                                      )),
                                                  CupertinoFormRow(
                                                      prefix: Text(
                                                        'Height',
                                                        style: TextStyle(
                                                            fontFamily: 'SFPro',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      child:
                                                          CupertinoTextFormFieldRow(
                                                        controller: HEIGHT,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return "Please enter Height";
                                                          }
                                                          return null;
                                                        },
                                                      )),
                                                  CupertinoFormRow(
                                                      prefix: Text(
                                                        'Age',
                                                        style: TextStyle(
                                                            fontFamily: 'SFPro',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      child:
                                                          CupertinoTextFormFieldRow(
                                                        controller: AGE,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return "Please enter Age";
                                                          }
                                                          return null;
                                                        },
                                                      )),
                                                  CupertinoFormRow(
                                                      prefix: Text(
                                                        'Gender',
                                                        style: TextStyle(
                                                            fontFamily: 'SFPro',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      child:
                                                          CupertinoTextFormFieldRow(
                                                        controller: GENDER,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return "Please enter Gender";
                                                          }
                                                          return null;
                                                        },
                                                      )),
                                                ]),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            CupertinoFormSection.insetGrouped(
                                                header: Text(
                                                  'Endurance Info',
                                                  style: TextStyle(
                                                      fontFamily: 'SFPro',
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                children: [
                                                  CupertinoFormRow(
                                                      prefix: Text(
                                                        'Push ups',
                                                        style: TextStyle(
                                                            fontFamily: 'SFPro',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      child:
                                                          CupertinoTextFormFieldRow(
                                                        controller: PUSHUPS,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return "Please enter push ups";
                                                          }
                                                          return null;
                                                        },
                                                      )),
                                                  CupertinoFormRow(
                                                      prefix: Text(
                                                        'Pull ups',
                                                        style: TextStyle(
                                                            fontFamily: 'SFPro',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      child:
                                                          CupertinoTextFormFieldRow(
                                                        controller: PULLUPS,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return "Please enter pull ups";
                                                          }
                                                          return null;
                                                        },
                                                      )),
                                                  CupertinoFormRow(
                                                      prefix: Text(
                                                        'Burpees',
                                                        style: TextStyle(
                                                            fontFamily: 'SFPro',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      child:
                                                          CupertinoTextFormFieldRow(
                                                        controller: BURPEES,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return "Please enter burpees";
                                                          }
                                                          return null;
                                                        },
                                                      )),
                                                ]),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            CupertinoFormSection.insetGrouped(
                                                header: Text(
                                                  'Muscle Size Info',
                                                  style: TextStyle(
                                                      fontFamily: 'SFPro',
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                children: [
                                                  CupertinoFormRow(
                                                      prefix: Text(
                                                        'Chest',
                                                        style: TextStyle(
                                                            fontFamily: 'SFPro',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      child:
                                                          CupertinoTextFormFieldRow(
                                                        controller: CHEST,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return "Please enter Chest Size.";
                                                          }
                                                          return null;
                                                        },
                                                      )),
                                                  CupertinoFormRow(
                                                      prefix: Text(
                                                        'Bicep',
                                                        style: TextStyle(
                                                            fontFamily: 'SFPro',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      child:
                                                          CupertinoTextFormFieldRow(
                                                        controller: BICEP,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return "Please enter Bicep Size.";
                                                          }
                                                          return null;
                                                        },
                                                      )),
                                                ]),
                                            SizedBox(height: 30),
                                            CupertinoButton.filled(
                                                child: Text("Calculate"),
                                                onPressed: () {
                                                  calculateAFS();
                                                }),
                                            SizedBox(height: 130),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                });
                          },
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }
}
