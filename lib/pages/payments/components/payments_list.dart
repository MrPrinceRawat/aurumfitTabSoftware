import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentsList extends StatefulWidget {
  const PaymentsList({Key? key, required this.users}) : super(key: key);

  final List? users;

  @override
  State<PaymentsList> createState() => _PaymentsListState();
}

class _PaymentsListState extends State<PaymentsList> {
  List _users = [];

  @override
  void initState() {
    super.initState();
    _users = widget.users!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(children: [
        Container(
          padding: EdgeInsets.only(top: 20, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total:",
                style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white.withOpacity(.9)),
              ),
              Text(
                // Add the total amount in the users list,
                // then convert it to string
                "\₹ ${_users.length > 0 ? _users.map((e) => e.amount).reduce((a, b) => (int.parse(a) + int.parse(b)).toString()) : 0}",
                style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.lightBackgroundGray),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 8,
        ),
        _users.length > 0
            ? Container(
                child: Column(
                children: [
                  ..._users.map((e) => Container(
                        decoration: BoxDecoration(
                          border: _users.length > 1
                              ? Border(
                                  bottom: BorderSide(
                                      color: CupertinoColors.inactiveGray,
                                      width: 2))
                              : null,
                        ),
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          children: [
                            Text(
                              e.name,
                              style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  color: CupertinoColors.white.withOpacity(.8)),
                            ),
                            Spacer(),
                            Text(
                              "\₹ ${e.amount}",
                              style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.systemGrey),
                            ),
                          ],
                        ),
                      )),
                  // SizedBox(
                  //   height: 8,
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     Text(
                  //       "Continue",
                  //       style: GoogleFonts.montserrat(
                  //           fontSize: 16,
                  //           fontWeight: FontWeight.bold,
                  //           color: CupertinoColors.systemBlue),
                  //     ),
                  //     Icon(
                  //       CupertinoIcons.right_chevron,
                  //       color: CupertinoColors.systemBlue,
                  //     ),
                  //   ],
                  // ),
                ],
              ))
            : Container(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        color: CupertinoColors.activeOrange,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "No Users Added",
                        style: GoogleFonts.montserrat(
                            fontSize: 16, color: CupertinoColors.white),
                      ),
                    ],
                  ),
                ),
              ),
      ]),
    );
  }
}
