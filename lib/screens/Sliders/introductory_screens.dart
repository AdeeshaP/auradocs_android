import 'dart:async';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart' as position;
import 'package:new_version_plus/new_version_plus.dart';
import 'package:app_version_update/app_version_update.dart';

import '../Login/user_login.dart';

class IntroScreen extends StatefulWidget {
  IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  String lat = "";
  String long = "";
  bool servicestatus = false;
  bool haspermission = false;
  position.Position? pos;
  VersionStatus? versionstatus;
  late SharedPreferences _storage;

  @override
  void initState() {
    super.initState();
    checkLongitudeAndLatitude();
    getVersionStatus();
    Future.delayed(Duration(seconds: 3), () {
      _verifyVersion();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // --------GET App Version Status--------------//
  Future<VersionStatus> getVersionStatus() async {
    NewVersionPlus newVersion =
        NewVersionPlus(androidId: "com.auradot.auradocs");
    VersionStatus? status = await newVersion.getVersionStatus();
    setState(() {
      versionstatus = status;
    });
    return versionstatus!;
  }

  // VERSION UPDATE

  Future<void> _verifyVersion() async {
    AppVersionUpdate.checkForUpdates(
      appleId: '1470368269',
      playStoreId: 'com.auradot.auradocs',
      country: 'us',
    ).then((result) async {
      if (result.canUpdate!) {
        await AppVersionUpdate.showAlertUpdate(
          appVersionResult: result,
          context: context,
          backgroundColor: Colors.grey[200],
          title: 'Update auraDOCS ?',
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 24
                : Responsive.isTabletPortrait(context)
                    ? 28
                    : 27,
          ),
          content: "auraDOCS recommends that you update to the new version. " +
              "You still have auraDOCS ${versionstatus!.localVersion} and new version (${versionstatus!.storeVersion})" +
              " is available in playstore.",
          contentTextStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: Responsive.isMobileSmall(context) ||
                      Responsive.isMobileMedium(context) ||
                      Responsive.isMobileLarge(context)
                  ? 16
                  : Responsive.isTabletPortrait(context)
                      ? 25
                      : 24,
              height: 1.44444),
          updateButtonText: 'UPDATE',
          updateTextStyle: TextStyle(
            fontSize: Responsive.isMobileSmall(context)
                ? 14
                : Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 16
                    : Responsive.isTabletPortrait(context)
                        ? 18
                        : 18,
          ),
          updateButtonStyle: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            ),
            foregroundColor: WidgetStateProperty.all(Colors.white),
            backgroundColor: WidgetStateProperty.all(Colors.green[900]),
            minimumSize: Responsive.isMobileSmall(context)
                ? WidgetStateProperty.all(Size(90, 40))
                : Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? WidgetStateProperty.all(Size(100, 45))
                    : Responsive.isTabletPortrait(context)
                        ? WidgetStateProperty.all(Size(160, 60))
                        : WidgetStateProperty.all(Size(140, 50)),
          ),
          cancelButtonText: 'NO THANKS',
          cancelButtonStyle: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            ),
            foregroundColor: WidgetStateProperty.all(Colors.white),
            backgroundColor: WidgetStateProperty.all(Colors.red[900]),
            minimumSize: Responsive.isMobileSmall(context)
                ? WidgetStateProperty.all(Size(90, 40))
                : Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? WidgetStateProperty.all(Size(100, 45))
                    : Responsive.isTabletPortrait(context)
                        ? WidgetStateProperty.all(Size(160, 60))
                        : WidgetStateProperty.all(Size(140, 50)),
          ),
          cancelTextStyle: TextStyle(
            fontSize: Responsive.isMobileSmall(context)
                ? 14
                : Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 16
                    : Responsive.isTabletPortrait(context)
                        ? 18
                        : 18,
          ),
        );
      }
    });
  }

  Future<void> checkLongitudeAndLatitude() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission;
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Location permissions are denied.',
                textScaler: TextScaler.linear(1),
              ),
            ),
          );
        } else if (permission == LocationPermission.deniedForever) {
          print("Location permissions are permanently denied");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Location permissions are permanently denied.',
                textScaler: TextScaler.linear(1),
              ),
            ),
          );
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        setState(() {});

        _storage = await SharedPreferences.getInstance();
        position.Position pos = await Geolocator.getCurrentPosition();
        long = pos.longitude.toString();
        lat = pos.latitude.toString();

        setState(() {
          _storage.setString('latitiude', lat);
          _storage.setString('longitude', long);
        });
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    PageDecoration pageDecoration = PageDecoration(
      bodyTextStyle: TextStyle(
        fontSize: Responsive.isMobileSmall(context) ||
                Responsive.isMobileMedium(context) ||
                Responsive.isMobileLarge(context)
            ? 18
            : Responsive.isTabletPortrait(context)
                ? 22
                : 25,
        color: Colors.grey,
      ),
      fullScreen: false,
      boxDecoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/auradocs1_bg.jpg"),
          fit: BoxFit.fill,
        ),
      ),
    );

    return SafeArea(
      child: IntroductionScreen(
        globalBackgroundColor: Colors.white,
        showDoneButton: true,
        showNextButton: true,
        pages: <PageViewModel>[
          PageViewModel(
            decoration: pageDecoration,
            titleWidget: Padding(
              padding: EdgeInsets.only(
                right: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.3
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.5
                        : size.width * 0.65,
                top: Responsive.isMobileSmall(context)
                    ? 10
                    : Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 20
                        : Responsive.isTabletPortrait(context)
                            ? size.width * 0.07
                            : size.width * 0.025,
              ),
              child: Text(
                "DOCUMENT CAPTURE",
                style: TextStyle(
                  fontSize: Responsive.isMobileSmall(context)
                      ? 20
                      : Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context)
                          ? 21
                          : Responsive.isTabletPortrait(context)
                              ? size.width * 0.04
                              : size.width * 0.025,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
                textScaler: TextScaler.linear(1),
              ),
            ),
            bodyWidget: Stack(
              children: <Widget>[
                // Container(
                //   child: Text(
                //     "auraDOCS advanced document capturing",
                //     style: TextStyle(
                //       fontSize: Responsive.isMobileSmall(context) ||
                // Responsive.isMobileMedium(context) ||
                // Responsive.isMobileLarge(context)
                //           ? 13
                //           : Responsive.isTabletPortrait(context)
                //               ? size.width * 0.027
                //               : size.width * 0.04,
                //       fontWeight: FontWeight.w700,
                //       color: Color.fromARGB(255, 81, 71, 71),
                //     ),
                //   ),
                // ),
                Padding(
                  padding: Responsive.isMobileSmall(context)
                      ? EdgeInsets.fromLTRB(50.0, 110, 50, 110)
                      : Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context)
                          ? EdgeInsets.fromLTRB(25.0, 140, 50, 150)
                          : Responsive.isTabletPortrait(context)
                              ? EdgeInsets.symmetric(
                                  vertical: size.width * 0.36,
                                  horizontal: size.width * 0.17,
                                )
                              : EdgeInsets.symmetric(
                                  vertical: size.width * 0.08,
                                  horizontal: size.width * 0.1,
                                ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "auraDOCS advance document capturing let you capture documents from any formats",
                      style: Responsive.isMobileSmall(context)
                          ? TextStyle(fontSize: 21)
                          : Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? Theme.of(context).textTheme.headlineSmall
                              : Responsive.isTabletPortrait(context)
                                  ? Theme.of(context).textTheme.headlineMedium
                                  : Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                      textScaler: TextScaler.linear(1),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? size.height * 0.45
                        : Responsive.isTabletPortrait(context)
                            ? size.height * 0.5
                            : size.height * 0.4,
                  ),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuradocsLogin(),
                          ),
                        );
                      },
                      child: Text(
                        "Let\'s Go",
                        style: GoogleFonts.lato(
                          textStyle: Theme.of(context).textTheme.bodyLarge,
                          fontSize: Responsive.isMobileSmall(context) ||
                                  Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? size.width * 0.055
                              : Responsive.isTabletPortrait(context)
                                  ? size.width * 0.035
                                  : size.width * 0.02,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                        textScaler: TextScaler.linear(1),
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            Color.fromARGB(255, 225, 120, 49)),
                        minimumSize: Responsive.isMobileSmall(context) ||
                                Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? WidgetStateProperty.all(
                                Size(size.width * 0.5, size.width * 0.12))
                            : Responsive.isTabletPortrait(context)
                                ? WidgetStateProperty.all(
                                    Size(size.width * 0.38, size.width * 0.09))
                                : WidgetStateProperty.all(
                                    Size(size.width * 0.25, size.width * 0.04)),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                                color: Color.fromARGB(255, 166, 81, 12)),
                          ),
                        ),
                        shadowColor: WidgetStateProperty.all(
                            Color.fromARGB(255, 20, 19, 17)),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          PageViewModel(
            decoration: pageDecoration,
            titleWidget: Padding(
              padding: EdgeInsets.only(
                right: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.38
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.55
                        : size.width * 0.7,
                top: Responsive.isMobileSmall(context)
                    ? 10
                    : Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 20
                        : Responsive.isTabletPortrait(context)
                            ? size.width * 0.07
                            : size.width * 0.025,
              ),
              child: Text(
                "DOCUMENT INDEX",
                style: TextStyle(
                  fontSize: Responsive.isMobileSmall(context) ||
                          Responsive.isMobileMedium(context) ||
                          Responsive.isMobileLarge(context)
                      ? 22
                      : Responsive.isTabletPortrait(context)
                          ? size.width * 0.04
                          : size.width * 0.025,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
                textScaler: TextScaler.linear(1),
              ),
            ),
            bodyWidget: Stack(
              children: <Widget>[
                // Text(
                //   "auraDOCS advanced document indexing",
                //   style: TextStyle(
                //     fontSize: Responsive.isMobileSmall(context) ||
                // Responsive.isMobileMedium(context) ||
                // Responsive.isMobileLarge(context)
                //         ? 13
                //         : Responsive.isTabletPortrait(context)
                //             ? size.width * 0.027
                //             : size.width * 0.04,
                //     fontWeight: FontWeight.w700,
                //     color: Color.fromARGB(255, 81, 71, 71),
                //   ),
                // ),
                Padding(
                  padding: Responsive.isMobileSmall(context)
                      ? EdgeInsets.fromLTRB(50.0, 110, 50, 110)
                      : Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context)
                          ? EdgeInsets.fromLTRB(25.0, 140, 50, 150)
                          : Responsive.isTabletPortrait(context)
                              ? EdgeInsets.symmetric(
                                  vertical: size.width * 0.36,
                                  horizontal: size.width * 0.17,
                                )
                              : EdgeInsets.symmetric(
                                  vertical: size.width * 0.08,
                                  horizontal: size.width * 0.1,
                                ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "auraDOCS advance document indexing let you categorize the documents easily",
                      style: Responsive.isMobileSmall(context)
                          ? TextStyle(fontSize: 21)
                          : Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? Theme.of(context).textTheme.headlineSmall
                              : Responsive.isTabletPortrait(context)
                                  ? Theme.of(context).textTheme.headlineMedium
                                  : Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                      textScaler: TextScaler.linear(1),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? size.height * 0.45
                        : Responsive.isTabletPortrait(context)
                            ? size.height * 0.5
                            : size.height * 0.4,
                  ),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuradocsLogin(),
                          ),
                        );
                      },
                      child: Text(
                        "Let\'s Go",
                        style: GoogleFonts.lato(
                          textStyle: Theme.of(context).textTheme.bodyLarge,
                          fontSize: Responsive.isMobileSmall(context) ||
                                  Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? size.width * 0.055
                              : Responsive.isTabletPortrait(context)
                                  ? size.width * 0.035
                                  : size.width * 0.02,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                        textScaler: TextScaler.linear(1),
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            Color.fromARGB(255, 225, 120, 49)),
                        minimumSize: Responsive.isMobileSmall(context) ||
                                Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? WidgetStateProperty.all(
                                Size(size.width * 0.5, size.width * 0.12))
                            : Responsive.isTabletPortrait(context)
                                ? WidgetStateProperty.all(
                                    Size(size.width * 0.38, size.width * 0.09))
                                : WidgetStateProperty.all(
                                    Size(size.width * 0.25, size.width * 0.04)),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                                color: Color.fromARGB(255, 166, 81, 12)),
                          ),
                        ),
                        shadowColor: WidgetStateProperty.all(
                            Color.fromARGB(255, 20, 19, 17)),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          PageViewModel(
            decoration: pageDecoration,
            titleWidget: Padding(
              padding: EdgeInsets.only(
                right: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.32
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.5
                        : size.width * 0.68,
                top: Responsive.isMobileSmall(context)
                    ? 10
                    : Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 20
                        : Responsive.isTabletPortrait(context)
                            ? size.width * 0.07
                            : size.width * 0.025,
              ),
              child: Text(
                "DOCUMENT SEARCH",
                style: TextStyle(
                  fontSize: Responsive.isMobileSmall(context) ||
                          Responsive.isMobileMedium(context) ||
                          Responsive.isMobileLarge(context)
                      ? 22
                      : Responsive.isTabletPortrait(context)
                          ? size.width * 0.04
                          : size.width * 0.025,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
                textScaler: TextScaler.linear(1),
              ),
            ),
            bodyWidget: Stack(
              children: <Widget>[
                // Text(
                //   "auraDOCS easy document searching",
                //   style: TextStyle(
                //     fontSize: Responsive.isMobileSmall(context) ||
                // Responsive.isMobileMedium(context) ||
                // Responsive.isMobileLarge(context)
                //         ? 14
                //         : Responsive.isTabletPortrait(context)
                //             ? size.width * 0.027
                //             : size.width * 0.04,
                //     fontWeight: FontWeight.w700,
                //     color: Color.fromARGB(255, 81, 71, 71),
                //   ),
                // ),
                Padding(
                  padding: Responsive.isMobileSmall(context)
                      ? EdgeInsets.fromLTRB(50.0, 110, 50, 110)
                      : Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context)
                          ? EdgeInsets.fromLTRB(25.0, 150, 50, 150)
                          : Responsive.isTabletPortrait(context)
                              ? EdgeInsets.symmetric(
                                  vertical: size.width * 0.36,
                                  horizontal: size.width * 0.17,
                                )
                              : EdgeInsets.symmetric(
                                  vertical: size.width * 0.08,
                                  horizontal: size.width * 0.1,
                                ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "auraDOCS let you find the documents in fast and easily.",
                      style: Responsive.isMobileSmall(context)
                          ? TextStyle(
                              fontSize: 21,
                            )
                          : Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? Theme.of(context).textTheme.headlineSmall
                              : Responsive.isTabletPortrait(context)
                                  ? Theme.of(context).textTheme.headlineMedium
                                  : Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                      textScaler: TextScaler.linear(1),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? size.height * 0.45
                        : Responsive.isTabletPortrait(context)
                            ? size.height * 0.5
                            : size.height * 0.4,
                  ),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuradocsLogin(),
                          ),
                        );
                      },
                      child: Text(
                        "Let\'s Go",
                        style: GoogleFonts.lato(
                          textStyle: Theme.of(context).textTheme.bodyLarge,
                          fontSize: Responsive.isMobileSmall(context) ||
                                  Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? size.width * 0.055
                              : Responsive.isTabletPortrait(context)
                                  ? size.width * 0.035
                                  : size.width * 0.02,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                        textScaler: TextScaler.linear(1),
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            Color.fromARGB(255, 225, 120, 49)),
                        minimumSize: Responsive.isMobileSmall(context) ||
                                Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? WidgetStateProperty.all(
                                Size(size.width * 0.5, size.width * 0.12))
                            : Responsive.isTabletPortrait(context)
                                ? WidgetStateProperty.all(
                                    Size(size.width * 0.38, size.width * 0.09))
                                : WidgetStateProperty.all(
                                    Size(size.width * 0.25, size.width * 0.04)),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                                color: Color.fromARGB(255, 166, 81, 12)),
                          ),
                        ),
                        shadowColor: WidgetStateProperty.all(
                            Color.fromARGB(255, 20, 19, 17)),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),

          //add more screen here
        ],

        onDone: () => goHomepage(context), //go to home page on done
        onSkip: () => goHomepage(context), // You can override on skip
        showSkipButton: true,
        dotsFlex: 0,
        nextFlex: 0,
        skipOrBackFlex: 0,
        skip: Padding(
          padding: Responsive.isMobileSmall(context)
              ? EdgeInsets.only(
                  left: size.width * 0.32,
                  right: size.width * 0.04,
                  bottom: size.width * 0.16,
                  top: size.width * 0.17,
                )
              : Responsive.isMobileMedium(context) ||
                      Responsive.isMobileLarge(context)
                  ? EdgeInsets.only(
                      left: size.width * 0.31,
                      right: size.width * 0.04,
                      bottom: size.width * 0.19,
                      top: size.width * 0.18,
                    )
                  : Responsive.isTabletPortrait(context)
                      ? EdgeInsets.only(
                          left: size.width * 0.4,
                          right: size.width * 0.06,
                          bottom: size.width * 0.11,
                          top: size.width * 0.11,
                        )
                      : EdgeInsets.only(
                          left: size.width * 0.5,
                          right: size.width * 0.04,
                          top: size.width * 0.005,
                          bottom: size.width * 0.005,
                        ),
          child: Text(
            'Skip',
            style: TextStyle(
              fontSize: Responsive.isMobileSmall(context)
                  ? 16
                  : Responsive.isMobileMedium(context)
                      ? 18
                      : Responsive.isMobileLarge(context)
                          ? 19
                          : Responsive.isTabletPortrait(context)
                              ? 21
                              : 22,
              color: Color.fromARGB(255, 166, 81, 12),
            ),
            textScaler: TextScaler.linear(1),
          ),
        ),
        next: Padding(
          padding: Responsive.isMobileSmall(context)
              ? EdgeInsets.only(
                  left: size.width * 0.04,
                  top: 5,
                )
              : Responsive.isMobileMedium(context) ||
                      Responsive.isMobileLarge(context)
                  ? EdgeInsets.only(
                      left: size.width * 0.03,
                      top: size.width * 0.003,
                    )
                  : Responsive.isTabletPortrait(context)
                      ? EdgeInsets.only(
                          left: size.width * 0.09,
                          top: 0,
                        )
                      : EdgeInsets.only(
                          left: size.width * 0.05,
                          bottom: size.width * 0.05,
                          top: size.width * 0.05,
                        ),
          child: Text(
            'Next',
            style: TextStyle(
              fontSize: Responsive.isMobileSmall(context)
                  ? 16
                  : Responsive.isMobileMedium(context)
                      ? 18
                      : Responsive.isMobileLarge(context)
                          ? 19
                          : Responsive.isTabletPortrait(context)
                              ? 21
                              : 22,
              color: Color.fromARGB(255, 166, 81, 12),
            ),
            textScaler: TextScaler.linear(1),
          ),
        ),
        done: Padding(
          padding: Responsive.isMobileSmall(context) ||
                  Responsive.isMobileMedium(context) ||
                  Responsive.isMobileLarge(context)
              ? EdgeInsets.only(
                  left: size.width * 0.02,
                )
              : Responsive.isTabletPortrait(context)
                  ? EdgeInsets.only(
                      left: size.width * 0.05,
                      top: size.width * 0.0025,
                    )
                  : EdgeInsets.only(
                      left: size.width * 0.05,
                      bottom: size.width * 0.05,
                      top: size.width * 0.05,
                    ),
          child: Text(
            'Done',
            style: TextStyle(
              fontSize: Responsive.isMobileSmall(context)
                  ? 16
                  : Responsive.isMobileMedium(context)
                      ? 18
                      : Responsive.isMobileLarge(context)
                          ? 19
                          : Responsive.isTabletPortrait(context)
                              ? 21
                              : 22,
              color: Color.fromARGB(255, 166, 81, 12),
            ),
            textScaler: TextScaler.linear(1),
          ),
        ),
        dotsDecorator: DotsDecorator(
          size: Size(10.0, 10.0), //size of dots
          color: Color.fromARGB(255, 121, 120, 120), //color of dots
          activeSize: Size(12.0, 10.0),
          activeColor: Colors.white, //color of active dot
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
      ),
    );
  }

  void goHomepage(context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) {
      return AuradocsLogin();
    }), (Route<dynamic> route) => false);
  }
}
