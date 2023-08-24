import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:students_app/screens/course.dart';

import '../models/course.dart';
import '../models/student_model.dart';
import '../services/global.dart';
import '../widgets/input_text.dart';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:blinking_text/blinking_text.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage>
    with SingleTickerProviderStateMixin {
  final formGlobalKey = GlobalKey<FormState>();
  String studentId = "";
  List<Student> studentList = [];
  List<Course> courseList = [];
  Student studentRecord = Student();
  final List<String> listGender = ['Male', 'Female', 'Others'];
  String? selectedGender;
  Course? selectedCourse;
  int counter = 10;
  ValueNotifier<bool> showHeader = ValueNotifier(true);
  late TabController _tabController;
  Uint8List? _selectedFile;
  String? _selectedFileName = "";

  static List<Tab> myTabs = <Tab>[
    const Tab(
      child: Text(
        "Student",
        style: TextStyle(color: Colors.white),
      ),
    ),
    // const Tab(
    //   child: Text(
    //     "Details",
    //     style: TextStyle(color: Colors.white),
    //   ),
    // ),
  ];

  @override
  void initState() {
    _tabController = TabController(
        vsync: this, length: myTabs.length, animationDuration: Duration.zero);

    Timer.periodic(const Duration(seconds: 2), (timer) {
      print(counter);
      counter--;
      if (counter == 0) {
        print('Cancel timer');
        timer.cancel();
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      print('5 seconds over');
      showHeader.value = false;
    });

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
      body: Container(
        decoration:
            const BoxDecoration(color: Color.fromARGB(255, 132, 159, 171)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formGlobalKey,
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: logoWidth,
                        height: logoHeight,
                        child: const CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/student.jpeg'),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    // ListenableBuilder(
                    //   listenable: showHeader,
                    //   builder: (context, child) {
                    //     if (showHeader.value) {
                    //       return const BlinkText(
                    //         'Please enter some data and save...',
                    //         beginColor: Colors.red,
                    //         endColor: Colors.green,
                    //         //duration: Duration(seconds: 1),
                    //         times: 5,
                    //         style: TextStyle(fontSize: 20),
                    //       );
                    //     } else {
                    //       return SizedBox();
                    //     }
                    //   },
                    // ),
                    TabBar(
                      tabs: myTabs,
                      controller: _tabController,
                    ),
                    SizedBox(
                      height: 2000,
                      child: TabBarView(controller: _tabController, children: [
                        getEntryForm(),
                      ]),
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget getEntryForm() {
    return Container(
      width: double.infinity,
      decoration:
          BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5)),
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputText(
                caption: 'Name',
                modelObject: studentRecord,
                fieldName: "student_name",
                width: 250,
              ),
              InputText(
                caption: 'Address',
                modelObject: studentRecord,
                fieldName: "address",
                width: 300,
              ),
              InputText(
                caption: 'Age',
                modelObject: studentRecord,
                fieldName: "student_age",
                width: 50,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                child: DropdownButton2(
                  hint: const Text("Select Gender"),
                  value: selectedGender,
                  items: listGender
                      .map((String genderCaption) => DropdownMenuItem<String>(
                            value: genderCaption,
                            child: Text(
                              genderCaption,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    selectedGender = value;

                    studentRecord.gender = selectedGender;
                    setState(() {});
                  },
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                  ),
                ),
              ),
              FutureBuilder(
                future: getCourseList(),
                builder: (context, snapshot) {
                  print("selectedCourse=" + selectedCourse.toString());
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                    child: DropdownButton2(
                      hint: const Text("Select Course"),
                      value: selectedCourse,
                      items: courseList
                          .map((Course course) => DropdownMenuItem<Course>(
                                value: course,
                                child: Text(
                                  course.courseName ?? "",
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (course) {
                        selectedCourse = course;
                        studentRecord.courseId = selectedCourse!.id.toString();
                        studentRecord.courseName = selectedCourse!.courseName;

                        setState(() {});
                      },
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40,
                      ),
                    ),
                  );
                },
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _selectFile,
                    child: Text('Select File'),
                  ),
                  Text(_selectedFileName ?? ""),
                  SizedBox(
                    width: 100,
                  ),
                  ElevatedButton(
                    onPressed: _uploadFile,
                    child: Text('Upload'),
                  ),
                ],
              ),
              getListWidget(),
            ],
          )),
    );
  }

  Widget getListWidget() {
    //  const Text(
    //         "List of Students",
    //         style: TextStyle(fontSize: 20),
    //       ),

    return FutureBuilder(
      future: getList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: studentList.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 181, 220, 237),
                    border: Border(bottom: BorderSide(color: Colors.black))),
                child: InkWell(
                  onTap: () {
                    studentRecord = studentList[index];
                    selectedGender = studentList[index].gender;
                    selectedCourse = null;
                    courseList.forEach(
                      (course_record) {
                        if (course_record.courseName ==
                            studentList[index].courseName) {
                          selectedCourse = course_record;
                        }
                      },
                    );

                    setState(() {});
                  },
                  child: ListTile(
                    leading: const Icon(Icons.man),
                    title: Text(studentList[index].studentName ?? ""),
                    subtitle: Text(
                        " Age : ${studentList[index].studentAge}, Address : ${studentList[index].studentAddress ?? ''}, Gender :${studentList[index].gender} "),
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
          );
        }
      },
    );
  }

  Future<void> saveRecord() async {
    try {
      Uri url = Uri.parse("$rootURL/student/create");
      if (studentId.isNotEmpty) {
        url = Uri.parse("$rootURL/student/update");
      }

      final response = await http.post(
        url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode(studentRecord.toJson()),
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

      Uri url = Uri.parse("$rootURL/student/getlist");

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
          // student.id = jsonItem['id'];
          // student.studentName = jsonItem['student_name'];
          // student.studentAge = jsonItem['student_age'];
          // student.studentAddress = jsonItem['address'];
          // student.gender = jsonItem['gender'];

          student.fromJson(jsonItem);

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
      if (studentId.isEmpty) {
        showMessage(context, "Select a record...");
      }

      Uri url = Uri.parse("$rootURL/student/delete");

      final response = await http.post(
        url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode(studentRecord.toJson()),
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
    studentRecord = Student();
    selectedGender = null;
    selectedCourse = null;
    setState(() {});
  }

  Future<void> getCourseList() async {
    try {
      if (courseList.isNotEmpty) return;

      Map<String, dynamic> body = {
        'user_id': "test",
      };

      Uri url = Uri.parse("$rootURL/course/getlist");

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
          course.fromJson(jsonItem);

          courseList.add(course);
        });

        print("courseList.length = ${courseList.length}");

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

  void _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['jpg', 'png']);

    if (result != null) {
      _selectedFile = result.files.first.bytes!;
      setState(() {
        _selectedFileName = result.files.first.name;
      });
    } else {
      // User canceled the picker
    }
  }

  void _uploadFile() async {
    if (_selectedFile != null) {
      var url = Uri.parse("$rootURL/file/upload");
      var request = http.MultipartRequest('POST', url);
      request.fields["user_id"] = "test";

      var multipart = await http.MultipartFile.fromBytes('file', _selectedFile!,
          filename: _selectedFileName,
          contentType: MediaType.parse("application/image"));
      request.files.add(multipart);

      var streamedResponse = await request.send();
      var _result = await http.Response.fromStream(streamedResponse);
      Map<String, dynamic> data = jsonDecode(_result.body);
      showMessage(context, data["message"]);
    } else {
      showMessage(context, "No files selected...");
    }
  }
}
