import 'package:flutter/material.dart';
import 'package:students_app/models/base_model.dart';

class InputText extends StatefulWidget {
  String caption;
  double width;
  BaseModelClass modelObject;
  String fieldName;

  InputText(
      {super.key,
      required this.caption,
      this.width = 150,
      required this.modelObject,
      required this.fieldName});

  @override
  State<InputText> createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    print("===> initState");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("===> Build");

    String fieldValue = "";
    if (widget.modelObject.get(widget.fieldName) != null) {
      fieldValue = widget.modelObject.get(widget.fieldName).toString();
      if (mounted) {
        controller.text = fieldValue;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: widget.width,
        child: TextFormField(
          //initialValue: fieldValue,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "${widget.caption} is required";
            }
          },
          onChanged: (value) {
            widget.modelObject.set(widget.fieldName, value);
          },
          controller: controller,
          decoration: InputDecoration(labelText: widget.caption),
        ),
      ),
    );
  }
}
