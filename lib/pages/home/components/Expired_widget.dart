import 'dart:ui';

import 'package:aurumfit/domians/usermanagement/admin.dart';
import 'package:aurumfit/pages/search/showInfo.dart';
import 'package:aurumfit/providers/auth/authprovider.dart';
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
  int count = 0;
  String error = '';
  bool isLoading = false;
  String token = '';
  int loadlimit = 10;

  @override
  void initState() {
    super.initState();
    setState(() {
      token = ref.read(AuthTokenProvider.notifier).state;
    });
    Future.delayed(Duration.zero, () {
      getExpiredUsers();
    });
  }

  void getExpiredUsers() async {
    setState(() {
      isLoading = true;
    });
    final response = await Admin(token: token).getExpiredMemberships();
    if (!response['error']) {
      setState(() {
        users = response['data'].data;
        count = response['data'].count;
      });
    } else {
      setState(() {
        error = response['message'];
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => ExpiredMembershipsFullPageView(
                    users: users, count: count)));
      },
      child: ClipRRect(
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
                            onTap: () {
                              getExpiredUsers();
                            },
                            child: Icon(
                              CupertinoIcons.refresh,
                              size: 20,
                              color: CupertinoColors.darkBackgroundGray,
                            )),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Total: ${count}",
                      style: TextStyle(
                          color: CupertinoColors.darkBackgroundGray,
                          fontFamily: "SFPro"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    isLoading
                        ? Center(
                            child: CupertinoActivityIndicator(),
                          )
                        : Container(
                            height:
                                (MediaQuery.of(context).size.height / 1.7) - 84,
                            child: users.length == 0
                                ? Center(
                                    child: Text(
                                    "No Users Found",
                                    style: TextStyle(
                                        color:
                                            CupertinoColors.darkBackgroundGray,
                                        fontFamily: "SFPro"),
                                  ))
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: loadlimit + 1,
                                    itemBuilder: (context, index) {
                                      return index == loadlimit
                                          ? CupertinoButton.filled(
                                              padding: EdgeInsets.all(0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                      CupertinoIcons.down_arrow,
                                                      color: CupertinoColors
                                                          .darkBackgroundGray,
                                                      size: 20),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text("Load More",
                                                      style: TextStyle(
                                                          color: CupertinoColors
                                                              .darkBackgroundGray,
                                                          fontFamily: "SFPro",
                                                          fontSize: 15))
                                                ],
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  loadlimit += 10;
                                                });
                                              })
                                          : GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                        builder: (context) =>
                                                            ShowInfo(
                                                              userid: users
                                                                      .elementAt(
                                                                          index)[
                                                                  "username"],
                                                            )));
                                              },
                                              child: Container(
                                                // add a border bottom
                                                decoration: BoxDecoration(
                                                    color: CupertinoColors.white
                                                        .withOpacity(.5),
                                                    border: Border.all(
                                                        color: CupertinoColors
                                                            .white
                                                            .withOpacity(.8),
                                                        width: 2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                margin:
                                                    EdgeInsets.only(bottom: 10),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 12.0,
                                                          bottom: 12.0,
                                                          left: 10.0,
                                                          right: 10.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        users.elementAt(
                                                            index)["username"],
                                                        softWrap: true,
                                                        overflow:
                                                            TextOverflow.fade,
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: CupertinoColors
                                                              .darkBackgroundGray,
                                                          fontFamily: "SFPro",
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                    }),
                          ),
                  ],
                ),
              ))),
    );
  }
}

class ExpiredMembershipsFullPageView extends StatelessWidget {
  const ExpiredMembershipsFullPageView(
      {Key? key, required this.users, required this.count})
      : super(key: key);

  final List users;
  final int count;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: CupertinoNavigationBarBackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          middle: Text("Expired Memberships",
              style: TextStyle(
                  color: CupertinoColors.lightBackgroundGray,
                  fontFamily: "SFPro",
                  fontWeight: FontWeight.w600)),
        ),
        child: Container(
          padding: EdgeInsets.only(top: 10, left: 20, right: 20),
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: count,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => ShowInfo(
                                  userid: users.elementAt(index)["username"],
                                )));
                  },
                  child: Container(
                    // add a border bottom
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: CupertinoColors.white.withOpacity(.2),
                                width: 1))),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 18.0, bottom: 18.0, left: 10.0, right: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            users.elementAt(index)["username"],
                            softWrap: true,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontSize: 15,
                              color: CupertinoColors.lightBackgroundGray,
                              fontFamily: "SFPro",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            CupertinoIcons.right_chevron,
                            color: CupertinoColors.lightBackgroundGray,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ));
  }
}
