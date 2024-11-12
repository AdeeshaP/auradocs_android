import 'dart:async';
import 'package:auradocs_android/screens/Sliders/introductory_screens.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LandingScreen extends StatefulWidget {
  LandingScreen();

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => IntroScreen(),
        ),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        SystemNavigator.pop();
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            width: size.width,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/auradocs_bg_2.jpg"),
                fit: BoxFit.fill,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(children: [
                SizedBox(
                  height: Responsive.isMobileSmall(context)
                      ? size.height * 0.04
                      : Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context) ||
                              Responsive.isTabletPortrait(context)
                          ? size.height * 0.07
                          : 0,
                ),
                Center(
                  child: Image.asset(
                    "assets/images/auradocs_logo-transparent.png",
                    scale: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 1
                        : Responsive.isTabletPortrait(context)
                            ? 0.9
                            : 0.7,
                    width: size.width * 0.9,
                    height: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? size.width * 0.28
                        : Responsive.isTabletPortrait(context)
                            ? size.width * 0.17
                            : size.width * 0.12,
                  ),
                ),
                SizedBox(
                  height: Responsive.isMobileSmall(context) ||
                          Responsive.isMobileMedium(context) ||
                          Responsive.isMobileLarge(context)
                      ? size.height * 0.42
                      : Responsive.isTabletPortrait(context)
                          ? size.width * 0.56
                          : size.width * 0.05,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 40.0),
                  child: Image.asset(
                    "assets/images/auradocs_1-removebg.png",
                    scale: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 1
                        : Responsive.isTabletPortrait(context)
                            ? 0.8
                            : 0.9,
                    width: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? size.width * 0.7
                        : Responsive.isTabletPortrait(context)
                            ? size.width * 0.5
                            : size.width * 0.6,
                    height: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? size.width * 0.38
                        : Responsive.isTabletPortrait(context)
                            ? size.width * 0.4
                            : size.width * 0.5,
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
