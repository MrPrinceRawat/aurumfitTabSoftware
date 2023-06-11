import 'dart:async';
import 'package:aurumfit/domians/usermanagement/serverRelated.dart';
import 'package:aurumfit/pages/search/showInfo.dart';
import 'package:aurumfit/providers/auth/authprovider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:convert';

class SearchExpanded extends ConsumerStatefulWidget {
  const SearchExpanded({Key? key}) : super(key: key);

  @override
  _SearchExpandedState createState() => _SearchExpandedState();
}

class _SearchExpandedState extends ConsumerState<SearchExpanded> {
  bool _isSearching = false;
  List users = [];
  Timer? _debounce;
  var userId = new TextEditingController();
  var currentPageLength = 1;
  String token = "";
  String searchText = "";
  int offset = 0;

  @override
  void initState() {
    super.initState();
    token = ref.read(AuthTokenProvider.notifier).state;
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

    _debounce = Timer(Duration(milliseconds: 500), () async {
      setState(() {
        this.searchText = searchText;
        offset = 0;
      });

      var users = await findUser();
      setState(() {
        this.users = users;
      });
    });
  }

  Future<dynamic> findUser() async {
    // Make a POST request to aurumfitnesscommunicator.ml to get the user list
    var url = Uri.parse(
        'https://backend.aurum.fitness/auth/getUser/v2/?limit=50&offset=$offset');
    var response = await http.post(url, body: {
      'name': searchText
    }, headers: {
      "Authorization": "Token $token",
    });
    if (response.statusCode != 200) {
      throw Exception("Cannot Fetch Users");
    }
    return jsonDecode(response.body);
  }

  markAtten(user) async {
    var status = await markUserAttendance(user, token);
    if (status["error"]) {
      Fluttertoast.showToast(
          msg: status["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: CupertinoColors.systemRed,
          textColor: CupertinoColors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Attendance Marked Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: CupertinoColors.systemGreen,
          textColor: CupertinoColors.white,
          fontSize: 16.0);
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
                          Text("Users",
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
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return index == users.length
                              ? CupertinoButton(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text("Load More"),
                                  onPressed: () async {
                                    setState(() {
                                      offset += 20;
                                    });
                                    var users = await findUser();
                                    setState(() {
                                      this.users += users;
                                    });
                                  })
                              : Slidable(
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
                                        onPressed: (context) =>
                                            markAtten(users[index]['username']),
                                        backgroundColor:
                                            CupertinoColors.systemBlue,
                                        foregroundColor: Colors.white,
                                        icon:
                                            CupertinoIcons.calendar_badge_plus,
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
                                                    userid: users[index]
                                                        ['username'],
                                                  )));
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(top: 10),
                                      padding: EdgeInsets.all(10),
                                      // add a margin bottom
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                        color: CupertinoColors.white
                                            .withOpacity(.2),
                                        width: 1,
                                      ))),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (context) =>
                                                      ShowInfo(
                                                        userid: users[index]
                                                            ['username'],
                                                      )));
                                        },
                                        child: Container(
                                          height: 60,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              40,
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
                                                    child: users[index]
                                                                ['pic'] !=
                                                            Null
                                                        ? CachedNetworkImage(
                                                            imageUrl:
                                                                "https://backend.aurum.fitness/" +
                                                                    users[index]
                                                                        ['pic'],
                                                            imageBuilder: (context,
                                                                    imageProvider) =>
                                                                Container(
                                                              width: 80.0,
                                                              height: 80.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                image: DecorationImage(
                                                                    image:
                                                                        imageProvider,
                                                                    fit: BoxFit
                                                                        .cover),
                                                              ),
                                                            ),
                                                            placeholder: (context,
                                                                    url) =>
                                                                CupertinoActivityIndicator(
                                                              color: CupertinoColors
                                                                  .darkBackgroundGray,
                                                            ),
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                Icon(CupertinoIcons
                                                                    .exclamationmark_circle),
                                                          )
                                                        : CircleAvatar(
                                                            radius: 48,
                                                            backgroundImage:
                                                                NetworkImage(
                                                                    "https://backend.aurum.fitness/media/" +
                                                                        "ntf.png"),
                                                          )),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          users[index]
                                                              ['username'],
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color: users[
                                                                          index]
                                                                      [
                                                                      'is_active']
                                                                  ? CupertinoColors
                                                                      .lightBackgroundGray
                                                                  : CupertinoColors
                                                                      .systemGrey,
                                                              fontFamily:
                                                                  'SFPro',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        !users[index]
                                                                ['is_active']
                                                            ? Text(
                                                                "INACTIVE",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: CupertinoColors
                                                                        .destructiveRed,
                                                                    fontFamily:
                                                                        'SFPro',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              )
                                                            : SizedBox()
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));
                        },
                        itemCount: users.length + 1,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    )
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
