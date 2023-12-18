import 'dart:async';
import 'dart:convert';
import 'package:aurumfit/components/failurepromptadpater.dart';
import 'package:aurumfit/domians/payments/Invoice.dart';
import 'package:aurumfit/domians/payments/models/Invoice.dart';
import 'package:aurumfit/domians/usermanagement/user_management.dart';
import 'package:aurumfit/pages/payments/components/InvoicingBlock.dart';
import 'package:aurumfit/pages/payments/components/payments_list.dart';
import 'package:aurumfit/providers/auth/authprovider.dart';
import 'package:billing/billing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  List users = [];
  String qrCode = "";
  String qrContent = "";
  String orderId = "";
  late Timer mytimer;
  String _userid = "";
  String result = "";
  String qrId = "";
  bool going = true;
  bool _loading = false;
  String token = "";
  late UserManagement userManagement;
  InvoiceModel? invoiceModel;
  bool bypass = false;
  bool multiple = false;
  List payments = [];

  @override
  void initState() {
    super.initState();
    token = ref.read(AuthTokenProvider.notifier).state;
    if (widget.userid != null) {
      _userid = widget.userid!;
      userManagement = UserManagement(userid: _userid, token: token);
      getUserInfo(_userid);
    } else {
      _userid = "";
    }
  }

  getUserInfo(_userid) async {
    setState(() {
      _loading = true;
    });
    try {
      var responseData = await userManagement.getUserInfo();
      setState(() {
        phone.text = responseData.Phone_number ?? "";
        name.text = responseData.name;
      });
      invoiceModel = await Invoice(userid: _userid).getInvoice(token);
      setState(() {
        this.invoiceModel = invoiceModel;
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      _loading = false;
    });
  }

  handlePayment() async {
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
      var invoiceID;
      if (!bypass) {
        invoiceID = invoiceModel != null
            ? invoiceModel!.InvoiceID
            : await Billing()
                .generateInvoice(
                    token,
                    BillingModel(
                      id: _userid,
                      plan: plan.text,
                      name: name.text,
                      phone: phone.text,
                      price: total.text,
                      duration: int.parse(months.text),
                      status: false,
                    ))
                .onError((error, stackTrace) => throw Exception("Error"));
      } else {
        invoiceID = "Bypass";
      }
      var data = {
        "user": _userid,
        "amount": amount.text,
        "plan": plan.text,
        "duration": months.text,
        "subtotal": total.text,
        "invoiceid": invoiceID,
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
                        "notes": {"order_ids": value['Order_id']}
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
                    setState(() {
                      qrCode = "";
                    });
                    showSuccessDialog(context);
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

  handlePaymentMultiple() async {
    var qrId = "";
    try {
      setState(() {
        _loading = true;
      });
      print("Making Payment");
      List ids = [];

      for (var i in payments) {
        var data = {
          "user": i.userid,
          "amount": i.amount,
          "plan": i.plan,
          "duration": i.duration,
          "subtotal": i.subtotal,
          "invoiceid": i.invoiceid,
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
              ids.add(value['Order_id']);
            });
      }
      var uri = Uri.parse("https://api.razorpay.com/v1/payments/qr_codes");
      // rzp_test_dpWU6ujgKpbthw:wpMjyFSqXGRcThUtOSuAAVGS
      await http
          .post(uri,
              headers: {
                'Authorization':
                    'Basic cnpwX2xpdmVfYzlEUlJKdzdqNjJ1R0c6WllpdDhkSHpLbUxkbjJUbllwdVEwVXls',
                // 'Basic cnpwX3Rlc3RfZHBXVTZ1amdLcGJ0aHc6d3BNanlGU3FYR1JjVGhVdE9TdUFBVkdT',
                'Content-Type': 'application/json'
              },
              body: json.encode({
                "type": "upi_qr",
                "name": _userid,
                "usage": "single_use",
                "fixed_amount": true,
                "payment_amount": payments.map((e) => e.amount).reduce(
                        (a, b) => (int.parse(a) + int.parse(b)).toString()) +
                    "00",
                "description": "Aurum Fitness",
                "notes": {
                  "order_ids": ids.join(","),
                }
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
            setState(() {
              qrCode = "";
            });
            showSuccessDialog(context);
          }
        });
      }
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
          trailing: GestureDetector(
            child: Icon(
              CupertinoIcons.flowchart,
              size: 24,
              color: multiple
                  ? CupertinoColors.activeBlue
                  : Colors.white.withOpacity(.4),
            ),
            onTap: () {
              setState(() {
                multiple = !multiple;
              });
            },
          ),
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
                    SizedBox(
                      height: 20,
                    ),
                    bypass
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showCupertinoDialog(
                                      context: context,
                                      builder: (_) {
                                        return CupertinoAlertDialog(
                                          title: Text(
                                            "Invoice Bypass",
                                            style:
                                                TextStyle(fontFamily: 'SFPro'),
                                          ),
                                          content: Text(
                                            "Cancel Invoice Bypass?",
                                            style:
                                                TextStyle(fontFamily: 'SFPro'),
                                          ),
                                          actions: [
                                            CupertinoDialogAction(
                                              child: Text("Cancel"),
                                              onPressed: () {
                                                Navigator.pop(_);
                                              },
                                            ),
                                            CupertinoDialogAction(
                                              child: Text(
                                                "Ok",
                                                style: TextStyle(
                                                    fontFamily: 'SFPro',
                                                    color: CupertinoColors
                                                        .systemGreen),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  bypass = false;
                                                });
                                                Navigator.pop(_);
                                              },
                                            )
                                          ],
                                        );
                                      });
                                },
                                child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: CupertinoColors.systemGrey,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.arrow_swap,
                                          color: CupertinoColors
                                              .darkBackgroundGray,
                                          size: 16,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "Invoice Bypass",
                                          style: TextStyle(
                                              fontFamily: 'SFPro',
                                              fontSize: 16,
                                              color: CupertinoColors
                                                  .darkBackgroundGray,
                                              decoration: TextDecoration.none,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    )),
                              ),
                            ],
                          )
                        : SizedBox(),
                    multiple ? PaymentsList(users: payments) : SizedBox(),
                    multiple
                        ? payments.length > 0
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CupertinoButton(
                                    child: Row(
                                      children: [
                                        Text("Continue"),
                                        Icon(
                                          CupertinoIcons.right_chevron,
                                          color: CupertinoColors.systemBlue,
                                        )
                                      ],
                                    ),
                                    onPressed: () {
                                      handlePaymentMultiple();
                                    },
                                  )
                                ],
                              )
                            : SizedBox()
                        : SizedBox(),
                    _userid != ""
                        ? Container(
                            margin: EdgeInsets.only(
                                top: 20, left: 20, right: 20, bottom: 20),
                            child: Row(
                              children: [
                                Text(
                                  _userid,
                                  style: TextStyle(
                                      fontFamily: 'SFPro',
                                      fontSize: 30,
                                      color: Colors.white,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.w200),
                                ),
                                CupertinoButton(
                                  child: Icon(
                                    CupertinoIcons.pen,
                                    color: CupertinoColors.inactiveGray,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _userid = "";
                                    });
                                  },
                                )
                              ],
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
                                                setState(() {
                                                  userManagement =
                                                      UserManagement(
                                                          userid: i[0],
                                                          token: token);
                                                });
                                                getUserInfo(i[0]);
                                              });
                                            },
                                          )
                                      ],
                                    )),
                              ]),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Slidable(
                        child: InvoicingBlock(
                          userid: _userid,
                          invoice: invoiceModel,
                        ),
                        endActionPane: ActionPane(
                          motion: ScrollMotion(),
                          children: [
                            SlidableAction(
                              label: 'Bypass',
                              icon: CupertinoIcons.arrow_swap,
                              onPressed: (context) {
                                showCupertinoDialog(
                                    context: context,
                                    builder: (_) {
                                      return CupertinoAlertDialog(
                                        title: Text(
                                          "Invoice Bypass",
                                          style: TextStyle(fontFamily: 'SFPro'),
                                        ),
                                        content: Text(
                                          "Are you sure you want to bypass Invoice for $_userid?",
                                          style: TextStyle(fontFamily: 'SFPro'),
                                        ),
                                        actions: [
                                          CupertinoDialogAction(
                                            child: Text("Cancel"),
                                            onPressed: () {
                                              Navigator.pop(_);
                                            },
                                          ),
                                          CupertinoDialogAction(
                                            child: Text(
                                              "Ok",
                                              style: TextStyle(
                                                  fontFamily: 'SFPro',
                                                  color: CupertinoColors
                                                      .destructiveRed),
                                            ),
                                            onPressed: () async {
                                              Navigator.pop(_);
                                              setState(() {
                                                bypass = true;
                                              });
                                            },
                                          )
                                        ],
                                      );
                                    });
                              },
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              borderRadius: BorderRadius.circular(10),
                              backgroundColor: CupertinoColors.systemRed,
                              foregroundColor: CupertinoColors.white,
                            ),
                          ],
                        ),
                      ),
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
                            child: Text(multiple ? "Add" : "Pay"),
                            onPressed: () async {
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
                                if (multiple) {
                                  setState(() {
                                    _loading = true;
                                  });
                                  var invoiceidtemp = invoiceModel != null
                                      ? invoiceModel!.InvoiceID
                                      : bypass
                                          ? "Bypass"
                                          : await Billing()
                                              .generateInvoice(
                                                  token,
                                                  BillingModel(
                                                    id: _userid,
                                                    plan: plan.text,
                                                    name: name.text,
                                                    phone: phone.text,
                                                    price: total.text,
                                                    duration:
                                                        int.parse(months.text),
                                                    status: false,
                                                  ))
                                              .onError((error, stackTrace) =>
                                                  throw Exception("Error"));
                                  setState(() {
                                    payments.add(paymentBlock(
                                        name: name.text,
                                        userid: _userid,
                                        plan: plan.text,
                                        duration: months.text,
                                        amount: amount.text,
                                        subtotal: total.text,
                                        invoiceid: invoiceidtemp));
                                  });
                                  // Clear all the handlers
                                  amount.clear();
                                  total.clear();
                                  plan.clear();
                                  months.clear();
                                  invoiceModel = null;
                                  setState(() {
                                    _loading = false;
                                  });
                                } else {
                                  handlePayment();
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

class paymentBlock {
  String name;
  String userid;
  String plan;
  String duration;
  String amount;
  String subtotal;
  String invoiceid;
  paymentBlock(
      {required this.name,
      required this.userid,
      required this.plan,
      required this.duration,
      required this.amount,
      required this.subtotal,
      required this.invoiceid});
}

void showSuccessDialog(context) {
  showDialog(context: context, builder: (context) => FunkyOverlay());
}

class FunkyOverlay extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FunkyOverlayState();
}

class FunkyOverlayState extends State<FunkyOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/greentick-unscreen.gif",
              ),
              // CupertinoButton.filled(
              //   child: Text("Receipt"),
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              // )
            ],
          )),
        ),
      ),
    );
  }
}
