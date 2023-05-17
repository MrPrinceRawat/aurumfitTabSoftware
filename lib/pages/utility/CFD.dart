import 'package:aurumfit/pages/settings/changebg.dart';
import 'package:aurumfit/pages/settings/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CFD extends StatefulWidget {
  const CFD({Key? key}) : super(key: key);

  @override
  State<CFD> createState() => _CFDState();
}

class _CFDState extends State<CFD> {
  @override
  void initState() {
    super.initState();
    _loadIp();
  }

  String ip = "";

  Future<void> _loadIp() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ip = prefs.getString('print_server_ip') ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
          child: Container(
        // color: CupertinoColors.systemGrey6,
        padding: EdgeInsets.only(left: 30, right: 30, top: 50),
        child: ListView(
          children: [
            Container(
              child: Text(
                "Settings",
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                    fontFamily: 'SFPro',
                    letterSpacing: 1.5),
              ),
            ),
            Container(
                // height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                  // color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.only(top: 20),
                // padding: EdgeInsets.only(top: 10),
                child: Material(
                    color: Colors.transparent,
                    child: CupertinoFormSection.insetGrouped(
                        margin: EdgeInsets.all(10),
                        backgroundColor: Colors.transparent,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.only(
                                left: 30, right: 30, bottom: 20, top: 20),
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
                              "Print Recipt",
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
                                      builder: (context) => PrintServer()));
                            },
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.only(
                                left: 30, right: 30, bottom: 20, top: 20),
                            leading: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Color(0xff2ca3c7),
                                  border: Border.fromBorderSide(BorderSide(
                                      color: Color(0xff2ca3c7), width: 2)),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Icon(
                                CupertinoIcons.photo_on_rectangle,
                                color: Color(0xffffffff),
                              ),
                            ),
                            title: Text(
                              "Change Default Background",
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
                                          changeDefaultBackground()));
                            },
                          ),
                        ])))
          ],
        ),
      )),
    );
  }
}
