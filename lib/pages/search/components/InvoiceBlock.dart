import 'package:aurumfit/domians/payments/models/Invoice.dart';
import 'package:aurumfit/pages/payments/components/InvoiceDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvoiceBlock extends StatelessWidget {
  const InvoiceBlock(
      {Key? key,
      required this.userid,
      required this.token,
      required this.invoice})
      : super(key: key);

  final String userid;
  final String token;
  final InvoiceModel? invoice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            border: Border.all(
                color: invoice!.paid ? Colors.green : Colors.red, width: 2),
            borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: CupertinoColors.darkBackgroundGray,
              borderRadius: invoice!.payments.length > 0
                  ? BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))
                  : BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/icon/pdf.png",
                      width: 45,
                      height: 45,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice!.InvoiceID,
                          style: TextStyle(
                              fontFamily: 'SFPro',
                              fontSize: 16,
                              color: CupertinoColors.lightBackgroundGray,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          invoice!.date,
                          style: TextStyle(
                              fontFamily: 'SFPro',
                              fontSize: 14,
                              color: CupertinoColors.inactiveGray,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      invoice!.paid ? "Paid" : "Unpaid",
                      style: TextStyle(
                          fontFamily: 'SFPro',
                          fontSize: 16,
                          color: invoice!.paid
                              ? CupertinoColors.activeGreen
                              : CupertinoColors.destructiveRed,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    CupertinoButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => InvoiceDetails(
                                      invoice: invoice!,
                                      userid: userid,
                                    )));
                      },
                      child: Text(
                        "View",
                        style: TextStyle(
                            fontFamily: 'SFPro',
                            fontSize: 16,
                            color: CupertinoColors.activeBlue,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          //loop through the dict of invoice payments
          Container(
            width: MediaQuery.of(context).size.width,
            height: 2,
            child: Row(children: [
              Container(
                width: ((MediaQuery.of(context).size.width - 64) *
                            (invoice!.amount_paid / invoice!.amount)) >
                        0
                    ? ((MediaQuery.of(context).size.width - 64) *
                        (invoice!.amount_paid / invoice!.amount))
                    : 0,
                color: Color.fromARGB(255, 0, 217, 255),
              ),
            ]),
          ),
          ListView.builder(
              shrinkWrap: true,
              itemCount: invoice!.payments.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        invoice!.payments.entries
                            .elementAt(index)
                            .value["date"],
                        style: TextStyle(
                            fontFamily: 'SFPro',
                            color: Color.fromRGBO(226, 226, 226, .94),
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        "₹ " +
                            invoice!.payments.entries
                                .elementAt(index)
                                .value["amount"]
                                .toString(),
                        style: TextStyle(
                            fontFamily: 'SFPro',
                            color: Color.fromRGBO(226, 226, 226, .94),
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                );
              })
        ]),
      ),
    );
  }
}
