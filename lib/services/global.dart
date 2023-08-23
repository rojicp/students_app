import 'package:flutter/material.dart';

bool showCounterExample = false;

String rootURL = "http://localhost:8080";

showMessage(context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.blueAccent, content: Text(message)));
}

showConfirmation(context, String captionText, Function onOkSelection) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Confirmation"),
        content: Text(captionText),
        actions: [
          ElevatedButton(
              onPressed: () {
                onOkSelection("Ok selected");
                Navigator.of(context).pop();
              },
              child: const Text("Ok")),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel")),
        ],
      );
    },
  );
}
