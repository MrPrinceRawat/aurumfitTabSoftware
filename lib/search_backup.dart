import 'dart:convert';
import 'package:aurumfit/addnew.dart';
import 'package:aurumfit/dynamicPayment.dart';
import 'package:aurumfit/showInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool _isSearching = false;
  List active_users = [];
  List inactive_users = [];
  var userId = new TextEditingController();

  Future<void> findUser(entered) async {
    // Make a POST request to aurumfitnesscommunicator.ml to get the user list
    var url = Uri.parse('https://backend.aurum.fitness/auth/getUser/');
    var response = await http.post(url, body: {
      'name': entered
    }, headers: {
      "Authorization": "Token 38bc32c9730b26e11b45f640aaef804c00c0c325",
    });
    var users = jsonDecode(response.body);
    print(users['active_users']);
    setState(() {
      active_users = users['active_users'];
      inactive_users = users['inactive_users'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: ListView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: 20, right: 20),
        children: [
          Container(
              height: 40,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 30, right: 10),
              margin: EdgeInsets.only(top: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Search",
                      style: TextStyle(
                          fontSize: 40,
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600)),
                  CupertinoButton(
                      child: Icon(CupertinoIcons.person_add_solid),
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => MemberSignUpPage()));
                      })
                ],
              )),
          Container(
            height: 40,
            margin: EdgeInsets.only(top: 20),
            width: MediaQuery.of(context).size.width - 50,
            child: CupertinoSearchTextField(
              placeholder: "Name, Number",
              prefixIcon: Icon(CupertinoIcons.search,
                  color: CupertinoColors.white.withOpacity(.3)),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: CupertinoColors.white.withOpacity(.3)),
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: "SFPro",
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w400),
              prefixInsets: EdgeInsets.only(left: 10),
              onChanged: (value) {
                setState(() {
                  _isSearching = value.isNotEmpty;
                  findUser(value);
                });
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
              height: 750,
              width: MediaQuery.of(context).size.width - 40,
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: active_users.map((user) {
                  return Container(
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.all(10),
                    // add a margin bottom
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: CupertinoColors.white.withOpacity(.1)),
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
                                  backgroundColor: CupertinoColors.white,
                                  child: user[1] != Null
                                      ? CircleAvatar(
                                          radius: 38,
                                          backgroundImage: user[1] != ""
                                              ? NetworkImage(
                                                  "https://backend.aurum.fitness/" +
                                                      user[1])
                                              : NetworkImage(
                                                  "https://backend.aurum.fitness/media/" +
                                                      "ntf.png"),
                                        )
                                      : CircleAvatar(
                                          radius: 48,
                                          backgroundImage: NetworkImage(
                                              "https://backend.aurum.fitness/media/" +
                                                  "ntf.png"),
                                        )),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 20),
                                  child: Text(
                                    user[0],
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: CupertinoColors.systemGrey,
                                        fontFamily: 'SFPro',
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(right: 20),
                                  child: Icon(
                                    CupertinoIcons.right_chevron,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
          SizedBox(
            height: 20,
          ),
          Text("Inactive Users",
              style: TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 20,
                  color: Color.fromARGB(192, 255, 255, 255))),
          SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }
}
