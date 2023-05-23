import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  Future<void> write(String key, String value) async {
    if (value != "" && key != "") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
    return;
  }

  Future<String> read(String key) async {
    if (key == "") {
      return "";
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = prefs.getString(key) ?? "";
    return value;
  }

  Future<void> clearStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
