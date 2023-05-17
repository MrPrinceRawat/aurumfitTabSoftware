import 'dart:convert';
import 'package:aurumfit/pages/search/addnew.dart';
import 'package:aurumfit/providers/auth/authprovider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:aurumfit/pages/search/SearchExpanded.dart';

class Search extends ConsumerStatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends ConsumerState<Search> {
  bool _isSearching = false;
  List active_users = [];
  List inactive_users = [];
  var userId = new TextEditingController();

  Future<void> findUser(entered) async {
    // Make a POST request to aurumfitnesscommunicator.ml to get the user list
    var url = Uri.parse('https://backend.aurum.fitness/auth/getUser/');
    final token = ref.read(AuthTokenProvider);
    var response = await http.post(url, body: {
      'name': entered
    }, headers: {
      "Authorization": "Token $token",
    });
    var users = jsonDecode(response.body);
    setState(() {
      active_users = users['active_users'];
      inactive_users = users['inactive_users'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: Column(
      children: [
        SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Search",
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'SFPro',
                    fontWeight: FontWeight.w500,
                  )),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      CupertinoPageRoute(builder: (context) {
                    return MemberSignUpPage();
                  }));
                },
                child: Icon(CupertinoIcons.person_add),
              )
            ],
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Hero(
              tag: "searchbar",
              child: CupertinoSearchTextField(
                placeholder: 'Name, Phone etc.',
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 500),
                      pageBuilder: (BuildContext context,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation) {
                        return SearchExpanded();
                      },
                      transitionsBuilder: (BuildContext context,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation,
                          Widget child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
              )),
        ),
      ],
    ));
  }
}
