import 'package:aurumfit/domians/payments/models/Invoice.dart';
import 'package:aurumfit/pages/payments/components/InvoicingBlock.dart';
import 'package:aurumfit/providers/auth/authprovider.dart';
import 'package:billing/billing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ChangeInvoiceDate extends ConsumerStatefulWidget {
  const ChangeInvoiceDate(
      {Key? key, required this.invoice, required this.userid})
      : super(key: key);

  final InvoiceModel? invoice;
  final String userid;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangeInvoiceDateState();
}

class _ChangeInvoiceDateState extends ConsumerState<ChangeInvoiceDate> {
  bool loading = false;

  changeDate() async {
    await Future.delayed(Duration(milliseconds: 200), () async {});
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2031),
    );
    if (date == null) {
      return;
    }
    await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("Are you sure?"),
            content: Text("Do you want to change the payment date?"),
            actions: [
              CupertinoDialogAction(
                  onPressed: () {
                    Navigator.pop(context);
                    return;
                  },
                  child: Text("Cancel")),
              CupertinoDialogAction(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Ok",
                    style: TextStyle(color: CupertinoColors.destructiveRed),
                  ))
            ],
          );
        });
    setState(() {
      loading = true;
    });
    await Billing()
        .changeInvoiceDate(
            DateFormat("dd-MM-y").format(date),
            widget.invoice!.InvoiceID,
            ref.read(AuthTokenProvider.notifier).state,
            BillingModel(
              id: widget.userid,
            ))
        .then((value) => Navigator.pop(context))
        .catchError((e) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text("Error"),
              content: Text(e.toString()),
              actions: [
                CupertinoDialogAction(
                    onPressed: () {
                      Navigator.pop(context);
                      return;
                    },
                    child: Text("Cancel")),
                CupertinoDialogAction(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Ok",
                      style: TextStyle(color: CupertinoColors.destructiveRed),
                    ))
              ],
            );
          });
    });
  }

  @override
  void initState() {
    super.initState();

    changeDate();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Change Invoice Date"),
      ),
      child: SafeArea(
          child: loading
              ? Center(
                  child: CupertinoActivityIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      InvoicingBlock(
                        invoice: widget.invoice,
                        userid: widget.userid,
                        showDetails: false,
                      ),
                    ],
                  ),
                )),
    );
  }
}
