import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Galary extends StatefulWidget {
  const Galary({Key? key}) : super(key: key);

  @override
  State<Galary> createState() => _GalaryState();
}

class _GalaryState extends State<Galary> {
  var users = [];

  @override
  void initState() {
    super.initState();
    findUser("");
  }

  Future<void> findUser(entered) async {
    // Make a POST request to aurumfitnesscommunicator.ml to get the user list
    var url = Uri.parse('https://backend.aurum.fitness/auth/getUser/');
    var response = await http.post(url, body: {
      'name': entered
    }, headers: {
      "Authorization": "Token 38bc32c9730b26e11b45f640aaef804c00c0c325",
    });
    var body = jsonDecode(response.body);
    var userlist = [];
    for (int i = 0; i < body.length; i++) {
      if (body[i][1] != "") {
        userlist.add(body[i]);
      }
    }
    setState(() {
      users = userlist;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("Galary"),
        ),
        child: Container(
            child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: users.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              width: (MediaQuery.of(context).size.width / 2) - 20,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRect(
                      child: Container(
                        height: 200,
                        width: (MediaQuery.of(context).size.width / 3) - 20,
                        child: Image(
                            image: NetworkImage(
                                "https://backend.aurum.fitnessss/media/" +
                                    users[index][1])),
                      ),
                    ),
                    Text(
                      users[index][0],
                      style: TextStyle(fontSize: 15),
                    )
                  ]),
              padding: EdgeInsets.only(bottom: 20),
            );
          },
        )));
  }
}
