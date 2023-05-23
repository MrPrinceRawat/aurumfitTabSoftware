import 'dart:convert';

import 'package:aurumfit/domians/usermanagement/models/models.dart';
import 'package:http/http.dart' as http;

class UserManagement {
  late String userid;

  UserManagement({required this.userid});

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
}
