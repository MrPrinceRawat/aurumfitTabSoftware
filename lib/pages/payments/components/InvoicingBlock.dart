import 'package:aurumfit/domians/payments/Invoice.dart';
import 'package:aurumfit/domians/payments/models/Invoice.dart';
import 'package:aurumfit/pages/payments/components/InvoiceDetails.dart';
import 'package:aurumfit/providers/auth/authprovider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvoicingBlock extends ConsumerStatefulWidget {
  const InvoicingBlock({Key? key, required this.userid, this.invoice})
      : super(key: key);

  final String userid;
  final InvoiceModel? invoice;

  @override
  ConsumerState<InvoicingBlock> createState() => _InvoicingBlockState();
}

class _InvoicingBlockState extends ConsumerState<InvoicingBlock> {
  String userid = "";
  InvoiceModel? invoiceModel;
  var token = "";
  String error = "";

  @override
  void initState() {
    super.initState();
    token = ref.read(AuthTokenProvider.notifier).state;
    userid = widget.userid;
    if (userid != "" && widget.invoice == null) {
      fetchInvoice();
    } else if (widget.invoice != null) {
      setState(() {
        this.invoiceModel = widget.invoice;
      });
    }
  }

  void fetchInvoice() async {
    Invoice invoice = Invoice(userid: userid);
    try {
      invoiceModel = await invoice.getInvoice(token);
      setState(() {
        this.invoiceModel = invoiceModel;
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll("Exception: ", "");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return userid != ""
        ? Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(
                  color: invoiceModel != null
                      ? invoiceModel!.paid
                          ? CupertinoColors.activeGreen
                          : CupertinoColors.destructiveRed
                      : CupertinoColors.inactiveGray,
                  width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: invoiceModel != null
                ? Column(
                    children: [
                      Container(
                        height: 60,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: CupertinoColors.darkBackgroundGray,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
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
                                      invoiceModel!.InvoiceID,
                                      style: TextStyle(
                                          fontFamily: 'SFPro',
                                          fontSize: 16,
                                          color: CupertinoColors
                                              .lightBackgroundGray,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      invoiceModel!.date,
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
                                  invoiceModel!.paid ? "Paid" : "Unpaid",
                                  style: TextStyle(
                                      fontFamily: 'SFPro',
                                      fontSize: 16,
                                      color: invoiceModel!.paid
                                          ? CupertinoColors.activeGreen
                                          : CupertinoColors.destructiveRed,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                widget.invoice != null
                                    ? Container()
                                    : CupertinoButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (context) =>
                                                      InvoiceDetails(
                                                        invoice: invoiceModel!,
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
                      Container(
                          height: 40,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total",
                                style: TextStyle(
                                    fontFamily: 'SFPro',
                                    fontSize: 16,
                                    color: CupertinoColors.inactiveGray,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "₹ " + invoiceModel!.amount.toString(),
                                style: TextStyle(
                                    fontFamily: 'SFPro',
                                    fontSize: 16,
                                    color: CupertinoColors.inactiveGray,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          )),
                    ],
                  )
                : error != ""
                    ? Container(
                        height: 60,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.exclamationmark_circle,
                                color: CupertinoColors.destructiveRed,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                error,
                                style: TextStyle(
                                    fontFamily: 'SFPro',
                                    color: CupertinoColors.inactiveGray,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Center(
                        child: CupertinoActivityIndicator(),
                      ),
          )
        : Container();
  }
}
