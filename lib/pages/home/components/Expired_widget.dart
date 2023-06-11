import 'dart:ui';

import 'package:aurumfit/pages/search/showInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpiredInvoiceWidget extends ConsumerStatefulWidget {
  const ExpiredInvoiceWidget({key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ExpiredInvoiceWidgetState();
}

class _ExpiredInvoiceWidgetState extends ConsumerState<ExpiredInvoiceWidget> {
  var users = [];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(
              width: MediaQuery.of(context).size.width / 2.5,
              height: MediaQuery.of(context).size.height / 1.7,
              padding: EdgeInsets.only(top: 10, left: 20, right: 20),
              decoration: BoxDecoration(
                  color: CupertinoColors.white.withOpacity(.5),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Expired Users",
                        style: TextStyle(
                          fontSize: 20,
                          color: CupertinoColors.darkBackgroundGray,
                          fontFamily: "SFPro",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          "View All",
                          style: TextStyle(
                              color: CupertinoColors.link,
                              fontSize: 15,
                              fontFamily: "SFPro"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Total: ${users.length}",
                    style: TextStyle(
                        color: CupertinoColors.darkBackgroundGray,
                        fontFamily: "SFPro"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: (MediaQuery.of(context).size.height / 1.7) - 84,
                    child: users.length == 0
                        ? Center(
                            child: Text(
                            "No Users Found",
                            style: TextStyle(
                                color: CupertinoColors.darkBackgroundGray,
                                fontFamily: "SFPro"),
                          ))
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => ShowInfo(
                                                userid: users
                                                    .elementAt(index)["user"],
                                              )));
                                },
                                child: Container(
                                  // add a border bottom
                                  decoration: BoxDecoration(
                                      color:
                                          CupertinoColors.white.withOpacity(.5),
                                      border: Border.all(
                                          color: CupertinoColors.white
                                              .withOpacity(.8),
                                          width: 2),
                                      borderRadius: BorderRadius.circular(15)),
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 12.0,
                                        bottom: 12.0,
                                        left: 10.0,
                                        right: 10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          users.elementAt(index)["user"],
                                          softWrap: true,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: CupertinoColors
                                                .darkBackgroundGray,
                                            fontFamily: "SFPro",
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.clock,
                                              color: CupertinoColors
                                                  .darkBackgroundGray,
                                              size: 12,
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              users.elementAt(index)["time"],
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: CupertinoColors
                                                      .darkBackgroundGray,
                                                  fontFamily: "SFPro"),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                  ),
                ],
              ),
            )));
  }
}
