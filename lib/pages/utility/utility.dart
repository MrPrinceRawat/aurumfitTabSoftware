import 'dart:convert';
import 'package:aurumfit/pages/payments/bill_user.dart';
import 'package:aurumfit/pages/payments/Subscription.dart';
import 'package:aurumfit/components/galary.dart';
import 'package:aurumfit/pages/payments/createInvoice.dart';
import 'package:aurumfit/pages/payments/dynamicPayment.dart';
import 'package:aurumfit/pages/utility/AFS.dart';
import 'package:aurumfit/pages/utility/printInvoice.dart';
import 'package:aurumfit/pages/utility/tokenQR.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Utility extends StatefulWidget {
  const Utility({Key? key}) : super(key: key);

  @override
  _UtilityState createState() => _UtilityState();
}

class _UtilityState extends State<Utility> {
  bool _showAppbar = true;
  ScrollController _scrollBottomBarController = new ScrollController();
  bool isScrollingDown = false;
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
                                    builder: (context) => BillUser()));
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
                              CupertinoIcons.doc,
                              color: Color(0xffffffff),
                            ),
                          ),
                          title: Text(
                            "Create Invoice",
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
                                    builder: (context) => CreateUserInvoice()));
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
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => CalcAFS()));
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
