import 'dart:convert';
import 'package:aurumfit/domians/storage/Storage.dart';
import 'package:aurumfit/pages/home/home.dart';
import 'package:aurumfit/providers/auth/authprovider.dart';
import 'package:authentication/authentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class Signin extends ConsumerStatefulWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends ConsumerState<Signin> {
  var showPassword = true;
  var emailController = new TextEditingController();
  var passwordController = new TextEditingController();
  var _loading = false;
  var error;
  var _logedin = false;
  Storage storage = new Storage();

  @override
  void initState() {
    super.initState();
    _checkLogin();
    ref.read(AuthTokenProvider);
  }

  void _checkLogin() async {
    String token = await storage.read('token');
    if (token != "") {
      ref.read(AuthTokenProvider.notifier).state = token;
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => Home()),
      );
    } else {
      setState(() {
        _logedin = true;
      });
    }
  }

  bool checkFilled() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      return false;
    }
    return true;
  }

  void login(context) async {
    setState(() {
      _loading = true;
    });

    Auth auth = new Auth(
        username: emailController.text, password: passwordController.text);
    Authentication authentication = new Authentication();
    String token = await authentication.signIn(auth);
    if (token != "") {
      storage.write('token', token);
      context.read(AuthTokenProvider.notifier).state = token;
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const Home()),
      );
    } else {
      setState(() {
        _loading = false;
        error = 'Invalid username or password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: Material(
      color: Color.fromRGBO(20, 20, 20, 1),
      child: SafeArea(
        child: Center(
            child: _loading
                ? CupertinoActivityIndicator()
                : _logedin == false
                    ? CupertinoActivityIndicator()
                    : SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                error != null
                                    ? Text(
                                        error,
                                        style: GoogleFonts.montserrat(
                                          color: Colors.red,
                                          fontSize: 15,
                                        ),
                                      )
                                    : SizedBox(),
                                SizedBox(height: 20),
                                Text("Log In",
                                    style: GoogleFonts.roboto(
                                        color: CupertinoColors.white
                                            .withOpacity(.8),
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500)),
                                Container(
                                  margin: EdgeInsets.only(top: 25),
                                  child: Column(
                                    children: [
                                      CupertinoTextField(
                                        decoration: BoxDecoration(
                                          color: CupertinoColors.white
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.all(16),
                                        controller: emailController,
                                        prefix: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16.0),
                                          child: Text(
                                            "Username",
                                            style: GoogleFonts.roboto(
                                                letterSpacing: 1,
                                                color: CupertinoColors.white
                                                    .withOpacity(.8),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ),
                                        style: GoogleFonts.roboto(
                                            letterSpacing: 1,
                                            color: CupertinoColors.white
                                                .withOpacity(.8),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      CupertinoTextField(
                                        decoration: BoxDecoration(
                                          color: CupertinoColors.white
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.all(16),
                                        obscureText: showPassword,
                                        controller: passwordController,
                                        suffix: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 1.0),
                                          child: IconButton(
                                            splashRadius: 1,
                                            icon: Icon(
                                              showPassword
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: CupertinoColors.white
                                                  .withOpacity(.6),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                showPassword = !showPassword;
                                              });
                                            },
                                          ),
                                        ),
                                        prefix: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16.0),
                                          child: Text(
                                            "Password",
                                            style: GoogleFonts.roboto(
                                                letterSpacing: 1,
                                                color: CupertinoColors.white
                                                    .withOpacity(.8),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ),
                                        style: GoogleFonts.roboto(
                                            letterSpacing: 1,
                                            color: CupertinoColors.white
                                                .withOpacity(.8),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      CupertinoButton(
                                        onPressed: checkFilled()
                                            ? () {
                                                login(context);
                                              }
                                            : null,
                                        padding: EdgeInsets.only(
                                            top: 16,
                                            bottom: 16,
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.35,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.35),
                                        color: CupertinoColors.white
                                            .withOpacity(.7),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Text(
                                          "Log In",
                                          style: GoogleFonts.roboto(
                                              letterSpacing: 1,
                                              color: CupertinoColors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                        ),
                      )),
      ),
    ));
  }
}
