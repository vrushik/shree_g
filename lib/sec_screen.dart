import 'package:app_settings/app_settings.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shreeganesh/JobDetail.dart';

import 'api.dart';
import 'app_localizations.dart';

void main() => runApp(Sec_screen());

class Sec_screen extends StatefulWidget {
  @override
  _Sec_screenState createState() => new _Sec_screenState();
}

class _Sec_screenState extends State<Sec_screen> {
  String dID, pswd, deviceID, PassengerName = "", PassengerAdd = "", name = "";
  var lat, longi;
  List<SourcefileName> source = new List();
  bool jobAvailable = false, noData = true;

  @override
  Future<void> initState() {
    _submit();
    super.initState();
    _getCurrentLocation();

    getAPICall(lat, longi).then((_) {
      setState(() {
        build(context);
      });
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
  }

  Future<void> _getCurrentLocation() async {
    final locData = await Location().getLocation();

    lat = locData.latitude;
    longi = locData.longitude;

    print(locData.latitude);
    print(locData.longitude);
  }

  _submit() async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    name = myPrefs.getString('name');
    print(name);
  }

  getAPICall(var latitude, var longitude) async {
//    FocusScope.of(context).requestFocus(FocusNode());
    var result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.none) {
      _showInternetDialog(AppLocalizations.of(context).translate('nointernet'),
          AppLocalizations.of(context).translate('internetreq'));
    } else {
      SharedPreferences myPrefs = await SharedPreferences.getInstance();

      dID = myPrefs.getString('driverId');
      pswd = myPrefs.getString('password');

      String speed = "0.0";

      var resp = await getDataAPICalling(
          dID, pswd, "", '${dID}, ${latitude}, ${longitude}, ${speed}');
      print(resp);

      JobData jobdata = new JobData.fromJson(resp);

      if (jobdata.success == true) {
        Job job = new Job.fromJson(resp);

        if(job != null && job.dat != null) {

          jobAvailable = true;
          noData = false;

          PassengerName = job.dat.passengers[0].Name;

          PassengerAdd = job.dat.destinationAddress.Town.toString() +
              ", " +
              job.dat.destinationAddress.Postcode.toString();

          source = job.dat.sourcefilename;
        } else if(job != null && job.dat == null){

          jobAvailable = false;
          noData = true;

        } else {

          jobAvailable = false;
          noData = true;

        }

        setState(() {
          build(context);
        });

      } else {
        print('API Error : =====> Success False}');
      }
    }
  }

  _showInternetDialog(title, text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(text),
            actions: <Widget>[
              FlatButton(
                child: Text(AppLocalizations.of(context).translate('ok')),
                onPressed: () {
                  Navigator.of(context).pop();
                  AppSettings.openDataRoamingSettings();
                },
              )
            ],
          );
        });
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text(
                AppLocalizations.of(context).translate('are_you_want_logout'),
                style: new TextStyle(
                  color: Colors.black,
                  fontFamily: 'mavenpro',
                  fontSize: 24,
                )),
            actions: <Widget>[
              SizedBox(height: 22, width: 10),
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(AppLocalizations.of(context).translate('no'),
                    style: new TextStyle(
                      color: Colors.lightBlue,
                      fontFamily: 'boldmaven',
                      fontSize: 17,
                    )),
              ),
              new FlatButton(
                child: Text(AppLocalizations.of(context).translate('yes'),
                    style: new TextStyle(
                      color: Colors.lightBlue,
                      fontFamily: 'boldmaven',
                      fontSize: 17,
                    )),
                onPressed: () {
                  logOffAPI(lat, longi);
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          ),
        ) ??
        false;
  }

  logOffAPI(var latitude, var longitude) async {
    FocusScope.of(context).requestFocus(FocusNode());
    var result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.none) {
      _showInternetDialog(AppLocalizations.of(context).translate('nointernet'),
          AppLocalizations.of(context).translate('internetreq'));
    } else {
      SharedPreferences myPrefs = await SharedPreferences.getInstance();

      dID = myPrefs.getString('driverId');
      pswd = myPrefs.getString('password');
      String speed = "0.0";

      var resp = await logoffAPICalling(
          dID, pswd, "", '${dID}, ${latitude}, ${longitude}, ${speed}');
      print("logoff response: ${resp}");

      JobData jobdata = new JobData.fromJson(resp);

      if (jobdata.success == true) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: new Scaffold(
          backgroundColor: Colors.white,
          body: new Column(children: [
            new Container(
                padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 25.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        _onBackPressed();
                      },
                      child: CircleAvatar(
                        radius: 13.0,
                        backgroundColor: Colors.white,
                        child: Image.asset('assets/left_arrow.png'),
                      ),
                    ),
                  ],
                )),
            new Visibility(
                visible: jobAvailable,
                child: Container(
                    height: MediaQuery.of(context).size.height * 0.40,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: source.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.29,
                            child: Card(
                              color: Colors.white,
                              child: Container(
                                child: Center(
                                    child:
                                        Image.network(source[index].FileName)),
                              ),
                            ),
                          );
                        }))),
            new Visibility(
                visible: jobAvailable,
                child: Container(
                  child: Center(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                          margin: const EdgeInsets.only(top: 20.0),
                          child: new Text(
                            PassengerName,
                            style: new TextStyle(
                              shadows: [
                                Shadow(
                                  blurRadius: 4.0,
                                  color: Colors.grey,
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Mavenpro',
                              fontSize: 65,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            new Visibility(
                visible: jobAvailable,
                child: Container(
                  child: Center(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                          margin: const EdgeInsets.all(10.0),
                          child: new Text(
                            PassengerAdd,
                            style: new TextStyle(
                              shadows: [
                                Shadow(
                                  blurRadius: 4.0,
                                  color: Colors.grey,
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                              color: Colors.black,
                              fontFamily: 'Mavenpro',
                              fontSize: 36,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            new Visibility(
              visible: noData,
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: new Center(
                    child: new Text(
                      AppLocalizations.of(context).translate('nojobavailable'),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.grey,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Mavenpro',
                        fontSize: 25,
                      ),
                    ),
                  )),
            ),
          ]),
        ));
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }
}
