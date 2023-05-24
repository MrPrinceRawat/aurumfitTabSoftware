import 'dart:convert';

import 'package:aurumfit/domians/payments/models/models.dart';
import 'package:aurumfit/pages/payments/components/InvoicingBlock.dart';
import 'package:aurumfit/providers/auth/authprovider.dart';
import 'package:billing/billing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class AddPaymentsToInvoice extends ConsumerStatefulWidget {
  const AddPaymentsToInvoice({
    Key? key,
    required this.userid,
    required this.invoice,
  }) : super(key: key);

  final InvoiceModel? invoice;
  final String userid;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPaymentsToInvoiceState();
}

class _AddPaymentsToInvoiceState extends ConsumerState<AddPaymentsToInvoice> {
  List payments = [];
  bool loading = false;
  String error = "";

  var token;
  List<int> selectedPayments = [];

  Future loadPaymentHistory() async {
    var url = 'https://backend.aurum.fitness/api/getPaymentHistoryStaff/';
    var token = ref.read(AuthTokenProvider.notifier).state;
    var response = await http.post(Uri.parse(url),
        body: json.encode({
          'name': widget.userid,
        }),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        });
    var data = json.decode(response.body);
    if (data["error"]) {
      throw Exception(data["message"]);
    }
    if (data.length > 0) {
      data = data["data"];
      return data;
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
      token = ref.read(AuthTokenProvider.notifier).state;
    });
    loadPaymentHistory().then((value) {
      print(value);
      setState(() {
        payments = value;
        loading = false;
      });
    }).catchError((e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    });
  }

  add() async {
    setState(() {
      loading = true;
    });
    Billing billing = Billing();
    selectedPayments.forEach((element) {
      var payment = payments[element];
      billing.addPayments(widget.invoice!.InvoiceID, payment["id"].toString(),
          int.parse(payment["amount"]), token, BillingModel(id: widget.userid));
    });
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            "Add Payments",
            style: TextStyle(fontFamily: 'SFPro', color: CupertinoColors.white),
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text(
              "Add",
              style: TextStyle(
                  fontFamily: 'SFPro', color: CupertinoColors.activeBlue),
            ),
            onPressed: () async {
              await add();
              Navigator.pop(context);
            },
          ),
        ),
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            SizedBox(
              height: 20,
            ),
            InvoicingBlock(
              userid: widget.userid,
              invoice: widget.invoice,
              showDetails: false,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Payments",
                  style: TextStyle(
                      fontFamily: 'SFPro',
                      fontSize: 26,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            loading
                ? CupertinoActivityIndicator()
                : error != ""
                    ? Text(
                        error,
                        style: TextStyle(
                            color: CupertinoColors.destructiveRed,
                            fontFamily: 'SFPro'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: payments.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                if (selectedPayments.contains(index)) {
                                  setState(() {
                                    selectedPayments.remove(index);
                                  });
                                } else {
                                  setState(() {
                                    selectedPayments.add(index);
                                  });
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: selectedPayments.contains(index)
                                            ? CupertinoColors.activeBlue
                                            : CupertinoColors.inactiveGray,
                                        width: 2),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              activeColor:
                                                  CupertinoColors.activeBlue,
                                              overlayColor: MaterialStateColor
                                                  .resolveWith((states) =>
                                                      Colors.transparent),
                                              side: BorderSide(
                                                  color: CupertinoColors
                                                      .inactiveGray,
                                                  width: 2),
                                              value: selectedPayments
                                                  .contains(index),
                                              onChanged: (value) {
                                                if (selectedPayments
                                                    .contains(index)) {
                                                  setState(() {
                                                    selectedPayments
                                                        .remove(index);
                                                  });
                                                } else {
                                                  setState(() {
                                                    selectedPayments.add(index);
                                                  });
                                                }
                                              }),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                payments[index]["id"]
                                                    .toString(),
                                                style: TextStyle(
                                                    fontFamily: 'SFPro',
                                                    fontSize: 18,
                                                    color:
                                                        CupertinoColors.white,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Text(
                                                payments[index]["date"],
                                                style: TextStyle(
                                                    fontFamily: 'SFPro',
                                                    fontSize: 14,
                                                    color: CupertinoColors
                                                        .inactiveGray,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "₹ ${payments[index]["amount"].toString()}",
                                        style: TextStyle(
                                            fontFamily: 'SFPro',
                                            fontSize: 18,
                                            color: CupertinoColors.white,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
          ]),
        )),
      ),
    );
  }
}
