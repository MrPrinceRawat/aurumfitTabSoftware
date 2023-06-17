import 'dart:convert';

import 'package:aurumfit/domians/usermanagement/models/models.dart';
import 'package:http/http.dart' as http;

/// This class is used to manage the user.
///
/// ### Description
/// This class is used to manage the user.
/// It does this by using the [UserModel] class.
/// It is used to get the user data from the database.
///
/// ### Parameters
/// This class has the following parameters:
///
/// | Type | Name | Description |
/// | :--- | :--- | :--- |
/// | String | userid | The id of the user. |
///
/// ### Examples
/// ```dart
/// UserManagement userManagement = UserManagement(userid: "userid");
/// ```
///
/// ### Methods
/// This class has the following methods:
///
/// #### getUserInfo
/// This method is used to get the user data from the database.
///
/// ##### Parameters
/// This method has the following parameters:
///
/// | Type | Name | Description |
/// | :--- | :--- | :--- |
/// | String | token | The token of the user. |
///
/// ##### Examples
/// ```dart
/// User user = await userManagement.getUserInfo("token");
/// ```

class UserManagement {
  late String userid;

  UserManagement({required this.userid});

  /// This method is used to get the user data from the database.
  ///
  /// ##### Parameters
  /// This method has the following parameters:
  ///
  /// | Type | Name | Description |
  /// | :--- | :--- | :--- |
  /// | String | token | The token of the user. |
  ///
  /// ##### Examples
  /// ```dart
  /// User user = await userManagement.getUserInfo("token");
  /// ```
  /// This method returns a [User] object.
  /// The [User] object contains the following data:
  /// - [userid]
  /// - [name]
  /// - [dob]
  /// - [Phone_number]
  /// - [Address]
  ///
  /// for more info on the [User] object, see [UserModel].
  ///
  ///
  Future<User> getUserInfo(token) async {
    var url = Uri.parse("https://backend.aurum.fitness/auth/getUserInfoStaff/");
    try {
      var response = await http.post(url, body: {
        'userid': userid
      }, headers: {
        "Authorization": "Token $token",
      });
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return User(
            userid: userid,
            name: responseData["name"] ?? "",
            dob: responseData["dob"] ?? "",
            Phone_number: responseData["phone"] ?? "",
            Address: responseData["address"] ?? "",
            profilePic: responseData["pfp"] ?? "",
            gender: responseData["gender"] ?? "",
            Membership_type: responseData["plan"] ?? "",
            Total_Payable_Amount: responseData["totalPayableAmount"] ?? 0,
            amount_paid: responseData["alreadyPaid"] ?? 0,
            Membership_duration: responseData["duration"] ?? "",
            Membership_start_date: responseData["startingFrom"] ?? "",
            active: responseData["active"],
            membershipStatus: responseData["membershipStatus"],
            attendanceStatus: responseData["attendanceStatus"]);
      } else {
        print("failed");
        throw Exception('Failed to load post');
      }
    } catch (e) {
      print(e);
    }
    return User(userid: userid);
  }

  Future<List> getUserAttendance(token, month, year) async {
    var url = Uri.parse(
        'https://backend.aurum.fitness/api/user/$userid/$year/$month/getAttendance');
    var res = await http.get(url, headers: {
      "Authorization": "Token $token",
    });
    if (res.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(res.body);
      return responseData["attendance"];
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<bool> markUserInactive(token) async {
    var url = Uri.parse('http://127.0.0.1:8000/auth/$userid/markInactive');
    var status = await http.get(url, headers: {
      "Authorization": "Token $token",
    });
    if (status.statusCode == 200) {
      return true;
    }
    return false;
  }
}
