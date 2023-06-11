import 'package:aurumfit/domians/payments/models/Invoice.dart';
import 'package:aurumfit/pages/payments/components/InvoicingBlock.dart';
import 'package:aurumfit/pages/payments/components/add_payment_to_invoice.dart';
import 'package:aurumfit/pages/payments/components/changeDate.dart';
import 'package:aurumfit/providers/auth/authprovider.dart';
import 'package:billing/billing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class InvoiceDetails extends ConsumerWidget {
  const InvoiceDetails({Key? key, required this.invoice, required this.userid})
      : super(key: key);

  final InvoiceModel invoice;
  final String userid;

  @override
  Widget build(BuildContext buildcontent, WidgetRef ref) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            middle: Text(
              "Invoice Details",
              style:
                  TextStyle(fontFamily: "SFPro", color: CupertinoColors.white),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                showCupertinoModalPopup(
                    context: buildcontent,
                    builder: (context) {
                      return CupertinoActionSheet(
                        actions: [
                          CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                              Billing().toggleInvoicePaymentStatus(
                                  !invoice.paid,
                                  invoice.InvoiceID,
                                  ref.read(AuthTokenProvider.notifier).state,
                                  BillingModel(id: invoice.InvoiceID));
                              Navigator.pop(buildcontent);
                            },
                            child: Text(
                              "Toggle Payment Status",
                              style: TextStyle(
                                  fontFamily: "SFPro",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) =>
                                          AddPaymentsToInvoice(
                                            invoice: invoice,
                                            userid: userid,
                                          )));
                            },
                            child: Text(
                              "Add Payments to Invoice",
                              style: TextStyle(
                                  fontFamily: "SFPro",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () async {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => ChangeInvoiceDate(
                                            invoice: invoice,
                                            userid: userid,
                                          )));
                            },
                            child: Text(
                              "Change Payment Date",
                              style: TextStyle(
                                  fontFamily: "SFPro",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () async {
                              Navigator.pop(context);
                              showCupertinoDialog(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      title: Text("Mark Invoice Expired"),
                                      content: Text(
                                          "Are you sure you want to mark this invoice as expired? This action cannot be undone."),
                                      actions: [
                                        CupertinoDialogAction(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Cancel"),
                                        ),
                                        CupertinoDialogAction(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await Billing().markInvoiceExpired(
                                                invoice.InvoiceID,
                                                ref
                                                    .read(AuthTokenProvider
                                                        .notifier)
                                                    .state,
                                                BillingModel(
                                                    id: invoice.InvoiceID));
                                            Navigator.pop(buildcontent);
                                          },
                                          child: Text("Mark Expired"),
                                        )
                                      ],
                                    );
                                  });
                            },
                            child: Text(
                              "Mark Invoice Expired",
                              style: TextStyle(
                                  fontFamily: "SFPro",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: CupertinoColors.destructiveRed),
                            ),
                          ),
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                                fontFamily: "SFPro",
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      );
                    });
              },
              child: Icon(
                CupertinoIcons.ellipsis_circle,
                color: CupertinoColors.inactiveGray,
              ),
            )),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  InvoicingBlock(
                    userid: userid,
                    invoice: invoice,
                    showDetails: false,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Invoice Details",
                    style: TextStyle(
                        fontFamily: "SFPro",
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CupertinoFormSection.insetGrouped(
                    margin: EdgeInsets.all(0),
                    children: [
                      CupertinoFormRow(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        prefix: Text(
                          "Invoice ID",
                          style: TextStyle(
                              fontFamily: "SFPro",
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        child: Text(
                          invoice.InvoiceID,
                          style: TextStyle(
                              fontFamily: "SFPro",
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      CupertinoFormRow(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        prefix: Text(
                          "Plan",
                          style: TextStyle(
                              fontFamily: "SFPro",
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        child: Text(
                          invoice.plan,
                          style: TextStyle(
                              fontFamily: "SFPro",
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      CupertinoFormRow(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        prefix: Text(
                          "Subtotal",
                          style: TextStyle(
                              fontFamily: "SFPro",
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        child: Text(
                          "₹ " + invoice.amount.toString(),
                          style: TextStyle(
                              fontFamily: "SFPro",
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      CupertinoFormRow(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        prefix: Text(
                          "Amount Paid",
                          style: TextStyle(
                              fontFamily: "SFPro",
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        child: Text(
                          "₹ " + invoice.amount_paid.toString(),
                          style: TextStyle(
                              fontFamily: "SFPro",
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      CupertinoFormRow(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        prefix: Text(
                          "Duration",
                          style: TextStyle(
                              fontFamily: "SFPro",
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        child: Text(
                          invoice.duration.toString() + " Months",
                          style: TextStyle(
                              fontFamily: "SFPro",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: CupertinoColors.white),
                        ),
                      ),
                      CupertinoFormRow(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        prefix: Text(
                          "Created At",
                          style: TextStyle(
                              fontFamily: "SFPro",
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        child: Text(
                          invoice.date,
                          style: TextStyle(
                              fontFamily: "SFPro",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: CupertinoColors.white),
                        ),
                      ),
                      CupertinoFormRow(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        prefix: Text(
                          "Expiry Date",
                          style: TextStyle(
                              fontFamily: "SFPro",
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        child: Text(
                          invoice.expiry_date,
                          style: TextStyle(
                              fontFamily: "SFPro",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: CupertinoColors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Payments",
                    style: TextStyle(
                        fontFamily: "SFPro",
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  invoice.payments.length > 0
                      ? CupertinoFormSection.insetGrouped(
                          margin: EdgeInsets.all(0),
                          children: invoice.payments.entries
                              .map((e) => CupertinoFormRow(
                                    padding: EdgeInsets.only(
                                        left: 10,
                                        right: 20,
                                        bottom: 14,
                                        top: 14),
                                    prefix: Row(
                                      children: [
                                        e.value.containsKey("method")
                                            ? e.value["method"] == "cash"
                                                ? Container(
                                                    height: 40,
                                                    width: 40,
                                                    decoration: BoxDecoration(
                                                        color: CupertinoColors
                                                            .white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Icon(
                                                      CupertinoIcons
                                                          .money_dollar_circle,
                                                      color: CupertinoColors
                                                          .activeGreen,
                                                    ),
                                                  )
                                                : Icon(
                                                    CupertinoIcons
                                                        .creditcard_fill,
                                                    color: CupertinoColors
                                                        .activeBlue,
                                                  )
                                            : Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                    color: CupertinoColors
                                                        .lightBackgroundGray,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                child: Icon(
                                                  CupertinoIcons
                                                      .money_dollar_circle,
                                                  color: CupertinoColors.black,
                                                  size: 30,
                                                ),
                                              ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              e.value["date"],
                                              style: TextStyle(
                                                  fontFamily: "SFPro",
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              e.key,
                                              style: TextStyle(
                                                  fontFamily: "SFPro",
                                                  fontSize: 14,
                                                  color: CupertinoColors
                                                      .inactiveGray,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      "₹ " + e.value["amount"].toString(),
                                      style: TextStyle(
                                          fontFamily: "SFPro",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ))
                              .toList())
                      : Center(
                          child: Text(
                            "No Payments",
                            style: TextStyle(
                                fontFamily: "SFPro",
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        )
                ],
              ),
            ),
          ),
        ));
  }
}
