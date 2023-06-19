import 'dart:async';
import 'dart:convert';

import 'package:aurumfit/domians/usermanagement/admin.dart';
import 'package:aurumfit/providers/auth/authprovider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class CalcAFS extends ConsumerStatefulWidget {
  const CalcAFS({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CalcAFSState();
}

class _CalcAFSState extends ConsumerState<CalcAFS> {
  var WEIGHT = TextEditingController();
  var PHONE = TextEditingController();
  var HEIGHT = TextEditingController();
  var AGE = TextEditingController();
  var GENDER = 0;
  var PUSHUPS = TextEditingController();
  var PULLUPS = TextEditingController();
  var BURPEES = TextEditingController();
  var CHEST = TextEditingController();
  var BICEP = TextEditingController();
  var user = TextEditingController();
  var userId = new TextEditingController();
  List users = [];
  double AFS = 0;
  Timer? _debounce;
  late Admin admin;
  var currentPageLength = 1;
  String token = "";
  String searchText = "";
  int offset = 0;

  @override
  void initState() {
    super.initState();
    token = ref.read(AuthTokenProvider.notifier).state;
    admin = Admin(token: token);
  }

  @override
  void dispose() {
    super.dispose();
    _debounce?.cancel();
  }

  void _onSearchTextChanged(String searchText) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(Duration(milliseconds: 500), () async {
      setState(() {
        this.searchText = searchText;
        offset = 0;
      });

      var users = await admin.findUser(searchText, offset);
      print(users);
      setState(() {
        this.users = users;
      });
    });
  }

  void calculateAFS() async {
    var BMI = (double.parse(WEIGHT.text) /
            (double.parse(HEIGHT.text) * double.parse(HEIGHT.text))) *
        10000;
    var BodyFat = (0.503 * double.parse(AGE.text) +
            (10.689 * GENDER +
                (3.172 * BMI) -
                (0.026 * (BMI * BMI)) +
                (0.181 * BMI * GENDER) -
                (0.02 * BMI * double.parse(AGE.text)) -
                (0.005 * (BMI * BMI) * GENDER) +
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
            title: Text("Your AFS is:  $AFS"),
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
            "phone": PHONE.text,
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
            "Authorization": "Token $token",
          },
        )
        .then((value) => json.decode(value.body))
        .then((value) => () {
              print(value);
              if (value["status"] != "Done") {
                showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: Text("Error"),
                        content: Text(value["status"]),
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
              }
            });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("Calculate AFS"),
        ),
        child: Container(
          padding: EdgeInsets.all(30),
          child: ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.heart, size: 70),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Calculate AFS",
                      style: TextStyle(
                          color: CupertinoColors.white.withOpacity(0.9),
                          fontFamily: 'SFPro',
                          fontSize: 35,
                          fontWeight: FontWeight.w500)),
                  SizedBox(
                    height: 20,
                  ),
                  CupertinoFormSection.insetGrouped(children: [
                    CupertinoFormRow(
                        prefix: Text(
                          'User ID',
                          style: TextStyle(
                              fontFamily: 'SFPro', fontWeight: FontWeight.w500),
                        ),
                        child: CupertinoTextFormFieldRow(
                          controller: userId,
                          onChanged: _onSearchTextChanged,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter Username";
                            }
                            return null;
                          },
                        )),
                  ]),
                  Container(
                      height: users.length == 0 ? 0 : 150,
                      decoration: BoxDecoration(
                          color: CupertinoColors.darkBackgroundGray,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      margin: EdgeInsets.only(
                          top: 0, left: 20, right: 20, bottom: 0),
                      child: ListView(
                        children: [
                          for (var i in users)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  userId.text = i['username'].toString();
                                  users = [];
                                });
                              },
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: CupertinoColors.white,
                                        width: 0.5),
                                  ),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor:
                                              CupertinoColors.white,
                                          child: i['pic'] != Null
                                              ? CachedNetworkImage(
                                                  imageUrl:
                                                      "https://backend.aurum.fitness/" +
                                                          i['pic'],
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      Container(
                                                    width: 80.0,
                                                    height: 80.0,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                  placeholder: (context, url) =>
                                                      CupertinoActivityIndicator(
                                                    color: CupertinoColors
                                                        .darkBackgroundGray,
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      Icon(CupertinoIcons
                                                          .exclamationmark_circle),
                                                )
                                              : CircleAvatar(
                                                  radius: 48,
                                                  backgroundImage: NetworkImage(
                                                      "https://backend.aurum.fitness/media/" +
                                                          "ntf.png"),
                                                )),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(left: 20),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                i['username'],
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: i['is_active']
                                                        ? CupertinoColors
                                                            .lightBackgroundGray
                                                        : CupertinoColors
                                                            .systemGrey,
                                                    fontFamily: 'SFPro',
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              !i['is_active']
                                                  ? Text(
                                                      "INACTIVE",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: CupertinoColors
                                                              .destructiveRed,
                                                          fontFamily: 'SFPro',
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    )
                                                  : SizedBox()
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                        ],
                      )),
                  CupertinoFormSection.insetGrouped(
                      header: Text(
                        'Basic Info',
                        style: TextStyle(
                            fontFamily: 'SFPro',
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                      children: [
                        CupertinoFormRow(
                            prefix: Text(
                              'Phone',
                              style: TextStyle(
                                  fontFamily: 'SFPro',
                                  fontWeight: FontWeight.w500),
                            ),
                            child: CupertinoTextFormFieldRow(
                              controller: PHONE,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter phone number";
                                }
                                return null;
                              },
                            )),
                        CupertinoFormRow(
                            prefix: Text(
                              'Weight',
                              style: TextStyle(
                                  fontFamily: 'SFPro',
                                  fontWeight: FontWeight.w500),
                            ),
                            child: CupertinoTextFormFieldRow(
                              controller: WEIGHT,
                              keyboardType: TextInputType.number,
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
                                  fontWeight: FontWeight.w500),
                            ),
                            child: CupertinoTextFormFieldRow(
                              controller: HEIGHT,
                              keyboardType: TextInputType.number,
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
                                  fontWeight: FontWeight.w500),
                            ),
                            child: CupertinoTextFormFieldRow(
                              controller: AGE,
                              keyboardType: TextInputType.number,
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
                                fontWeight: FontWeight.w500),
                          ),
                          child: CupertinoSlidingSegmentedControl(
                              children: <int, Widget>{
                                0: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      'Male',
                                      style: TextStyle(
                                          fontFamily: "SFPro",
                                          color: CupertinoColors.black),
                                    )),
                                1: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      'Female',
                                      style: TextStyle(
                                          fontFamily: "SFPro",
                                          color: CupertinoColors.black),
                                    )),
                              },
                              groupValue: GENDER,
                              onValueChanged: (i) {
                                setState(() {
                                  GENDER = i as int;
                                });
                              }),
                        ),
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
                            fontWeight: FontWeight.w600),
                      ),
                      children: [
                        CupertinoFormRow(
                            prefix: Text(
                              'Push ups',
                              style: TextStyle(
                                  fontFamily: 'SFPro',
                                  fontWeight: FontWeight.w500),
                            ),
                            child: CupertinoTextFormFieldRow(
                              controller: PUSHUPS,
                              keyboardType: TextInputType.number,
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
                                  fontWeight: FontWeight.w500),
                            ),
                            child: CupertinoTextFormFieldRow(
                              controller: PULLUPS,
                              keyboardType: TextInputType.number,
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
                                  fontWeight: FontWeight.w500),
                            ),
                            child: CupertinoTextFormFieldRow(
                              controller: BURPEES,
                              keyboardType: TextInputType.number,
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
                            fontWeight: FontWeight.w600),
                      ),
                      children: [
                        CupertinoFormRow(
                            prefix: Text(
                              'Chest',
                              style: TextStyle(
                                  fontFamily: 'SFPro',
                                  fontWeight: FontWeight.w500),
                            ),
                            child: CupertinoTextFormFieldRow(
                              controller: CHEST,
                              keyboardType: TextInputType.number,
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
                                  fontWeight: FontWeight.w500),
                            ),
                            child: CupertinoTextFormFieldRow(
                              controller: BICEP,
                              keyboardType: TextInputType.number,
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
        ));
  }
}
