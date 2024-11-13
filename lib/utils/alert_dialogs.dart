import 'package:auradocs_android/Bloc/document_bloc.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

showProgressDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: <Widget>[
        CircularProgressIndicator(color: Colors.amber),
        SizedBox(
          width: Responsive.isMobileSmall(context) ||
                  Responsive.isMobileMedium(context) ||
                  Responsive.isMobileLarge(context)
              ? 1
              : 10,
        ),
        Container(
          margin: EdgeInsets.only(left: 5),
          child: Text(
            "Loading",
            style: TextStyle(
              fontSize: Responsive.isMobileSmall(context) ||
                      Responsive.isMobileMedium(context) ||
                      Responsive.isMobileLarge(context)
                  ? 15
                  : Responsive.isTabletPortrait(context)
                      ? 24
                      : 20,
            ),
            textScaler: TextScaler.linear(1),
          ),
        ),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

closeDialog(context) {
  Navigator.of(context, rootNavigator: true).pop('dialog');
}

showPendingDocIndexedSuccesfullyPopup(BuildContext context, String imagePath,
    String message, Function okHandler, Color color) {
  Widget okButton = TextButton(
    child: Text(
      "OK",
      style: GoogleFonts.lato(
        textStyle: Theme.of(context).textTheme.bodyMedium,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      textScaler: TextScaler.linear(1),
    ),
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(color),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    ),
    onPressed: () {
      okHandler();
    },
  );

  // show the dialog
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.84,
          height: MediaQuery.of(context).size.height * 0.37,
          padding: EdgeInsets.fromLTRB(30, 15, 30, 10),
          color: Color.fromARGB(255, 218, 216, 216),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              Image.asset(
                imagePath,
                width: 80,
                height: 80,
                alignment: Alignment.centerLeft,
              ),
              SizedBox(height: 15),
              Text(
                textAlign: TextAlign.center,
                message,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.black,
                    height: 1.5,
                    fontSize: 19,
                    fontFamily: "open sans",
                    fontWeight: FontWeight.w500),
                textScaler: TextScaler.linear(1),
              ),
              SizedBox(height: 25),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 100,
                  child: okButton,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// -------------- last Docuent Submit Popup ----------------//
lastDocuentSubmitPopup(BuildContext context, String message, String imagePath,
    Widget yesDestination, Color color, String un, String token) {
  Widget okButton = TextButton(
    child: Text(
      "OK",
      style: GoogleFonts.lato(
        textStyle: Theme.of(context).textTheme.bodyMedium,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      textScaler: TextScaler.linear(1),
    ),
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(color),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    ),
    onPressed: () async {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return BlocProvider(
              create: (context) => DocumentBloc(un, token),
              child: yesDestination);
        }),
      );
    },
  );

  // show the dialog
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.84,
          height: MediaQuery.of(context).size.height * 0.38,
          padding: EdgeInsets.fromLTRB(30, 15, 30, 10),
          color: Color.fromARGB(255, 218, 216, 216),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              Image.asset(
                imagePath,
                width: 80,
                height: 80,
                alignment: Alignment.centerLeft,
              ),
              SizedBox(height: 20),
              Text(
                textAlign: TextAlign.center,
                message,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.black,
                    height: 1.4,
                    fontSize: 19,
                    fontFamily: "open sans",
                    fontWeight: FontWeight.w500),
                textScaler: TextScaler.linear(1),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 100,
                  child: okButton,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// -------------- Location Popup ----------------//
showWarningDialogPopup(BuildContext context, IconData icon, String message,
    Function okHandler, Color color) {
  Size size = MediaQuery.of(context).size;
  Widget okButton = TextButton(
    child: Text(
      "OK",
      style: GoogleFonts.lato(
        textStyle: Theme.of(context).textTheme.bodyMedium,
        fontSize: Responsive.isMobileSmall(context)
            ? 11.5
            : Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 13
                : Responsive.isTabletPortrait(context)
                    ? 18
                    : 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      textScaler: TextScaler.linear(1),
    ),
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(color),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    ),
    onPressed: () {
      okHandler();
    },
  );

  // show the dialog
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: Container(
          width: Responsive.isMobileSmall(context) ||
                  Responsive.isMobileMedium(context) ||
                  Responsive.isMobileLarge(context)
              ? size.width * 0.75
              : Responsive.isTabletPortrait(context)
                  ? size.width * 0.6
                  : size.width * 0.5,
          height: Responsive.isMobileSmall(context) ||
                  Responsive.isMobileMedium(context) ||
                  Responsive.isMobileLarge(context)
              ? 270
              : Responsive.isTabletPortrait(context)
                  ? 300
                  : 320,
          padding: EdgeInsets.fromLTRB(30, 15, 30, 10),
          color: Color.fromARGB(255, 218, 216, 216),
          child: Column(
            children: <Widget>[
              SizedBox(height: 15),
              Icon(icon,
                  size: Responsive.isMobileSmall(context)
                      ? 60
                      : Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context)
                          ? 65
                          : Responsive.isTabletPortrait(context)
                              ? 75
                              : 80,
                  color: Colors.red),
              SizedBox(height: 15),
              Text(
                textAlign: TextAlign.center,
                message,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Color.fromARGB(255, 243, 46, 32),
                    height: 1.3,
                    fontSize: Responsive.isMobileSmall(context)
                        ? 17.5
                        : Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? 19
                            : Responsive.isTabletPortrait(context)
                                ? 22
                                : 24,
                    fontFamily: "open sans",
                    fontWeight: FontWeight.w500),
                textScaler: TextScaler.linear(1),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: Responsive.isMobileSmall(context) ||
                          Responsive.isMobileMedium(context) ||
                          Responsive.isMobileLarge(context)
                      ? 100
                      : Responsive.isTabletPortrait(context)
                          ? 120
                          : 130,
                  child: okButton,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// -------------- Warning Dilaog Popup 2 ----------------//
showWarningDialogPopupTwo(BuildContext context, IconData icon, String message,
    Widget yesDestination, Color color) {
  Widget okButton = TextButton(
    child: Text(
      "OK",
      style: GoogleFonts.lato(
        textStyle: Theme.of(context).textTheme.bodyMedium,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      textScaler: TextScaler.linear(1),
    ),
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(color),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    ),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return yesDestination;
        }),
      );
    },
  );

  // show the dialog
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.36,
          padding: EdgeInsets.fromLTRB(30, 15, 30, 10),
          color: Color.fromARGB(255, 218, 216, 216),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              Icon(icon, size: 60, color: Colors.red),
              SizedBox(height: 10),
              Text(
                textAlign: TextAlign.center,
                message,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Color.fromARGB(255, 243, 46, 32),
                    height: 1.3,
                    fontSize: 18,
                    fontFamily: "open sans",
                    fontWeight: FontWeight.w500),
                textScaler: TextScaler.linear(1),
              ),
              SizedBox(height: 18),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 100,
                  child: okButton,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

showWarningDialogPopupThree(BuildContext context, IconData icon, String message,
    Function okHandler, Color color, String butonName) {
  Widget okButton = TextButton(
    child: Text(
      butonName,
      style: GoogleFonts.lato(
        textStyle: Theme.of(context).textTheme.bodyMedium,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      textScaler: TextScaler.linear(1),
    ),
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(color),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    ),
    onPressed: () {
      okHandler();
    },
  );

  // show the dialog
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          height: 270,
          padding: EdgeInsets.fromLTRB(30, 15, 30, 10),
          color: Color.fromARGB(255, 218, 216, 216),
          child: Column(
            children: <Widget>[
              SizedBox(height: 15),
              Icon(icon, size: 65, color: Colors.red),
              SizedBox(height: 15),
              Text(
                textAlign: TextAlign.center,
                message,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Color.fromARGB(255, 243, 46, 32),
                    height: 1.3,
                    fontSize: 19,
                    fontFamily: "open sans",
                    fontWeight: FontWeight.w500),
                textScaler: TextScaler.linear(1),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 100,
                  child: okButton,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

getVerisonUpdatePopup(BuildContext context, String title, String message,
    Function updateHandler, Function updatelaterHandler, String imagePath) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.81,
          height: MediaQuery.of(context).size.height * 0.43,
          padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.black,
                    fontSize: 19,
                    fontFamily: "open sans",
                    fontWeight: FontWeight.w500,
                  ),
                  textScaler: TextScaler.linear(1),
                ),
              ),
              SizedBox(height: 18),
              Text(
                textAlign: TextAlign.justify,
                message,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.black,
                    height: 1.3,
                    fontSize: 15,
                    fontFamily: "open sans",
                    fontWeight: FontWeight.normal),
                textScaler: TextScaler.linear(1),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(25, 10, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: 100,
                      child: TextButton(
                          child: Text(
                            "No Thanks",
                            style: GoogleFonts.lato(
                              textStyle: Theme.of(context).textTheme.bodyMedium,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.green[800],
                            ),
                            textScaler: TextScaler.linear(1),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.transparent),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                          onPressed: () {
                            updatelaterHandler();
                          }),
                    ),
                    Container(
                      width: 100,
                      child: TextButton(
                          child: Text(
                            "Update",
                            style: GoogleFonts.lato(
                              textStyle: Theme.of(context).textTheme.bodyMedium,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textScaler: TextScaler.linear(1),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.green[800]),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                          onPressed: () {
                            updateHandler();
                          }),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 2),
              Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  imagePath,
                  width: 250,
                  height: 80,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// -------------- Leave Validation Popup ----------------//
companyUrlValidationPopup(BuildContext context, IconData icon, String title,
    String message, Function okHandler) {
  // Setup OK Button
  Widget okButton = TextButton(
    child: Text(
      "OK",
      style: GoogleFonts.lato(
        textStyle: Theme.of(context).textTheme.bodyMedium,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      textScaler: TextScaler.linear(1),
    ),
    style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        backgroundColor:
            WidgetStateProperty.all(Color.fromARGB(255, 237, 172, 10))),
    onPressed: () {
      okHandler();
    },
  );

  // show the dialog
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 320,
          padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 3),
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(254, 244, 67, 54),
                  textStyle: Theme.of(context).textTheme.headlineSmall,
                ),
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(1),
              ),
              SizedBox(height: 15),
              Icon(
                icon,
                size: 70,
                color: Colors.red,
              ),
              SizedBox(height: 20),
              Text(
                message,
                style: GoogleFonts.lato(
                  textStyle: Theme.of(context).textTheme.displaySmall,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                textScaler: TextScaler.linear(1),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 120,
                  height: 40,
                  child: okButton,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

passswordResetPopup(BuildContext context, String message, String imagePath,
    Widget yesDestination, Color color) {
  Widget okButton = TextButton(
    child: Text(
      "Ok",
      style: GoogleFonts.lato(
        textStyle: Theme.of(context).textTheme.bodyMedium,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      textScaler: TextScaler.linear(1),
    ),
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(color),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    ),
    onPressed: () async {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) {
          return yesDestination;
        }),
        (route) => false,
      );
    },
  );

  // show the dialog
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          height: MediaQuery.of(context).size.height * 0.35,
          padding: EdgeInsets.fromLTRB(20, 15, 20, 10),
          color: Color.fromARGB(255, 218, 216, 216),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              Image.asset(
                imagePath,
                width: 80,
                height: 80,
                alignment: Alignment.centerLeft,
              ),
              SizedBox(height: 20),
              Text(
                textAlign: TextAlign.center,
                message,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.black,
                    height: 1.4,
                    fontSize: 19,
                    fontFamily: "open sans",
                    fontWeight: FontWeight.w500),
                textScaler: TextScaler.linear(1),
              ),
              SizedBox(height: 15),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 80,
                  child: okButton,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// -------------- share document Submit Popup ----------------//
shareFileSuccessPopup(BuildContext context, String message, String imagePath,
    Widget yesDestination, Color color) {
  Widget okButton = TextButton(
    child: Text(
      "OK",
      style: GoogleFonts.lato(
        textStyle: Theme.of(context).textTheme.bodyMedium,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      textScaler: TextScaler.linear(1),
    ),
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(color),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    ),
    onPressed: () async {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
        builder: (context) {
          return yesDestination;
        },
      ), (Route<dynamic> route) => false);
    },
  );

  // show the dialog
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.35,
          padding: EdgeInsets.symmetric(vertical: 12),
          color: Color.fromARGB(255, 218, 216, 216),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              Image.asset(
                imagePath,
                width: 70,
                height: 70,
                alignment: Alignment.centerLeft,
              ),
              SizedBox(height: 20),
              Text(
                textAlign: TextAlign.center,
                message,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.black,
                    height: 1.5,
                    fontSize: 20,
                    fontFamily: "open sans",
                    fontWeight: FontWeight.w500),
                textScaler: TextScaler.linear(1),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 80,
                  child: okButton,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
