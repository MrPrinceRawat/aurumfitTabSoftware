import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class authData {
  static final authData _instance = authData._internal();

  String token = '';
  String username = '';
  String password = '';

  Future<bool> login(String username, String password) async {
    var url = Uri.parse("https://backend.aurum.fitness/auth/login");
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}));
    print(response.body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      this.token = data["token"];
      this.username = username;
      return true;
    } else {
      return false;
    }
  }

  factory authData(String username, String password) {
    _instance.login(username, password);
    return _instance;
  }

  authData._internal();
}
