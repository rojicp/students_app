import 'package:students_app/models/base_model.dart';

class Course implements BaseModelClass {
  int? id;
  String? courseName;
  String? courseDetails;

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
    data['course_name'] = courseName;
    data['course_details'] = courseDetails;

    return data;
  }

  @override
  fromJson(Map<String?, dynamic> json) {
    id = json['id'];
    courseName = json['course_name'];
    courseDetails = json['course_details'];
  }
}
