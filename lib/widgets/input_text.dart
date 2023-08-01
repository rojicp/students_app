import 'package:flutter/material.dart';

class InputText extends StatefulWidget {
  TextEditingController controller;
  String caption;
  double width;

  InputText(
      {super.key,
      required this.controller,
      required this.caption,
      this.width = 150});

  @override
  State<InputText> createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "${widget.caption} is required";
          }
        },
        controller: widget.controller,
        decoration: InputDecoration(labelText: widget.caption),
      ),
    );
  }
}
