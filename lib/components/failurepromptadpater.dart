import 'package:flutter/cupertino.dart';

// create a function to show the error dialog
void showErrorDialog(BuildContext context, String message) {
  showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
}
