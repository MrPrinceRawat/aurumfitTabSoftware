import 'package:flutter/cupertino.dart';

class PaymentHistoryBlock extends StatefulWidget {
  const PaymentHistoryBlock({Key? key, required this.data}) : super(key: key);

  final data;

  @override
  State<PaymentHistoryBlock> createState() => _PaymentHistoryBlockState();
}

class _PaymentHistoryBlockState extends State<PaymentHistoryBlock> {
  bool expanded = false;
  late List data;

  @override
  void initState() {
    data = widget.data;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            // Loop through the data and display the payment history
            for (var index = 0; index < data.length; index++)
              StatefulBuilder(
                builder: (context, setState) {
                  return GestureDetector(
                    onTap: (() {
                      setState(() {
                        expanded = expanded ? false : true;
                      });
                    }),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 50,
                        height: expanded
                            ? MediaQuery.of(context).size.height / 5
                            : MediaQuery.of(context).size.height / 10,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: data[index]["additional_info"]
                                        ["bill_printed"]
                                    ? CupertinoColors.systemGreen
                                    : CupertinoColors.inactiveGray,
                                width: 2),
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Row(children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 15.0, right: 20),
                              child: Text(
                                data[index]["months"],
                                style: TextStyle(
                                    fontFamily: 'SFPro',
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: data[index]["additional_info"]
                                            ["bill_printed"]
                                        ? CupertinoColors.systemGreen
                                        : CupertinoColors.inactiveGray),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.74,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(data[index]["type"],
                                              style: TextStyle(
                                                fontFamily: 'SFPro',
                                                fontSize: 18,
                                              )),
                                          Text(data[index]["date"],
                                              style: TextStyle(
                                                  fontFamily: 'SFPro',
                                                  fontSize: 16,
                                                  color: CupertinoColors
                                                      .inactiveGray)),
                                        ],
                                      ),
                                      Text("₹" + data[index]["amount"],
                                          style: TextStyle(
                                            fontFamily: 'SFPro',
                                            fontSize: 18,
                                          )),
                                    ],
                                  ),
                                ),
                                expanded
                                    ? SizedBox(
                                        height: 15,
                                      )
                                    : SizedBox(
                                        height: 0,
                                      ),
                                expanded
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.74,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                                width: 1.0,
                                                color: CupertinoColors
                                                    .inactiveGray),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        data[index][
                                                                "additional_info"]
                                                            ["VPA"],
                                                        style: TextStyle(
                                                            fontFamily: 'SFPro',
                                                            fontSize: 16,
                                                            color: CupertinoColors
                                                                .inactiveGray)),
                                                    Text(
                                                        "#" +
                                                            data[index]["id"]
                                                                .toString(),
                                                        style: TextStyle(
                                                            fontFamily: 'SFPro',
                                                            fontSize: 16,
                                                            color: CupertinoColors
                                                                .inactiveGray)),
                                                  ],
                                                ),
                                                Text(
                                                    "₹" +
                                                        data[index]["additional_info"]
                                                                ["subtotal"]
                                                            .toString(),
                                                    style: TextStyle(
                                                        fontFamily: 'SFPro',
                                                        fontSize: 16,
                                                        color: CupertinoColors
                                                            .inactiveGray)),
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    : SizedBox(height: 0)
                              ],
                            ),
                          ]),
                        ),
                      ),
                    ),
                  );
                },
              )
          ],
        ));
    ;
  }
}
