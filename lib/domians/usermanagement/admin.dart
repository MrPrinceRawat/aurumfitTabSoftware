import 'dart:convert';

import 'package:aurumfit/domians/usermanagement/models/models.dart';
import 'package:http/http.dart' as http;

class Admin {
  late String token;

  Admin({required this.token});

  /// This method is used to get the user data from the database.

  Future getExpiredMemberships() async {
    var url = Uri.parse(
        "https://backend.aurum.fitness/dashboard/get-expired-memberships");
    var data;
    var status = await http.get(url, headers: {
      "Authorization": "Token $token",
    });

    if (status.statusCode == 200) {
      data = jsonDecode(status.body);

      return {"error": false, "data": AdminData.fromJson(data)};
    } else {
      return {"error": true, "message": "Something went wrong"};
    }
  }

  Future<dynamic> findUser(searchText, offset) async {
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
}
