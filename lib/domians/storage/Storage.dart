import 'package:shared_preferences/shared_preferences.dart';

/// This class is used to store data in the local storage.
///
/// ### Description
/// This class is used to store data in the local storage.
/// It does this by using the shared_preferences package.
/// It stores the data in the form of key-value pairs.
///
/// ### Parameters
/// This class has no parameters.
///
/// ### Examples
/// ```dart
/// Storage storage = Storage();
/// ```
///
/// ### Methods
/// This class has the following methods:
///
/// #### write
/// This method is used to write data to the local storage.
///
/// ##### Parameters
/// This method has the following parameters:
///
/// | Type | Name | Description |
/// | :--- | :--- | :--- |
/// | String | key | The key of the data to be stored. |
/// | String | value | The value of the data to be stored. |
///
/// ##### Examples
/// ```dart
/// storage.write("key", "value");
/// ```
///
/// #### read
/// This method is used to read data from the local storage.
///
/// ##### Parameters
/// This method has the following parameters:
///
/// | Type | Name | Description |
/// | :--- | :--- | :--- |
/// | String | key | The key of the data to be read. |
///
/// ##### Examples
/// ```dart
/// String value = await storage.read("key");
/// ```
///
/// #### clearStorage
/// This method is used to clear the local storage.
///
/// ##### Parameters
/// This method has no parameters.
///
/// ##### Examples
/// ```dart
/// storage.clearStorage();
/// ```
///
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
