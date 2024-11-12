import 'package:auradocs_android/Models/users.dart';
import 'package:auradocs_android/utils/alert_dialogs.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../API-Services/api_service.dart';

class AuradocsLogin extends StatefulWidget {
  AuradocsLogin({super.key});

  @override
  State<AuradocsLogin> createState() => _AuradocsLoginState();
}

class _AuradocsLoginState extends State<AuradocsLogin> {
  late SharedPreferences storage;
  final _secureStorage = const FlutterSecureStorage();
  final TextEditingController companyController =
      TextEditingController(text: "");
  final TextEditingController usernameController =
      TextEditingController(text: "");
  final TextEditingController passwordController =
      TextEditingController(text: "");
  final TextEditingController emailController = TextEditingController(text: "");
  bool _obscureText = true;
  var _selectedCamera = -1;
  var _autoEnableFlash = false;
  ScanResult? scanResult;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final String KEY_USERNAME = "KEY_USERNAME";
  final String KEY_EMAIL = "KEY_EMAIL";
  final String KEY_PASSWORD = "KEY_PASSWORD";
  final String KEY_COMPANY = "KEY_COMPANY";
  final String KEY_LOCAL_AUTH_ENABLED = "KEY_LOCAL_AUTH_ENABLED";
  final String REQUIRE_BIOMETRIC_LOGIN_SELECT_YES =
      "REQUIRE_BIOMETRIC_LOGIN_SELECT_YES";
  bool _validate = false;
  RegExp regex = new RegExp(r'^.{3,}$');
  var localAuth = LocalAuthentication();

  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  List<BarcodeFormat> selectedFormats = [..._possibleFormats];
  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  FocusNode _focusNode3 = FocusNode();
  FocusNode? _lastFocusedNode;

  @override
  void initState() {
    super.initState();
    sharedPrefrences();
    Future.delayed(Duration(seconds: 3), () {
      _readFromStorage();
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    companyController.dispose();
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    super.dispose();
  }

  Future<void> sharedPrefrences() async {
    String? isLocalAuthEnabled =
        await _secureStorage.read(key: "KEY_LOCAL_AUTH_ENABLED");

    print("isLocalAuthEnabled $isLocalAuthEnabled");
    if (isLocalAuthEnabled == "true") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Biometric authentication is enabled.",
          style: TextStyle(
            fontSize: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 15
                : Responsive.isTabletPortrait(context)
                    ? 20
                    : 20,
          ),
          textScaler: TextScaler.linear(1),
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 5),
        content: Text(
          "Biometric authentication is disabled.",
          style: TextStyle(
            fontSize: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 15
                : Responsive.isTabletPortrait(context)
                    ? 20
                    : 20,
          ),
          textScaler: TextScaler.linear(1),
        ),
      ));
    }
  }

  // Read values
  Future<void> _readFromStorage() async {
    String isLocalAuthEnabled =
        await _secureStorage.read(key: "KEY_LOCAL_AUTH_ENABLED") ?? "false";

    if ("true" == isLocalAuthEnabled) {
      bool didAuthenticate = await localAuth.authenticate(
          localizedReason: 'Please authenticate to sign in',
          options: const AuthenticationOptions(useErrorDialogs: false));

      if (didAuthenticate) {
        usernameController.text =
            await _secureStorage.read(key: KEY_USERNAME) ?? '';
        passwordController.text =
            await _secureStorage.read(key: KEY_PASSWORD) ?? '';
        companyController.text =
            await _secureStorage.read(key: KEY_COMPANY) ?? '';
        ApiService.companyCode =
            await _secureStorage.read(key: KEY_COMPANY) ?? '';

        signInSuceessful(usernameController.text, passwordController.text);
      }
    } else {
      usernameController.text = '';
      passwordController.text = '';
      companyController.text = '';
    }
  }

  Future<void> _scan() async {
    var result = await BarcodeScanner.scan(
      options: ScanOptions(
        restrictFormat: selectedFormats,
        useCamera: _selectedCamera,
        autoEnableFlash: _autoEnableFlash,
      ),
    );
    setState(() {
      ApiService.companyCode = result.rawContent;
      companyController.text = result.rawContent;
      print("Qr code is  " + result.rawContent);
    });
  }

  void _seeOrHidePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // _requestFingerprintAuthentication() async {
  //   bool? validateForm = _key.currentState!.validate();

  //   print("validate $validateForm");
  //   if (validateForm == true) {
  //     // await _storage.write(key: KEY_LOCAL_AUTH_ENABLED, value: "false");

  //     await _storage.write(key: KEY_USERNAME, value: usernameController.text);
  //     await _storage.write(key: KEY_PASSWORD, value: passwordController.text);
  //     await _storage.write(key: KEY_COMPANY, value: companyController.text);

  //     String yesOrNo =
  //         await _storage.read(key: "REQUIRE_LOGIN_SELECT_YES") ?? "false";

  //     print("yesOrNo $yesOrNo");

  //     if (await localAuth.canCheckBiometrics) {
  //       if (yesOrNo == "false") {
  //         await showModalBottomSheet<void>(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return EnableLocalAuthModalBottomSheet(
  //                 action: _onEnableLocalAuth);
  //           },
  //         );
  //       }
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    print(size.width);
    print(size.height);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          return;
        }
        SystemNavigator.pop();
      },
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/auradocs_bg_2.jpg"),
                fit: BoxFit.fill,
              ),
            ),
            width: size.width,
            height: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: Responsive.isMobileSmall(context)
                        ? size.height * 0.03
                        : Responsive.isMobileMedium(context)
                            ? size.height * 0.05
                            : Responsive.isMobileLarge(context)
                                ? size.height * 0.05
                                : Responsive.isTabletPortrait(context)
                                    ? size.height * 0.02
                                    : size.height * 0.01,
                  ),
                  Center(
                    child: Image.asset(
                      "assets/images/auradocs_logo-transparent.png",
                      width: size.width * 0.8,
                      height: Responsive.isMobileSmall(context)
                          ? size.width * 0.26
                          : Responsive.isMobileMedium(context)
                              ? size.width * 0.3
                              : Responsive.isMobileLarge(context)
                                  ? size.width * 0.3
                                  : Responsive.isTabletPortrait(context)
                                      ? size.width * 0.23
                                      : size.width * 0.1,
                    ),
                  ),
                  SizedBox(
                    height: Responsive.isMobileSmall(context)
                        ? size.width * 0.14
                        : Responsive.isMobileMedium(context)
                            ? size.width * 0.2
                            : Responsive.isMobileLarge(context)
                                ? size.width * 0.2
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.2
                                    : size.width * 0.08,
                  ),
                  Center(
                    child: Form(
                      key: _key,
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black54)),
                          height: Responsive.isMobileSmall(context)
                              ? size.width * 0.7
                              : Responsive.isMobileMedium(context)
                                  ? size.width * 0.71
                                  : Responsive.isMobileLarge(context)
                                      ? size.width * 0.71
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.59
                                          : size.width * 0.45,
                          width: Responsive.isMobileSmall(context)
                              ? size.width * 0.9
                              : Responsive.isMobileMedium(context)
                                  ? size.width * 0.87
                                  : Responsive.isMobileLarge(context)
                                      ? size.width * 0.88
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.75
                                          : size.width * 0.7,
                          child: SingleChildScrollView(
                              child: Column(
                            children: [
                              SizedBox(height: size.width * 0.03),
                              companyNameTextField(),
                              usernameTextField(),
                              passwordTextField(),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Responsive.isMobileSmall(
                                              context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 4.0
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.03
                                          : size.width * 0.03,
                                  vertical: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 4.0
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.015
                                          : size.width * 0.01,
                                ),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // InkWell(
                                      //   onTap: () {
                                      //     // Navigator.push(
                                      //     //   context,
                                      //     //   MaterialPageRoute(
                                      //     //     builder: (context) =>
                                      //     //         ForgotPasswordScreenOne(),
                                      //     //   ),
                                      //     // );
                                      //   },
                                      //   child: Text(
                                      //     "Forgot Password ?",
                                      //     style: TextStyle(
                                      //       color: Colors.blue,
                                      //       fontSize: Responsive.isMobileSmall(
                                      //               context)
                                      //           ? size.width * 0.036
                                      //           : Responsive.isMobileMedium(
                                      //                   context)
                                      //               ? size.width * 0.034
                                      //               : Responsive.isMobileLarge(
                                      //                       context)
                                      //                   ? size.width * 0.034
                                      //                   : Responsive
                                      //                           .isTabletPortrait(
                                      //                               context)
                                      //                       ? size.width * 0.02
                                      //                       : size.width * 0.015,
                                      //     ),
                                      //   ),
                                      // ),
                                      Expanded(
                                          child: IconButton(
                                            icon: Icon(
                                                Icons.qr_code_scanner_sharp),
                                            color: Colors.black54,
                                            onPressed: _scan,
                                            iconSize: Responsive.isMobileSmall(
                                                    context)
                                                ? size.width * 0.11
                                                : Responsive.isMobileMedium(
                                                        context)
                                                    ? size.width * 0.115
                                                    : Responsive.isMobileLarge(
                                                            context)
                                                        ? size.width * 0.12
                                                        : Responsive
                                                                .isTabletPortrait(
                                                                    context)
                                                            ? size.width * 0.09
                                                            : size.width * 0.07,
                                          ),
                                          flex: 2),
                                      Expanded(
                                          flex: Responsive.isMobileSmall(
                                                      context) ||
                                                  Responsive.isMobileMedium(
                                                      context) ||
                                                  Responsive.isMobileLarge(
                                                      context)
                                              ? 4
                                              : Responsive.isTabletPortrait(
                                                      context)
                                                  ? 3
                                                  : 3,
                                          child: Text("")),
                                      Expanded(
                                        flex: 6,
                                        child: Row(
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                usernameController.clear();
                                                companyController.clear();
                                                passwordController.clear();

                                                if (_lastFocusedNode != null) {
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          _lastFocusedNode);
                                                }
                                              },
                                              child: Text(
                                                "Reset",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: Responsive
                                                          .isMobileSmall(
                                                              context)
                                                      ? size.width * 0.035
                                                      : Responsive.isMobileMedium(
                                                              context)
                                                          ? size.width * 0.036
                                                          : Responsive.isMobileLarge(
                                                                  context)
                                                              ? size.width *
                                                                  0.037
                                                              : Responsive
                                                                      .isTabletPortrait(
                                                                          context)
                                                                  ? size.width *
                                                                      0.025
                                                                  : size.width *
                                                                      0.015,
                                                  color: Colors.white,
                                                ),
                                                textScaler:
                                                    TextScaler.linear(1),
                                              ),
                                              style: TextButton.styleFrom(
                                                backgroundColor: Color.fromARGB(
                                                    255, 237, 172, 10),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                minimumSize: Responsive
                                                        .isMobileSmall(context)
                                                    ? Size(60, 20)
                                                    : Responsive.isMobileMedium(
                                                            context)
                                                        ? Size(70, 25)
                                                        : Responsive
                                                                .isMobileLarge(
                                                                    context)
                                                            ? Size(70, 25)
                                                            : Responsive
                                                                    .isTabletPortrait(
                                                                        context)
                                                                ? Size(
                                                                    size.width *
                                                                        0.18,
                                                                    40)
                                                                : Size(160, 45),
                                              ),
                                            ),
                                            SizedBox(width: 3),
                                            TextButton(
                                              child: Text(
                                                "Submit",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: Responsive
                                                          .isMobileSmall(
                                                              context)
                                                      ? 12
                                                      : Responsive
                                                              .isMobileMedium(
                                                                  context)
                                                          ? 13
                                                          : Responsive.isMobileLarge(
                                                                  context)
                                                              ? 15
                                                              : Responsive
                                                                      .isTabletPortrait(
                                                                          context)
                                                                  ? size.width *
                                                                      0.025
                                                                  : size.width *
                                                                      0.015,
                                                ),
                                                textScaler:
                                                    TextScaler.linear(1),
                                              ),
                                              style: TextButton.styleFrom(
                                                backgroundColor: Color.fromARGB(
                                                    255, 237, 172, 10),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                minimumSize: Responsive
                                                        .isMobileSmall(context)
                                                    ? Size(60, 20)
                                                    : Responsive.isMobileMedium(
                                                            context)
                                                        ? Size(75, 25)
                                                        : Responsive
                                                                .isMobileLarge(
                                                                    context)
                                                            ? Size(75, 25)
                                                            : Responsive
                                                                    .isTabletPortrait(
                                                                        context)
                                                                ? Size(
                                                                    size.width *
                                                                        0.17,
                                                                    40)
                                                                : Size(110, 45),
                                              ),
                                              onPressed: () async {
                                                setState(() {
                                                  if (companyController
                                                      .text.isEmpty) {
                                                    showWarningDialogPopup(
                                                      context,
                                                      Icons.warning,
                                                      "Login Failed. You should scan the QR and set the company URL.",
                                                      okRecognition,
                                                      Color.fromARGB(
                                                          255, 237, 172, 10),
                                                    );
                                                  } else if (usernameController
                                                          .text.isEmpty ||
                                                      passwordController
                                                          .text.isEmpty ||
                                                      !regex.hasMatch(
                                                          passwordController
                                                              .text)) {
                                                    _validate = true;
                                                  } else {
                                                    print("SUCCESSFUL LOGIN");
                                                    signInSuceessful(
                                                        usernameController.text
                                                            .toLowerCase()
                                                            .trim(),
                                                        passwordController
                                                            .text);
                                                  }
                                                });

                                                // companyController.text.isNotEmpty
                                                //     ? signInSuceessful(
                                                //         usernameController.text
                                                //             .toLowerCase(),
                                                //         passwordController.text)
                                                //     : showWarningDialogPopup(
                                                //         context,
                                                //         Icons.warning,
                                                //         "Login Failed. You should scan the QR and set the company URL.",
                                                //         okRecognition,
                                                //         Color.fromARGB(
                                                //             255, 237, 172, 10),
                                                //       );
                                              },
                                            ),
                                          ],
                                        ),
                                      )
                                    ]),
                              ),
                            ],
                          ))),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: Responsive.isMobileSmall(context) ||
                                Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? 20.0
                            : Responsive.isTabletPortrait(context)
                                ? 50
                                : 80),
                    child: GestureDetector(
                      child: SizedBox(
                        child: Icon(
                          Icons.fingerprint_outlined,
                          size: Responsive.isMobileSmall(context)
                              ? size.width * 0.2
                              : Responsive.isMobileMedium(context)
                                  ? size.width * 0.27
                                  : Responsive.isMobileLarge(context)
                                      ? size.width * 0.27
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.15
                                          : size.width * 0.1,
                          color: Color.fromARGB(136, 238, 162, 9),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget companyNameTextField() {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(
        left: Responsive.isMobileSmall(context) ||
                Responsive.isMobileMedium(context) ||
                Responsive.isMobileLarge(context)
            ? 8.0
            : Responsive.isTabletPortrait(context)
                ? size.width * 0.03
                : size.width * 0.03,
        right: Responsive.isMobileSmall(context) ||
                Responsive.isMobileMedium(context) ||
                Responsive.isMobileLarge(context)
            ? 8.0
            : Responsive.isTabletPortrait(context)
                ? size.width * 0.03
                : size.width * 0.03,
        top: Responsive.isMobileSmall(context) ||
                Responsive.isMobileMedium(context) ||
                Responsive.isMobileLarge(context)
            ? 5.0
            : Responsive.isTabletPortrait(context)
                ? size.width * 0.01
                : size.width * 0.005,
      ),
      child: SizedBox(
        height: Responsive.isMobileSmall(context) ||
                Responsive.isMobileMedium(context) ||
                Responsive.isMobileLarge(context)
            ? 50
            : Responsive.isTabletPortrait(context)
                ? 60
                : 70,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1),
          ),
          child: TextFormField(
            onTap: () {
              setState(() {
                _lastFocusedNode = _focusNode1;
              });
            },
            focusNode: _focusNode1,
            enabled: false,
            controller: companyController,
            autofocus: false,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.name,
            style: TextStyle(
                fontSize: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.045
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.03
                        : size.width * 0.02,
                height: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 0.05
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.002
                        : size.width * 0.0015,
                color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(),
              labelText: "Company",
              labelStyle: TextStyle(
                color: Colors.black54,
                fontSize: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.04
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.02
                        : size.width * 0.015,
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 40),
              prefixIcon: Icon(
                Icons.home_filled,
                size: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.07
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.04
                        : size.width * 0.025,
                color: Colors.grey,
              ),
              suffixIcon: Icon(
                Icons.home,
                size: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.07
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.04
                        : size.width * 0.025,
                color: Colors.grey,
              ),
              hintText: "Enter the company url",
              hintStyle: TextStyle(color: Colors.white60, fontSize: 15),
              errorText: _validate && companyController.text.isEmpty
                  ? 'URL is required...'
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget usernameTextField() {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.isMobileSmall(context) ||
                Responsive.isMobileMedium(context) ||
                Responsive.isMobileLarge(context)
            ? 8.0
            : Responsive.isTabletPortrait(context)
                ? size.width * 0.03
                : size.width * 0.03,
        vertical: Responsive.isMobileSmall(context) ||
                Responsive.isMobileMedium(context) ||
                Responsive.isMobileLarge(context)
            ? 3.0
            : Responsive.isTabletPortrait(context)
                ? size.width * 0.005
                : size.width * 0.005,
      ),
      child: SizedBox(
        height: Responsive.isMobileSmall(context) ||
                Responsive.isMobileMedium(context) ||
                Responsive.isMobileLarge(context)
            ? 50
            : Responsive.isTabletPortrait(context)
                ? 60
                : 70,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1),
          ),
          child: TextFormField(
            onTap: () {
              setState(() {
                _lastFocusedNode = _focusNode2;
              });
            },
            controller: usernameController,
            // autofocus: false,
            focusNode: _focusNode2,
            onSaved: (value) {
              usernameController.text = value!;
            },
            textInputAction: TextInputAction.next,
            style: TextStyle(
                fontSize: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.045
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.03
                        : size.width * 0.02,
                height: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 0.05
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.002
                        : size.width * 0.0015,
                color: Colors.black),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Username",
              labelStyle: TextStyle(
                color: Colors.black54,
                fontSize: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.04
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.02
                        : size.width * 0.015,
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 40),
              prefixIcon: Icon(
                Icons.person,
                size: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.07
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.04
                        : size.width * 0.025,
                color: Colors.grey,
              ),
              suffixIcon: Icon(
                Icons.person,
                size: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.07
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.04
                        : size.width * 0.025,
                color: Colors.grey,
              ),
              hintText: "Enter the username",
              hintStyle:
                  TextStyle(color: Colors.white60, fontSize: size.width * 0.04),
              errorText: _validate && usernameController.text.isEmpty
                  ? 'Username is required...'
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  // Widget emailTextField() {
  //   Size size = MediaQuery.of(context).size;
  //   return Padding(
  //     padding: EdgeInsets.symmetric(
  //       horizontal: Responsive.isMobileSmall(context) ||
  //               Responsive.isMobileMedium(context) ||
  //               Responsive.isMobileLarge(context)
  //           ? 8.0
  //           : Responsive.isTabletPortrait(context)
  //               ? size.width * 0.03
  //               : size.width * 0.03,
  //       vertical: Responsive.isMobileSmall(context) ||
  //               Responsive.isMobileMedium(context) ||
  //               Responsive.isMobileLarge(context)
  //           ? 5.0
  //           : Responsive.isTabletPortrait(context)
  //               ? size.width * 0.01
  //               : size.width * 0.005,
  //     ),
  //     child: SizedBox(
  //       height: Responsive.isMobileSmall(context) ||
  //               Responsive.isMobileMedium(context) ||
  //               Responsive.isMobileLarge(context)
  //           ? 50
  //           : Responsive.isTabletPortrait(context)
  //               ? 60
  //               : 70,
  //       child: TextFormField(
  //         controller: emailController,
  //         autofocus: false,
  //         onSaved: (value) {
  //           emailController.text = value!;
  //         },
  //         textInputAction: TextInputAction.next,
  //         keyboardType: TextInputType.text,
  //         style: TextStyle(
  //             fontSize: Responsive.isMobileSmall(context) ||
  //                     Responsive.isMobileMedium(context) ||
  //                     Responsive.isMobileLarge(context)
  //                 ? size.width * 0.045
  //                 : Responsive.isTabletPortrait(context)
  //                     ? size.width * 0.025
  //                     : size.width * 0.02,
  //             height: Responsive.isMobileSmall(context) ||
  //                     Responsive.isMobileMedium(context) ||
  //                     Responsive.isMobileLarge(context)
  //                 ? 0.05
  //                 : Responsive.isTabletPortrait(context)
  //                     ? size.width * 0.001
  //                     : size.width * 0.001,
  //             color: Colors.black),
  //         decoration: InputDecoration(
  //           border: OutlineInputBorder(),
  //           labelText: "Email",
  //           labelStyle: TextStyle(
  //             color: Colors.black54,
  //             fontSize: Responsive.isMobileSmall(context) ||
  //                     Responsive.isMobileMedium(context) ||
  //                     Responsive.isMobileLarge(context)
  //                 ? size.width * 0.04
  //                 : Responsive.isTabletPortrait(context)
  //                     ? size.width * 0.02
  //                     : size.width * 0.015,
  //           ),
  //           prefixIconConstraints: BoxConstraints(minWidth: 40),
  //           prefixIcon: Icon(
  //             Icons.email,
  //             size: Responsive.isMobileSmall(context) ||
  //                     Responsive.isMobileMedium(context) ||
  //                     Responsive.isMobileLarge(context)
  //                 ? size.width * 0.07
  //                 : Responsive.isTabletPortrait(context)
  //                     ? size.width * 0.04
  //                     : size.width * 0.025,
  //             color: Colors.grey,
  //           ),
  //           suffixIcon: Icon(
  //             Icons.email,
  //             size: Responsive.isMobileSmall(context) ||
  //                     Responsive.isMobileMedium(context) ||
  //                     Responsive.isMobileLarge(context)
  //                 ? size.width * 0.07
  //                 : Responsive.isTabletPortrait(context)
  //                     ? size.width * 0.04
  //                     : size.width * 0.025,
  //             color: Colors.grey,
  //           ),
  //           hintText: "Enter the email",
  //           hintStyle:
  //               TextStyle(color: Colors.white60, fontSize: size.width * 0.04),
  //           errorText: _validate && usernameController.text.isEmpty
  //               ? 'Email is required...'
  //               : null,
  //         ),
  //         // validator: (value) {
  //         //   if (value!.isEmpty) {
  //         //     return ("Username is required..");
  //         //   }
  //         //   return null;
  //         // },
  //       ),
  //     ),
  //   );
  // }

  Widget passwordTextField() {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(
        left: Responsive.isMobileSmall(context) ||
                Responsive.isMobileMedium(context) ||
                Responsive.isMobileLarge(context)
            ? 8.0
            : Responsive.isTabletPortrait(context)
                ? size.width * 0.03
                : size.width * 0.03,
        right: Responsive.isMobileSmall(context) ||
                Responsive.isMobileMedium(context) ||
                Responsive.isMobileLarge(context)
            ? 8.0
            : Responsive.isTabletPortrait(context)
                ? size.width * 0.03
                : size.width * 0.03,
      ),
      child: SizedBox(
        height: Responsive.isMobileSmall(context) ||
                Responsive.isMobileMedium(context) ||
                Responsive.isMobileLarge(context)
            ? 50
            : Responsive.isTabletPortrait(context)
                ? 60
                : 70,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1),
          ),
          child: TextFormField(
            onTap: () {
              setState(() {
                _lastFocusedNode = _focusNode3;
              });
            },
            focusNode: _focusNode3,
            controller: passwordController,
            autofocus: false,
            onSaved: (value) {
              passwordController.text = value!;
              FocusScope.of(context).unfocus();
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.visiblePassword,
            obscureText: _obscureText,
            style: TextStyle(
                fontSize: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.045
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.03
                        : size.width * 0.02,
                height: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 0.05
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.002
                        : size.width * 0.0015,
                color: Colors.black),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green, width: 1.0),
              ),
              labelText: "Password",
              labelStyle: TextStyle(
                color: Colors.black54,
                fontSize: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.04
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.02
                        : size.width * 0.015,
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 40),
              prefixIcon: Icon(
                Icons.lock,
                size: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.07
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.04
                        : size.width * 0.025,
                color: Colors.grey,
              ),
              suffixIcon: IconButton(
                onPressed: _seeOrHidePassword,
                icon: Icon(
                  _obscureText == true
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: Responsive.isMobileSmall(context) ||
                          Responsive.isMobileMedium(context) ||
                          Responsive.isMobileLarge(context)
                      ? size.width * 0.07
                      : Responsive.isTabletPortrait(context)
                          ? size.width * 0.04
                          : size.width * 0.025,
                  color: Colors.grey,
                ),
              ),
              hintText: "Enter the password",
              hintStyle: TextStyle(color: Colors.white60, fontSize: 15),
              errorText: _validate && passwordController.text.isEmpty
                  ? 'Password is required...'
                  : _validate && !regex.hasMatch(passwordController.text)
                      ? "Enter Valid Password(Min. 3 Character)"
                      : null,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signInSuceessful(String userName, String pword) async {
    storage = await SharedPreferences.getInstance();
    if (_key.currentState!.validate()) {
      // var req = await ApiService.loginSuccess(userName, pword);
      var req = await ApiService.loginSuccessWithMobile(userName, pword);
      print(req.statusCode);
      print(req.body);

      if (req.statusCode == 200) {
        User user = User.fromJsonFile(jsonDecode(req.body));
        Map<String, dynamic> responseBody = jsonDecode(req.body);

        List<String> authentication =
            List<String>.from(responseBody['value']['authentication']);

        storage.setString('token', user.token!);
        storage.setString('user_data', req.body);

        storage.setString('code', companyController.text);

        // Convert the authentication list to JSON and store it
        String authList = jsonEncode(authentication);
        storage.setString('authentication', authList);

        await _secureStorage.write(
            key: KEY_USERNAME, value: usernameController.text.trim());
        await _secureStorage.write(
            key: KEY_PASSWORD, value: passwordController.text);
        await _secureStorage.write(
            key: KEY_COMPANY, value: companyController.text);

        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => HomeScreenNew(
        //               user: user,
        //               code: companyController.text,
        //             )));
      } else if (req.statusCode == 500 || req.statusCode == 501) {
        showWarningDialogPopup(
          context,
          Icons.warning,
          "Server Error.! \nPlease contact system admin..",
          okRecognition,
          Color.fromARGB(255, 237, 172, 10),
        );
      } else if (req.statusCode == 502) {
        showWarningDialogPopup(
          context,
          Icons.warning,
          "Bad Gateway Error.! \nPlease contact system admin..",
          okRecognition,
          Color.fromARGB(255, 237, 172, 10),
        );
      } else if (req.statusCode == 404) {
        showWarningDialogPopup(
          context,
          Icons.warning,
          "Login Failed.!! \nUsername or password is wrong.",
          okRecognition,
          Color.fromARGB(255, 237, 172, 10),
        );
      } else {
        showWarningDialogPopup(
          context,
          Icons.warning,
          "Login Failed.!! \nSystem Error.",
          okRecognition,
          Color.fromARGB(255, 237, 172, 10),
        );
      }
    }
  }

  void okRecognition() {
    closeDialog(context);
  }
}
