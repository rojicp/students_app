import 'package:students_app/models/base_model.dart';

class Student implements BaseModelClass {
  int? id;
  String? studentName;
  String? studentAddress;
  int? studentAge;
  String? gender;
  String? courseId;
  String? courseName;

  @override
  get(String fieldName) {
    Map<String?, dynamic> _mapRep = toJson();

    if (_mapRep.containsKey(fieldName)) {
      return _mapRep[fieldName];
    }
  }

  @override
  set(String fieldName, fieldValue) {
    Map<String?, dynamic> _mapRep = toJson();
    if (_mapRep.containsKey(fieldName)) {
      _mapRep[fieldName] = fieldValue;
      fromJson(_mapRep);
    }
  }

  @override
  Map<String?, dynamic> toJson() {
    final Map<String?, dynamic> data = <String?, dynamic>{};

    data['id'] = id;
    data['student_name'] = studentName;
    data['address'] = studentAddress;
    data['student_age'] = studentAge;
    data['gender'] = gender;
    data['course_id'] = courseId;
    data['course_name'] = courseName;

    return data;
  }

  @override
  fromJson(Map<String?, dynamic> json) {
    id = json['id'];
    studentName = json['student_name'];
    studentAddress = json['address'];
    studentAge = json['student_age'];
    gender = json['gender'];
    courseId = json['course_id'];
    courseName = json['course_name'];
  }
}
