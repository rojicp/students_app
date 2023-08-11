import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/course.dart';
import '../services/global.dart';
import '../widgets/input_text.dart';

import 'package:dropdown_button2/dropdown_button2.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  TextEditingController courseName = TextEditingController();
  TextEditingController courseDetails = TextEditingController();

  final formGlobalKey = GlobalKey<FormState>();
  String courseId = "";

  List<Course> courseList = [];

  @override
  Widget build(BuildContext context) {
    double logoWidth = 150;
    double logoHeight = 150;
    if (MediaQuery.of(context).size.width < 800) {
      logoWidth = 75;
      logoHeight = 75;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Course Page"),
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
      body: Container(
        decoration:
            BoxDecoration(color: const Color.fromARGB(255, 132, 159, 171)),
        child: Padding(
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
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // InputText(
                        //   caption: 'Course Name',
                        //   controller: courseName,
                        //   width: 250,
                        // ),
                        // InputText(
                        //   caption: 'Course Details',
                        //   controller: courseDetails,
                        //   width: 300,
                        // ),
                      ],
                    )),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                "List of Courses",
                style: TextStyle(fontSize: 20),
              ),
              FutureBuilder(
                future: getList(),
                builder: (context, snapshot) {
                  return Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: courseList.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 181, 220, 237),
                              border: Border(
                                  bottom: BorderSide(color: Colors.black))),
                          child: InkWell(
                            onTap: () {
                              courseId = courseList[index].id.toString();
                              courseName.text =
                                  courseList[index].courseName ?? "";
                              courseDetails.text =
                                  courseList[index].courseDetails ?? "";
                            },
                            child: ListTile(
                              leading: const Icon(Icons.man),
                              title: Text(courseList[index].courseName ?? ""),
                              subtitle: Text(
                                  " Details : ${courseList[index].courseDetails}"),
                              trailing: ElevatedButton(
                                  onPressed: () {
                                    courseId = courseList[index].id.toString();
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
      ),
    );
  }

  Future<void> saveRecord() async {
    try {
      Map<String, dynamic> body = {
        'id': courseId,
        'course_name': courseName.text,
        'course_details': courseDetails.text,
      };

      Uri url = Uri.parse("http://localhost:8080/course/create");
      if (courseId.isNotEmpty) {
        url = Uri.parse("http://localhost:8080/course/update");
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
        if (courseId.isEmpty) {
          courseId = data["id"].toString();
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

      Uri url = Uri.parse("http://localhost:8080/course/getlist");

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

        courseList.clear();
        jsonData.forEach((jsonItem) {
          Course course = Course();
          course.id = jsonItem['id'];
          course.courseName = jsonItem['course_name'];
          course.courseDetails = jsonItem['course_details'];

          courseList.add(course);
        });

        print(courseList.length);

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
        'id': courseId,
        'course_name': courseName.text,
        'course_details': courseDetails.text
      };

      if (courseId.isEmpty) {
        showMessage(context, "Select a record...");
      }

      Uri url = Uri.parse("http://localhost:8080/course/delete");

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
    courseId = "";
    courseName.text = "";
    courseDetails.text = "";
  }
}
