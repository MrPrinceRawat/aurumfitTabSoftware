import 'package:shared_preferences/shared_preferences.dart';

saveServerIp(ip) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('print_server_ip', ip);
}

getServerIp() async {
  final prefs = await SharedPreferences.getInstance();
  final ipGot = await prefs.getString('print_server_ip') ?? "";
  return ipGot;
}
