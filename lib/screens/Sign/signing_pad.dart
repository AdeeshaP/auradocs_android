import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:auradocs_android/API-Services/api_service.dart';
import 'package:auradocs_android/screens/Sign/sign_doc_list.dart';
import 'package:auradocs_android/utils/alert_dialogs.dart';
import 'package:external_path/external_path.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:ui' as ui;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class SigningPad extends StatefulWidget {
  const SigningPad(
      {super.key,
      required this.docId,
      required this.approvalId,
      required this.signIds});

  final int docId;
  final int approvalId;
  final int signIds;

  @override
  State<SigningPad> createState() => _SigningPadState();
}

class _SigningPadState extends State<SigningPad> {
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  late SharedPreferences _storage;
  Map<String, dynamic>? userObj;
  String username = "";
  String token = "";
  String compnyCode = "";
  String thumbImage = "";
  String thumbImageBase64 = "";
  String signImageBase64 = "";
  String signImage = "";
  Map<String, dynamic>? responsedata;
  List<dynamic> valueList = [];
  bool isLoading = true;
  bool haveData = false;
  int docID = 0;
  int approvalID = 0;
  int signID = 0;
  Uint8List? _bytesOfImg;
  List authentication = [];

  @override
  void initState() {
    super.initState();
    getSharedPrefrences();
  }

  void _handleClearButtonPressed() {
    signatureGlobalKey.currentState!.clear();
  }

  Future<void> getSharedPrefrences() async {
    _storage = await SharedPreferences.getInstance();
    userObj = jsonDecode(_storage.getString('user_data')!);
    String? authListJson = _storage.getString('authentication');
    authentication =
        authListJson != null ? List<String>.from(jsonDecode(authListJson)) : [];

    if (mounted)
      setState(() {
        username = userObj!["value"]["userName"];
        token = _storage.getString('token')!;
        compnyCode = _storage.getString('code')!;

        docID = widget.docId;
        approvalID = widget.approvalId;
        signID = widget.signIds;
      });
  }

  void _handlePreviewButtonPressed() async {
    final data =
        await signatureGlobalKey.currentState!.toImage(pixelRatio: 3.0);
    // final bytes = await data.toByteData(format: ui.ImageByteFormat.png);
    // _bytesOfImg = bytes!.buffer.asUint8List();
    // signImageBase64 = base64.encode(_bytesOfImg!);
    final pngBytes = await data.toByteData(format: ui.ImageByteFormat.png);
    _bytesOfImg = pngBytes!.buffer.asUint8List();

    img.Image? pngImage = img.decodeImage(_bytesOfImg!); // Decode the PNG bytes
    List<int> jpegBytes = img.encodeJpg(pngImage!); // Convert to JPEG
    Uint8List jpegUint8List = Uint8List.fromList(jpegBytes);

    // Encode JPEG to Base64
    signImageBase64 = base64.encode(_bytesOfImg!);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(),
            body: Center(
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/auradocs_logo-transparent.png",
                    scale: 1.2,
                  ),
                  Container(
                    height: 300,
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    child: Image.memory(jpegUint8List),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // TextButton(
                      //   child: Text('Download'),
                      //   style: TextButton.styleFrom(
                      //     fixedSize: Size(110, 40),
                      //     backgroundColor: Color.fromARGB(255, 245, 114, 54),
                      //     foregroundColor: Colors.white,
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(0),
                      //     ),
                      //   ),
                      //   onPressed: () {
                      //     downlaodIamgeToGallery(jpegUint8List);
                      //   },
                      // ),
                      TextButton(
                        style: TextButton.styleFrom(
                          fixedSize: Size(110, 40),
                          backgroundColor: Color.fromARGB(255, 245, 114, 54),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        child: Text('Upload'),
                        onPressed: () async {
                          uploadSignatures();
                          // await checkBiometric();

                          // await getAvailableBiometrics();

                          // await authenticate();
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> uploadSignatures() async {
    showProgressDialog(context);

    var random = Random.secure();
    var randomInt = random.nextInt(10000);

    Map<String, dynamic> payloadImage = {};

    thumbImageBase64 = base64.encode(_bytesOfImg!);
    signImageBase64 = base64.encode(_bytesOfImg!);

    signImage = "Sign$randomInt.png";
    thumbImage = "Thumb$randomInt.jpeg";

    payloadImage['signImage'] = signImageBase64;
    payloadImage['signImageName'] = signImage;
    payloadImage['sign_id'] = signID.toString();
    payloadImage['approval_id'] = approvalID.toString();

    print("approavl id is " + payloadImage['approval_id']);
    print("sign id is " + payloadImage['sign_id']);
    print("signImageName is " + payloadImage['signImageName']);

    final pl = jsonEncode(payloadImage);

    var response4 =
        await ApiService.uploadSignatures(token, docID, username, pl);

    print('Response body: ${response4.body}');
    closeDialog(context);

    if (response4.statusCode == 200) {
      shareFileSuccessPopup(
        context,
        "Signatures Uploaded Successfully.",
        'assets/images/success-green-icon.png',
        SignAvailableDocuments(),
        Color.fromARGB(255, 237, 172, 10),
      );
    } else if (response4.statusCode == 500) {
      showWarningDialogPopup(
        context,
        Icons.warning,
        "Server error! Please contact auraDOCS administrator.",
        okRecognition,
        Color.fromARGB(255, 237, 172, 10),
      );
    } else {
      print('Upload failed');
      showWarningDialogPopup(
        context,
        Icons.warning,
        "Upload failed.",
        okRecognition,
        Color.fromARGB(255, 237, 172, 10),
      );
    }
  }

  void okRecognition() {
    closeDialog(context);
  }

  Future<void> checkBiometric() async {
    bool canCheckBiometrics = await _localAuthentication.canCheckBiometrics;

    print('Biometrics supported: $canCheckBiometrics');
  }

  Future<void> getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics =
        await _localAuthentication.getAvailableBiometrics();

    print('Available biometrics: $availableBiometrics');
  }

  Future<void> authenticate() async {
    bool isAuthenticated = false;

    try {
      isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print('Error during biometric authentication: $e');
    }

    if (isAuthenticated) {
      print('Biometric authentication successful');
      // Call Post Method
    } else {
      print('Biometric authentication failed');
    }
  }

  void downlaodIamgeToGallery(Uint8List jpegBytes) async {
    // final Uint8List imageData = bytes.buffer.asUint8List();

    var downldDir = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_PICTURES);

    var random = Random.secure();
    int randomInt = random.nextInt(1000);

    print("Adeesha 1");
    final file = await File('${downldDir}/signature${randomInt}.png').create();
    await file.writeAsBytes(jpegBytes);

    print("Adeesha 2");

    ImageGallerySaver.saveImage(jpegBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image downloaded successfully..'),
      ),
    );

    print("Adeesha 3");
  }

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
          children: [
            Image.asset(
              "assets/images/auradocs_logo-transparent.png",
              scale: 1.2,
            ),
            Text(
              "Signature Pad",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                child: SfSignaturePad(
                    key: signatureGlobalKey,
                    backgroundColor: Colors.white,
                    strokeColor: Colors.black,
                    minimumStrokeWidth: 3.0,
                    maximumStrokeWidth: 4.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.grey)),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  child: Text('Preview'),
                  style: TextButton.styleFrom(
                    fixedSize: Size(110, 40),
                    backgroundColor: Color.fromARGB(255, 245, 114, 54),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  onPressed: _handlePreviewButtonPressed,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    fixedSize: Size(110, 40),
                    backgroundColor: Color.fromARGB(255, 245, 114, 54),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  child: Text('Clear'),
                  onPressed: _handleClearButtonPressed,
                )
              ],
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center),
    );
  }
}
