class Email {
  bool success;
  String msg;

  Email({this.success, this.msg});

  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      success: json["success"],
      msg: json["msg"],
    );
  }
}
