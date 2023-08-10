abstract class BaseModelClass {
  Map<String?, dynamic> toJson();

  fromJson(Map<String?, dynamic> json);

  set(String fieldName, dynamic fieldValue);

  dynamic get(String fieldName);
}
