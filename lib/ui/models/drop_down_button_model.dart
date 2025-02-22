import 'dart:convert';

DropDownButtonModel dropDownButtonModelFromJson(String str) =>
    DropDownButtonModel.fromJson(json.decode(str));

String dropDownButtonModelToJson(DropDownButtonModel data) =>
    json.encode(data.toJson());

class DropDownButtonModel {
  DropDownButtonModel({
    required this.id,
    required this.value,
  });

  dynamic id;
  String value;

  factory DropDownButtonModel.fromJson(Map<String, dynamic> json) =>
      DropDownButtonModel(
        id: json["id"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "value": value,
      };
}
