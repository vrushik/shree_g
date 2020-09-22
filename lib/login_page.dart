import 'package:app_settings/app_settings.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:screen/screen.dart';
import 'home_page.dart';
//import 'package:simple_permissions/simple_permissions.dart';

class LoginPage extends StatefulWidget {

  static String tag = 'login-page';

  @override
  _LoginPageState createState() => new _LoginPageState();

}

class _LoginData {
  String driverid = '';
  String password = '';
}

class _LoginPageState extends State<LoginPage> {

  final driverController = TextEditingController();
  final passwordController = TextEditingController();

  var driverID_validate = false;
  var password_validate = false;

  bool monVal = false;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  _LoginData _data = new _LoginData();

  String status;
//  Permission permission;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    status =  "Select an item";
//    print(Permission.values);
  }

//  requestPermission() async {
//    String res =  (await SimplePermissions.requestPermission(permission)) as String;
//    print('Permission result is ${res.toString()}');
//
//    setState(() {
//      status = '${permission.toString()} = ${res.toString()}';
//    });
//  }

  _submit() async {
    var result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.none) {
      _showInternetDialog('No internet', "Internet connection required!");
    } else {
      setState(() {
        driverController.text.isEmpty
            ? driverID_validate = true
            : driverID_validate = false;
        passwordController.text.isEmpty
            ? password_validate = true
            : password_validate = false;
      });

//      _formKey.currentState.save(); // Save our form now.

      if(_data.driverid.trim().length > 0 && _data.password.trim().length>0){
        print('DriverID: ${_data.driverid}');
        print('Password: ${_data.password}');
      } else {
        print('Fields are empty!');
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
                child: Text('OK'),
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

    Screen.keepOn(true);
    Screen.setBrightness(1.0);

//    requestPermission();

    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 90.0,
        child: Image.asset('assets/icon.jpg'),
      ),
    );

    final driver = TextFormField(
        controller: driverController,
        keyboardType: TextInputType.emailAddress,
        // Use email input type for emails.
        decoration: new InputDecoration(
            labelText: 'DriverID',
            errorText: driverID_validate ? 'Required field!' : null,
            icon: new Icon(Icons.account_circle)),
        onSaved: (String value) {
          this._data.driverid = value;
        },
    );

    final password = TextFormField(
        controller: passwordController,
        obscureText: true, // Use secure text for passwords.
        decoration: new InputDecoration(
            labelText: 'Password',
            errorText: password_validate ? 'Required field!' : null,
            icon: new Icon(Icons.lock)),
        onSaved: (String value) {
          this._data.password = value;
        },
    );

//    final loginButton = Padding(
//      padding: EdgeInsets.symmetric(vertical: 16.0),
//      child: RaisedButton(
//        shape: RoundedRectangleBorder(
//          borderRadius: BorderRadius.circular(0),
//        ),
//        onPressed: () {
//          Navigator.of(context).pushNamed(HomePage.tag);
//        },
//        padding: EdgeInsets.all(12),
//        color: Colors.black45,
//        child: Text('Log In', style: TextStyle(color: Colors.white)),
//      ),
//    );

    final rememberMe = Row(
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
        Text("Remember me"),
      ],
    );

    final loginButton = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Container(
          height: 60.0,
          width: 340,
          margin: const EdgeInsets.only(top: 15.0),
          child: new RaisedButton(
            child: new Text(
              'Login',
              style: new TextStyle(
                color: Colors.white,
                fontFamily: 'Maven_pro_bold',
                fontSize: 22,
              ),
            ),
            onPressed: _submit,
            color: Colors.black54,
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          children: <Widget>[
            logo,
            SizedBox(height: 8.0),
            driver,
            SizedBox(height: 14.0),
            password,
            SizedBox(height: 20.0),
            rememberMe,
            SizedBox(height: 10.0),
            loginButton
//            ,forgotLabel
          ],
        ),
      ),
    );
  }
}
