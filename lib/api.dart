import 'package:http/http.dart' as http;
import 'dart:convert';

Future playStoreVerionCheck(String PDAProduct) async {
  String url =
      'http://api-ivcardodriver.azurewebsites.net/API/DriverLogin/GetAppDetail';
  final response = await http.post(url,
      headers: {"Accept": "Application/json"},
      body: {'PDAProduct': PDAProduct});
  var convertedDataToJson = jsonDecode(response.body);
  return convertedDataToJson;
}

Future login(
    String DriverId, String PassWord, String Deviceid, var xlocation) async {
  String url =
      'http://api-ivcardodriver.azurewebsites.net/API/DriverLogin/Login/';
  Map<String, String> headerParams = {
    "Accept": "Application/json",
    "charset": "UTF-8",
    "X-Location": xlocation,
  };
  final response = await http.post(url,
      headers: headerParams,
      body: {'DriverId': DriverId, 'PassWord': PassWord, 'Deviceid': Deviceid});
  var convertedDataToJson = jsonDecode(response.body);
  return convertedDataToJson;
}

Future updateEmailAPICalling(
    String DriverId, String PassWord, String Email) async {
  String url =
      'http://api-ivcardodriver.azurewebsites.net/API/Booking/UpdateDriverEmail/';
  final response = await http.post(url,
      headers: {"Accept": "Application/json"},
      body: {'DriverId': DriverId, 'PassWord': PassWord, 'Email': Email});
  var convertedDataToJson = jsonDecode(response.body);
  return convertedDataToJson;
}

Future getDataAPICalling(
    String DriverId, String PassWord, String Deviceid, var xlocation) async {
  String url =
      'http://api-ivcardodriver.azurewebsites.net/API/Booking/GetAllBookingsByDriverIdAndStatus_V1/';
  Map<String, String> headerParams = {
    "Accept": "Application/json",
    "charset": "UTF-8",
    "X-Location": xlocation,
  };
  final response = await http.post(url,
      headers: headerParams,
      body: {'DriverId': DriverId, 'PassWord': PassWord, 'Deviceid': Deviceid});
  var convertedDataToJson = jsonDecode(response.body);
  return convertedDataToJson;
}

Future logoffAPICalling(
    String DriverId, String PassWord, String Deviceid, var xlocation) async {
  String url =
      'http://api-ivcardodriver.azurewebsites.net/API/DriverLogin/Logoff/';
  Map<String, String> headerParams = {
    "Accept": "Application/json",
    "charset": "UTF-8",
    "X-Location": xlocation,
  };
  final response = await http.post(url,
      headers: headerParams,
      body: {'DriverId': DriverId, 'PassWord': PassWord, 'Deviceid': Deviceid});
  var convertedDataToJson = jsonDecode(response.body);
  return convertedDataToJson;
}
