import 'dart:async';
import 'dart:convert';
import 'package:aurumfit/components/failurepromptadpater.dart';
import 'package:aurumfit/providers/auth/authprovider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DynamicQrCode extends ConsumerStatefulWidget {
  const DynamicQrCode({Key? key, this.userid}) : super(key: key);

  final String? userid;

  @override
  _DynamicQrCodeState createState() => _DynamicQrCodeState();
}

class _DynamicQrCodeState extends ConsumerState<DynamicQrCode> {
  var amount = TextEditingController();
  var total = TextEditingController();
  var months = TextEditingController();
  var plan = TextEditingController();
  var name = TextEditingController();
  var phone = TextEditingController();
  var old = TextEditingController();
  List users = [];
  String qrCode = "";
  String orderId = "";
  late Timer mytimer;
  String? _userid;
  String result = "";
  String qrId = "";
  bool going = true;
  bool _loading = false;
  var paymentType = "Partial Payment";
  String token = "";

  @override
  void initState() {
    super.initState();
    token = ref.read(AuthTokenProvider.notifier).state;
    if (widget.userid != null) {
      _userid = widget.userid;
      getUserInfo(_userid);
    } else {
      _userid = "";
    }
  }

  getUserInfo(_userid) async {
    setState(() {
      _loading = true;
    });
    Uri url = Uri.parse("https://backend.aurum.fitness/auth/getUserInfoStaff/");
    try {
      final http.Response response = await http.post(url, body: {
        "userid": _userid,
      }, headers: {
        "Authorization": "Token $token",
      });
      final Map<String, dynamic> responseData = json.decode(response.body);

      print(responseData);
      setState(() {
        phone.text = responseData["phone"];
        old.text = (responseData["alreadyPaid"] ?? 0).toString();
        total.text = (responseData["totalPayableAmount"] ?? 0).toString();
        plan.text = responseData["plan"] ?? "Lite";
        months.text =
            (int.parse(responseData["duration"] == "None" ? "30" : "30") / 30)
                .round()
                .toString();
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

  Future<void> Print() async {
    setState(() {
      _loading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('print_server_ip') ?? "";
    print(ip);
    if (ip == "") {
      setState(() {
        _loading = false;
      });
    } else {
      var url = Uri.parse("http://$ip:13687");
      Map data = {
        "name": name.text,
        "number": phone.text,
        "price": (int.parse(amount.text) + int.parse(old.text)).toString(),
        "paymentmode": "UPI",
        "plan": plan.text + "(${months.text} months)",
        "months": months.text,
        "invoiceno": orderId,
        "subtotal": total.text
      };
      var body = json.encode(data);
      var response = await http.post(url, body: body, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      });
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
        });
        showCupertinoDialog(
            context: context,
            builder: (_) {
              return CupertinoAlertDialog(
                title: Text("Success"),
                content: Text("Printing Successful"),
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
        setState(() {
          _loading = false;
        });
        showCupertinoDialog(
            context: context,
            builder: (_) {
              return CupertinoAlertDialog(
                title: Text("Error"),
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
      }
    }
  }

  makePayment() async {
    var qrId = "";
    try {
      setState(() {
        _loading = true;
      });
      print("Making Payment");
      var PM = "";
      await showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text('Payment Mode'),
              content: Text(
                  'Do you Want a Link or Qr code?\n\nIf you want a link, please select "Link"\n\nIf you want a qr code, please select "Qr code"'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('Link'),
                  onPressed: () {
                    Navigator.pop(context);
                    PM = "Link";
                  },
                ),
                CupertinoDialogAction(
                  child: Text('Qr Code'),
                  onPressed: () {
                    Navigator.pop(context);
                    PM = "Qr Code";
                  },
                )
              ],
            );
          });
      var data = {
        "user": _userid,
        "amount": amount.text,
        "plan": plan.text,
        "duration": months.text,
        "subtotal": total.text,
        "invoiceid": ""
      };
      var url = Uri.parse(
          "https://backend.aurum.fitness/auth/CreateOrderForRazorPay/");
      var body = json.encode(data);
      await http
          .post(url, body: body, headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token'
          })
          .then((value) => json.decode(value.body))
          .then((value) async {
            print(value);
            if (PM == "Qr Code") {
              print("QR Code");
              var uri =
                  Uri.parse("https://api.razorpay.com/v1/payments/qr_codes");
              await http
                  .post(uri,
                      headers: {
                        'Authorization':
                            'Basic cnpwX2xpdmVfYzlEUlJKdzdqNjJ1R0c6WllpdDhkSHpLbUxkbjJUbllwdVEwVXls',
                        'Content-Type': 'application/json'
                      },
                      body: json.encode({
                        "type": "upi_qr",
                        "name": _userid,
                        "usage": "single_use",
                        "fixed_amount": true,
                        "payment_amount": amount.text + "00",
                        "description": "Aurum Fitness",
                        "notes": {"order_id": value['Order_id']}
                      }))
                  .then((value) => json.decode(value.body))
                  .then((value) {
                print(value);
                qrId = value['id'];
                qrCode = value['image_url'];
                setState(() {
                  _loading = false;
                });
              });
              while (going) {
                await Future.delayed(Duration(seconds: 2));
                print("Checking");
                await verifyPayment(qrId).then((value) {
                  if (value) {
                    print("Payment Successful");
                    setState(() {
                      _loading = false;
                    });
                    going = false;
                    showCupertinoDialog(
                        context: context,
                        builder: (_) {
                          return CupertinoAlertDialog(
                            title: Text("Success"),
                            content: Text("Payment Successful"),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: Text("Ok"),
                                onPressed: () {
                                  setState(() {
                                    qrCode = "";
                                  });
                                  Navigator.pop(_);
                                },
                              )
                            ],
                          );
                        });
                  }
                });
              }
            } else if (PM == "Link") {
              print("Link");
              var uri = Uri.parse("https://api.razorpay.com/v1/payment_links/");
              await http
                  .post(uri,
                      headers: {
                        'Authorization':
                            'Basic cnpwX2xpdmVfYzlEUlJKdzdqNjJ1R0c6WllpdDhkSHpLbUxkbjJUbllwdVEwVXls',
                        'Content-Type': 'application/json'
                      },
                      body: json.encode({
                        "upi_link": "true",
                        "amount": int.parse("${amount.text}00"),
                        "currency": "INR",
                        "accept_partial": false,
                        "description": "Payment for order id " +
                            value['Order_id'].toString(),
                        "customer": {
                          "name": name.text,
                          "contact": "+91" + phone.text,
                        },
                        "notify": {
                          "sms": true,
                          "email": false,
                          "whatsapp": true,
                        },
                        "reminder_enable": true,
                        "notes": {"order_id": value['Order_id']},
                        "callback_url":
                            "https://backend.aurum.fitness/signup?&payment_status=success&status_message=Success",
                        "callback_method": "get"
                      }))
                  .then((value) => json.decode(value.body))
                  .then((value) {
                print(value);
                var link = value['short_url'];
                print(link);
                // Create a cupertino alert dialog
                showCupertinoDialog(
                    context: context,
                    builder: (_) {
                      return CupertinoAlertDialog(
                        title: Text("Payment Link"),
                        content: Text(link),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: const Text('Ok'),
                            onPressed: () {
                              Navigator.pop(_);
                            },
                          )
                        ],
                      );
                    });
                setState(() {
                  _loading = false;
                });
              });
            }
          });
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
      showErrorDialog(context, e.toString());
      setState(() {
        _loading = false;
      });
    }
  }

  handleNewMembership() async {
    var qrId = "";
    try {
      setState(() {
        _loading = true;
      });
      print("Making Payment");
      var PM = "";
      await showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text('Payment Mode'),
              content: Text(
                  'Do you Want a Link or Qr code?\n\nIf you want a link, please select "Link"\n\nIf you want a qr code, please select "Qr code"'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('Link'),
                  onPressed: () {
                    Navigator.pop(context);
                    PM = "Link";
                  },
                ),
                CupertinoDialogAction(
                  child: Text('Qr Code'),
                  onPressed: () {
                    Navigator.pop(context);
                    PM = "Qr Code";
                  },
                )
              ],
            );
          });
      var invoiceID = await http.post(
          Uri.parse("https://backend.aurum.fitness/payments/createInvoice/"),
          body: json.encode(
            {
              "user": _userid,
              "subtotal": total.text,
              "plan": plan.text,
              "duration": months.text,
              "status": false,
              "payments": {}
            },
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token'
          });
      if (!json.decode(invoiceID.body)['success']) {
        showErrorDialog(context, json.decode(invoiceID.body)['error']);
        setState(() {
          _loading = false;
        });
        return;
      }
      var data = {
        "user": _userid,
        "amount": amount.text,
        "plan": plan.text,
        "duration": months.text,
        "subtotal": total.text,
        "invoiceid": json.decode(invoiceID.body)['InvoiceID'],
      };
      var url = Uri.parse(
          "https://backend.aurum.fitness/auth/CreateOrderForRazorPay/");
      var body = json.encode(data);
      await http
          .post(url, body: body, headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token'
          })
          .then((value) => json.decode(value.body))
          .then((value) async {
            print(value);
            if (PM == "Qr Code") {
              print("QR Code");
              var uri =
                  Uri.parse("https://api.razorpay.com/v1/payments/qr_codes");
              await http
                  .post(uri,
                      headers: {
                        'Authorization':
                            'Basic cnpwX2xpdmVfYzlEUlJKdzdqNjJ1R0c6WllpdDhkSHpLbUxkbjJUbllwdVEwVXls',
                        'Content-Type': 'application/json'
                      },
                      body: json.encode({
                        "type": "upi_qr",
                        "name": _userid,
                        "usage": "single_use",
                        "fixed_amount": true,
                        "payment_amount": amount.text + "00",
                        "description": "Aurum Fitness",
                        "notes": {"order_id": value['Order_id']}
                      }))
                  .then((value) => json.decode(value.body))
                  .then((value) {
                print(value);
                qrId = value['id'];
                qrCode = value['image_url'];
                setState(() {
                  _loading = false;
                });
              });
              while (going) {
                await Future.delayed(Duration(seconds: 2));
                print("Checking");
                await verifyPayment(qrId).then((value) {
                  if (value) {
                    print("Payment Successful");
                    setState(() {
                      _loading = false;
                    });
                    going = false;
                    showCupertinoDialog(
                        context: context,
                        builder: (_) {
                          return CupertinoAlertDialog(
                            title: Text("Success"),
                            content: Text("Payment Successful"),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: Text("Ok"),
                                onPressed: () {
                                  setState(() {
                                    qrCode = "";
                                  });
                                  Navigator.pop(_);
                                },
                              )
                            ],
                          );
                        });
                  }
                });
              }
            } else if (PM == "Link") {
              print("Link");
              var uri = Uri.parse("https://api.razorpay.com/v1/payment_links/");
              await http
                  .post(uri,
                      headers: {
                        'Authorization':
                            'Basic cnpwX2xpdmVfYzlEUlJKdzdqNjJ1R0c6WllpdDhkSHpLbUxkbjJUbllwdVEwVXls',
                        'Content-Type': 'application/json'
                      },
                      body: json.encode({
                        "upi_link": "true",
                        "amount": int.parse("${amount.text}00"),
                        "currency": "INR",
                        "accept_partial": false,
                        "description": "Payment for order id " +
                            value['Order_id'].toString(),
                        "customer": {
                          "name": name.text,
                          "contact": "+91" + phone.text,
                        },
                        "notify": {
                          "sms": true,
                          "email": false,
                          "whatsapp": true,
                        },
                        "reminder_enable": true,
                        "notes": {"order_id": value['Order_id']},
                        "callback_url":
                            "https://backend.aurum.fitness/signup?&payment_status=success&status_message=Success",
                        "callback_method": "get"
                      }))
                  .then((value) => json.decode(value.body))
                  .then((value) {
                print(value);
                var link = value['short_url'];
                print(link);
                // Create a cupertino alert dialog
                showCupertinoDialog(
                    context: context,
                    builder: (_) {
                      return CupertinoAlertDialog(
                        title: Text("Payment Link"),
                        content: Text(link),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: const Text('Ok'),
                            onPressed: () {
                              Navigator.pop(_);
                            },
                          )
                        ],
                      );
                    });
                setState(() {
                  _loading = false;
                });
              });
            }
          });
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
      showErrorDialog(context, e.toString());
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> findUser(entered) async {
    // Make a POST request to aurumfitnesscommunicator.ml to get the user list
    var url = Uri.parse('https://backend.aurum.fitness/auth/getUser/');
    var response = await http.post(url, body: {
      'name': entered
    }, headers: {
      "Authorization": "Token $token",
    });
    print((response.body));
    setState(() {
      users = jsonDecode(response.body);
    });
  }

  verifyPayment(id) async {
    bool status = false;
    var req = await http.get(
        Uri.parse("https://api.razorpay.com/v1/payments/qr_codes/$id/payments"),
        headers: {
          'Authorization':
              'Basic cnpwX2xpdmVfYzlEUlJKdzdqNjJ1R0c6WllpdDhkSHpLbUxkbjJUbllwdVEwVXls'
        });
    var response = jsonDecode(req.body);
    return status = response['count'] > 0;
  }

  @override
  void dispose() {
    super.dispose();
    going = false;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        // backgroundColor: Colors.grey[200],
        navigationBar: CupertinoNavigationBar(
          middle: Text('Dynamic QR Code'),
        ),
        child: _loading
            ? Container(
                child: Center(
                child: CupertinoActivityIndicator(
                  radius: 20,
                ),
              ))
            : qrCode.isEmpty
                ? Container(
                    child: ListView(children: [
                    _userid != ""
                        ? Container(
                            margin: EdgeInsets.only(
                                top: 40, left: 20, right: 20, bottom: 20),
                            child: Text(
                              _userid!,
                              style: TextStyle(
                                  fontFamily: 'SFPro',
                                  fontSize: 30,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w200),
                            ),
                          )
                        : CupertinoFormSection.insetGrouped(
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
                                            child: Text(i[0]),
                                            onPressed: () {
                                              setState(() {
                                                _userid = i[0];
                                                users = [];
                                                getUserInfo(i[0]);
                                              });
                                            },
                                          )
                                      ],
                                    )),
                              ]),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: CupertinoSlidingSegmentedControl(
                          children: <String, Widget>{
                            "Partial Payment": Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'Partial Payment',
                                  style: TextStyle(
                                      fontFamily: "SFPro",
                                      color: CupertinoColors.black),
                                )),
                            "New Membership": Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'New Membership',
                                  style: TextStyle(
                                      fontFamily: "SFPro",
                                      color: CupertinoColors.black),
                                )),
                          },
                          groupValue: paymentType,
                          onValueChanged: (String? i) {
                            setState(() {
                              paymentType = i ?? "Partial Payment";
                            });
                          }),
                    ),
                    CupertinoFormSection.insetGrouped(
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
                            prefix: Text('Already Paid'),
                            child: CupertinoTextFormFieldRow(
                              controller: old,
                              placeholder: 'Enter Already Paid Amount',
                            ),
                          ),
                        ]),
                    CupertinoFormSection
                        .insetGrouped(header: Text('Plan Details'), children: [
                      CupertinoFormRow(
                          prefix: Text('Plan'),
                          child: CupertinoTextFormFieldRow(
                            controller: plan,
                            placeholder: 'plan',
                            readOnly: true,
                            onTap: () {
                              showCupertinoModalPopup(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoActionSheet(
                                      title: Text('Select plan'),
                                      actions: <Widget>[
                                        CupertinoActionSheetAction(
                                          child: Text(
                                            'Lite',
                                            style:
                                                TextStyle(fontFamily: 'SFPro'),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              plan.text = 'Lite';
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        CupertinoActionSheetAction(
                                          child: Text(
                                            'Mid',
                                            style:
                                                TextStyle(fontFamily: 'SFPro'),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              plan.text = 'Mid';
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        CupertinoActionSheetAction(
                                          child: Text(
                                            'Premium',
                                            style:
                                                TextStyle(fontFamily: 'SFPro'),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              plan.text = 'Premium';
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        CupertinoActionSheetAction(
                                          child: Text(
                                            'T-Shirt',
                                            style:
                                                TextStyle(fontFamily: 'SFPro'),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              plan.text = 'T-Shirt';
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                      cancelButton: CupertinoActionSheetAction(
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    );
                                  });
                            },
                          )),
                      CupertinoFormRow(
                        prefix: Text('Months'),
                        child: CupertinoTextFormFieldRow(
                          controller: months,
                          placeholder: 'Months',
                          readOnly: true,
                          onTap: () {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (context) {
                                  return CupertinoActionSheet(
                                    title: Text('Select Months'),
                                    actions: <Widget>[
                                      CupertinoActionSheetAction(
                                        child: Text(
                                          '1',
                                          style: TextStyle(fontFamily: 'SFPro'),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            months.text = '1';
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      CupertinoActionSheetAction(
                                        child: Text(
                                          '3',
                                          style: TextStyle(fontFamily: 'SFPro'),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            months.text = '3';
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      CupertinoActionSheetAction(
                                        child: Text(
                                          '6',
                                          style: TextStyle(fontFamily: 'SFPro'),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            months.text = '6';
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      CupertinoActionSheetAction(
                                        child: Text(
                                          '12',
                                          style: TextStyle(fontFamily: 'SFPro'),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            months.text = '12';
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  );
                                });
                          },
                        ),
                      )
                    ]),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          CupertinoFormSection.insetGrouped(
                              header: Text('Payment Details'),
                              children: [
                                CupertinoFormRow(
                                  prefix: Text(
                                    'Paying Amount',
                                    style: TextStyle(fontFamily: 'SFPro'),
                                  ),
                                  child: CupertinoTextFormFieldRow(
                                    controller: amount,
                                    style: TextStyle(fontFamily: 'SFPro'),
                                    // decoration: BoxDecoration(
                                    //   color: CupertinoColors.black,
                                    //   borderRadius: BorderRadius.circular(10),
                                    // ),
                                    placeholder: 'Price',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                CupertinoFormRow(
                                    prefix: Text("Total Amount",
                                        style: TextStyle(fontFamily: 'SFPro')),
                                    child: CupertinoTextFormFieldRow(
                                      style: TextStyle(fontFamily: 'SFPro'),
                                      // decoration: BoxDecoration(
                                      //   color: CupertinoColors.white,
                                      //   borderRadius: BorderRadius.circular(10),
                                      // ),
                                      placeholder: 'Total',
                                      keyboardType: TextInputType.number,
                                      controller: total,
                                    )),
                              ]),
                          CupertinoButton(
                            child: Text('Pay'),
                            onPressed: () {
                              if (amount.text.isEmpty ||
                                  total.text.isEmpty ||
                                  plan.text.isEmpty ||
                                  months.text.isEmpty) {
                                showCupertinoDialog(
                                    context: context,
                                    builder: (context) {
                                      return CupertinoAlertDialog(
                                        title: Text('Error'),
                                        content: Text('Please fill all fields'),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            child: Text('Ok'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          )
                                        ],
                                      );
                                    });
                              } else {
                                if (paymentType == "Partial Payment") {
                                  makePayment();
                                } else {
                                  handleNewMembership();
                                }
                              }
                            },
                          )
                        ],
                      ),
                    )
                  ]))
                : Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: Image.network(qrCode),
                    ),
                  ));
  }
}
