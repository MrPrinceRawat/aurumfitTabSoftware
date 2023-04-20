import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

checkforPendingPrintables() async {
  var status = false;
  var url = Uri.parse(
      "https://backend.aurum.fitness/api/isPendingPrintAvailable/check");
  await http
      .get(url, headers: {
        "Authorization": "Token 38bc32c9730b26e11b45f640aaef804c00c0c325",
      })
      .then((value) => jsonDecode(value.body))
      .then((value) {
        if (value["Check"] == "Yup") {
          status = true;
        }
      });
  return status;
}

fetchforPendingPrintables() async {
  var status = [];
  var url = Uri.parse(
      "https://backend.aurum.fitness/api/isPendingPrintAvailable/get");
  await http
      .get(url, headers: {
        "Authorization": "Token 38bc32c9730b26e11b45f640aaef804c00c0c325",
      })
      .then((value) => jsonDecode(value.body))
      .then((value) {
        status = value;
      });
  return status;
}

markAsPrinted(orderid) async {
  var url = Uri.parse("https://backend.aurum.fitness/api/order/" +
      orderid.toString() +
      "/markPrinted");
  http
      .get(url, headers: {
        "Authorization": "Token 38bc32c9730b26e11b45f640aaef804c00c0c325",
      })
      .then((value) => jsonDecode(value.body))
      .then((value) {
        if (value == "Done") {
          return true;
        } else {
          return false;
        }
      });
}

PrintGlobal(data) async {
  final prefs = await SharedPreferences.getInstance();
  final ip = prefs.getString('print_server_ip');
  if (ip == null) {
    return false;
  }
  var url = Uri.parse("http://$ip:13687/printrecipt");
  var body = json.encode(data);
  try {
    var response = await http.post(url, body: body, headers: {
      "Accept": "application/json",
      "Content-Type": "application/json"
    });
    print(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } catch (reason) {
    return;
  }
}

FileUploadHandler(String username, String file, String token) async {
  if (token == '') {
    return {'error': true, 'message': 'Token not found'};
  }

  //create multipart request for POST or PATCH method
  var request = http.MultipartRequest(
      "POST", Uri.parse("https://backend.aurum.fitness/api/uploadUserImage/"));
  //add text fields
  request.fields["username"] = username;
  //create multipart using filepath, string or bytes
  var pic = await http.MultipartFile.fromPath("image", file);
  //add multipart to request
  request.files.add(pic);
  request.headers['Authorization'] = 'Token ' + token;
  var response = await request.send();
  //Get the response from the server
  var responseData = await response.stream.toBytes();
  var responseString = String.fromCharCodes(responseData);

  if (response.statusCode == 200) {
    return {'error': false, 'message': responseString};
  } else {
    return {'error': true, 'message': responseString};
  }
}

getLink(userid, number, plan, amount, subtotal, token) async {
  var url = Uri.parse(
      "https://backend.aurum.fitness/auth/PaymentLinkForNotification/");
  var body = json.encode({
    "user": userid,
    "phone": number,
    "plan": plan,
    "amount": amount,
    "subtotal": subtotal,
  });
  var response = await http.post(url, body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Token " + token,
  });
  if (response.statusCode == 200) {
    return {'error': false, 'message': jsonDecode(response.body)};
  } else {
    return {'error': true, 'message': response.reasonPhrase};
  }
}

sendPaymentNotification(userid, name, number, amount, dueDate, token) async {
  print("Sending Payment Notification");
  var link =
      await getLink(userid, number, "AURUM Open-GYM", amount, amount, token);
  print(link);
  if (link['error'] == true) {
    return {'error': true, 'message': link['message']};
  } else if (link['message']["link"] == null) {
    return {'error': true, 'message': "Link not found"};
  }
  var key =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYzMzNhMjZjYjE1YWZjNDBjZjE2NTUxMCIsIm5hbWUiOiJBdXJ1bSBGaXRuZXNzIiwiYXBwTmFtZSI6IkFpU2Vuc3kiLCJjbGllbnRJZCI6IjYzMzNhMjZjYjE1YWZjNDBjZjE2NTUwZiIsImFjdGl2ZVBsYW4iOiJCQVNJQ19UUklBTCIsImlhdCI6MTY2NDMyODMwMH0.l3aObN92Pq3gfbUvhfMLvN9mamC3c9wqpuK6NMWLJIQ";
  var url = Uri.parse("https://backend.aisensy.com/campaign/t1/api");
  var body = json.encode({
    "apiKey": key,
    "campaignName": "Amount Pending",
    "destination": "+91" + number,
    "userName": name,
    "source": "Aurum POS",
    "templateParams": [
      "₹" + amount.toString(),
      link['message']["link"],
    ]
  });
  var response = await http.post(url, body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
  });
  print(response.body);
  if (response.statusCode == 200) {
    return {
      'error': false,
      'message': 'Payment Notification Sent',
    };
  } else {
    return {
      'error': true,
      'message': jsonDecode(response.body)['errorMessage']
    };
  }
}

markUserAttendance(userid, token) async {
  var url = Uri.parse(
      "https://backend.aurum.fitness/api/user/$userid/markAttendance");
  var response = await http.get(url, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Token " + token
  });
  if (response.statusCode == 200) {
    return {'error': false, 'message': jsonDecode(response.body)};
  } else {
    return {'error': true, 'message': response.reasonPhrase};
  }
}

getAttendances() async {
  var date = DateTime.now().year.toString() +
      "-" +
      DateTime.now().month.toString() +
      "-" +
      DateTime.now().day.toString();
  var url =
      Uri.parse("https://backend.aurum.fitness/api/api/$date/getAttendance");
  var response = await http.get(url, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Token 38bc32c9730b26e11b45f640aaef804c00c0c325",
  });
  if (jsonDecode(response.body)[0] != "No attendance found.") {
    return {'error': false, 'message': jsonDecode(response.body)};
  } else {
    return {'error': true, 'message': "No attendance found."};
  }
}

// get last 30 days attendance count
getAttendancesCount() async {
  var url = Uri.parse("https://backend.aurum.fitness/api/getAttendanceCount");
  var response = await http.get(url, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Token 38bc32c9730b26e11b45f640aaef804c00c0c325",
  });
  print(response.body);
  if (jsonDecode(response.body)[0] != "No attendance found.") {
    return {'error': false, 'message': jsonDecode(response.body)};
  } else {
    return {'error': true, 'message': "No attendance found."};
  }
}

getExpiredMemberships() async {
  // var url = Uri.parse("http://127.0.0.1:8000/auth/getExpiredMemberships");
  var url =
      Uri.parse("https://backend.aurum.fitness/api/getExpiredMemberships");

  var response = await http.get(url, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Token 38bc32c9730b26e11b45f640aaef804c00c0c325",
  });
  print(response.body);
  if (jsonDecode(response.body)[0] != "No expired memberships found.") {
    return {'error': false, 'message': jsonDecode(response.body)};
  } else {
    return {'error': true, 'message': "No expired memberships found."};
  }
}
