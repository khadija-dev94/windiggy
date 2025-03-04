import 'dart:convert';
import 'dart:ui';

class CenterPoint {
  Offset centerOffset;
  CenterPoint({this.centerOffset});

  //////////////////////////////////////////////CONVERT OBJECT TO JSON
  Map<String, dynamic> toJson() => _itemToJson(this);

  /////////////////////////////////////////CONVERT
  static List encondeToJson(List<CenterPoint> list) {
    List jsonList = List();
    list.map((item) => jsonList.add(item.toJson())).toList();
    return jsonList;
  }

  factory CenterPoint.fromJson(Map<String, dynamic> parsedJson) {
    return CenterPoint(
      centerOffset: Offset(parsedJson['x'], parsedJson['y']),
    );
  }

  //Given a list of students, encode as Json
  static String listToJson(List<CenterPoint> pointsList) {
    List<Map<String, dynamic>> jsonList = List();
    pointsList.map((item) => jsonList.add(item.toJson())).toList();
    String jsonStr = jsonEncode(jsonList);
    print(jsonStr);

    return jsonStr;
  }

  //Given a JSON string representing an array of Students, decode as a List of Student
  static List<CenterPoint> fromJsonArray(String jsonString) {
    //print(jsonString);
    var dynamicList = jsonDecode(jsonString);
    print(dynamicList);
    List<CenterPoint> students = new List<CenterPoint>();
    dynamicList.forEach((f) {
      print(f);
      students.add(CenterPoint.fromJson(f));
    });

    return students;
  }

  Map<String, dynamic> _itemToJson(CenterPoint centerPoint) {
    return <String, dynamic>{
      'x': centerPoint.centerOffset.dx,
      'y': centerPoint.centerOffset.dy,
    };
  }
}
