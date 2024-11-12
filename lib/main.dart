import 'dart:convert';
import 'dart:io';
import 'package:auradocs_android/Models/users.dart';
import 'package:auradocs_android/screens/File-sharing/external_file_share.dart';
import 'package:auradocs_android/screens/home_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_handler/share_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/Sliders/landing_page.dart';

List<CameraDescription> cameras = [];
late SharedPreferences _storage;

class PostHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _storage = await SharedPreferences.getInstance();
  cameras = await availableCameras();
  String username = "";
  String token = "";
  String code = "";
  List authentication = [];
  await Permission.storage.request();
  HttpOverrides.global = new PostHttpOverrides();

  final sharedMedia1 = await ShareHandler.instance.getInitialSharedMedia();

  String? authListJson = _storage.getString('authentication');
  authentication =
      authListJson != null ? List<String>.from(jsonDecode(authListJson)) : [];

  if (_storage.getString('user_data') != null) {
    Map<String, dynamic> userObj = jsonDecode(_storage.getString('user_data')!);
    username = userObj["value"]["userName"];
    token = _storage.getString('token')!;
    code = _storage.getString('code')!;
  }

  if (sharedMedia1 != null) {
    runApp(
      MaterialApp(
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.amber),
        home: ShareingFilesReceiveScreen(
          sharedMedia: sharedMedia1,
          userName: username,
          token: token,
          code: code,
        ),
      ),
    );
  } else {
    runApp(
      MaterialApp(
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.amber),
        home: MyApp(
            _storage, username, token, code, authentication, sharedMedia1),
      ),
    );
  }
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  SharedPreferences storage;
  final String usr, tokn, code;
  final List authetication;
  final sharedMedia2;

  MyApp(this.storage, this.usr, this.tokn, this.code, this.authetication,
      this.sharedMedia2);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    print("tokn $tokn");
    print("usr $usr");
    print("code $code");
    print("sharedMedia2 $sharedMedia2");

    if (tokn == "" && usr == "" && code == "" && sharedMedia2 == null) {
      return MaterialApp(
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
        debugShowMaterialGrid: false,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: LandingScreen(),
      );
    } else if (tokn != "" && usr != "" && code != "" && sharedMedia2 != null) {
      return MaterialApp(
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.amber),
        home: ShareingFilesReceiveScreen(
          sharedMedia: sharedMedia2,
          userName: usr,
          token: tokn,
          code: code,
        ),
      );
    } else {
      return MaterialApp(
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
        debugShowMaterialGrid: false,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: HomePage(
          user: User(
              userName: usr,
              token: tokn,
              authenticated_features: authetication),
          code: code,
        ),
      );
    }
  }
}
