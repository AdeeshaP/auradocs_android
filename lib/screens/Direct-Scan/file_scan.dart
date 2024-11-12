import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:auradocs_android/API-Services/api_service.dart';
import 'package:auradocs_android/Models/users.dart';
import 'package:auradocs_android/screens/Sliders/landing_page.dart';
import 'package:auradocs_android/screens/contact_us_screen.dart';
import 'package:auradocs_android/screens/full-screen-viewer/full_screen_viewer.dart';
import 'package:auradocs_android/screens/home_screen.dart';
import 'package:auradocs_android/utils/constants.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img1;
import 'dart:ui' as ui;
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

import '../../utils/alert_dialogs.dart';

// ignore: must_be_immutable
class DirectScan extends StatefulWidget {
  DirectScan({
    super.key,
    required this.file1,
  });

  File? file1;

  @override
  State<DirectScan> createState() => _DirectScanState();
}

class _DirectScanState extends State<DirectScan> {
  double _scale = 1.0;
  late SharedPreferences _storage;
  Map<String, dynamic>? userObj;
  String username = "";
  String token = "";
  String compnyCode = "";
  String folderName = "";
  Uint8List? imageValueBytes;
  String mimeType = "";
  List<int> bytes = [];
  bool isLoading = true;
  String? templateType;
  int templateId = 0;
  List<String> dropdownValues = [];
  List<Map<String, dynamic>>? values;
  List<TextEditingController> _controllers = [];
  bool isCheckBoxMarked = false;
  Uint8List? _bytesOfImg;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  AudioPlayer audioplayer = AudioPlayer();
  String textFileContent = "";
  bool isPlaying = false;
  Duration duartion = Duration.zero;
  Duration position = Duration.zero;
  String _initialValue = "Please Select";
  // String _selectedValue = "Please Select";
  List<String> _selectedValues = [];
  String lat = "";
  String long = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  String fileBaseName = "";
  int x = 0;
  int newX = 0;
  int y = 0;
  int newY = 0;
  int w = 0;
  int newW = 0;
  int h = 0;
  int newH = 0;
  var pageNumber = 0;
  var ocrText = "";
  Uint8List? pdfToimg;
  List<dynamic> alltextFieldvalues = [];
  List<dynamic> ocrTextFieldvalues = [];
  List<dynamic> textFieldvalues2 = [];
  int fileIndex = 0;
  List<String> ocrValues2 = [];
  List<String> userNames = [];
  int viewedImageHeight = 0;
  int viewedImageWidth = 0;
  List<int> extractPdfPageNos = [0];
  String recognizedText = "";
  String viewdFileBase64String = "";
  String? assigendUser;
  String remarksComment = "";
  TextEditingController remraksController = new TextEditingController();
  bool isLoadedTextFields = false;
  String fieldType1 = "";
  FocusNode _focusNode = FocusNode();
  TextEditingController searchController = TextEditingController();
  List<List<dynamic>> csvData = [];
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  ScrollController _scrollController = ScrollController();
  TextEditingController folderpathContrller = TextEditingController();
  String? currentFolderPath;
  String trimmedValue = "";
  GlobalKey _toolTipKey = GlobalKey();
  List authentication = [];

  @override
  void initState() {
    super.initState();
    getViewedFileData();
    _initFile();
  }

  @override
  void dispose() {
    _controllers.forEach((tcontroller) => tcontroller.dispose());
    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
    }
    audioplayer.dispose();
    super.dispose();
  }

  void okRecognition() {
    closeDialog(context);
  }

  void _clearAllTextFields() {
    for (TextEditingController controller in _controllers) {
      controller.clear();
    }
    remraksController.clear();
    setState(() {
      assigendUser == null;
    });
  }

  Future<void> getViewedFileData() async {
    getTemplatesDropdown();

    _bytesOfImg = await widget.file1!.readAsBytes();
    setState(() {
      mimeType = lookupMimeType(widget.file1!.path)!;
      viewdFileBase64String = base64.encode(_bytesOfImg!);
    });

    if (mimeType == 'image/jpg' ||
        mimeType == 'image/jpeg' ||
        mimeType == 'image/png' ||
        mimeType == 'image/gif') {
      Uint8List _imageData = _bytesOfImg!.buffer.asUint8List();
      final Image image = Image.memory(_imageData);
      final Completer<ui.Image> completer = Completer();
      image.image.resolve(const ImageConfiguration()).addListener(
            ImageStreamListener(
                (ImageInfo info, bool _) => completer.complete(info.image)),
          );
      final ui.Image rawImage = await completer.future;
      setState(() {
        viewedImageWidth = rawImage.width;
        viewedImageHeight = rawImage.height;
      });
    }
    getUsernamesDropdown();
    ocrValues2.clear();
  }

  // --------GET API -  Dropdown list for templates -------------//

  Future<void> getTemplatesDropdown() async {
    _storage = await SharedPreferences.getInstance();
    userObj = jsonDecode(_storage.getString('user_data')!);
    token = _storage.getString('token')!;
    compnyCode = _storage.getString('code')!;
    String? authListJson = _storage.getString('authentication');
    authentication =
        authListJson != null ? List<String>.from(jsonDecode(authListJson)) : [];

    print("Authentication2: $authentication");
    if (mounted) {
      setState(() {
        username = userObj!["value"]["userName"];
      });
    }
    var response2 = await ApiService.getAvalableTemplatesLists(username, token);
    var templatelist = jsonDecode(response2.body);

    setState(() {
      values = List<Map<String, dynamic>>.from(templatelist['value']);
      dropdownValues = values!.map((e) => e.values.first.toString()).toList();
    });

    _bytesOfImg = await widget.file1!.readAsBytes();
    String _base64String = base64.encode(_bytesOfImg!);
    print("Base64 string is  " + _base64String);
    setState(() {
      fileBaseName = p.basename(widget.file1!.path);
    });
  }

  // --------GET API -  Dropdown list for Users -------------//

  Future<void> getUsernamesDropdown() async {
    _storage = await SharedPreferences.getInstance();
    token = _storage.getString('token')!;

    var response3 = await ApiService.getUserNames(token);
    var userlist = jsonDecode(response3.body);

    setState(() {
      List<dynamic> values = userlist['value'];
      userNames = values.map((item) => item[0].toString()).toSet().toList();
    });
  }

  // -------- GET API - Template Textfields for selected dropdown item -------------//

  Future<List<String>> getTextFieldsForSelectedTemplate(
      int tempId, String usertoken, String imageValueX) async {
    _storage = await SharedPreferences.getInstance();
    token = _storage.getString('token')!;
    usertoken = token;
    tempId = templateId;

    var response3 =
        await ApiService.getAvailableTemplateById(tempId, usertoken);
    if (response3.statusCode == 200) {
      var ocrValues = jsonDecode(response3.body)['value']
          .where((field) => field['indexFieldType'] == 'OCR')
          .toList();
      if (ocrValues.length > 0) {
        for (var field in ocrValues) {
          setState(() {
            x = field['x'];
            y = field['y'];
            w = field['w'];
            h = field['h'];
          });
          setState(() {
            newX = x * viewedImageWidth ~/ 100;
            newY = y * viewedImageHeight ~/ 100;
            newW = w * viewedImageWidth ~/ 100;
            newH = h * viewedImageHeight ~/ 100;
          });

          ocrText = await extractOCRText(imageValueX, newX, newY, newW, newH);

          if (mounted)
            setState(() {
              ocrValues2.add(ocrText);
            });
        }
      }

      var selectedTemplate = jsonDecode(response3.body);
      setState(() {
        alltextFieldvalues = selectedTemplate['value'].toList();

        textFieldvalues2 = selectedTemplate['value']
            .where((field) => field['indexFieldType'] != 'OCR')
            .toList();

        ocrTextFieldvalues = selectedTemplate['value']
            .where((field) => field['indexFieldType'] == 'OCR')
            .toList();

        folderpathContrller.text = jsonDecode(response3.body)['temp_path'];
      });

      if (ocrTextFieldvalues.length == 0) {
        _controllers = List.generate(
          alltextFieldvalues.length,
          (index4) => TextEditingController(),
        );
      } else {
        _controllers = List.generate(
          alltextFieldvalues.length,
          (index4) => index4 < ocrTextFieldvalues.length
              ? TextEditingController(text: ocrValues2[index4])
              : TextEditingController(),
        );
      }

      _selectedValues = List<String>.generate(
          alltextFieldvalues.length, (index) => _initialValue);
    }
    return ocrValues2;
  }

  // ------------Text extracting method---------------//

  Future<String> extractOCRText(
      String base64String, int x, int y, int w, int h) async {
    var random = Random.secure();
    var randomInt = random.nextInt(100000);
    if (mimeType == 'image/jpg' ||
        mimeType == 'image/jpeg' ||
        mimeType == 'image/png' ||
        mimeType == 'image/gif') {
      Directory tempDir1 = await getTemporaryDirectory();

      Uint8List imageData = base64.decode(base64String);

      final image = img1.decodeImage(imageData);

      final croppedImage =
          img1.copyCrop(image!, x: x, y: y, width: w, height: h);
      final croppedImageData = img1.encodeJpg(croppedImage);

      String filename = 'abc$randomInt.jpg';
      File imageFile = File('${tempDir1.path}/$filename');
      await imageFile.writeAsBytes(croppedImageData);

      recognizedText = await FlutterTesseractOcr.extractText(imageFile.path,
          language: 'eng');
      await imageFile.delete();
    } else if (mimeType == 'application/pdf') {
      final imageX = img1.decodeImage(pdfToimg!);
      final croppedImageX =
          img1.copyCrop(imageX!, x: x, y: y, width: w, height: h);
      final croppedImageData = img1.encodeJpg(croppedImageX);
      String appDocDirectory = (await getTemporaryDirectory()).path;
      final imagePath = '$appDocDirectory/xyz$randomInt.jpg';
      File imageFile2 = File(imagePath);
      await imageFile2.writeAsBytes(croppedImageData);

      recognizedText = await FlutterTesseractOcr.extractText(imageFile2.path,
          language: 'eng');
      await imageFile2.delete();
    }
    return recognizedText;
  }

  // ------------ POST API - Save Pending Documents to the Index Folder ------------ //
  Future<void> uploadPendingDocumentsToIndex() async {
    showProgressDialog(context);
    _storage = await SharedPreferences.getInstance();
    userObj = jsonDecode(_storage.getString('user_data')!);
    String user = userObj!["value"]["userName"];
    String token = _storage.getString('token')!;

    Map<String, dynamic> payloadImage = {};

    List<Map<String, String>> indexValues = [];

    for (var i = 0; i < alltextFieldvalues.length; i++) {
      String fieldName = alltextFieldvalues[i]['indexFieldName'].toString();
      String fieldValue = _controllers[i].text.trim();

      if (alltextFieldvalues[i]['indexFieldType'] == 'Check-Box') {
        Map<String, String> indexValue = {
          fieldName: isCheckBoxMarked.toString(),
        };
        indexValues.add(indexValue);
      } else {
        Map<String, String> indexValue = {
          fieldName: fieldValue,
        };
        indexValues.add(indexValue);
      }
    }

    payloadImage['indexValue'] = indexValues;
    payloadImage['mime/type'] = mimeType;
    payloadImage['valueImage'] = viewdFileBase64String;
    payloadImage['templateId'] = templateId;
    payloadImage['longitude'] = _storage.getString('longitude');
    payloadImage['latitude'] = _storage.getString('latitiude');
    payloadImage['extractedText'] = "";
    payloadImage["approvedUser"] = assigendUser;
    payloadImage["remark"] = remraksController.text;

    final pl = jsonEncode(payloadImage);

    var response4 = await ApiService.indexPendingDocuments(
        templateId, templateType!, fileBaseName, token, user, pl);

    print('Response body: ${response4.body.toString()}');
    closeDialog(context);

    if (response4.statusCode == 200) {
      print('Pending Documents send to Indexed');
      lastDocuentSubmitPopup(
        context,
        "File Indexed Successfully.",
        'assets/images/success-green-icon.png',
        HomePage(
          user: User(
              token: token,
              userName: user,
              authenticated_features: authentication),
          code: compnyCode,
        ),
        Color.fromARGB(255, 237, 172, 10),
        username,
        token,
      ).then((val) {});
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
    }
  }

  // -------------- Zoom In File-----------------//
  void _zoomIn() {
    setState(() {
      _scale *= 1.2;
    });
  }

  // -------------- Zoom Out File-----------------//
  void _zoomOut() {
    setState(() {
      _scale /= 1.2;
    });
  }

  // -------------- Display Normal Text Field-----------------//

  Widget displayTextFormFields(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(1),
        ),
        child: TextFormField(
          maxLines: alltextFieldvalues[index]['indexFieldType'] == 'Text-Area'
              ? 5
              : alltextFieldvalues[index]['indexFieldDisplayAs'] == 'Address'
                  ? 4
                  : 1,
          controller: _controllers[index],
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
            labelText: alltextFieldvalues[index]['indexFieldRequiredYN'] == 'Y'
                ? "\* " + alltextFieldvalues[index]['indexFieldDisplayAs']
                : alltextFieldvalues[index]['indexFieldDisplayAs'],
            labelStyle: TextStyle(
              fontSize: Responsive.isMobileSmall(context) ||
                      Responsive.isMobileMedium(context) ||
                      Responsive.isMobileLarge(context)
                  ? 14
                  : Responsive.isTabletPortrait(context)
                      ? 15
                      : 16,
            ),
          ),
          validator: (String? value) {
            value = _controllers[index].text;
            if (alltextFieldvalues[index]['indexFieldRequiredYN'] == 'Y' &&
                value.isEmpty) {
              return "${alltextFieldvalues[index]['indexFieldDisplayAs']} is required.";
            }
            return null;
          },
          keyboardType: TextInputType.text,
        ),
      ),
    );
  }

  // -------------- Display Folder Path Text Field-----------------//

  Widget displayFolderPathTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(1),
        ),
        child: TextFormField(
            style: TextStyle(color: Colors.black87),
            readOnly: true,
            enabled: false,
            focusNode: _focusNode,
            maxLines: folderpathContrller.text.length > 35 ? 2 : 1,
            controller: folderpathContrller,
            onSaved: (newValue) {
              folderpathContrller.text = newValue!;
              FocusScope.of(context).unfocus();
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromARGB(244, 236, 230, 230),
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
              labelText: "Folder Path",
              labelStyle: TextStyle(
                fontSize: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 14
                    : Responsive.isTabletPortrait(context)
                        ? 15
                        : 16,
              ),
            ),
            keyboardType: TextInputType.text),
      ),
    );
  }

  // -------------- Display OCR Text Field-----------------//

  Widget displayOCRTextFields(int index) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        height: Responsive.isMobileSmall(context) ||
                Responsive.isMobileMedium(context) ||
                Responsive.isMobileLarge(context)
            ? size.width * 0.13
            : Responsive.isTabletPortrait(context)
                ? size.width * 0.07
                : size.width * 0.05,
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                height: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.13
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.06
                        : size.width * 0.04,
                decoration: BoxDecoration(
                  color: Colors.grey[350],
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Center(
                  child: Text(
                    "OCR",
                    style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context) ||
                                Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? 16
                            : Responsive.isTabletPortrait(context)
                                ? 18
                                : 17,
                        fontWeight: FontWeight.w500),
                    textScaler: TextScaler.linear(1),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(1),
                ),
                child: TextFormField(
                    textInputAction: TextInputAction.next,
                    controller: _controllers[index],
                    // onChanged: (newValue) {
                    //   _controllers[index].text = newValue;
                    // },
                    onSaved: (newValue) {
                      _controllers[index].text = newValue!;
                    },
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0)),
                      labelText: alltextFieldvalues[index]
                                  ['indexFieldRequiredYN'] ==
                              'Y'
                          ? "\* " +
                              alltextFieldvalues[index]['indexFieldDisplayAs']
                          : alltextFieldvalues[index]['indexFieldDisplayAs'],
                      labelStyle: TextStyle(
                        fontSize: Responsive.isMobileSmall(context) ||
                                Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? 14
                            : Responsive.isTabletPortrait(context)
                                ? 15
                                : 16,
                      ),
                    ),
                    validator: (value) {
                      value = _controllers[index].text;
                      if (alltextFieldvalues[index]['indexFieldRequiredYN'] ==
                              'Y' &&
                          value.isEmpty) {
                        return "${alltextFieldvalues[index]['indexFieldDisplayAs']} is required.";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------- Display DateTime Picker-----------------//
  Widget displayDateTimePicker(int index) {
    return GestureDetector(
      onTap: () => _selectDate(context, index),
      child: AbsorbPointer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1),
            ),
            child: TextFormField(
              controller: _controllers[index],
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(12, 16, 12, 16),
                suffixIcon: Icon(
                  Icons.calendar_month,
                  size: Responsive.isMobileSmall(context) ||
                          Responsive.isMobileMedium(context) ||
                          Responsive.isMobileLarge(context)
                      ? 25
                      : Responsive.isTabletPortrait(context)
                          ? 30
                          : 30,
                ),
                labelText:
                    textFieldvalues2[index]['indexFieldRequiredYN'] == 'Y'
                        ? "\* " + textFieldvalues2[index]['indexFieldDisplayAs']
                        : textFieldvalues2[index]['indexFieldDisplayAs'],
                labelStyle: TextStyle(
                  fontSize: Responsive.isMobileSmall(context) ||
                          Responsive.isMobileMedium(context) ||
                          Responsive.isMobileLarge(context)
                      ? 14
                      : Responsive.isTabletPortrait(context)
                          ? 15
                          : 16,
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
              ),
              validator: (value) {
                value = _controllers[index].text;
                if (alltextFieldvalues[index]['indexFieldRequiredYN'] == 'Y' &&
                    value.isEmpty) {
                  return '${alltextFieldvalues[index]['indexFieldDisplayAs']} is required';
                }
                return null;
              },
              keyboardType: TextInputType.datetime,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.amber,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          ),
        );
      },
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _controllers[index].text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // ----------------------- Display pd_data dropdown ---------------//
  Widget displayPdDataDropdowns(int index) {
    List<dynamic> dropdownValues2 = [_initialValue];

    var pdDataList = textFieldvalues2[index]['pd_data'];
    if (pdDataList != null) {
      for (var pdData in pdDataList) {
        dropdownValues2.add(pdData['templateId']);
      }
    }

    print("_selectedValue for index $index: ${_selectedValues[index]}");

    if (_selectedValues[index].isEmpty) {
      _selectedValues[index] = _initialValue;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(1),
        ),
        child: DropdownButtonFormField(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(12),
            labelText: textFieldvalues2[index]['indexFieldRequiredYN'] == 'Y'
                ? "\* " + textFieldvalues2[index]['indexFieldDisplayAs']
                : textFieldvalues2[index]['indexFieldDisplayAs'],
            labelStyle: TextStyle(
              fontSize: Responsive.isMobileSmall(context) ||
                      Responsive.isMobileMedium(context) ||
                      Responsive.isMobileLarge(context)
                  ? 14
                  : Responsive.isTabletPortrait(context)
                      ? 15
                      : 16,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
          ),
          value: _selectedValues[index],
          onChanged: (newValue) {
            setState(() {
              _selectedValues[index] = newValue!;
              _controllers[index].text = newValue.toString();
            });
          },
          items: dropdownValues2.map<DropdownMenuItem<String>>((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  // -------------- Display Checkbox-----------------//

  Widget displayCheckbox(int index) {
    return CheckboxListTile(
      title: Text(
        textFieldvalues2[index]['indexFieldDisplayAs'],
        style: TextStyle(
            fontSize: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 16
                : Responsive.isTabletPortrait(context)
                    ? 17
                    : 17,
            color: Colors.black54),
        textScaler: TextScaler.linear(1),
      ),
      value: isCheckBoxMarked,
      onChanged: (bool? value) {
        setState(() {
          isCheckBoxMarked = value!;
        });
      },
      activeColor: Colors.amber,
      checkColor: Colors.black,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  // ------------  Upload file formats initialize ---------------- //

  Future<void> _initFile() async {
    final fileName = widget.file1?.path.split('/').last;
    print(fileName);
    if (fileName!.endsWith('.mp4')) {
      _videoPlayerController = VideoPlayerController.file(widget.file1!);
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: 2,
        autoPlay: true,
        fullScreenByDefault: false,
      );

      if (this.mounted) setState(() {});
    } else if (fileName.endsWith('.mp3') || fileName.endsWith('.m4a')) {
      await audioplayer.play(UrlSource(widget.file1!.path), volume: 3.0);
      audioplayer.onDurationChanged.listen((Duration duration) {
        if (this.mounted)
          setState(() {
            duartion = duration;
          });
      });
      audioplayer.onPositionChanged.listen((Duration duration) {
        if (this.mounted)
          setState(() {
            position = duration;
          });
      });
      setState(() {
        isPlaying = true;
      });
    } else if (fileName.endsWith('.txt')) {
      try {
        File file = File(widget.file1!.path);
        String content = await file.readAsString();
        setState(() {
          textFileContent = content;
        });
      } catch (e) {
        print("Error loading file: $e");
      }
    } else if (fileName.endsWith('.csv')) {
      try {
        File file = File(widget.file1!.path);
        String csvContent = await file.readAsString();

        List<List<dynamic>> parsedCsv =
            CsvToListConverter().convert(csvContent);

        setState(() {
          csvData = parsedCsv;
          isLoading = false;
        });
        print("csvContent $csvContent");
      } catch (e) {
        print("Error loading CSV file: $e");
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Function to reset all dropdown values to initial value
  void resetAllThings() {
    setState(() {
      assigendUser = null;
      isCheckBoxMarked = false;
      _selectedValues = List<String>.generate(
          alltextFieldvalues.length, (index) => _initialValue);
    });
    _clearAllTextFields();
  }

  _scrollToMaxValue() {
    if (_scrollController.positions.length > 0) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (templateType != null)
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToMaxValue());

    Size size = MediaQuery.of(context).size;
    final fileName = widget.file1!.path.split('/').last;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop();
      },
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                getSearchBoxWidget(),
                Divider(height: 10),
                SizedBox(
                  height: Responsive.isMobileSmall(context)
                      ? size.height * 0.86
                      : Responsive.isMobileMedium(context)
                          ? size.height * 0.85
                          : Responsive.isMobileLarge(context)
                              ? size.height * 0.85
                              : Responsive.isTabletPortrait(context)
                                  ? size.height * 0.9
                                  : size.height * 0.85,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            height: Responsive.isMobileSmall(context) ||
                                    Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.1
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.07
                                    : size.width * 0.045,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(width: 10),
                                Icon(Icons.check_sharp,
                                    color: Colors.white,
                                    size: Responsive.isMobileSmall(context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 25
                                        : 35),
                                SizedBox(
                                    width: Responsive.isMobileSmall(context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 5
                                        : 15),
                                Text(
                                  "View",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Responsive.isMobileSmall(context)
                                        ? 16
                                        : Responsive.isMobileMedium(context) ||
                                                Responsive.isMobileLarge(
                                                    context)
                                            ? 18
                                            : Responsive.isTabletPortrait(
                                                    context)
                                                ? 22
                                                : 21,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textScaler: TextScaler.linear(1),
                                ),
                              ],
                            ),
                            color: Color.fromARGB(255, 233, 104, 44),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          child: Container(
                            color: Color.fromARGB(218, 1, 5, 25),
                            height: Responsive.isMobileSmall(context)
                                ? size.height * 0.55
                                : Responsive.isMobileMedium(context)
                                    ? size.height * 0.57
                                    : Responsive.isMobileLarge(context)
                                        ? size.height * 0.68
                                        : Responsive.isTabletPortrait(context)
                                            ? size.height * 0.55
                                            : size.height * 0.5,
                            child: Column(
                              children: [
                                Container(
                                  height: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.height * 0.05
                                      : Responsive.isTabletPortrait(context)
                                          ? size.height * 0.05
                                          : size.height * 0.055,
                                  color: Colors.black26,
                                  child: Row(children: <Widget>[
                                    Expanded(flex: 10, child: Text("")),
                                    // ------------ Zoom-in and Zoom-out Buttons-------------
                                    Expanded(
                                      flex: 2,
                                      child: GestureDetector(
                                        onTap: _zoomIn,
                                        child: Icon(
                                          Icons.add,
                                          size: Responsive.isMobileSmall(
                                                  context)
                                              ? 20
                                              : Responsive.isMobileMedium(
                                                          context) ||
                                                      Responsive.isMobileLarge(
                                                          context)
                                                  ? 25
                                                  : Responsive.isTabletPortrait(
                                                          context)
                                                      ? 30
                                                      : 29,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: GestureDetector(
                                        onTap: _zoomOut,
                                        child: Icon(
                                          Icons.remove,
                                          size: Responsive.isMobileSmall(
                                                  context)
                                              ? 20
                                              : Responsive.isMobileMedium(
                                                          context) ||
                                                      Responsive.isMobileLarge(
                                                          context)
                                                  ? 25
                                                  : Responsive.isTabletPortrait(
                                                          context)
                                                      ? 30
                                                      : 29,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    // ------------ Full Screen Mode Button-------------
                                    Expanded(
                                      flex: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FullScreenViewer(
                                                base64String:
                                                    viewdFileBase64String,
                                                mimeT: mimeType,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Icon(
                                          Icons.fullscreen,
                                          size: Responsive.isMobileSmall(
                                                  context)
                                              ? 20
                                              : Responsive.isMobileMedium(
                                                          context) ||
                                                      Responsive.isMobileLarge(
                                                          context)
                                                  ? 27
                                                  : Responsive.isTabletPortrait(
                                                          context)
                                                      ? 30
                                                      : 29,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  ]),
                                ),
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      color: Colors.transparent,
                                      height: Responsive.isMobileSmall(
                                                  context) ||
                                              Responsive.isMobileMedium(context)
                                          ? size.height * 0.49
                                          : Responsive.isMobileLarge(context)
                                              ? size.height * 0.58
                                              : Responsive.isTabletPortrait(
                                                      context)
                                                  ? size.height * 0.29
                                                  : size.height * 0.41,
                                      width: double.infinity,
                                      child: ClipRRect(
                                        clipBehavior: Clip.hardEdge,
                                        child: Transform.scale(
                                          scale: _scale,
                                          child: (fileName.endsWith('.jpg') ||
                                                  fileName.endsWith('.png') ||
                                                  fileName.endsWith('.jpeg') ||
                                                  fileName.endsWith('.gif'))
                                              ? galleryPhotoOrCapturedPhoto()
                                              : Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: Responsive
                                                                    .isMobileSmall(
                                                                        context) ||
                                                                Responsive
                                                                    .isMobileMedium(
                                                                        context) ||
                                                                Responsive
                                                                    .isMobileLarge(
                                                                        context)
                                                            ? 50
                                                            : Responsive
                                                                    .isTabletPortrait(
                                                                        context)
                                                                ? 70
                                                                : 60,
                                                        color: Colors.grey),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      "This file Format is not supported for view...",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: Responsive
                                                                    .isMobileSmall(
                                                                        context) ||
                                                                Responsive
                                                                    .isMobileMedium(
                                                                        context) ||
                                                                Responsive
                                                                    .isMobileLarge(
                                                                        context)
                                                            ? 18
                                                            : Responsive
                                                                    .isTabletPortrait(
                                                                        context)
                                                                ? 25
                                                                : 26,
                                                      ),
                                                      textScaler:
                                                          TextScaler.linear(1),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // --------- DOCUMENT DETAILS SECTION ------------- //
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Container(
                            height: Responsive.isMobileSmall(context) ||
                                    Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.1
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.07
                                    : size.width * 0.05,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(width: 10),
                                Icon(
                                  Icons.assignment,
                                  color: Colors.white,
                                  size: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 25
                                      : 35,
                                ),
                                SizedBox(
                                  width: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 5
                                      : 15,
                                ),
                                Text(
                                  "Document Index",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Responsive.isMobileSmall(context)
                                        ? 16
                                        : Responsive.isMobileMedium(context) ||
                                                Responsive.isMobileLarge(
                                                    context)
                                            ? 18
                                            : Responsive.isTabletPortrait(
                                                    context)
                                                ? 22
                                                : 21,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textScaler: TextScaler.linear(1),
                                ),
                              ],
                            ),
                            color: Color.fromARGB(255, 233, 104, 44),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: DropdownButton<String>(
                                elevation: 2,
                                underline: Container(),
                                isExpanded: true,
                                hint: Text(
                                  "Template Name",
                                  style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: Responsive.isMobileSmall(
                                                context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 13
                                        : Responsive.isTabletPortrait(context)
                                            ? 16
                                            : 17,
                                  ),
                                  textScaler: TextScaler.linear(1),
                                ),
                                value: templateType,
                                onChanged: (String? newValue) async {
                                  int index = dropdownValues.indexOf(newValue!);
                                  int selectedTemplateKey =
                                      int.parse(values![index].keys.first);
                                  setState(() {
                                    templateType = newValue;
                                    templateId = selectedTemplateKey;
                                  });

                                  print(selectedTemplateKey);
                                  await getTextFieldsForSelectedTemplate(
                                      selectedTemplateKey,
                                      token,
                                      viewdFileBase64String);
                                  ocrValues2.clear();
                                },
                                items: dropdownValues
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontSize:
                                            Responsive.isMobileSmall(context) ||
                                                    Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 15
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 17
                                                    : 17,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textScaler: TextScaler.linear(1),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            autovalidateMode: _autoValidate,
                            key: _formKey,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                children: <Widget>[
                                  if ((templateType != null ||
                                          templateId != 0) &&
                                      (alltextFieldvalues.length > 0) &&
                                      (folderpathContrller.text != "-"))
                                    displayFolderPathTextField(),
                                  FutureBuilder(
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator(
                                            color: Colors.amber);
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        if (alltextFieldvalues.length > 0) {
                                          return ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:
                                                alltextFieldvalues.length,
                                            itemBuilder: (context, index) {
                                              String field =
                                                  alltextFieldvalues[index]
                                                      ['indexFieldType'];

                                              if (index <
                                                  alltextFieldvalues.length) {
                                                if (field == "OCR") {
                                                  if (index <
                                                      ocrTextFieldvalues
                                                          .length) {
                                                    fieldType1 = "OCR";
                                                  } else if (index >
                                                      ocrTextFieldvalues
                                                          .length) {
                                                    fieldType1 = "OCR";
                                                  }
                                                } else {
                                                  if (index <
                                                      textFieldvalues2.length) {
                                                    fieldType1 = field;
                                                  } else if (index >
                                                      textFieldvalues2.length) {
                                                    fieldType1 = field;
                                                  }
                                                }

                                                bool isDate =
                                                    fieldType1 == "Date";
                                                bool isPDDropdown =
                                                    fieldType1 == "Select";
                                                bool isOCRTextField =
                                                    fieldType1 == "OCR";
                                                bool isTextField = fieldType1 ==
                                                        "Text" ||
                                                    fieldType1 == "disabled" ||
                                                    fieldType1 ==
                                                        "Folder-Name" ||
                                                    fieldType1 == "File-Name" ||
                                                    fieldType1 == "Text-Area" ||
                                                    fieldType1 ==
                                                        "Please Select" ||
                                                    fieldType1 == "Barcode" ||
                                                    fieldType1 == "bulk" ||
                                                    fieldType1 == "ImageArea";
                                                bool isCheckBox =
                                                    fieldType1 == "Check-Box";

                                                if (isDate) {
                                                  return displayDateTimePicker(
                                                      index);
                                                } else if (isTextField) {
                                                  return displayTextFormFields(
                                                      index);
                                                } else if (isOCRTextField) {
                                                  return displayOCRTextFields(
                                                      index);
                                                } else if (isPDDropdown) {
                                                  return displayPdDataDropdowns(
                                                      index);
                                                } else if (isCheckBox) {
                                                  return displayCheckbox(index);
                                                } else {
                                                  return CircularProgressIndicator(
                                                      color: Colors.amber);
                                                }
                                              } else {
                                                print("No data");
                                              }
                                              return CircularProgressIndicator(
                                                  color: Colors.amber);
                                            },
                                          );
                                        } else {
                                          return SizedBox();
                                        }
                                      }
                                    },
                                    future: null,
                                  ),
                                  SizedBox(height: 10),
                                  if (templateType != null || templateId != 0)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          child: Text(
                                            'Save',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: Responsive
                                                          .isMobileSmall(
                                                              context) ||
                                                      Responsive.isMobileMedium(
                                                          context) ||
                                                      Responsive.isMobileLarge(
                                                          context)
                                                  ? 15
                                                  : Responsive.isTabletPortrait(
                                                          context)
                                                      ? 18
                                                      : 20,
                                              color: Colors.white,
                                            ),
                                            textScaler: TextScaler.linear(1),
                                          ),
                                          onPressed: () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              _formKey.currentState!.save();

                                              await uploadPendingDocumentsToIndex();

                                              _formKey.currentState!.reset();
                                              setState(() {
                                                isCheckBoxMarked = false;
                                                for (TextEditingController controller
                                                    in _controllers) {
                                                  controller.clear();
                                                }

                                                _selectedValues =
                                                    List<String>.generate(
                                                        alltextFieldvalues
                                                            .length,
                                                        (index) =>
                                                            _initialValue);

                                                _autoValidate =
                                                    AutovalidateMode.disabled;
                                              });
                                            } else {
                                              setState(() {
                                                _autoValidate =
                                                    AutovalidateMode.always;
                                              });
                                            }
                                          },
                                          style: TextButton.styleFrom(
                                              minimumSize: Size(
                                                Responsive.isMobileSmall(
                                                        context)
                                                    ? 95
                                                    : Responsive.isMobileMedium(
                                                            context)
                                                        ? 95
                                                        : Responsive
                                                                .isMobileLarge(
                                                                    context)
                                                            ? 100
                                                            : Responsive
                                                                    .isTabletPortrait(
                                                                        context)
                                                                ? 100
                                                                : 130,
                                                Responsive.isMobileSmall(
                                                            context) ||
                                                        Responsive
                                                            .isMobileMedium(
                                                                context) ||
                                                        Responsive
                                                            .isMobileLarge(
                                                                context)
                                                    ? 35
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? 45
                                                        : 50,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              backgroundColor: Color.fromARGB(
                                                  255, 30, 128, 219)),
                                        ),
                                        SizedBox(width: 10),
                                        TextButton(
                                          child: Text(
                                            'Reset',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: Responsive
                                                          .isMobileSmall(
                                                              context) ||
                                                      Responsive.isMobileMedium(
                                                          context) ||
                                                      Responsive.isMobileLarge(
                                                          context)
                                                  ? 15
                                                  : Responsive.isTabletPortrait(
                                                          context)
                                                      ? 18
                                                      : 20,
                                              color: Colors.white,
                                            ),
                                            textScaler: TextScaler.linear(1),
                                          ),
                                          onPressed: resetAllThings,
                                          style: TextButton.styleFrom(
                                              minimumSize: Size(
                                                Responsive.isMobileSmall(
                                                        context)
                                                    ? 95
                                                    : Responsive.isMobileMedium(
                                                            context)
                                                        ? 95
                                                        : Responsive
                                                                .isMobileLarge(
                                                                    context)
                                                            ? 100
                                                            : Responsive
                                                                    .isTabletPortrait(
                                                                        context)
                                                                ? 100
                                                                : 130,
                                                Responsive.isMobileSmall(
                                                            context) ||
                                                        Responsive
                                                            .isMobileMedium(
                                                                context) ||
                                                        Responsive
                                                            .isMobileLarge(
                                                                context)
                                                    ? 35
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? 45
                                                        : 50,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              backgroundColor: Color.fromARGB(
                                                  255, 237, 172, 10)),
                                        ),
                                      ],
                                    ),
                                  SizedBox(height: size.height * 0.06),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // AdvancedSearchBox(_isAdvanceSearchVisible),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget galleryPhotoOrCapturedPhoto() {
    return SingleChildScrollView(
      child: Image.file(
        widget.file1!,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget pdfViewer() {
    return SfPdfViewer.file(
      widget.file1!,
      key: _pdfViewerKey,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      canShowPaginationDialog: false,
    );
  }

  Widget mp4FilePlayer() {
    return Chewie(controller: _chewieController!);
  }

  Widget textFileViewer() {
    return SingleChildScrollView(
      child: Html(data: textFileContent),
    );
  }

  Widget csvViewer() {
    return isLoading
        ? Center(
            child: Container(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(color: Colors.amber),
            ),
          )
        : SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                dataRowMaxHeight: 20,
                dataRowMinHeight: 20,
                border: TableBorder.all(width: 1),
                headingRowHeight: 20,
                columns: List.generate(
                  csvData.first.length,
                  (index) => DataColumn(
                    label: Text(
                      csvData.first[index].toString(),
                      style: TextStyle(fontSize: 11),
                      textScaler: TextScaler.linear(1),
                    ),
                  ),
                ),
                rows: List.generate(
                  csvData.length - 1,
                  (rowIndex) => DataRow(
                    cells: List.generate(
                      csvData.first.length,
                      (cellIndex) => DataCell(Text(
                        csvData[rowIndex + 1][cellIndex].toString(),
                        style: TextStyle(fontSize: 11),
                        textScaler: TextScaler.linear(1),
                      )),
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Widget mp3Player() {
    Size size = MediaQuery.of(context).size;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              "assets/images/mp3-file.jpg",
              width: Responsive.isMobileSmall(context) ||
                      Responsive.isMobileMedium(context) ||
                      Responsive.isMobileLarge(context)
                  ? size.width * 0.2
                  : Responsive.isTabletPortrait(context)
                      ? size.width * 0.18
                      : size.width * 0.15,
              height: Responsive.isMobileSmall(context) ||
                      Responsive.isMobileMedium(context) ||
                      Responsive.isMobileLarge(context)
                  ? size.width * 0.2
                  : Responsive.isTabletPortrait(context)
                      ? size.width * 0.18
                      : size.width * 0.15,
              fit: BoxFit.cover,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                formatTime(position),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 15
                        : Responsive.isTabletPortrait(context)
                            ? 20
                            : 21),
                textScaler: TextScaler.linear(1),
              ),
              Slider(
                value: position.inSeconds.toDouble(),
                max: duartion.inSeconds.toDouble(),
                onChanged: (value) async {
                  audioplayer.seek(Duration(seconds: value.toInt()));
                  await audioplayer.resume();
                },
                activeColor: Colors.blue,
              ),
              Text(
                formatTime(duartion - position),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 15
                        : Responsive.isTabletPortrait(context)
                            ? 20
                            : 21),
                textScaler: TextScaler.linear(1),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 20
                    : Responsive.isTabletPortrait(context)
                        ? 30
                        : 30,
                child: IconButton(
                  onPressed: () async {
                    if (isPlaying) {
                      audioplayer.pause();
                      if (this.mounted)
                        setState(() {
                          isPlaying = false;
                        });
                    } else {
                      if (position == duartion) {
                        await audioplayer.seek(Duration(seconds: 0));
                      }
                      await audioplayer.play(UrlSource(widget.file1!.path),
                          position: position);
                      if (this.mounted)
                        setState(() {
                          isPlaying = true;
                        });
                    }
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: Responsive.isMobileSmall(context)
                        ? 24
                        : Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? 25
                            : Responsive.isTabletPortrait(context)
                                ? 32
                                : 35,
                  ),
                ),
              ),
              SizedBox(width: 10),
              CircleAvatar(
                radius: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 20
                    : Responsive.isTabletPortrait(context)
                        ? 30
                        : 30,
                child: IconButton(
                  onPressed: () async {
                    setState(() {
                      audioplayer.stop();
                      isPlaying = false;
                    });
                  },
                  icon: Icon(
                    Icons.stop,
                    size: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 24
                        : Responsive.isTabletPortrait(context)
                            ? 32
                            : 35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MP3 Player Time Durations
  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }

  Container getSearchBoxWidget() {
    Size size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(color: Colors.grey[300]),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Responsive.isMobileSmall(context) ||
                  Responsive.isMobileMedium(context) ||
                  Responsive.isMobileLarge(context)
              ? size.width * 0.02
              : Responsive.isTabletPortrait(context)
                  ? size.width * 0.02
                  : 12,
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 10),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.home,
                        size: Responsive.isMobileSmall(context) ||
                                Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? 25
                            : 35),
                    color: Colors.black54,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return HomePage(
                              user: User(
                                  token: token,
                                  userName: username,
                                  authenticated_features: authentication),
                              code: compnyCode,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: Container(
                      height: Responsive.isMobileSmall(context)
                          ? 40
                          : Responsive.isMobileMedium(context)
                              ? 41
                              : Responsive.isMobileLarge(context)
                                  ? 42
                                  : Responsive.isTabletPortrait(context)
                                      ? 45
                                      : 45,
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaler: TextScaler.linear(1),
                        ),
                        child: TextFormField(
                          onFieldSubmitted: (value) {
                            searchController.value =
                                searchController.value.copyWith(
                              text: value.trimRight(),
                              selection: TextSelection.collapsed(
                                  offset: value.trimRight().length),
                            );
                          },
                          controller: searchController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFFFFFF),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 14.0),
                            hintText: "Search...",
                            hintStyle: TextStyle(
                              fontSize: Responsive.isMobileSmall(context)
                                  ? 16
                                  : Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 18
                                      : Responsive.isTabletPortrait(context)
                                          ? 22
                                          : 21,
                              color: Color(0xFFB3B1B1),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              size: Responsive.isMobileSmall(context) ||
                                      Responsive.isMobileMedium(context) ||
                                      Responsive.isMobileLarge(context)
                                  ? 20
                                  : 30,
                              color: Colors.black54,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 1.0,
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          onSaved: (newValue) {
                            searchController.text == newValue;
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        trimmedValue = searchController.text.trimRight();
                      });
                      if (trimmedValue.isEmpty || trimmedValue == "") {
                        final dynamic tooltip = _toolTipKey.currentState;
                        tooltip?.ensureTooltipVisible();
                      } else {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) {
                        //       return BlocProvider(
                        //         create: (context) =>
                        //             DocumentBloc(username, token),
                        //         child: SearchedDocumentListScreen(
                        //             searchValue: trimmedValue),
                        //       );
                        //     },
                        //   ),
                        // );
                      }
                    },
                    child: Tooltip(
                      key: _toolTipKey,
                      triggerMode: trimmedValue == ""
                          ? TooltipTriggerMode.manual
                          : TooltipTriggerMode.tap,
                      message: "Search Value is Required.",
                      showDuration: Duration(seconds: 3),
                      child: Container(
                        height: Responsive.isMobileSmall(context)
                            ? 40
                            : Responsive.isMobileMedium(context)
                                ? 41
                                : Responsive.isMobileLarge(context)
                                    ? 42
                                    : Responsive.isTabletPortrait(context)
                                        ? 45
                                        : 45,
                        width: Responsive.isMobileSmall(context)
                            ? 40
                            : Responsive.isMobileMedium(context)
                                ? 41
                                : Responsive.isMobileLarge(context)
                                    ? 42
                                    : Responsive.isTabletPortrait(context)
                                        ? 45
                                        : 45,
                        decoration: BoxDecoration(
                          color: serachBarbuttonColor,
                          border: Border(
                              right: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          )),
                        ),
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 30,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        cardColor: Colors.white,
                      ),
                      child: PopupMenuButton<String>(
                        onSelected: choiceAction,
                        itemBuilder: (BuildContext context) {
                          return _menuOptions.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(
                                choice,
                                style: TextStyle(
                                  fontSize: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.044
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.03
                                          : size.width * 0.02,
                                ),
                                textScaler: TextScaler.linear(1),
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

//Side Menu Bar Options
  List<String> _menuOptions = [
    'Contact Us',
    'Log Out',
  ];

// --------- Side Menu Bar Navigation ---------- //
  void choiceAction(String choice) {
    if (choice == _menuOptions[0]) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return ContactUsScreen();
        }),
      );
    } else if (choice == _menuOptions[1]) {
      if (!mounted)
        return;
      else
        showDialog(
            barrierColor: Color.fromARGB(177, 18, 17, 17),
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                backgroundColor: Colors.white,
                title: Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.isMobileSmall(context)
                        ? 20
                        : Responsive.isMobileMedium(context)
                            ? 22
                            : Responsive.isMobileLarge(context)
                                ? 23
                                : Responsive.isTabletPortrait(context)
                                    ? 25
                                    : 25,
                  ),
                  textScaler: TextScaler.linear(1),
                ),
                content: Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(
                    fontSize: Responsive.isMobileSmall(context)
                        ? 14
                        : Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? 16
                            : Responsive.isTabletPortrait(context)
                                ? 18
                                : 21,
                    color: Colors.black,
                  ),
                  textScaler: TextScaler.linear(1),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 13
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 15
                                : Responsive.isTabletPortrait(context)
                                    ? 17
                                    : 20,
                        color: Colors.black,
                      ),
                      textScaler: TextScaler.linear(1),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      userLogout();
                    },
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 13
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 15
                                : Responsive.isTabletPortrait(context)
                                    ? 17
                                    : 20,
                        color: Colors.white,
                      ),
                      textScaler: TextScaler.linear(1),
                    ),
                    style: TextButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 156, 47, 47),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        )),
                  ),
                ],
              );
            });
    }
  }

  void userLogout() async {
    var response = await ApiService.logoutUser(username, token);

    if (response.statusCode == 403) {
      _storage.clear();
      setState(() {
        ApiService.companyCode = "";
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LandingScreen(),
        ),
        (route) => false,
      );
    }
  }
}
