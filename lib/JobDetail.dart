class Job {
  bool success;
  String msg;

  final data dat;

  Job({this.success, this.msg, this.dat});

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      success: json["success"],
      msg: json["msg"],
      dat: data.fromJson(
        json['data'],
      ),
    );
  }
}

class JobData {
  bool success;
  String msg;

  JobData({this.success, this.msg});

  factory JobData.fromJson(Map<String, dynamic> json) {
    return JobData(
      success: json["success"],
      msg: json["msg"],
    );
  }
}

class data {
  final List<Passengers> passengers;
  final List<SourcefileName> sourcefilename;
  final DestinationAddress destinationAddress;

  data({this.passengers, this.destinationAddress, this.sourcefilename});

  factory data.fromJson(Map<String, dynamic> json) {
    return data(
        passengers: parsePassenger(json),
        destinationAddress: DestinationAddress.fromJson(
          json['DestinationAddress'],
        ),
        sourcefilename: parseFile(json));
  }

  static List<Passengers> parsePassenger(passengerJson) {
    var list = passengerJson['Passengers'] as List;
    List<Passengers> passList =
    list.map((data) => Passengers.fromJson(data)).toList();
    return passList;
  }

  static List<SourcefileName> parseFile(fileJson) {
    var list = fileJson['SourcefileName'] as List;
    List<SourcefileName> fileList =
    list.map((data) => SourcefileName.fromJson(data)).toList();
    return fileList;
  }
}

class Passengers {
  String Name;
  String MobileNo;

  Passengers({this.Name, this.MobileNo});

  factory Passengers.fromJson(Map<String, dynamic> json) {
    return Passengers(Name: json["Name"], MobileNo: json["MobileNo"]);
  }
}

class SourcefileName {
  String FileName;

  SourcefileName({this.FileName});

  factory SourcefileName.fromJson(Map<String, dynamic> json) {
    return SourcefileName(FileName: json["FileName"]);
  }
}

class DestinationAddress {
  final String Town, Postcode;

  DestinationAddress({this.Town, this.Postcode});

  factory DestinationAddress.fromJson(Map<String, dynamic> json) {
    return DestinationAddress(
      Town: json["Town"],
      Postcode: json["Postcode"],
    );
  }
}
