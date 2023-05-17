import 'dart:convert';
import 'dart:io';
import 'package:aurumfit/components/failurepromptadpater.dart';
import 'package:aurumfit/domians/storage/fileHandling.dart';
import 'package:aurumfit/domians/usermanagement/serverRelated.dart';
import 'package:aurumfit/providers/auth/authprovider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../domians/usermanagement/serverRelated.dart';

class PrintRecipt extends ConsumerStatefulWidget {
  const PrintRecipt({Key? key}) : super(key: key);

  @override
  _PrintReciptState createState() => _PrintReciptState();
}

class _PrintReciptState extends ConsumerState<PrintRecipt> {
  String paymentModeInt = "Cash";
  var plan = new TextEditingController()..text = "Lite";
  int monthsInt = 1;
  var name = new TextEditingController();
  var phone = new TextEditingController();
  var price = new TextEditingController();
  var serverIp = new TextEditingController();
  var orderId = 0;
  var subtotal = new TextEditingController();
  var userId = new TextEditingController();
  var startDate = new TextEditingController();
  List users = [];
  var _loading = false;
  var alreadyPaid = 0;
  var serverStatus = "F";
  var ip = "";
  var updSocket;
  var printableAvailable = false;
  var autoPrintLoading = false;
  String token = "";

  @override
  void initState() {
    // initServer();
    token = ref.read(AuthTokenProvider.notifier).state;
  }

  printAll() async {
    setState(() {
      autoPrintLoading = true;
    });
    var bills = await fetchforPendingPrintables();
    if (bills.length > 0) {
      var printQueue = "";
      for (var i = 0; i < bills.length; i++) {
        var currentElement = bills[i];
        printQueue += "\n" + currentElement["name"];
      }
      var choice = false;
      await showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text("Print queue"),
              content: Text(printQueue),
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
                    choice = true;
                  },
                )
              ],
            );
          });
      if (choice) {
        for (var i = 0; i < bills.length; i++) {
          var currentElement = bills[i];
          var vpa = currentElement["paymentmode"];
          print(currentElement["name"]);
          String MembershipDuration =
              (int.parse(currentElement["months"]) / 30).toString();
          Map dataToSend = {
            "name": currentElement["name"],
            "number": currentElement["number"],
            "price": currentElement["price"],
            "paymentmode": vpa,
            "plan": currentElement["plan"] + "($MembershipDuration months)",
            "months": currentElement["name"],
            "invoiceno": currentElement["invoiceno"],
            "subtotal": currentElement["subtotal"]
          };
          await PrintGlobal(dataToSend);
          await markAsPrinted(currentElement["invoiceno"].toString(), token);
        }
      }
      setState(() {
        autoPrintLoading = false;
        printableAvailable = false;
      });
    }
  }

  @override
  void dispose() {
    plan.dispose();
    name.dispose();
    phone.dispose();
    price.dispose();
    if (updSocket != null) updSocket.close();
    super.dispose();
  }

  initServer() async {
    var ipGot = await getServerIp();
    if (ipGot == "") {
      await scanForServer();
    } else {
      if (await checkServerStatus(ipGot) == true) {
        setState(() {
          ip = ipGot;
        });
      } else {
        scanForServer();
      }
    }
    if (await checkforPendingPrintables()) {
      setState(() {
        printableAvailable = true;
      });
    }
  }

  Future<bool> checkServerStatus(checkIp) async {
    print(checkIp);
    var url = Uri.parse("http://$checkIp:13687/");
    var status = false;
    try {
      await http.get(url).then((value) {
        status = true;
      }).catchError((err) {
        print(err);
        status = false;
      });
    } catch (e) {
      print(e);
      status = false;
    }
    return status;
  }

  Future<void> scanForServer() async {
    setState(() {
      serverStatus = "S";
    });
    print("Scanning for server!!");
    var addressesIListenFrom = InternetAddress.anyIPv4;
    int portIListenOn = 50000; //0 is random
    var data = "Hello, World";
    var codec = new Utf8Codec();
    List<int> dataToSend = codec.encode(data);
    await RawDatagramSocket.bind(addressesIListenFrom, portIListenOn)
        .then((RawDatagramSocket udpSocket) {
      setState(() {
        updSocket = udpSocket;
      });
      udpSocket.timeout(Duration(seconds: 5), onTimeout: (event) {
        setState(() {
          serverStatus = "NF";
        });
        udpSocket.close();
      }).listen((RawSocketEvent event) async {
        if (event == RawSocketEvent.read) {
          Datagram? dg = udpSocket.receive();
          if (dg == null) return;
          var serverIp = dg.address.address;
          if (serverIp != "") {
            print(serverIp);
            var statusCheck = await checkServerStatus(serverIp);
            if (statusCheck) {
              setState(() {
                ip = serverIp;
                serverStatus = "F";
              });
              saveServerIp(serverIp);
            }
            print("Status Check " + statusCheck.toString());
            udpSocket.close();
          }
        }
      });
    });
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
      "Authorization": "Token $token",
    });
    print((response.body));
    setState(() {
      users = jsonDecode(response.body);
    });
  }

  Future<int> getOrderID(int type) async {
    // Check orderid exists

    var CheckUrl =
        Uri.parse("https://backend.aurum.fitness/auth/checkorderid/");
    Map checkData = {
      "user": userId.text,
      "amount": price.text,
    };
    try {
      var response = await http.post(CheckUrl,
          headers: {
            "Authorization": "Token $token",
          },
          body: checkData);
      var jsonResponse = jsonDecode(response.body);
      if (response.body.contains("OK")) {
        var invoiceID = await http.post(
            Uri.parse("https://backend.aurum.fitness/payments/createInvoice/"),
            body: json.encode(
              {
                "user": userId.text,
                "subtotal": subtotal.text,
                "plan": plan.text,
                "duration": monthsInt.toString(),
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
          return 0;
        }
        // Create ORDERID
        // var ServerUrl =
        //     Uri.parse("http://127.0.0.1:8000/auth/order/" + type.toString());
        var ServerUrl = Uri.parse(
            "https://backend.aurum.fitness/auth/order/" + type.toString());
        Map orderData = {
          "user": userId.text,
          "amount": price.text,
          "plan": plan.text,
          "duration": monthsInt.toString(),
          "subtotal": subtotal.text,
          "method": paymentModeInt,
          "start": startDate.text,
          'msgNumber': phone.text,
          "invoiceid": json.decode(invoiceID.body)['InvoiceID'],
        };
        try {
          var response = await http.post(ServerUrl,
              headers: {
                "Authorization": "Token $token",
              },
              body: orderData);
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse.containsKey("Order_id")) {
            setState(() {
              orderId = jsonResponse['Order_id'];
            });
            return jsonResponse['Order_id'];
          } else {
            showCupertinoDialog(
                context: context,
                builder: (_) {
                  return CupertinoAlertDialog(
                    title: Text("Error"),
                    content: Text(jsonResponse),
                    actions: [
                      CupertinoDialogAction(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(_);
                        },
                      )
                    ],
                  );
                });
            return 0;
          }
        } catch (e) {
          print(e);
          setState(() {
            _loading = false;
          });
        }
        return 0;
      } else {
        var invoiceID = await http.post(
            Uri.parse("https://backend.aurum.fitness/payments/createInvoice/"),
            body: json.encode(
              {
                "user": userId.text,
                "subtotal": subtotal.text,
                "plan": plan.text,
                "duration": monthsInt.toString(),
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
          return 0;
        }
        await showCupertinoDialog(
            context: context,
            builder: (_) {
              return CupertinoAlertDialog(
                title: Text("Order Already Exists!"),
                content: Text("Order " +
                    jsonResponse["ID"].toString() +
                    " for user " +
                    userId.text +
                    " already exists on " +
                    jsonResponse["date"]),
                actions: [
                  CupertinoDialogAction(
                    child: Text(
                      "Use this",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      setState(() {
                        orderId = jsonResponse["ID"];
                      });
                      Navigator.pop(_);
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text("Create Anyway"),
                    onPressed: () async {
                      Navigator.pop(_);
                      // Create ORDERID
                      var ServerUrl = Uri.parse(
                          "https://backend.aurum.fitness/auth/order/" +
                              type.toString());
                      Map orderData = {
                        "user": userId.text,
                        "amount": price.text,
                        "plan": plan.text,
                        "duration": monthsInt.toString(),
                        "subtotal": subtotal.text,
                        "method": paymentModeInt,
                        "start": startDate.text,
                        'msgNumber': phone.text,
                        "invoiceid": json.decode(invoiceID.body)['InvoiceID'],
                      };
                      print(orderData);
                      try {
                        var response = await http.post(ServerUrl,
                            headers: {
                              "Authorization": "Token $token",
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
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: CupertinoColors.destructiveRed),
                    ),
                    onPressed: () {
                      Navigator.pop(_);
                    },
                  ),
                ],
              );
            });
        return 0;
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
        "purpose": "bill",
      }, headers: {
        "Authorization": "Token $token",
      });
      final Map<String, dynamic> responseData = json.decode(response.body);

      print(responseData);
      setState(() {
        phone.text = responseData["phone"];
        name.text = responseData["name"];
        alreadyPaid = responseData["totalPayableAmount"];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print(e);
    }
  }

  Future<void> printRecept() async {
    setState(() {
      _loading = true;
    });
    var url = Uri.parse("http://$ip:13687/printrecipt");
    var orderid = await getOrderID(1);
    if (orderid == 0) {
      setState(() {
        _loading = false;
      });
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text("Failed"),
              content: Text("Printing Failed, Invalid Orderid"),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.pop(_);
                  },
                )
              ],
            );
          });
      return;
    }
    var metric = plan.text == "T-Shirt"
        ? "(${monthsInt.toString()} Units)"
        : "(${monthsInt.toString()} months)";
    Map data = {
      "name": name.text,
      "number": phone.text,
      "price": subtotal.text == alreadyPaid.toString()
          ? alreadyPaid
          : (alreadyPaid + int.parse(price.text)).toString(),
      "paymentmode": paymentModeInt,
      "plan": plan.text + metric,
      "months": monthsInt.toString(),
      "invoiceno": orderId,
      "subtotal": subtotal.text,
      "start": startDate.text,
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
              content: Text("Updated but not printed!"),
              actions: <Widget>[
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

  Future<void> save() async {
    setState(() {
      _loading = true;
    });
    var orderid = await getOrderID(0);
    if (orderid == 0) {
      setState(() {
        _loading = false;
      });
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text("Failed"),
              content: Text("Printing Failed, Invalid Orderid"),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.pop(_);
                  },
                )
              ],
            );
          });
      return;
    }
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text("Saved"),
            content: Text("User Info Saved to be printed later"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("Ok"),
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
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            middle: Text('Print Recipt',
                style: TextStyle(
                    fontFamily: 'SFPro',
                    fontWeight: FontWeight.w600,
                    fontSize: 20)),
            trailing: _loading
                ? CupertinoActivityIndicator()
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text("Save",
                        style: TextStyle(fontFamily: "SFPro", fontSize: 18)),
                    onPressed: CheckAllFilled() ? save : null)),
        child: SafeArea(
            child: _loading
                ? Container(
                    child: Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  )
                : Container(
                    // color: CupertinoColors.systemGrey6,
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: ListView(children: <Widget>[
                      serverStatus == "S"
                          ? Container(
                              margin: EdgeInsets.only(top: 10),
                              width: MediaQuery.of(context).size.width,
                              height: 100,
                              decoration: BoxDecoration(
                                  color: CupertinoColors.darkBackgroundGray,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CupertinoActivityIndicator(),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Scanning for Server...",
                                      style: TextStyle(
                                          fontFamily: 'SFPro',
                                          letterSpacing: 0,
                                          fontSize: 20),
                                    )
                                  ]),
                            )
                          : SizedBox(),
                      serverStatus == "NF"
                          ? Container(
                              margin: EdgeInsets.only(top: 10),
                              width: MediaQuery.of(context).size.width,
                              height: 100,
                              decoration: BoxDecoration(
                                  color: CupertinoColors.darkBackgroundGray,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.exclamationmark_triangle,
                                      color: CupertinoColors.systemYellow,
                                      size: 25,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Print Server Offline!",
                                      style: TextStyle(
                                          fontFamily: 'SFPro',
                                          letterSpacing: 0,
                                          fontSize: 20),
                                    )
                                  ]),
                            )
                          : SizedBox(),
                      printableAvailable
                          ? Container(
                              margin: EdgeInsets.only(top: 10),
                              width: MediaQuery.of(context).size.width,
                              height: 100,
                              decoration: BoxDecoration(
                                  color: CupertinoColors.darkBackgroundGray,
                                  borderRadius: BorderRadius.circular(20)),
                              child: autoPrintLoading
                                  ? Center(
                                      child: CupertinoActivityIndicator(),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                          Icon(
                                            CupertinoIcons.square_stack_fill,
                                            color: CupertinoColors.activeBlue,
                                            size: 25,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            "Bills Available to Print",
                                            style: TextStyle(
                                                fontFamily: 'SFPro',
                                                letterSpacing: 0,
                                                fontSize: 20),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          serverStatus == "F"
                                              ? CupertinoButton(
                                                  child: Text("Print All"),
                                                  onPressed: () {
                                                    printAll();
                                                  })
                                              : Text(
                                                  "Get Server Online to Print All",
                                                  style: TextStyle(
                                                      color: CupertinoColors
                                                          .systemGrey),
                                                )
                                        ]))
                          : SizedBox(),
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
                                      child: Text(i[0]),
                                      onPressed: () {
                                        setState(() {
                                          userId.text = i[0];
                                          getUserInfo(i[0]);
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
                            child: CupertinoSlidingSegmentedControl(
                                children: <String, Widget>{
                                  "Cash": Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        'Cash',
                                        style: TextStyle(
                                            fontFamily: "SFPro",
                                            color: CupertinoColors.black),
                                      )),
                                  "UPI": Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        'UPI',
                                        style: TextStyle(
                                            fontFamily: "SFPro",
                                            color: CupertinoColors.black),
                                      )),
                                },
                                groupValue: paymentModeInt,
                                onValueChanged: (String? i) {
                                  setState(() {
                                    paymentModeInt = i ?? "Cash";
                                  });
                                }),
                          ),
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
                                            CupertinoActionSheetAction(
                                              child: Text('PT'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                plan.value = TextEditingValue(
                                                    text: "PT");
                                              },
                                            ),
                                            CupertinoActionSheetAction(
                                              child: Text('T-Shirt'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                plan.value = TextEditingValue(
                                                    text: "T-Shirt");
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
                            child: CupertinoSlidingSegmentedControl(
                                children: <int, Widget>{
                                  1: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        '1',
                                        style: TextStyle(
                                            fontFamily: "SFPro",
                                            color: CupertinoColors.black),
                                      )),
                                  3: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        '3',
                                        style: TextStyle(
                                            fontFamily: "SFPro",
                                            color: CupertinoColors.black),
                                      )),
                                  6: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        '6',
                                        style: TextStyle(
                                            fontFamily: "SFPro",
                                            color: CupertinoColors.black),
                                      )),
                                  12: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        '12',
                                        style: TextStyle(
                                            fontFamily: "SFPro",
                                            color: CupertinoColors.black),
                                      )),
                                },
                                groupValue: monthsInt,
                                onValueChanged: (int? i) {
                                  setState(() {
                                    monthsInt = i ?? 1;
                                  });
                                }),
                          ),
                          CupertinoFormRow(
                              prefix: Text('Start Date'),
                              child: CupertinoTextFormFieldRow(
                                controller: startDate,
                                keyboardType: TextInputType.datetime,
                              )),
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
                                prefix: Text('Paying Amount'),
                                child: CupertinoTextFormFieldRow(
                                  controller: price,
                                  keyboardType: TextInputType.number,
                                )),
                          ]),
                      SizedBox(
                        height: 20,
                      ),
                      // CupertinoButton(
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Icon(CupertinoIcons.add),
                      //         Text("Add More"),
                      //       ],
                      //     ),
                      //     onPressed: () {
                      //       var metric = plan.text == "T-Shirt"
                      //           ? "(${monthsInt.toString()} Units)"
                      //           : "(${monthsInt.toString()} months)";
                      //       PushQueue({
                      //         "name": name.text,
                      //         "number": phone.text,
                      //         "price": subtotal.text == alreadyPaid.toString()
                      //             ? alreadyPaid
                      //             : (alreadyPaid + int.parse(price.text))
                      //                 .toString(),
                      //         "paymentmode": paymentModeInt,
                      //         "plan": plan.text + metric,
                      //         "months": monthsInt.toString(),
                      //         "invoiceno": orderId,
                      //         "subtotal": subtotal.text
                      //       });
                      //     })
                    ]))));
  }
}
