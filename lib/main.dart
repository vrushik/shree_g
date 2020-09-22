import 'dart:convert';
import 'dart:io';

import 'package:appcenter/appcenter.dart';
import 'package:appcenter_crashes/appcenter_crashes.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:screen/screen.dart';
import 'package:shreeganesh/login_screen.dart';

import 'app_localizations.dart';
import 'home_page.dart';
import 'login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static bool resumed = true, sec_res = false;

  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    HomePage.tag: (context) => HomePage(),
  };

  @override
  Widget build(BuildContext context) {
    final android = defaultTargetPlatform == TargetPlatform.android;
//    var app_secret = android ? "123cfac9-123b-123a-123f-123273416a48" : "321cfac9-123b-123a-123f-123273416a48";
    var app_secret = android
        ? "79e3f986-bcf2-4072-bcc9-c1eef8076899"
        : "79e3f986-bcf2-4072-bcc9-c1eef8076899";
    AppCenter.start(app_secret, [AppCenterCrashes.id]);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      title: 'iVcardo Meeting Board',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        primaryColor: const Color(0xff636363),
        fontFamily: 'Mavenpro',
      ),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('es', 'AR'),
        Locale('it', 'IT'),
        Locale('ru', 'RU'),
        Locale('sv', 'SE'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },
      home: LoginScreen(),
      routes: routes,
    );
  }
}
