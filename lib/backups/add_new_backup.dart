import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:aurumfit/dynamicPayment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:aurumfit/BLOC/serverRelated.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart';

class MemberSignUpPage extends StatefulWidget {
  const MemberSignUpPage({Key? key}) : super(key: key);

  @override
  _MemberSignUpPageState createState() => _MemberSignUpPageState();
}

class _MemberSignUpPageState extends State<MemberSignUpPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  String token = "";
  bool _isLoading = false;
  File? _image;
  String error = "";

  Future<bool> signup() async {
    setState(() {
      _isLoading = true;
    });
    var url = Uri.parse('https://backend.aurum.fitness/auth/create-user/');
    var request = await http.post(url, body: {
      'username':
          "${_firstNameController.text}_${_lastNameController.text}_${_phoneNumberController.text}",
      'email': _emailController.text,
      'password': "123456",
    });
    print(request.body);
    var data = json.decode(request.body);
    if (data['success']) {
      print("true");
      setState(() {
        _isLoading = false;
        token = json.decode(request.body)['Key'];
      });
      return true;
    } else {
      setState(() {
        _isLoading = false;
        error = data["Error"];
      });
      return false;
    }
  }

  _showPicker() async {
    var image =
        await ImagePicker.platform.pickImage(source: ImageSource.camera);
    setState(() {
      _image = File(image!.path);
    });
  }

  Future<void> updateMemberInfo() async {
    setState(() {
      _isLoading = true;
    });
    if (!await signup()) {
      showCupertinoDialog(
          context: context,
          builder: ((_) {
            return CupertinoAlertDialog(
              title: Text("Error"),
              content: Text("Failed to create user\n" + error),
              actions: [
                CupertinoDialogAction(
                    child: Text("OK"),
                    onPressed: (() {
                      Navigator.pop(_);
                    })),
              ],
            );
          }));
      return;
    }
    if (_image == null) {
      // showCupertinoDialog(
      //     context: context,
      //     builder: ((_) {
      //       return CupertinoAlertDialog(
      //         title: Text("Error"),
      //         content: Text("Please select an image"),
      //         actions: [
      //           CupertinoDialogAction(
      //               child: Text("OK"),
      //               onPressed: (() {
      //                 Navigator.pop(_);
      //               })),
      //         ],
      //       );
      //     }));
      // return;
    } else {
      var upload = await FileUploadHandler(
          "${_firstNameController.text}_${_lastNameController.text}_${_phoneNumberController.text}",
          _image!.path,
          token);
      if (!upload['error']) {
        showCupertinoDialog(
            context: context,
            builder: ((_) {
              return CupertinoAlertDialog(
                title: Text("Error"),
                content: Text("Failed to upload image"),
                actions: [
                  CupertinoDialogAction(
                      child: Text("OK"),
                      onPressed: (() {
                        Navigator.pop(_);
                      })),
                ],
              );
            }));
        return;
      }
    }
    var url = Uri.parse('https://backend.aurum.fitness/auth/update-member/');
    var request = await http.post(url, body: {
      'FirstName': _firstNameController.text,
      'LastName': _lastNameController.text,
      'phone': _phoneNumberController.text,
      'Address': "",
      'DOB': _dateController.text,
    }, headers: {
      'Authorization': 'Token $token',
    });
    print(request.body);
    if (request.body.contains('success')) {
      print("true");
      setState(() {
        _isLoading = false;
        showCupertinoDialog(
            context: context,
            builder: (_) {
              return CupertinoAlertDialog(
                title: Text('Payment Gateway'),
                content: Text('Do you want to accept payment too?'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.pop(_);
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text('Yes'),
                    onPressed: () {
                      Navigator.pop(_);
                      Navigator.push(context,
                          CupertinoPageRoute(builder: (context) {
                        return DynamicQrCode(
                            userid:
                                "${_firstNameController.text}_${_lastNameController.text}_${_phoneNumberController.text}");
                      }));
                    },
                  ),
                ],
              );
            });
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      showCupertinoDialog(
          context: context,
          builder: ((_) {
            return CupertinoAlertDialog(
              title: Text("Error"),
              content: Text("Failed to update user info"),
              actions: [
                CupertinoDialogAction(
                    child: Text("OK"),
                    onPressed: (() {
                      Navigator.pop(_);
                    })),
              ],
            );
          }));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Member Sign Up'),
        ),
        child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: new Container(
              width: 200.0,
              height: 200.0,
              child: _isLoading
                  ? Container(
                      child: Center(
                      child: CupertinoActivityIndicator(
                        radius: 20,
                      ),
                    ))
                  : new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Container(
                            width: MediaQuery.of(context).size.width - 80,
                            child: Column(children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width - 80,
                                child: Text(
                                  'Sign up \ninto your account',
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'SFPro',
                                      letterSpacing: 1,
                                      color: Colors.white),
                                ),
                                margin: EdgeInsets.only(bottom: 20),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(children: [
                                GestureDetector(
                                  onTap: () {
                                    _showPicker();
                                  },
                                  child: _image != null
                                      ? Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: FileImage(_image!),
                                                  fit: BoxFit.cover)),
                                        )
                                      : Icon(
                                          CupertinoIcons.person_alt_circle,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                ),
                              ]),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width - 80,
                                height: 70,
                                child: CupertinoTextField(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  placeholder: 'First name',
                                  controller: _firstNameController,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'SFPro',
                                      letterSpacing: 1,
                                      color: Colors.white),
                                  placeholderStyle: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'SFPro',
                                      letterSpacing: 1,
                                      color: Colors.white),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.white, width: 1))),
                                ),
                                margin: EdgeInsets.only(bottom: 20),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width - 80,
                                height: 70,
                                child: CupertinoTextField(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  placeholder: 'Last name',
                                  controller: _lastNameController,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'SFPro',
                                      letterSpacing: 1,
                                      color: Colors.white),
                                  placeholderStyle: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'SFPro',
                                      letterSpacing: 1,
                                      color: Colors.white),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.white, width: 1))),
                                ),
                                margin: EdgeInsets.only(bottom: 20),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width - 80,
                                height: 70,
                                child: CupertinoTextField(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  placeholder: 'Phone Number',
                                  keyboardType: TextInputType.number,
                                  controller: _phoneNumberController,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'SFPro',
                                      letterSpacing: 1,
                                      color: Colors.white),
                                  placeholderStyle: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'SFPro',
                                      letterSpacing: 1,
                                      color: Colors.white),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.white, width: 1))),
                                ),
                                margin: EdgeInsets.only(bottom: 20),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width - 80,
                                height: 70,
                                child: CupertinoTextField(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  placeholder: 'Gender',
                                  keyboardType: TextInputType.number,
                                  controller: _phoneNumberController,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'SFPro',
                                      letterSpacing: 1,
                                      color: Colors.white),
                                  placeholderStyle: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'SFPro',
                                      letterSpacing: 1,
                                      color: Colors.white),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.white, width: 1))),
                                ),
                                margin: EdgeInsets.only(bottom: 20),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width - 80,
                                height: 70,
                                child: CupertinoTextField(
                                  controller: _dateController,
                                  // enabled: false,
                                  prefix: Icon(
                                    Icons.calendar_today,
                                    color: Colors.white,
                                  ),
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
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.6,
                                            // Set white border to top
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              border: Border(
                                                top: BorderSide(
                                                  color: Colors.white,
                                                  width: 1.0,
                                                ),
                                              ),
                                            ),
                                            child: CupertinoDatePicker(
                                              backgroundColor: Colors.black,
                                              mode:
                                                  CupertinoDatePickerMode.date,
                                              initialDateTime: DateTime.now(),
                                              onDateTimeChanged:
                                                  (DateTime newDateTime) {
                                                setState(() {
                                                  var formatter =
                                                      new DateFormat(
                                                          'yyyy/MM/dd');
                                                  _dateController.text =
                                                      formatter
                                                          .format(newDateTime);
                                                  print(_dateController.text);
                                                });
                                              },
                                            ),
                                          );
                                        });
                                  },
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.white, width: 1))),
                                ),
                                margin: EdgeInsets.only(bottom: 20),
                              ),
                              _emailController.text.isNotEmpty ||
                                      _phoneNumberController.text.isNotEmpty ||
                                      _firstNameController.text.isNotEmpty ||
                                      _lastNameController.text.isNotEmpty ||
                                      _dateController.text.isNotEmpty
                                  ? Container(
                                      width: MediaQuery.of(context).size.width -
                                          80,
                                      height: 70,
                                      child: CupertinoButton(
                                        color: Colors.black,
                                        child: Text(
                                          'OK',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'SFPro',
                                              letterSpacing: 1,
                                              color: Colors.white),
                                        ),
                                        onPressed: () async {
                                          updateMemberInfo();
                                        },
                                      ),
                                      margin: EdgeInsets.only(bottom: 20),
                                    )
                                  : Container(),
                            ]),
                            margin: EdgeInsets.only(bottom: 20),
                          ),
                        ]),
            )));
  }
}
