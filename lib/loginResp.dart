class Login {
  bool success;
  String msg;
  final data dat;

  Login({this.success, this.msg, this.dat});

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      success: json["success"],
      msg: json["msg"],
      dat: data.fromJson(
        json['data'],
      ),
    );
  }
}

class LoginOnly {
  bool success;
  String msg;

  LoginOnly({this.success, this.msg});

  factory LoginOnly.fromJson(Map<String, dynamic> json) {
    return LoginOnly(
      success: json["success"],
      msg: json["msg"],
    );
  }
}

class data {
  final String Name,
      EmailName,
      ProfileImage,
      MobileNo,
      EmployeeGUID,
      DriverNo,
      PCOLicense;
  final bool IsAllowed, CanSwapVehicle;
  final int Id, DriverId;
  final Address address;
  final Vehicle vehicle;

  data(
      {this.Id,
      this.DriverId,
      this.ProfileImage,
      this.EmailName,
      this.Name,
      this.MobileNo,
      this.DriverNo,
      this.PCOLicense,
      this.EmployeeGUID,
      this.IsAllowed,
      this.address,
      this.vehicle,
      this.CanSwapVehicle});

  factory data.fromJson(Map<String, dynamic> json) {
    return data(
      Id: json["Id"] == null ? null : json["Id"],
      DriverId: json["DriverId"],
      ProfileImage: json["ProfileImage"],
      EmailName: json["EmailName"],
      Name: json["Name"],
      MobileNo: json["MobileNo"],
      DriverNo: json["DriverNo"],
      PCOLicense: json["PCOLicense"],
      EmployeeGUID: json["EmployeeGUID"],
      IsAllowed: json["IsAllowed"],
      address: Address.fromJson(
        json['Address'],
      ),
      vehicle: Vehicle.fromJson(
        json['Vehicle'],
      ),
      CanSwapVehicle: json["CanSwapVehicle"],
    );
  }
}

class Address {
  final String PremiseName, Address2, Address3, Latitude, Longitude, County;
  final int Id, DriverId;

  Address(
      {this.Id,
      this.DriverId,
      this.Address3,
      this.Address2,
      this.PremiseName,
      this.County,
      this.Latitude,
      this.Longitude});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      Id: json["Id"],
      DriverId: json["DriverId"],
      Address3: json["Address3"],
      Address2: json["Address2"],
      PremiseName: json["PremiseName"],
      County: json["County"],
      Latitude: json["Latitude"],
      Longitude: json["Longitude"],
    );
  }
}

class Vehicle {
  final String Variant, Make, Model, Colour, RegNo;
  final int Id;

  Vehicle(
      {this.Id, this.Model, this.Make, this.Variant, this.Colour, this.RegNo});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      Id: json["Id"],
      Model: json["Model"],
      Make: json["Make"],
      Variant: json["Variant"],
      Colour: json["Colour"],
      RegNo: json["RegNo"],
    );
  }
}
