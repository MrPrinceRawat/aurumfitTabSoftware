import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aurumfit/components/failurepromptadpater.dart';
import 'package:aurumfit/domians/storage/fileHandling.dart';
import 'package:aurumfit/domians/usermanagement/serverRelated.dart';
import 'package:aurumfit/pages/payments/components/InvoicingBlock.dart';
import 'package:aurumfit/providers/auth/authprovider.dart';
import 'package:billing/billing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../domians/usermanagement/serverRelated.dart';

class CreateUserInvoice extends ConsumerStatefulWidget {
  const CreateUserInvoice({Key? key}) : super(key: key);

  @override
  _CreateUserInvoiceState createState() => _CreateUserInvoiceState();
}

class _CreateUserInvoiceState extends ConsumerState<CreateUserInvoice> {
  var plan = new TextEditingController()..text = "Lite";
  int monthsInt = 1;
  var name = new TextEditingController();
  var phone = new TextEditingController();
  var price = new TextEditingController();
  var userId = new TextEditingController();
  var userid = "";
  List users = [];
  var _loading = false;
  var alreadyPaid = 0;
  String token = "";
  var latestInvoice = {};
  Timer? _debounce;

  @override
  void initState() {
    // initServer();
    token = ref.read(AuthTokenProvider.notifier).state;
    super.initState();
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

    _debounce = Timer(Duration(milliseconds: 500), () {
      findUser(searchText);
    });
  }

  bool CheckAllFilled() {
    if (name.text.isNotEmpty &&
        phone.text.isNotEmpty &&
        price.text.isNotEmpty &&
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

  save() async {
    setState(() {
      _loading = true;
    });
    Billing billing = new Billing();
    BillingModel billingModel = new BillingModel(
      id: userId.text,
      name: name.text,
      phone: phone.text,
      plan: plan.text,
      duration: monthsInt,
      price: price.text,
    );
    try {
      print("Getting latest invoice / Creating new invoice");
      await billing
          .generateInvoice(token, billingModel)
          .then((value) => showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                    title: Text("Invoice Generated"),
                    content: Text("Invoice Generated Successfully"),
                    actions: [
                      CupertinoDialogAction(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  )))
          .onError((error, stackTrace) => showErrorDialog(
              context, "Something went wrong " + error.toString()));
    } catch (e) {
      print(e);
      showErrorDialog(context, "Something went wrong");
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            middle: Text('Billing',
                style: TextStyle(
                    fontFamily: 'SFPro',
                    fontWeight: FontWeight.w600,
                    fontSize: 20)),
            trailing: _loading
                ? CupertinoActivityIndicator()
                : SizedBox(
                    width: 0,
                  )),
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
                      name.text != ""
                          ? Padding(
                              padding: const EdgeInsets.only(
                                top: 20,
                                left: 20,
                                right: 20,
                              ),
                              child: InvoicingBlock(
                                userid: userId.text,
                              ))
                          : SizedBox(),
                      CupertinoFormSection.insetGrouped(
                        header: Text('User Info'),
                        children: [
                          CupertinoFormRow(
                              prefix: Text('User ID'),
                              child: CupertinoTextFormFieldRow(
                                onChanged: (value) {
                                  _onSearchTextChanged(value);
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
                                          userid = i[0];
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
                              prefix: Text('Price'),
                              child: CupertinoTextFormFieldRow(
                                keyboardType: TextInputType.number,
                                controller: price,
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CupertinoButton.filled(
                          padding: EdgeInsets.zero,
                          child: Text("Generate Invoice",
                              style: TextStyle(
                                  fontFamily: "SFPro",
                                  fontSize: 18,
                                  color: CupertinoColors.white)),
                          onPressed: () {
                            if (CheckAllFilled() == false) {
                              showErrorDialog(
                                  context, "Please fill all fields");
                            } else {
                              save();
                            }
                          },
                        ),
                      )
                    ]))));
  }
}
