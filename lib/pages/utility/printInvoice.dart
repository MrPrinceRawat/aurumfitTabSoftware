import 'dart:convert';

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class printInvoice extends StatefulWidget {
  const printInvoice({Key? key}) : super(key: key);

  @override
  _printInvoiceState createState() => _printInvoiceState();
}

class _printInvoiceState extends State<printInvoice> {
  var paymentMode = new TextEditingController()..text = "Cash";
  var plan = new TextEditingController()..text = "Lite";
  var months = new TextEditingController()..text = "1";
  var name = new TextEditingController();
  var phone = new TextEditingController();
  var price = new TextEditingController();
  var serverIp = new TextEditingController();
  var orderId = 0;
  var dueDate = new TextEditingController();
  var exDate = new TextEditingController();
  var subtotal = new TextEditingController();
  var userId = new TextEditingController();
  List users = [];
  var _loading = false;

  @override
  void dispose() {
    paymentMode.dispose();
    plan.dispose();
    months.dispose();
    name.dispose();
    phone.dispose();
    price.dispose();
    super.dispose();
  }

  bool CheckAllFilled() {
    if (name.text.isNotEmpty &&
        phone.text.isNotEmpty &&
        price.text.isNotEmpty &&
        subtotal.text.isNotEmpty &&
        userId.text.isNotEmpty)
      return true;
    else
      return false;
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

  Future<int> getOrderID() async {
    var ServerUrl =
        Uri.parse("https://backend.aurum.fitness/auth/CreateOrderForRazorPay/");
    Map orderData = {
      "user": userId.text,
      "amount": price.text,
      "plan": plan.text,
      "duration": months.text,
      "subtotal": subtotal.text
    };
    try {
      var response = await http.post(ServerUrl,
          headers: {
            "Authorization": "Token 38bc32c9730b26e11b45f640aaef804c00c0c325",
          },
          body: orderData);
      print(response.body);
      var jsonResponse = jsonDecode(response.body);
      if (response.body.contains("Order_id")) {
        setState(() {
          orderId = jsonResponse['Order_id'];
        });
        return jsonResponse['Order_id'];
      }
    } catch (e) {
      print(e);
      setState(() {
        _loading = false;
      });
    }
    return 0;
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

  // Make a future function to get the razorpay qr code
  Future getQR(orderid) async {
    var ServerUrl = Uri.parse("https://api.razorpay.com/v1/payments/qr_codes");
    var token = 'rzp_live_c9DRRJw7j62uGG:ZYit8dHzKmLdn2TnYpuQ0Uyl';
    // convert the token to base64
    var base64 = base64Encode(utf8.encode(token));
    Map data = {
      "type": "upi_qr",
      "name": name.text,
      "usage": "single_use",
      "fixed_amount": true,
      "payment_amount": "${price.text}00",
      "description": "Aurum Fitness",
      "notes": {"order_id": orderid}
    };

    try {
      var response = await http.post(ServerUrl,
          headers: {
            "Authorization": "Basic $base64",
            'Content-Type': 'application/json',
          },
          body: json.encode(data));
      print(response.body);
      var jsonResponse = jsonDecode(response.body);
      if (response.body.contains("image_url")) {
        // fetch the qr code from url
        var qrCode = Uri.parse(jsonResponse['image_url']);
        var response = await http.get(qrCode);
        print(response.body);
        return response.bodyBytes;
      }
    } catch (e) {
      print(e);
      setState(() {
        _loading = false;
      });
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
      print("No IP");
    } else {
      var url = Uri.parse("http://$ip:13687/printinvoice");
      var orderid = await getOrderID();

      if (orderId == 0) {
        return;
      }

      var qrCode = await getQR(orderid);

      Map<String, String> data = {
        "name": name.text,
        "number": phone.text,
        "invoiceno": orderId.toString(),
        "plan": "${plan.text} (${months.text} Months)",
        "price": price.text,
        'subtotal': subtotal.text,
        'dueDate': dueDate.text,
        'exDate': exDate.text,
      };
      // var body = json.encode(data);

      var response =
          http.MultipartFile.fromBytes('media', qrCode, filename: 'qr.png');

      var request = http.MultipartRequest("POST", url);
      request.files.add(response);
      request.fields.addAll(data);
      var streamedResponse = await request.send();
      streamedResponse.stream.transform(utf8.decoder).listen((value) {
        print(value);
        setState(() {
          _loading = false;
        });
      });
    }
  }

  fetch() async {
    Uri uri = Uri.parse(
        "https://static01.nyt.com/images/2021/09/14/science/07CAT-STRIPES/07CAT-STRIPES-mediumSquareAt3X-v2.jpg");
    var req = await http.get(uri);
    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest(
        "POST", Uri.parse("http://192.168.0.15:13687/printdoc"));
    var pic = http.MultipartFile.fromBytes("file", req.bodyBytes,
        filename: "cat.jpg");
    request.files.add(pic);
    var response = await request.send();

    //Get the response from the server
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    print(responseString);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            middle: Text('Print Invoice',
                style: TextStyle(
                    fontFamily: 'SFPro',
                    fontWeight: FontWeight.w600,
                    fontSize: 20)),
            trailing: _loading
                ? CupertinoActivityIndicator()
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text("Print",
                        style: TextStyle(fontFamily: "SFPro", fontSize: 18)),
                    onPressed: CheckAllFilled() ? Print : null)),
        child: SafeArea(
            child: _loading
                ? Container(
                    child: Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  )
                : Container(
                    color: CupertinoColors.systemGrey6,
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: ListView(children: <Widget>[
                      CupertinoFormSection.insetGrouped(
                        header: Text('User Info'),
                        children: [
                          CupertinoFormRow(
                              prefix: Text('User ID'),
                              child: CupertinoTextFormFieldRow(
                                onChanged: (value) {
                                  findUser(value);
                                },
                                controller: userId,
                                placeholder: 'user',
                              )),
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
                                          userId.text = i;
                                          getUserInfo(i);
                                          users = [];
                                        });
                                      },
                                    )
                                ],
                              )),
                          CupertinoFormRow(
                              prefix: Text('Name'),
                              child: CupertinoTextFormFieldRow(
                                controller: name,
                                placeholder: 'Name',
                              )),
                          CupertinoFormRow(
                              prefix: Text('Phone'),
                              child: CupertinoTextFormFieldRow(
                                controller: phone,
                                placeholder: '1122334455',
                                keyboardType: TextInputType.number,
                                keyboardAppearance: Brightness.dark,
                              )),
                        ],
                      ),
                      CupertinoFormSection.insetGrouped(
                        header: Text('Membership Info'),
                        children: [
                          CupertinoFormRow(
                              prefix: Text('Payment Mode'),
                              child: CupertinoTextFormFieldRow(
                                readOnly: true,
                                controller: paymentMode,
                                onTap: () {
                                  showCupertinoModalPopup(
                                      context: context,
                                      builder: (context) {
                                        return CupertinoActionSheet(
                                          title: Text('Payment Mode'),
                                          message: Text('Select Payment Mode'),
                                          actions: <Widget>[
                                            CupertinoActionSheetAction(
                                              isDefaultAction: true,
                                              child: Text('Cash'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                paymentMode.value =
                                                    TextEditingValue(
                                                        text: "Cash");
                                              },
                                            ),
                                            CupertinoActionSheetAction(
                                              child: Text('UPI'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                paymentMode.value =
                                                    TextEditingValue(
                                                        text: "UPI");
                                              },
                                            ),
                                          ],
                                          cancelButton:
                                              CupertinoActionSheetAction(
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
                              prefix: Text('Plan'),
                              child: CupertinoTextFormFieldRow(
                                readOnly: true,
                                controller: plan,
                                onTap: () {
                                  showCupertinoModalPopup(
                                      context: context,
                                      builder: (context) {
                                        return CupertinoActionSheet(
                                          title: Text('Plan'),
                                          message: Text('Select a Plan'),
                                          actions: <Widget>[
                                            CupertinoActionSheetAction(
                                              isDefaultAction: true,
                                              child: Text('Lite'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                plan.value = TextEditingValue(
                                                    text: "Lite");
                                              },
                                            ),
                                            CupertinoActionSheetAction(
                                              child: Text('Mid'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                plan.value = TextEditingValue(
                                                    text: "Mid");
                                              },
                                            ),
                                            CupertinoActionSheetAction(
                                              child: Text('Premium'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                plan.value = TextEditingValue(
                                                    text: "Premium");
                                              },
                                            ),
                                          ],
                                          cancelButton:
                                              CupertinoActionSheetAction(
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
                              prefix: Text('Duration'),
                              child: CupertinoTextFormFieldRow(
                                readOnly: true,
                                controller: months,
                                onTap: () {
                                  showCupertinoModalPopup(
                                      context: context,
                                      builder: (context) {
                                        return CupertinoActionSheet(
                                          title: Text('Duration'),
                                          message:
                                              Text('Select the plan duration'),
                                          actions: <Widget>[
                                            CupertinoActionSheetAction(
                                              isDefaultAction: true,
                                              child: Text('1'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                months.value =
                                                    TextEditingValue(text: "1");
                                              },
                                            ),
                                            CupertinoActionSheetAction(
                                              child: Text('3'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                months.value =
                                                    TextEditingValue(text: "3");
                                              },
                                            ),
                                            CupertinoActionSheetAction(
                                              child: Text('6'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                months.value =
                                                    TextEditingValue(text: "6");
                                              },
                                            ),
                                          ],
                                          cancelButton:
                                              CupertinoActionSheetAction(
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
                              prefix: Text('Due Date'),
                              child: CupertinoTextFormFieldRow(
                                controller: dueDate,
                                keyboardType: TextInputType.datetime,
                              )),
                          CupertinoFormRow(
                              prefix: Text('Expering Date'),
                              child: CupertinoTextFormFieldRow(
                                  controller: exDate)),
                        ],
                      ),
                      CupertinoFormSection.insetGrouped(
                          header: Text(
                            "Pricing Info",
                            style: TextStyle(fontFamily: 'SFPro'),
                          ),
                          children: [
                            CupertinoFormRow(
                                prefix: Text('Subtotal'),
                                child: CupertinoTextFormFieldRow(
                                  controller: subtotal,
                                  keyboardType: TextInputType.number,
                                )),
                            CupertinoFormRow(
                                prefix: Text('Price'),
                                child: CupertinoTextFormFieldRow(
                                  controller: price,
                                  keyboardType: TextInputType.number,
                                )),
                          ]),
                    ]))));
  }
}
