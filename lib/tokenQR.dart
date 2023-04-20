import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TokenQR extends StatefulWidget {
  const TokenQR({Key? key}) : super(key: key);

  @override
  _TokenQRState createState() => _TokenQRState();
}

class _TokenQRState extends State<TokenQR> {
  var userController = TextEditingController();
  List users = [];
  String? _userid;
  String _token = "";
  bool _loading = false;

  getUserToken(name) async {
    setState(() {
      _loading = true;
    });
    var url = 'https://backend.aurum.fitness/api/getUserToken/';
    var response = await http.post(Uri.parse(url), body: {
      'username': name
    }, headers: {
      "Authorization": "Token 38bc32c9730b26e11b45f640aaef804c00c0c325",
    });
    print(response.body);
    var data = json.decode(response.body);
    if (data['status'] == 'success') {
      setState(() {
        _token = data['Key'];
      });
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> findUser(entered) async {
    // Make a POST request to aurumfitnesscommunicator.ml to get the user list
    var url = Uri.parse('https://backend.aurum.fitnessss/auth/getUser/');
    var response = await http.post(url, body: {
      'name': entered
    }, headers: {
      "Authorization": "Token 38bc32c9730b26e11b45f640aaef804c00c0c325",
    });
    setState(() {
      users = jsonDecode(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          middle: Text('Token QR',
              style:
                  TextStyle(color: CupertinoColors.white, fontFamily: "SFPro")),
        ),
        child: SafeArea(
            child: _token == ""
                ? _loading
                    ? Center(child: CupertinoActivityIndicator(radius: 15.0))
                    : Container(
                        color: CupertinoColors.systemGroupedBackground,
                        margin: EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            CupertinoFormSection.insetGrouped(children: [
                              CupertinoFormRow(
                                  prefix: Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Text('Token QR',
                                        style: TextStyle(
                                            color: CupertinoColors.black,
                                            fontFamily: "SFPro",
                                            fontSize: 16)),
                                  ),
                                  child: CupertinoTextFormFieldRow(
                                    textAlign: TextAlign.left,
                                    controller: userController,
                                    onChanged: (value) {
                                      findUser(value);
                                    },
                                  ))
                            ]),
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
                                            getUserToken(i);
                                          });
                                        },
                                      )
                                  ],
                                )),
                          ],
                        ),
                      )
                : Center(
                    child: QrImage(
                      data: "https://aurum.fitness/settoken?token=" + _token,
                      version: QrVersions.auto,
                      size: 200.0,
                      foregroundColor: CupertinoColors.black,
                    ),
                  )));
  }
}
