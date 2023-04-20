import 'dart:async';
import 'package:aurumfit/BLOC/serverRelated.dart';
import 'package:aurumfit/showInfo.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:convert';

class SearchExpanded extends StatefulWidget {
  const SearchExpanded({Key? key}) : super(key: key);

  @override
  State<SearchExpanded> createState() => _SearchExpandedState();
}

class _SearchExpandedState extends State<SearchExpanded> {
  bool _isSearching = false;
  List active_users = [];
  List inactive_users = [];
  Timer? _debounce;
  var userId = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _debounce?.cancel();
  }

  void _onSearchTextChanged(String searchText) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(Duration(milliseconds: 500), () {
      findUser(searchText);
    });
  }

  Future<void> findUser(entered) async {
    // Make a POST request to aurumfitnesscommunicator.ml to get the user list
    var url = Uri.parse('https://backend.aurum.fitness/auth/getUser/v2/');
    var response = await http.post(url, body: {
      'name': entered
    }, headers: {
      "Authorization": "Token 38bc32c9730b26e11b45f640aaef804c00c0c325",
    });
    var users = jsonDecode(response.body);
    print(users);
    print(users['active_users']);
    setState(() {
      active_users = users['active_users'];
      inactive_users = users['inactive_users'];
    });
  }

  markAtten(user) async {
    var status = await markUserAttendance(
        user, "38bc32c9730b26e11b45f640aaef804c00c0c325");
    if (status["error"]) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text("Error"),
              content: Text(status["message"]),
              actions: [
                CupertinoDialogAction(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    } else {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text("Success"),
              content: Text("Marked attendance"),
              actions: [
                CupertinoDialogAction(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        child: Column(
          children: [
            Container(
                height: 100,
                // add a border bottom
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  color: CupertinoColors.white.withOpacity(.2),
                  width: 1,
                ))),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      padding: EdgeInsets.only(left: 20, right: 20),
                      width: MediaQuery.of(context).size.width - 90,
                      child: Hero(
                        tag: "searchbar",
                        child: CupertinoSearchTextField(
                          placeholder: 'Search',
                          autofocus: true,
                          suffixIcon: Icon(CupertinoIcons.clear),
                          onChanged: _onSearchTextChanged,
                        ),
                      ),
                    ),
                    GestureDetector(
                        child: CupertinoButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ))
                  ],
                )),
            // SizedBox(height: 20),
            Container(
              height: MediaQuery.of(context).size.height - 100,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          Text("Active Users",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: CupertinoColors.systemGrey,
                                  fontFamily: 'SFPro',
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 100 * active_users.length.toDouble(),
                      child: ListView(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        children: active_users.map((user) {
                          return Slidable(
                            startActionPane: ActionPane(
                              // A motion is a widget used to control how the pane animates.
                              motion: const ScrollMotion(),

                              extentRatio: 0.2,
                              dragDismissible: false,

                              // A pane can dismiss the Slidable.
                              // All actions are defined in the children parameter.
                              children: [
                                // A SlidableAction can have an icon and/or a label.
                                SlidableAction(
                                  onPressed: (context) => markAtten(user[0]),
                                  backgroundColor: CupertinoColors.systemBlue,
                                  foregroundColor: Colors.white,
                                  icon: CupertinoIcons.calendar_badge_plus,
                                  label: 'Add Attendance',
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => ShowInfo(
                                              userid: user[0],
                                            )));
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 10),
                                padding: EdgeInsets.all(10),
                                // add a margin bottom
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: CupertinoColors.white.withOpacity(.2),
                                  width: 1,
                                ))),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) => ShowInfo(
                                                  userid: user[0],
                                                )));
                                  },
                                  child: Container(
                                    height: 60,
                                    width:
                                        MediaQuery.of(context).size.width - 40,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: CircleAvatar(
                                              radius: 40,
                                              backgroundColor:
                                                  CupertinoColors.white,
                                              child: user[1] != Null
                                                  ? CachedNetworkImage(
                                                      imageUrl:
                                                          "https://backend.aurum.fitness/" +
                                                              user[1],
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          Container(
                                                        width: 80.0,
                                                        height: 80.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit:
                                                                  BoxFit.cover),
                                                        ),
                                                      ),
                                                      placeholder: (context,
                                                              url) =>
                                                          CupertinoActivityIndicator(
                                                        color: CupertinoColors
                                                            .darkBackgroundGray,
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(CupertinoIcons
                                                              .exclamationmark_circle),
                                                    )
                                                  : CircleAvatar(
                                                      radius: 48,
                                                      backgroundImage: NetworkImage(
                                                          "https://backend.aurum.fitness/media/" +
                                                              "ntf.png"),
                                                    )),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(left: 20),
                                              child: Text(
                                                user[0],
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: CupertinoColors
                                                        .systemGrey,
                                                    fontFamily: 'SFPro',
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          Text(
                            "Inactive Users",
                            style: TextStyle(
                                fontSize: 18,
                                color: CupertinoColors.systemGrey,
                                fontFamily: 'SFPro',
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 120 * inactive_users.length.toDouble(),
                      child: ListView(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        children: inactive_users.map((user) {
                          return Container(
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.all(10),
                            // add a margin bottom
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                              color: CupertinoColors.white.withOpacity(.2),
                              width: 1,
                            ))),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => ShowInfo(
                                              userid: user[0],
                                            )));
                              },
                              child: Container(
                                height: 60,
                                width: MediaQuery.of(context).size.width - 40,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: CircleAvatar(
                                          radius: 40,
                                          backgroundColor:
                                              CupertinoColors.white,
                                          child: user[1] != Null
                                              ? CachedNetworkImage(
                                                  imageUrl:
                                                      "https://backend.aurum.fitness/" +
                                                          user[1],
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      Container(
                                                    width: 80.0,
                                                    height: 80.0,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                  placeholder: (context, url) =>
                                                      CupertinoActivityIndicator(
                                                    color: CupertinoColors
                                                        .darkBackgroundGray,
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      Icon(CupertinoIcons
                                                          .exclamationmark_circle),
                                                )
                                              : CircleAvatar(
                                                  radius: 48,
                                                  backgroundImage: NetworkImage(
                                                      "https://backend.aurum.fitness/media/" +
                                                          "ntf.png"),
                                                )),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(left: 20),
                                          child: Text(
                                            user[0],
                                            style: TextStyle(
                                                fontSize: 18,
                                                color:
                                                    CupertinoColors.systemGrey,
                                                fontFamily: 'SFPro',
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
