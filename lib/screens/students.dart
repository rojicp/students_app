import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/global.dart';
import '../widgets/input_text.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  TextEditingController studentName = TextEditingController();
  TextEditingController studentAddress = TextEditingController();
  TextEditingController studentAge = TextEditingController();
  final formGlobalKey = GlobalKey<FormState>();
  String studentId = "";

  List<Student> studentList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Students Page"),
            const Spacer(),
            ElevatedButton(
                onPressed: () {
                  clearScreen();
                },
                child: const Text("New")),
            ElevatedButton(
                onPressed: () {
                  if (formGlobalKey.currentState!.validate()) {
                    saveRecord();
                  }
                },
                child: const Text("Save"))
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formGlobalKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 0.5)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputText(
                      caption: 'Name',
                      controller: studentName,
                      width: 250,
                    ),
                    InputText(
                      caption: 'Address',
                      controller: studentAddress,
                      width: 300,
                    ),
                    InputText(
                      caption: 'Age',
                      controller: studentAge,
                      width: 50,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "List of Students",
              style: TextStyle(fontSize: 20),
            ),
            FutureBuilder(
              future: getList(),
              builder: (context, snapshot) {
                return Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: studentList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 181, 220, 237),
                            border: Border(
                                bottom: BorderSide(color: Colors.black))),
                        child: InkWell(
                          onTap: () {
                            studentId = studentList[index].id.toString();
                            studentName.text =
                                studentList[index].studentName ?? "";

                            studentAge.text =
                                studentList[index].studentAge.toString();
                          },
                          child: ListTile(
                            leading: const Icon(Icons.man),
                            title: Text(studentList[index].studentName ?? ""),
                            subtitle:
                                Text(" Age : ${studentList[index].studentAge}"),
                            trailing: ElevatedButton(
                                onPressed: () {
                                  studentId = studentList[index].id.toString();
                                  showConfirmation(
                                      context, "Do you want to delete this?",
                                      (String message) {
                                    print(message);
                                    deleteRecord();
                                  });
                                },
                                child: const Text("Delete")),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> saveRecord() async {
    try {
      Map<String, dynamic> body = {
        'id': studentId,
        'student_name': studentName.text,
        'student_age': studentAge.text,
      };

      Uri url = Uri.parse("http://localhost:8080/student/create");
      if (studentId.isNotEmpty) {
        url = Uri.parse("http://localhost:8080/student/update");
      }

      final response = await http.post(
        url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode(body),
      );

      Map<String, dynamic> data = jsonDecode(response.body);
      String msg = data["message"];
      if (msg.toLowerCase().contains("success")) {
        showMessage(context, msg);
        if (studentId.isEmpty) {
          studentId = data["id"].toString();
        }
        clearScreen();
        setState(() {});
        print("msg = $msg");
      } else {
        showMessage(context, msg);
        print("msg = $msg");
      }
    } catch (e) {
      showMessage(context, "Error : $e");
      print("msg = $e}");
    }
  }

  Future<void> getList() async {
    try {
      Map<String, dynamic> body = {
        'user_id': "test",
      };

      Uri url = Uri.parse("http://localhost:8080/student/getlist");

      final response = await http.post(
        url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode(body),
      );

      Map<String, dynamic> data = jsonDecode(response.body);
      String msg = data["message"];
      if (msg.toLowerCase().contains("success")) {
        var jsonData = data["listData"];

        studentList.clear();
        jsonData.forEach((jsonItem) {
          Student student = Student();
          student.id = jsonItem['id'];
          student.studentName = jsonItem['student_name'];
          student.studentAge = jsonItem['student_age'];

          studentList.add(student);
        });

        print(studentList.length);

        //clearScreen();
        print("msg = $msg");
      } else {
        showMessage(context, msg);
        print("msg = $msg");
      }
    } catch (e) {
      showMessage(context, "Error : $e");
      print("msg = $e}");
    }
  }

  Future<void> deleteRecord() async {
    try {
      Map<String, dynamic> body = {
        'id': studentId,
        'student_name': studentName.text,
        'student_age': studentAge.text,
      };

      if (studentId.isEmpty) {
        showMessage(context, "Select a record...");
      }

      Uri url = Uri.parse("http://localhost:8080/student/delete");

      final response = await http.post(
        url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode(body),
      );

      Map<String, dynamic> data = jsonDecode(response.body);
      String msg = data["message"];
      if (msg.toLowerCase().contains("success")) {
        showMessage(context, msg);

        clearScreen();
        setState(() {});
        print("msg = $msg");
      } else {
        showMessage(context, msg);
        print("msg = $msg");
      }
    } catch (e) {
      showMessage(context, "Error : $e");
      print("msg = $e}");
    }
  }

  void clearScreen() {
    studentId = "";
    studentName.text = "";
    studentAddress.text = "";
    studentAge.text = "";
  }
}

class Student {
  int? id;
  String? studentName;
  String? studentAddress;
  int? studentAge;
}
