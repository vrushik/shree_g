class Person {
  bool success;
  String msg;
  final data dat;

  Person({this.success, this.msg, this.dat});

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      success: json["success"],
      msg: json["msg"],
      dat: data.fromJson(
        json['data'],
      ),
    );
  }
}

class data {
  final double PDAVersion;
  final String AppName;

  data({this.PDAVersion, this.AppName});

  factory data.fromJson(Map<String, dynamic> json) {
    return data(
      PDAVersion: json["PDAVersion"],
      AppName: json["AppName"],
    );
  }
}
