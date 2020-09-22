import 'package:app_settings/app_settings.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:package_info/package_info.dart';
import 'package:permission/permission.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:screen/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shreeganesh/data.dart';
import 'package:shreeganesh/loginResp.dart';
import 'package:shreeganesh/sec_screen.dart';

import 'api.dart';
import 'app_localizations.dart';
import 'emailResp.dart';
import 'main.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginData {
  String driverid = '';
  String password = '';
  String email = '';
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {

  PermissionName permissionName = PermissionName.Location;
  final Location location = Location();

  List<PermissionName> permissionNames = [];
  ProgressDialog pr = null;

  TextEditingController driverController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  var driverID_validate = false,
      password_validate = false,
      email_validate = false,
      lat,
      longi;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<FormState> _emailKey = new GlobalKey<FormState>();

  _LoginData _data = new _LoginData();
  bool monVal = false, _validate = false, _e_validate = false, aa = false;

  String driver_id, pwd, email, dID, pswd, check, message = '';
  Dialog simpleDialog;

  @override
  Future<void> initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    getDIdPaswd().then((_) {
      setState(() {
        driverController = new TextEditingController(text: dID);
        passwordController = new TextEditingController(text: pswd);
      });
    });
  }

  getDIdPaswd() async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();

    dID = myPrefs.getString('driverId');
    pswd = myPrefs.getString('password');
    check = myPrefs.getString('checkbox');

    if (check.toString() == "true") {
      monVal = true;
//      print('data:=====> ${monVal}');
    }
  }

  Future<void> _getCurrentLocation() async {
    final locData = await Location().getLocation();

    lat = locData.latitude;
    longi = locData.longitude;

    print(locData.latitude);
    print(locData.longitude);
  }

  _submit() async {
    FocusScope.of(context).requestFocus(FocusNode());

    await pr.show();
    var result = await Connectivity().checkConnectivity();

    _getCurrentLocation();

    if (result == ConnectivityResult.none) {
      _showInternetDialog(AppLocalizations.of(context).translate('nointernet'),
          AppLocalizations.of(context).translate('internetreq'));
    } else {
      if (_formKey.currentState.validate()) {
        // No any error in validation
        _formKey.currentState.save();
      } else {
        // validation error
        setState(() {
          _validate = true;
        });
      }

      if (driverController.text.trim().length > 0 &&
          passwordController.text.trim().length > 0) {
        print('DriverID: ${driverController.text}');
        print('Password: ${passwordController.text}');

        var resp = await playStoreVerionCheck("1");
        print(resp);

        if (resp.containsKey('success')) {
          Person person = new Person.fromJson(resp);
          print('data: ${person.dat.AppName}');

          PackageInfo packageInfo = await PackageInfo.fromPlatform();

          String buildNumber = packageInfo.buildNumber;
          String version = packageInfo.version;

          print(
              'version: ${version}' + "====>" + 'buildNumber: ${buildNumber}');

          if (person.dat.PDAVersion != 6.4) {
            _showUpdateAppDialog('iVcardo Meeting Board',
                AppLocalizations.of(context).translate('force_update_text'));
          } else {
            _doLoginAuthentication(
                driverController.text, passwordController.text, lat, longi);
          }
        }
      } else {
        print('Fields are empty!');
      }
    }
  }

  _doLoginAuthentication(final String driverId, final String password,
      var latitude, var longitude) async {
    String token = "test";
    String speed = "0.0";

//    var xLocation = driverId + "," + "" + "," + "" + "," + "0.0";
    print('${driverId}, ${latitude}, ${longitude}, ${speed}');

    await pr.hide();
    var resp = await login(driverId, password, token,
        '${driverId}, ${latitude}, ${longitude}, ${speed}');

    LoginOnly only = new LoginOnly.fromJson(resp);

    if (only.success == true) {
      Login login_resp = new Login.fromJson(resp);
      print('data----->: ${login_resp.dat.Name}');

      SharedPreferences myPrefs = await SharedPreferences.getInstance();
      myPrefs.setString('name', login_resp.dat.Name);

      if (monVal) {
        myPrefs.setString('driverId', driverController.text);
        myPrefs.setString('password', passwordController.text);
        myPrefs.setString('checkbox', "true");
      } else {
        myPrefs.setString('checkbox', "false");
      }

      myPrefs.setString('regno', login_resp.dat.vehicle.RegNo);
      myPrefs.setString('make', login_resp.dat.vehicle.Make);
      myPrefs.setString('model', login_resp.dat.vehicle.Model);
      myPrefs.setString('colour', login_resp.dat.vehicle.Colour);

      String em = driverController.text + "@ivcardo.global";

      if (login_resp.dat.EmailName == em) {
        showSimpleCustomDialog(context);
      } else {
        MyApp.resumed = false;
        aa = false;
        MyApp.sec_res = true;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Sec_screen()));
      }
    } else {
      _showErrorDialog(only.msg);
    }
  }

  _submit_Email() async {
    FocusScope.of(context).requestFocus(FocusNode());
    var result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.none) {
      _showInternetDialog(AppLocalizations.of(context).translate('nointernet'),
          AppLocalizations.of(context).translate('internetreq'));
    } else {
      if (_emailKey.currentState.validate()) {
        _emailKey.currentState.save();
      } else {
        setState(() {
          _e_validate = true;
        });
      }

      if (emailController.text.trim().length > 0) {
        var resp =
            await updateEmailAPICalling(dID, pswd, emailController.text.trim());
        print(resp);

        Email em = new Email.fromJson(resp);

        if (em.success == true) {
          Navigator.of(context).pop();

          SharedPreferences myPrefs = await SharedPreferences.getInstance();
          myPrefs.setString('email', emailController.text.trim());
        } else {
          Navigator.of(context).pop();
          _showErrorDialog(em.msg);
        }
      } else {
        print('Email ID Field Is Empty!');
      }
    }
  }

  _showErrorDialog(text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
//            title: Text(title),
            content: Text(text),
            actions: <Widget>[
              FlatButton(
                child: Text(AppLocalizations.of(context).translate('ok')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  void dispose() {
    emailController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void showSimpleCustomDialog(BuildContext mContext) {
    simpleDialog = new Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Container(
          height: 210.0,
          width: 350.0,
          child: Form(
            key: this._emailKey,
            autovalidate: _e_validate,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                    padding: const EdgeInsets.only(
                        left: 20, top: 10.0, right: 20, bottom: 10),
                    child: new TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        // Use email input type for emails.
                        decoration: new InputDecoration(
                          labelText: AppLocalizations.of(context).translate('enter_email'),
                          errorText: email_validate ? AppLocalizations.of(context).translate('error_required_field') : null,
                        ),
                        validator: validate_Email,
                        onSaved: (String value) {
                          this._data.email = value;
                          email = value;
                        })),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      new Container(
                        height: 60.0,
                        width: 280,
                        child: new RaisedButton(
                          child: new Text(
                            AppLocalizations.of(context).translate('continue_text'),
                            style: new TextStyle(
                              color: Colors.white,
                              fontFamily: 'Maven_pro_bold',
                              fontSize: 22,
                            ),
                          ),
                          onPressed: _submit_Email,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
    showDialog(
        barrierDismissible: false,
        context: mContext,
        builder: (BuildContext context) => simpleDialog);
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
            title: new Text(AppLocalizations.of(context).translate('exit')),
            content: new Text(AppLocalizations.of(context).translate('are_you_want_exit')),
            actions: <Widget>[
              SizedBox(height: 22, width: 10),
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(AppLocalizations.of(context).translate('no')),
              ),
              new FlatButton(
                child: Text(AppLocalizations.of(context).translate('yes')),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        ) ??
        false;
  }

  _showUpdateAppDialog(title, text) {
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

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);

    getDIdPaswd();

    pr = ProgressDialog(context);

    pr.style(
      borderRadius: 2.0,
      message: AppLocalizations.of(context).translate('pleasewait'),
      progressWidget: CircularProgressIndicator(),
      elevation: 5.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
    );

    permissionNames.add(PermissionName.Storage);
    permissionNames.add(PermissionName.Location);
    permissionNames.add(PermissionName.Camera);

    Permission.requestPermissions(permissionNames);

    getDIdPaswd();

    Screen.keepOn(true);
    Screen.setBrightness(1.0);

    return WillPopScope(
        onWillPop: _onBackPressed,
        child: new Scaffold(
          //key: this.scaffoldKey,
          backgroundColor: Colors.white,
          body: new Container(
              padding: new EdgeInsets.only(left: 28.0, right: 28.0),
              child: new Form(
                key: this._formKey,
                autovalidate: _validate,
                child: Center(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        new Container(
                            child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircleAvatar(
                              radius: 90.0,
                              child: Image.asset('assets/icon.jpg'),
                            ),
                          ],
                        )),
                        new Container(
                            padding: const EdgeInsets.only(
                                left: 12.0, top: 20.0, right: 12.0),
                            child: new TextFormField(
                                controller: driverController,
                                keyboardType: TextInputType.emailAddress,
                                // Use email input type for emails.
                                decoration: new InputDecoration(
                                    labelText: AppLocalizations.of(context).translate('prompt_username'),
                                    icon: new Icon(Icons.account_circle)),
                                validator: validate_DriverID,
                                onSaved: (String value) {
                                  this._data.driverid = value;
                                  driver_id = value;
                                })),
                        new Container(
                          padding: const EdgeInsets.only(
                              left: 12.0, top: 10.0, right: 12.0),
                          child: new TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              // Use secure text for passwords.
                              decoration: new InputDecoration(
                                  labelText: AppLocalizations.of(context).translate('prompt_password'),
                                  icon: new Icon(Icons.lock)),
                              validator: validate_Password,
                              onSaved: (String value) {
                                this._data.password = value;
                                pwd = value;
                              }),
                        ),
                        new Container(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: new Row(
                            children: <Widget>[
                              Checkbox(
                                value: monVal,
                                activeColor: Colors.black54,
                                onChanged: (bool value) {
                                  setState(() {
                                    monVal = value;
                                  });
                                },
                              ),
                              Text(AppLocalizations.of(context).translate('rememberme')),
                            ],
                          ),
                        ),
                        new Container(
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Container(
                                height: 65.0,
                                width: 330,
                                margin: const EdgeInsets.only(top: 25.0),
                                child: new RaisedButton(
                                  child: new Text(
                                    AppLocalizations.of(context).translate('logintext'),
                                    style: new TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Mavenpro',
                                      fontSize: 22,
                                    ),
                                  ),
                                  onPressed: _submit,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ));
  }

  String validate_DriverID(String value) {
    String pattern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return AppLocalizations.of(context).translate('error_required_field');
    } else if (!regExp.hasMatch(value)) {
      return AppLocalizations.of(context).translate('invalid_driver_id');
    } else {
      return null;
    }
  }

  String validate_Email(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (value.length == 0) {
      return AppLocalizations.of(context).translate('error_required_field');
    } else if (!regex.hasMatch(value)) {
      return AppLocalizations.of(context).translate('error_enter_valid_email');
    } else {
      return null;
    }
  }

  String validate_Password(String value) {
    if (value.length == 0) {
      return AppLocalizations.of(context).translate('error_required_field');
    } else {
      return null;
    }
  }
}
