import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Backgrounds {
  final String name;
  final String location;

  Backgrounds({required this.name, required this.location});

  static Future<List<Backgrounds>> getBackgrounds() async {
    final prefs = await SharedPreferences.getInstance();
    final backgroundsJson = prefs.getString('backgrounds');
    if (backgroundsJson != null) {
      final backgroundsList = json.decode(backgroundsJson) as List<dynamic>;
      final backgrounds = backgroundsList
          .map((b) => Backgrounds(
                name: b['name'] as String,
                location: b['location'] as String,
              ))
          .toList();
      return backgrounds;
    } else {
      return _setDefaultBackgrounds();
    }
  }

  static Future<void> setBackgrounds(List<Backgrounds> backgrounds) async {
    final prefs = await SharedPreferences.getInstance();
    final backgroundsJson = json.encode(backgrounds
        .map((b) => {
              'name': b.name,
              'location': b.location,
            })
        .toList());
    await prefs.setString('backgrounds', backgroundsJson);
  }

  static Future<String?> getDefaultBackground() async {
    final prefs = await SharedPreferences.getInstance();
    final defaultBackground = prefs.getString('defaultBackground');
    return defaultBackground;
  }

  static Future<void> setDefaultBackground(String backgroundName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultBackground', backgroundName);
  }

  static List<Backgrounds> _setDefaultBackgrounds() {
    return [
      Backgrounds(name: "home.jpg", location: "home.jpg"),
      Backgrounds(name: "home#1.jpg", location: "home#1.jpg"),
      Backgrounds(name: "home#2.jpg", location: "home#2.jpg"),
      Backgrounds(name: "home#3.jpg", location: "home#3.jpg"),
      Backgrounds(name: "home#4.jpg", location: "home#4.jpg"),
      Backgrounds(name: "home#5.jpg", location: "home#5.jpg"),
      Backgrounds(name: "home#6.jpg", location: "home#6.jpg"),
      Backgrounds(name: "home#7.jpg", location: "home#7.jpg"),
      Backgrounds(name: "home#8.jpg", location: "home#8.jpg"),
    ];
  }
}
