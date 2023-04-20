import 'dart:math';

String generatePassword({int length = 10}) {
  const String uppercaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const String lowercaseLetters = 'abcdefghijklmnopqrstuvwxyz';
  const String numbers = '0123456789';
  const String specialCharacters = '!@#\$%^&*()-_+={}[]|\\:;"<>,.?/~';

  String allCharacters =
      '$uppercaseLetters$lowercaseLetters$numbers$specialCharacters';
  Random random = Random.secure();

  List<String> passwordCharacters = List.generate(
      length, (index) => allCharacters[random.nextInt(allCharacters.length)],
      growable: false);

  return passwordCharacters.join();
}
