import 'package:aurumfit/domians/payments/models/Invoice.dart';
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
              width: MediaQuery.of(context).size.width,
              height: 70,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(26, 26, 26, 0.933),
                  borderRadius: invoice!.payments.length > 0
                      ? BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))
                      : BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/icon/pdf.png",
                          width: 36,
                          height: 36,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          invoice!.InvoiceID,
                          style: TextStyle(
                              fontFamily: 'SFPro',
                              color: Color.fromRGBO(226, 226, 226, .94),
                              fontSize: 15,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Text(
                      "₹ " + invoice!.amount.toString(),
                      style: TextStyle(
                          color: Color.fromRGBO(226, 226, 226, .94),
                          fontFamily: 'SFPro',
                          fontSize: 15,
                          letterSpacing: .5,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              )),
          //loop through the dict of invoice payments
          Container(
            width: MediaQuery.of(context).size.width,
            height: 2,
            child: Row(children: [
              Container(
                width: (MediaQuery.of(context).size.width *
                            (invoice!.amount_paid / invoice!.amount)) >
                        0
                    ? (MediaQuery.of(context).size.width *
                            (invoice!.amount_paid / invoice!.amount)) -
                        64
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
