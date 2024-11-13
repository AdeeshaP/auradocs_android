import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:auradocs_android/API-Services/api_service.dart';
import 'package:auradocs_android/Bloc/document_bloc.dart';
import 'package:auradocs_android/Bloc/document_event.dart';
import 'package:auradocs_android/Bloc/document_state.dart';
import 'package:auradocs_android/Models/users.dart';
import 'package:auradocs_android/screens/Document-Search/search_list.dart';
import 'package:auradocs_android/screens/Pending-Docs/pending_doc_list.dart';
import 'package:auradocs_android/screens/Sliders/landing_page.dart';
import 'package:auradocs_android/screens/contact_us_screen.dart';
import 'package:auradocs_android/screens/full-screen-viewer/full_screen_viewer.dart';
import 'package:auradocs_android/screens/home_screen.dart';
import 'package:auradocs_android/utils/alert_dialogs.dart';
import 'package:auradocs_android/utils/constants.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:image/image.dart' as img1;
import 'dart:ui' as ui;
import 'package:pdf_image_renderer/pdf_image_renderer.dart' as render;

class PendingDocumentsViewer extends StatefulWidget {
  PendingDocumentsViewer({
    super.key,
    required this.fileNames2,
    required this.folderName,
    required this.indexOfFile,
    required this.removeDocCallBack,
  });

  final String folderName;
  final int indexOfFile;
  final List<dynamic> fileNames2;
  final Function removeDocCallBack;

  @override
  State<PendingDocumentsViewer> createState() => _PendingDocumentsViewerState();
}

class _PendingDocumentsViewerState extends State<PendingDocumentsViewer> {
  double _scale = 1.0;
  late SharedPreferences _storage;
  Map<String, dynamic>? userObj;
  String username = "";
  String token = "";
  String compnyCode = "";
  final audioplayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Map<String, dynamic>? responsedata;
  Map<String, dynamic>? valueList;
  String folderName = "";
  String fileName = " ";
  Uint8List? imageValueBytes;
  String imageValue = "";
  String mimeType = "";
  Uint8List? bytesImage;
  List<int> bytes = [];
  File? _mp3File;
  File? _mp4File;
  File? pdffile;
  bool isLoading = true;
  String? templateType;
  int templateId = 0;
  List<Map<String, dynamic>>? values2;
  List<TextEditingController> _allcontrollers = [];
  final _formKey = GlobalKey<FormState>();
  Key textFieldKey = UniqueKey();
  Key oCRtextFieldKey = UniqueKey();
  bool isCheckBoxMarked = false;
  List<String> _selectedValues = [];
  String lat = "";
  String long = "";
  bool servicestatus = false;
  List<dynamic> valList = [];
  int fileIndex = 0;
  List<String> ocrValues2 = [];
  int viewedImageHeight = 0;
  int viewedImageWidth = 0;
  List<int> extractPdfPageNos = [0];
  String recognizedText = "";
  int x = 0;
  int newX = 0;
  int y = 0;
  int newY = 0;
  int w = 0;
  int newW = 0;
  int h = 0;
  int newH = 0;
  Uint8List? pdfToimg;
  List<dynamic> alltextFieldvalues = [];
  List<dynamic> textFieldvalues2 = [];
  List<dynamic> ocrTextFieldvalues = [];
  String? assigendUser;
  String remarksComment = "";
  TextEditingController remraksController = new TextEditingController();
  String fieldType1 = "";
  bool isLoadedTextFields = false;
  TextEditingController searchController = TextEditingController();
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool saveAndNext = false;
  String _selectedItem = 'Save >';
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  String _initialValue = "Please Select";
  ScrollController _scrollController = ScrollController();
  bool isAlIndexedOnce = false;
  int totalNoOfFilesToIndex = 1;
  TextEditingController folderpathContrller = TextEditingController();
  String? currentFolderPath;
  FocusNode _focusNode = FocusNode();
  String trimmedValue = "";
  GlobalKey _toolTipKey = GlobalKey();
  List authentication = [];

  @override
  void initState() {
    super.initState();
    fileIndex = widget.indexOfFile;
    viewSelectedPendingDocument(widget.fileNames2[fileIndex], fileIndex);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
    }
    audioplayer.dispose();
    _allcontrollers.forEach((tcontroller) => tcontroller.dispose());
    folderpathContrller.dispose();
    super.dispose();
  }

  void okRecognition() {
    closeDialog(context);
  }

  void _clearAllTextFields() {
    for (TextEditingController controller in _allcontrollers) {
      controller.clear();
    }
    remraksController.clear();
  }

  // ---------------------------------------------------- API CALL----------------------------------------------------//

// -------- GET API - get selected document to view -------------//
  Future<void> viewSelectedPendingDocument(String fileN, int indx) async {
    // getTemplatesDropdown();

    _storage = await SharedPreferences.getInstance();
    userObj = jsonDecode(_storage.getString('user_data')!);
    token = _storage.getString('token')!;
    compnyCode = _storage.getString('code')!;
    String? authListJson = _storage.getString('authentication');
    authentication =
        authListJson != null ? List<String>.from(jsonDecode(authListJson)) : [];

    print("Authentication2: $authentication");
    if (mounted)
      setState(() {
        username = userObj!["value"]["userName"];
        fileName = fileN;
        folderName = widget.folderName;
        fileIndex = indx;
      });

    context.read<DocumentBloc>().add(FetchTemplateDropdown(username, token));

    var response = await ApiService.viewPendingDocument(
        username, token, folderName, fileName);

    responsedata = jsonDecode(response.body);

    if (responsedata!['status'] == 200) {
      if (!mounted) return;
      setState(() {
        valueList = responsedata!['value'];
        imageValue =
            valueList!['ImageValue'] == null ? "" : valueList!['ImageValue'];
        mimeType = valueList!['mimetype'];
        imageValueBytes = base64.decode(imageValue);
        bytesImage = base64.decode(imageValue.split('\n').join());
      });
    }

    if (mimeType == 'image/jpg' ||
        mimeType == 'image/jpeg' ||
        mimeType == 'image/png' ||
        mimeType == 'image/gif') {
      Uint8List _imageData = bytesImage!.buffer.asUint8List();
      Image image1 = Image.memory(_imageData);
      Completer<ui.Image> completer = Completer();
      image1.image.resolve(const ImageConfiguration()).addListener(
            ImageStreamListener(
                (ImageInfo info, bool _) => completer.complete(info.image)),
          );
      ui.Image rawImage = await completer.future;
      setState(() {
        viewedImageWidth = rawImage.width;
        viewedImageHeight = rawImage.height;
      });
    } else if (mimeType == 'application/pdf') {
      var random = Random.secure();
      int randomInt = random.nextInt(1000);
      Directory tempDir = await getTemporaryDirectory();
      File pdffile2 = File('${tempDir.path}/sample$randomInt.pdf');
      List<int> imageValueBytesX = base64Decode(imageValue);
      await pdffile2.writeAsBytes(imageValueBytesX);

      render.PdfImageRendererPdf pdf2 =
          render.PdfImageRendererPdf(path: pdffile2.path);
      await pdf2.open();
      await pdf2.openPage(pageIndex: 0);
      final pagesize = await pdf2.getPageSize(pageIndex: 0);

      pdfToimg = await pdf2.renderPage(
        pageIndex: 0,
        width: pagesize.width,
        height: pagesize.height,
        x: 0,
        y: 0,
        scale: 2,
        background: Colors.white,
      );

      await pdf2.closePage(pageIndex: 0);
      pdf2.close();

      Image image2 = Image.memory(pdfToimg!);

      Completer<ui.Image> completer = Completer();
      image2.image.resolve(ImageConfiguration()).addListener(
            ImageStreamListener(
                (ImageInfo info, bool _) => completer.complete(info.image)),
          );
      final ui.Image rawImage2 = await completer.future;
      setState(() {
        viewedImageWidth = rawImage2.width;
        viewedImageHeight = rawImage2.height;
      });
    }

    print("template id is $templateId");
    setState(() {
      // if (templateId != 0 && saveAndNext == false) {
      //   getTextFieldsForSelectedTemplate(templateId, token, imageValue);
      // }
    });
    // getUsernamesDropdown();

    ocrValues2.clear();

    if (fileN.endsWith('.mp4')) {
      Directory tempDirec = await getTemporaryDirectory();
      _mp4File = File('${tempDirec.path}/temp.mp4');
      bytes = base64.decode(imageValue);
      await _mp4File!.writeAsBytes(bytes);
      _videoPlayerController = VideoPlayerController.file(_mp4File!);
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: 2,
        autoPlay: true,
        fullScreenByDefault: false,
      );

      setState(() {});
    }
    if (fileN.endsWith('.mp3')) {
      audioplayer.setReleaseMode(ReleaseMode.stop);
      Directory tempDir = await getTemporaryDirectory();
      _mp3File = File('${tempDir.path}/temp.mp3');
      bytes = base64.decode(imageValue);
      if (_mp3File != null) {
        await _mp3File!.writeAsBytes(bytes);
      }
      await audioplayer.setSourceUrl(_mp3File!.path);
      audioplayer.onPlayerStateChanged.listen((state) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      });

      //listen to audio duration
      audioplayer.onDurationChanged.listen((newDuration) {
        setState(() {
          duration = newDuration;
        });
      });

      //listen to audio position
      audioplayer.onPositionChanged.listen((newPosition) {
        setState(() {
          position = newPosition;
        });
      });
    }
  }

// -------- GET API - Textfields for selected template item -------------//

  Future<List<String>> getTextFieldsForSelectedTemplate(
      int tempId, String usertoken, String imageValueX) async {
    // if (isLoadedTextFields == false) {
    //   showProgressDialog(context);
    // }

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
          String ocrText =
              await extractOCRText(imageValueX, newX, newY, newW, newH);

          if (mounted)
            setState(() {
              ocrValues2.add(ocrText);
            });
        }
      }
      setState(() {
        alltextFieldvalues = jsonDecode(response3.body)['value'].toList();

        textFieldvalues2 = jsonDecode(response3.body)['value']
            .where((field) => field['indexFieldType'] != 'OCR')
            .toList();

        ocrTextFieldvalues = jsonDecode(response3.body)['value']
            .where((field) => field['indexFieldType'] == 'OCR')
            .toList();

        folderpathContrller.text = jsonDecode(response3.body)['temp_path'];
      });

      if (ocrTextFieldvalues.length == 0) {
        _allcontrollers = List.generate(
          alltextFieldvalues.length,
          (index4) => TextEditingController(),
        );
      } else {
        _allcontrollers = List.generate(
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
    Random random = Random.secure();
    int randomInt = random.nextInt(100000);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    if (mimeType == 'image/jpg' ||
        mimeType == 'image/jpeg' ||
        mimeType == 'image/png' ||
        mimeType == 'image/gif') {
      Directory tempDir1 = await getTemporaryDirectory();
      Uint8List imageData = base64.decode(base64String);

      img1.Image? image = img1.decodeImage(imageData);

      img1.Image croppedImage1 =
          img1.copyCrop(image!, x: x, y: y, width: w, height: h);

      List<int> croppedImageData1 = img1.encodeJpg(croppedImage1);

      String filename = 'abc$randomInt.jpg';
      File imageFile = File('${tempDir1.path}/$filename');

      await imageFile.writeAsBytes(croppedImageData1);

      final RecognizedText recognized = await textRecognizer
          .processImage(InputImage.fromFilePath(imageFile.path));

      recognizedText = recognized.text;
    } else if (mimeType == 'application/pdf') {
      img1.Image? imageX = img1.decodeImage(pdfToimg!);

      img1.Image croppedImageX =
          img1.copyCrop(imageX!, x: x, y: y, width: w, height: h);
      List<int> croppedImageData2 = img1.encodeJpg(croppedImageX);

      String appDocDirectory2 = (await getTemporaryDirectory()).path;
      final imagePath2 = '$appDocDirectory2/xyz$randomInt.jpg';
      File imageFile2 = File(imagePath2);
      await imageFile2.writeAsBytes(croppedImageData2);

      final RecognizedText recognized2 = await textRecognizer
          .processImage(InputImage.fromFilePath(imageFile2.path));

      recognizedText = recognized2.text;

      // recognizedText = await FlutterTesseractOcr.extractText(imageFile2.path,
      //     language: 'eng',
      //     args: {
      //       "psm": "4",
      //       "preserve_interword_spaces": "1",
      //     });

      await imageFile2.delete();
    }
    return recognizedText;
  }

  // -------- GET API - Delete selecetd grid item -------------//

  Future<void> removeIndexedDocumentFromPending(String fileN) async {
    _storage = await SharedPreferences.getInstance();
    userObj = jsonDecode(_storage.getString('user_data')!);
    token = _storage.getString('token')!;

    if (mounted) {
      setState(() {
        username = userObj!["value"]["userName"];
        fileName = fileN;
        folderName = widget.folderName;
      });
    }

    if (fileName != "" && folderName != "") {
      var response = await ApiService.deletePendingDocument(
        username,
        token,
        folderName,
        fileName,
      );

      responsedata = jsonDecode(response.body);
      print(responsedata);
      if (!mounted) return;
      setState(() {
        valList = valList.map((folder) {
          final String key = folder.keys.first;
          final List<dynamic> values = folder.values.first;
          if (key == folderName) {
            values.remove(fileName);
          }
          return {key: values};
        }).toList();
      });
    }
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

    if (alltextFieldvalues.length > 0) {
      for (var i = 0; i < alltextFieldvalues.length; i++) {
        String fieldName = alltextFieldvalues[i]['indexFieldName'].toString();
        print("fieldName is $fieldName");
        String fieldValue = _allcontrollers[i].text.trim();
        print("fieldValue is $fieldValue");

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
    }

    payloadImage['indexValue'] = indexValues;
    payloadImage['mime/type'] = mimeType;
    payloadImage['valueImage'] = imageValue;
    payloadImage['templateId'] = templateId;
    payloadImage['longitude'] = _storage.getString('longitude');
    payloadImage['latitude'] = _storage.getString('latitiude');
    payloadImage['extractedText'] = "";
    payloadImage["approvedUser"] = assigendUser;
    payloadImage["remark"] = remraksController.text;

    final pl = jsonEncode(payloadImage);

    var response4 = await ApiService.indexPendingDocuments(
        templateId, templateType!, fileName, token, user, pl);
    print('Response body: ${response4.body.toString()}');

    closeDialog(context);
    if (response4.statusCode == 200) {
      widget.removeDocCallBack();

      await removeIndexedDocumentFromPending(widget.fileNames2[fileIndex]);

      await updatesFileNamesList(fileIndex);
      setState(() {
        isLoadedTextFields = true;
      });

      print("number of items in widget.fileNames2 ${widget.fileNames2.length}");
      print("widget.fileNames2 ${widget.fileNames2}");
      if (widget.fileNames2.isNotEmpty) {
        print("fileIndex $fileIndex");
        if (fileIndex == widget.fileNames2.length) {
          viewSelectedPendingDocument(
              widget.fileNames2[fileIndex - 1], fileIndex - 1);
        } else {
          viewSelectedPendingDocument(widget.fileNames2[fileIndex], fileIndex);
        }

        showPendingDocIndexedSuccesfullyPopup(
          context,
          'assets/images/success-green-icon.png',
          "File Indexed Successfully.",
          okRecognition,
          Color.fromARGB(255, 237, 172, 10),
        );
      } else {
        print("list is empty");
        lastDocuentSubmitPopup(
          context,
          "Last File Indexed Successfully.",
          'assets/images/success-green-icon.png',
          PendingDocsListScreen(),
          Color.fromARGB(255, 237, 172, 10),
          username,
          token,
        );
      }
    } else if (response4.statusCode == 500 || response4.statusCode == 501) {
      showWarningDialogPopup(
        context,
        Icons.warning,
        "Internal server error! Please contact auraDOCS administrator.",
        okRecognition,
        Color.fromARGB(255, 237, 172, 10),
      );
    }
  }

  // ------------ POST API - Send Full Folder when indexing ------------ //

  Future<void> indexAllPendingDocumentsAtOnce2() async {
    showProgressDialog(context);
    _storage = await SharedPreferences.getInstance();

    Map<String, dynamic> payloadImage = {};

    List<Map<String, String>> indexValues = [];

    if (alltextFieldvalues.length > 0) {
      for (var i = 0; i < alltextFieldvalues.length; i++) {
        String fieldName = alltextFieldvalues[i]['indexFieldName'].toString();
        String fieldValue = _allcontrollers[i].text.trim();

        if (alltextFieldvalues[i]['indexFieldType'] == 'Check-Box') {
          Map<String, String> indexValue = {
            "key": fieldName,
            "value": isCheckBoxMarked.toString(),
          };
          indexValues.add(indexValue);
        } else {
          Map<String, String> indexValue = {
            "key": fieldName,
            "value": fieldValue,
          };
          indexValues.add(indexValue);
        }
      }
    }

    payloadImage['templateId'] = templateId;
    payloadImage['longitude'] = _storage.getString('longitude');
    payloadImage['latitude'] = _storage.getString('latitude');
    payloadImage['extractedText'] = "";
    payloadImage['indexValue'] = indexValues;
    payloadImage['fileList'] = widget.fileNames2;

    final pl = jsonEncode(payloadImage);

    var response5 = await ApiService.indexAllDocumentsAtOnce(
        templateId, templateType!, folderName, token, username, pl);

    if (response5.statusCode == 200) {
      widget.removeDocCallBack();

      for (String fileName in widget.fileNames2) {
        await removeIndexedDocumentFromPending(fileName);
      }

      setState(() {
        isLoadedTextFields = true;
      });

      closeDialog(context);

      print("number of items in widget.fileNames2 ${widget.fileNames2.length}");
      print("widget.fileNames2 ${widget.fileNames2}");

      lastDocuentSubmitPopup(
        context,
        "Folder Indexed Successfully.",
        'assets/images/success-green-icon.png',
        PendingDocsListScreen(),
        Color.fromARGB(255, 237, 172, 10),
        username,
        token,
      );
    } else if (response5.statusCode == 404) {
      closeDialog(context);

      showWarningDialogPopup(
        context,
        Icons.warning,
        "Folder indexing failed.",
        okRecognition,
        Color.fromARGB(255, 237, 172, 10),
      );
    } else if (response5.statusCode == 500 || response5.statusCode == 501) {
      closeDialog(context);

      showWarningDialogPopup(
        context,
        Icons.warning,
        "Internal server error! Please contact auraDOCS administrator.",
        okRecognition,
        Color.fromARGB(255, 237, 172, 10),
      );
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

  List<dynamic> updatesFileNamesList(int index) {
    widget.fileNames2.removeAt(index);
    return widget.fileNames2;
  }

  //-----------**********------  DISPLAY TEXT FIELDS ----------*********----------------

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
              ? 4
              : alltextFieldvalues[index]['indexFieldDisplayAs'] == 'Address'
                  ? 3
                  : 1,
          textInputAction: TextInputAction.next,
          controller: _allcontrollers[index],
          onSaved: (newValue) {
            _allcontrollers[index].text == newValue;
            FocusScope.of(context).unfocus();
          },
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
            value = _allcontrollers[index].text;
            if (alltextFieldvalues[index]['indexFieldRequiredYN'] == 'Y' &&
                value.isEmpty) {
              return "${alltextFieldvalues[index]['indexFieldDisplayAs']} is required.";
            }
            return null;
          },
          keyboardType: alltextFieldvalues[index]['indexFieldType'] == 'Text' ||
                  alltextFieldvalues[index]['indexFieldType'] ==
                      'Please Select' ||
                  alltextFieldvalues[index]['indexFieldType'] == 'Text-Area' ||
                  alltextFieldvalues[index]['indexFieldType'] ==
                      "Folder-Name" ||
                  alltextFieldvalues[index]['indexFieldType'] == "Select"
              ? TextInputType.text
              : TextInputType.datetime,
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

  //-------------- Display OCR Text Field-----------------//

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
                  controller: _allcontrollers[index],
                  // onChanged: (newValue) {
                  //   _allcontrollers[index].text = newValue;
                  // },
                  onSaved: (newValue) {
                    _allcontrollers[index].text = newValue!;
                  },
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0)),
                    labelText:
                        alltextFieldvalues[index]['indexFieldRequiredYN'] == 'Y'
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
                    value = _allcontrollers[index].text;
                    if (alltextFieldvalues[index]['indexFieldRequiredYN'] ==
                            'Y' &&
                        value.isEmpty) {
                      return "${alltextFieldvalues[index]['indexFieldDisplayAs']} is required.";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                ),
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
              controller: _allcontrollers[index],
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
                labelText: alltextFieldvalues[index]['indexFieldRequiredYN'] ==
                        'Y'
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
              ),
              validator: (value) {
                value = _allcontrollers[index].text;
                if (alltextFieldvalues[index]['indexFieldRequiredYN'] == 'Y' &&
                    value.isEmpty) {
                  return '${alltextFieldvalues[index]['indexFieldDisplayAs']} is required';
                }
                return null;
              },
              // keyboardType: TextInputType.datetime,
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
        _allcontrollers[index].text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // ----------------------- Display pd_data dropdown ---------------//

  Widget displayPdDataDropdowns(int index) {
    List<String> dropdownValues2 = [_initialValue];

    var pdDataList = alltextFieldvalues[index]['pd_data'];
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
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(1),
        ),
        child: DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(12),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
          ),
          // value: _selectedValue,
          value: _selectedValues[index],
          onChanged: (newValue) {
            setState(() {
              // _selectedValue = newValue!;
              _selectedValues[index] = newValue!;
              _allcontrollers[index].text = newValue.toString();
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
        alltextFieldvalues[index]['indexFieldDisplayAs'],
        style: TextStyle(
          fontSize: Responsive.isMobileSmall(context) ||
                  Responsive.isMobileMedium(context) ||
                  Responsive.isMobileLarge(context)
              ? 16
              : Responsive.isTabletPortrait(context)
                  ? 17
                  : 17,
          color: Colors.black54,
        ),
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

  // Widget displayContainer(int index) {
  //   return Container(
  //     height: 50,
  //     width: MediaQuery.of(context).size.width,
  //     color: Colors.amber,
  //     child: Text("Index is $index"),
  //   );
  // }
  _scrollToMaxValue() {
    if (_scrollController.positions.length > 0) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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

  @override
  Widget build(BuildContext context) {
    if (templateType != null)
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToMaxValue());

    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => PendingDocsListScreen(),
          ),
          (route) => false,
        );
      },
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                getSearchBoxWidget(),
                Divider(height: 8),
                SizedBox(
                  height: Responsive.isMobileSmall(context)
                      ? size.height * 0.86
                      : Responsive.isMobileMedium(context)
                          ? size.height * 0.85
                          : Responsive.isMobileLarge(context)
                              ? size.height * 0.85
                              : Responsive.isTabletPortrait(context)
                                  ? size.height * 0.86
                                  : size.height * 0.85,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: _scrollController,
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
                                Icon(
                                  Icons.check_sharp,
                                  color: Colors.white,
                                  size: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 25
                                      : 35,
                                ),
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
                        // --------- PREVIEW AREA ----------
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5.0),
                          child: Container(
                            color: Color.fromARGB(218, 1, 5, 25),
                            height: Responsive.isMobileSmall(context)
                                ? size.height * 0.6
                                : Responsive.isMobileMedium(context)
                                    ? size.height * 0.6
                                    : Responsive.isMobileLarge(context)
                                        ? size.height * 0.6
                                        : Responsive.isTabletPortrait(context)
                                            ? size.height * 0.66
                                            : size.height * 0.6,
                            child: Column(
                              children: [
                                Container(
                                  height: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.height * 0.06
                                      : Responsive.isTabletPortrait(context)
                                          ? size.height * 0.05
                                          : size.height * 0.06,
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
                                                base64String: imageValue,
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
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, left: 0),
                                  child: Container(
                                    height: Responsive.isMobileSmall(context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 28
                                        : Responsive.isTabletPortrait(context)
                                            ? 35
                                            : 35,
                                    color: Colors.black12,
                                    child: Text(
                                      widget.fileNames2.isNotEmpty
                                          ? widget.fileNames2[fileIndex]
                                          : "",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: Responsive.isMobileSmall(
                                                context)
                                            ? 13
                                            : Responsive.isMobileMedium(context)
                                                ? 14
                                                : Responsive.isMobileLarge(
                                                        context)
                                                    ? 15
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? 19
                                                        : 19,
                                      ),
                                      textAlign: TextAlign.start,
                                      textScaler: TextScaler.linear(1),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 8.0, right: 8.0),
                                    child: Container(
                                      color: Colors.white,
                                      height: Responsive.isMobileSmall(context)
                                          ? 300
                                          : Responsive.isMobileMedium(context)
                                              ? 320
                                              : Responsive.isMobileLarge(
                                                      context)
                                                  ? size.width * 0.9
                                                  : Responsive.isTabletPortrait(
                                                          context)
                                                      ? size.height * 0.5
                                                      : size.height * 0.45,
                                      width: double.infinity,
                                      child: ClipRRect(
                                        clipBehavior: Clip.hardEdge,
                                        child: Transform.scale(
                                          scale: _scale,
                                          child: displayFile(mimeType),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // --------- SKIP BUTTONS ----------

                                Container(
                                  height: 40,
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(
                                          Icons.arrow_back_ios,
                                          color: fileIndex == 0
                                              ? Colors.grey
                                              : Colors.white,
                                        ),
                                        iconSize: 24,
                                        onPressed: fileIndex == 0
                                            ? null
                                            : () async {
                                                setState(() {
                                                  fileIndex = fileIndex - 1;
                                                });
                                                print(
                                                    "after pressed reverse arrow : $fileIndex");
                                                viewSelectedPendingDocument(
                                                    widget
                                                        .fileNames2[fileIndex],
                                                    fileIndex);

                                                // ---------- NEED TO ADD IN NEAR FUTURE ------------

                                                //   .then((value) {
                                                // if (saveAndNext == true) {
                                                //   setState(() {
                                                //     isCheckBoxMarked =
                                                //         isCheckBoxMarked;

                                                //   });
                                                // } else {
                                                //   setState(() {
                                                //     isCheckBoxMarked = false;

                                                //     _selectedValues = List<
                                                //             String>.generate(
                                                //         alltextFieldvalues
                                                //             .length,
                                                //         (index) =>
                                                //             _initialValue);
                                                //   });
                                                //   }
                                                // });
                                              },
                                      ),
                                      IconButton(
                                          icon: Icon(
                                            Icons.arrow_forward_ios,
                                            color: fileIndex ==
                                                    widget.fileNames2.length - 1
                                                ? Colors.grey
                                                : Colors.white,
                                          ),
                                          iconSize: 24,
                                          onPressed: () async {
                                            if (fileIndex <
                                                widget.fileNames2.length - 1) {
                                              setState(() {
                                                fileIndex = fileIndex + 1;
                                              });
                                              print(
                                                  "after pressed forward arrow : $fileIndex");
                                              print(
                                                  "widget.fileNames2.length : ${widget.fileNames2.length}");
                                              viewSelectedPendingDocument(
                                                  widget.fileNames2[fileIndex],
                                                  fileIndex);

                                              // ---------- NEED TO ADD IN NEAR FUTURE ------------

                                              // .then((value) {
                                              // if (saveAndNext == true) {
                                              //   setState(() {
                                              //     isCheckBoxMarked =
                                              //         isCheckBoxMarked;
                                              //   });
                                              // } else {
                                              //   setState(() {
                                              //     isCheckBoxMarked = false;

                                              //     _selectedValues =
                                              //         List<String>.generate(
                                              //             alltextFieldvalues
                                              //                 .length,
                                              //             (index) =>
                                              //                 _initialValue);
                                              //   });
                                              // }
                                              // });
                                            } else {
                                              null;
                                            }
                                          }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // --------- DOCUMENT DETAILS SECTION ------------- //
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        BlocBuilder<DocumentBloc, DocumentState>(
                            builder: (context, state) {
                          if (state is DocumentLoading) {
                            return CircularProgressIndicator(
                                color: Colors.amber);
                          } else if (state is TemplateDropdownLoaded) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(0),
                                  border: Border.all(color: borderColor),
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
                                        fontSize:
                                            Responsive.isMobileSmall(context) ||
                                                    Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 13
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 16
                                                    : 17,
                                      ),
                                      textScaler: TextScaler.linear(1),
                                    ),
                                    value: templateType,
                                    onChanged: (String? newValue) async {
                                      int index = state.dropdownValues
                                          .indexOf(newValue!);
                                      int selectedTemplateKey = int.parse(
                                          state.values[index].keys.first);
                                      setState(() {
                                        templateType = newValue;
                                        templateId = selectedTemplateKey;
                                      });

                                      print(templateId);
                                      await getTextFieldsForSelectedTemplate(
                                          selectedTemplateKey,
                                          token,
                                          imageValue);

                                      ocrValues2.clear();
                                    },
                                    items: state.dropdownValues
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                            fontSize: Responsive.isMobileSmall(
                                                        context) ||
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
                            );
                          } else if (state is DocumentError) {
                            return Text("Error: ${state.message}");
                          } else {
                            return Text('Select a template');
                          }
                        }),

                        //     DropdownButton<String>(
                        //       items: state.dropdownValues
                        //           .map((value) => DropdownMenuItem<String>(
                        //                 value: value,
                        //                 child: Text(value),
                        //               ))
                        //           .toList(),
                        //       onChanged: (newValue) {
                        //         // Handle the dropdown change if needed
                        //       },
                        //     );
                        //   } else if (state is DocumentError) {
                        //     return Text("Error: ${state.message}");
                        //   } else {
                        //     return Text('Select a template');
                        //   }

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            key: _formKey,
                            autovalidateMode: _autoValidate,
                            child: Column(
                              children: <Widget>[
                                if ((templateType != null || templateId != 0) &&
                                    (alltextFieldvalues.length > 0) &&
                                    (folderpathContrller.text != "-"))
                                  displayFolderPathTextField(),
                                FutureBuilder(
                                  future: null,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator(
                                          color: Colors.amber);
                                    } else if (snapshot.hasError) {
                                      return Text(
                                        'Error: ${snapshot.error}',
                                        textScaler: TextScaler.linear(1),
                                      );
                                    } else {
                                      if (alltextFieldvalues.isNotEmpty) {
                                        return ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: alltextFieldvalues.length,
                                          itemBuilder: (context, index) {
                                            String field =
                                                alltextFieldvalues[index]
                                                    ['indexFieldType'];

                                            if (index <
                                                alltextFieldvalues.length) {
                                              if (field == "OCR") {
                                                if (index <
                                                    ocrTextFieldvalues.length) {
                                                  fieldType1 = "OCR";
                                                } else if (index >
                                                    ocrTextFieldvalues.length) {
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
                                                  fieldType1 == "Folder-Name" ||
                                                  fieldType1 == "File-Name" ||
                                                  fieldType1 == "Bulk" ||
                                                  fieldType1 == "Text-Area" ||
                                                  fieldType1 ==
                                                      "Please Select" ||
                                                  fieldType1 == "Barcode" ||
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
                                              } else if (isCheckBox) {
                                                return displayCheckbox(index);
                                              } else if (isPDDropdown) {
                                                return displayPdDataDropdowns(
                                                    index);
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
                                ),
                                //  ------------ Index All at once checkbox ------------------

                                if ((templateType != null || templateId != 0) &&
                                    (alltextFieldvalues.length > 0))
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 9,
                                          child: Text(
                                            "Folder Index ",
                                            style: TextStyle(
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
                                                  ? 16
                                                  : Responsive.isMobileMedium(
                                                              context) ||
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 17
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? 17
                                                          : 17,
                                              color: Colors.black87,
                                            ),
                                            textScaler: TextScaler.linear(1),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Checkbox(
                                            value: isAlIndexedOnce,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isAlIndexedOnce = value!;

                                                if (isAlIndexedOnce == true) {
                                                  totalNoOfFilesToIndex =
                                                      widget.fileNames2.length;

                                                  print(
                                                      "totalNoOfFilesToIndex $totalNoOfFilesToIndex");
                                                }
                                              });
                                              print(
                                                  "isAlIndexedOnce $isAlIndexedOnce");
                                            },
                                            activeColor: Colors.amber,
                                            checkColor: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                SizedBox(height: size.height * 0.03),

                                if ((templateType != null || templateId != 0) &&
                                    (alltextFieldvalues.length > 0))
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: Responsive.isMobileSmall(
                                                    context) ||
                                                Responsive.isMobileMedium(
                                                    context)
                                            ? 130
                                            : Responsive.isMobileLarge(context)
                                                ? 130
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 140
                                                    : 150,
                                        height: Responsive.isMobileSmall(
                                                context)
                                            ? 38
                                            : Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 40
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 45
                                                    : 50,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.transparent),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Color.fromARGB(
                                                255, 30, 128, 219)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () async {
                                                if (_selectedItem == "Save >") {
                                                  setState(() {
                                                    saveAndNext = false;
                                                  });

                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    print("If block-validate");
                                                    _formKey.currentState!
                                                        .save();

                                                    if (isAlIndexedOnce ==
                                                        false) {
                                                      await uploadPendingDocumentsToIndex();

                                                      _formKey.currentState!
                                                          .reset();
                                                      setState(() {
                                                        isCheckBoxMarked =
                                                            false;
                                                        for (TextEditingController controller
                                                            in _allcontrollers) {
                                                          controller.clear();
                                                        }
                                                        _selectedValues = List<
                                                                String>.generate(
                                                            alltextFieldvalues
                                                                .length,
                                                            (index) =>
                                                                _initialValue);

                                                        _autoValidate =
                                                            AutovalidateMode
                                                                .disabled;
                                                      });
                                                    } else {
                                                      showDialog(
                                                          barrierColor:
                                                              Color.fromARGB(
                                                                  177,
                                                                  18,
                                                                  17,
                                                                  17),
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            0),
                                                              ),
                                                              backgroundColor:
                                                                  Colors.white,
                                                              title: Text(
                                                                'Index All',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: Responsive
                                                                          .isMobileSmall(
                                                                              context)
                                                                      ? 20
                                                                      : Responsive.isMobileMedium(
                                                                              context)
                                                                          ? 22
                                                                          : Responsive.isMobileLarge(context)
                                                                              ? 23
                                                                              : Responsive.isTabletPortrait(context)
                                                                                  ? 25
                                                                                  : 25,
                                                                ),
                                                                textScaler:
                                                                    TextScaler
                                                                        .linear(
                                                                            1),
                                                              ),
                                                              content: Text(
                                                                'There are $totalNoOfFilesToIndex files that are going to be indexed. Are you sure you want to index all at once?',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: Responsive
                                                                          .isMobileSmall(
                                                                              context)
                                                                      ? 14
                                                                      : Responsive.isMobileMedium(context) ||
                                                                              Responsive.isMobileLarge(context)
                                                                          ? 16
                                                                          : Responsive.isTabletPortrait(context)
                                                                              ? 18
                                                                              : 21,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                textScaler:
                                                                    TextScaler
                                                                        .linear(
                                                                            1),
                                                                textAlign:
                                                                    TextAlign
                                                                        .justify,
                                                              ),
                                                              actions: <Widget>[
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child: Text(
                                                                    'Cancel',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize: Responsive.isMobileSmall(
                                                                              context)
                                                                          ? 13
                                                                          : Responsive.isMobileMedium(context) || Responsive.isMobileLarge(context)
                                                                              ? 15
                                                                              : Responsive.isTabletPortrait(context)
                                                                                  ? 17
                                                                                  : 20,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                    textScaler:
                                                                        TextScaler
                                                                            .linear(1),
                                                                  ),
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                    fixedSize:
                                                                        Size(90,
                                                                            40),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .grey
                                                                            .shade400,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              2),
                                                                    ),
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();

                                                                    // NEW SERVICE METHOD NEED TO BE ADDED

                                                                    await indexAllPendingDocumentsAtOnce2();
                                                                    _formKey
                                                                        .currentState!
                                                                        .reset();
                                                                    setState(
                                                                      () {
                                                                        isCheckBoxMarked =
                                                                            false;
                                                                        isAlIndexedOnce =
                                                                            false;
                                                                        for (TextEditingController controller
                                                                            in _allcontrollers) {
                                                                          controller
                                                                              .clear();
                                                                        }
                                                                        // _selectedValue =
                                                                        //     _initialValue;
                                                                        _selectedValues = List<String>.generate(
                                                                            alltextFieldvalues
                                                                                .length,
                                                                            (index) =>
                                                                                _initialValue);

                                                                        _autoValidate =
                                                                            AutovalidateMode.disabled;
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Text(
                                                                    'OK',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize: Responsive.isMobileSmall(
                                                                              context)
                                                                          ? 13
                                                                          : Responsive.isMobileMedium(context) || Responsive.isMobileLarge(context)
                                                                              ? 15
                                                                              : Responsive.isTabletPortrait(context)
                                                                                  ? 17
                                                                                  : 20,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    textScaler:
                                                                        TextScaler
                                                                            .linear(1),
                                                                  ),
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                          fixedSize: Size(
                                                                              90,
                                                                              40),
                                                                          backgroundColor: Colors
                                                                              .amber,
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(2),
                                                                          )),
                                                                ),
                                                              ],
                                                            );
                                                          });
                                                    }
                                                  } else {
                                                    setState(() {
                                                      _autoValidate =
                                                          AutovalidateMode
                                                              .always;
                                                    });
                                                    print(
                                                        "Else block-validate");
                                                  }
                                                } else {
                                                  setState(() {
                                                    saveAndNext = true;
                                                  });
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    print("If block-validate");
                                                    _formKey.currentState!
                                                        .save();

                                                    await uploadPendingDocumentsToIndex();

                                                    setState(() {
                                                      _autoValidate =
                                                          AutovalidateMode
                                                              .disabled;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      _autoValidate =
                                                          AutovalidateMode
                                                              .always;
                                                    });
                                                    print(
                                                        "Else block-validate");
                                                  }
                                                }
                                              },
                                              child: Container(
                                                width: Responsive.isMobileSmall(
                                                        context)
                                                    ? 70
                                                    : Responsive.isMobileMedium(
                                                            context)
                                                        ? 80
                                                        : Responsive
                                                                .isMobileLarge(
                                                                    context)
                                                            ? 80
                                                            : Responsive
                                                                    .isTabletPortrait(
                                                                        context)
                                                                ? 90
                                                                : 100,
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 30, 128, 219),
                                                ),
                                                child: Text(
                                                  _selectedItem.length > 8
                                                      ? '${_selectedItem.substring(0, 8)}..'
                                                      : _selectedItem,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontSize: Responsive
                                                            .isMobileSmall(
                                                                context)
                                                        ? 14
                                                        : Responsive
                                                                .isMobileMedium(
                                                                    context)
                                                            ? 15.5
                                                            : Responsive
                                                                    .isMobileLarge(
                                                                        context)
                                                                ? 16
                                                                : Responsive.isTabletPortrait(
                                                                        context)
                                                                    ? 18
                                                                    : 20,
                                                  ),
                                                  textScaler:
                                                      TextScaler.linear(1),
                                                ),
                                              ),
                                            ),
                                            //  ------------ Save , Skip and Reset Buttons ------------------
                                            Container(
                                              width: 40,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                    left: BorderSide(
                                                  color: Colors.grey,
                                                )),
                                              ),
                                              child: PopupMenuButton(
                                                icon: Icon(
                                                  Icons.arrow_drop_down,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                itemBuilder:
                                                    (BuildContext context) =>
                                                        <PopupMenuEntry>[
                                                  PopupMenuItem(
                                                    child: Text(
                                                      'Save >',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: Responsive
                                                                    .isMobileSmall(
                                                                        context) ||
                                                                Responsive
                                                                    .isMobileMedium(
                                                                        context) ||
                                                                Responsive
                                                                    .isMobileLarge(
                                                                        context)
                                                            ? 15
                                                            : Responsive
                                                                    .isTabletPortrait(
                                                                        context)
                                                                ? 18
                                                                : 20,
                                                      ),
                                                      textScaler:
                                                          TextScaler.linear(1),
                                                    ),
                                                    value: 'Save >',
                                                  ),
                                                  PopupMenuItem(
                                                    child: Text(
                                                      'Hold and Next >>',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: Responsive
                                                                    .isMobileSmall(
                                                                        context) ||
                                                                Responsive
                                                                    .isMobileMedium(
                                                                        context) ||
                                                                Responsive
                                                                    .isMobileLarge(
                                                                        context)
                                                            ? 15
                                                            : Responsive
                                                                    .isTabletPortrait(
                                                                        context)
                                                                ? 18
                                                                : 20,
                                                        color: Colors.black,
                                                      ),
                                                      textScaler:
                                                          TextScaler.linear(1),
                                                    ),
                                                    value: 'Save >>',
                                                  ),
                                                ],
                                                onSelected: (value) {
                                                  setState(() {
                                                    _selectedItem =
                                                        value.toString();
                                                  });
                                                  print(
                                                      "new select item is $_selectedItem");

                                                  if (_selectedItem ==
                                                      "Save >") {
                                                    setState(() {
                                                      saveAndNext = false;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      saveAndNext = true;
                                                    });
                                                  }

                                                  print(
                                                      "new saveAndNext status is $saveAndNext");
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      TextButton(
                                        child: Text(
                                          'Skip',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: Responsive.isMobileSmall(
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
                                          if (fileIndex <
                                              widget.fileNames2.length - 1) {
                                            setState(() {
                                              fileIndex = fileIndex + 1;
                                            });
                                            // await viewSelectedPendingDocument(
                                            //         widget
                                            //             .fileNames2[fileIndex],
                                            //         fileIndex)
                                            //     .then((value) {
                                            //   setState(() {
                                            //     isCheckBoxMarked =
                                            //         isCheckBoxMarked;
                                            //     // _selectedValue = _selectedValue;
                                            //   });

                                            //   // } else {
                                            //   //   setState(() {
                                            //   //     isCheckBoxMarked = false;
                                            //   //     _selectedValue =
                                            //   //         _initialValue;
                                            //   //   });
                                            //   // }
                                            // });
                                            await viewSelectedPendingDocument(
                                                widget.fileNames2[fileIndex],
                                                fileIndex);
                                          } else {
                                            null;
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          minimumSize: Size(
                                            Responsive.isMobileSmall(context)
                                                ? 95
                                                : Responsive.isMobileMedium(
                                                        context)
                                                    ? 100
                                                    : Responsive.isMobileLarge(
                                                            context)
                                                        ? 100
                                                        : Responsive
                                                                .isTabletPortrait(
                                                                    context)
                                                            ? 100
                                                            : 130,
                                            Responsive.isMobileSmall(context) ||
                                                    Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 35
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 45
                                                    : 50,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          backgroundColor:
                                              Color.fromARGB(255, 34, 181, 207),
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      TextButton(
                                        child: Text(
                                          'Reset',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: Responsive.isMobileSmall(
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
                                              Responsive.isMobileSmall(context)
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
                                                      Responsive.isMobileMedium(
                                                          context) ||
                                                      Responsive.isMobileLarge(
                                                          context)
                                                  ? 35
                                                  : Responsive.isTabletPortrait(
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // ),
      ),
    );
  }

  // -------- PROCESS MP3 ------------//
  // Future<void> setAudio() async {

  // }

  String? formatTime(Duration duration) {
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

  Future<File> _getPDFFile() async {
    Directory tempDir = await getTemporaryDirectory();
    var random = Random.secure();
    var randomInt = random.nextInt(100000);
    var filename = 'sample_$randomInt.pdf';
    pdffile = File('${tempDir.path}/$filename');
    final imageValueBytes = base64.decode(imageValue);
    await pdffile?.writeAsBytes(imageValueBytes);
    return pdffile!;
  }

  //------------- DISPLAY FILES --------------

  Widget displayFile(String mimeType) {
    Size size = MediaQuery.of(context).size;

    if (mimeType == 'image/jpg' ||
        mimeType == 'image/jpeg' ||
        mimeType == 'image/png' ||
        mimeType == 'image/gif') {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: FullScreenWidget(
          disposeLevel: DisposeLevel.Low,
          child: Image.memory(
            bytesImage!,
            fit: BoxFit.contain,
          ),
        ),
      );
    } else if (mimeType == 'application/pdf') {
      return FutureBuilder<File>(
        future: _getPDFFile(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return SfPdfViewer.file(
              pdffile!,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              canShowPaginationDialog: false,
            );
          } else if (snapshot.hasError) {
            return Text('Error loading PDF file');
          } else {
            return CircularProgressIndicator(color: Colors.amber);
          }
        },
      );
    } else if (mimeType == 'text/csv') {
      final csvBytes = base64Decode(imageValue);
      final decodedCsv = utf8.decode(csvBytes);
      final csvData = CsvToListConverter().convert(decodedCsv);

      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(width: 1),
            headingRowHeight: 20,
            dataRowMinHeight: 20,
            dataRowMaxHeight: 20,
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
    } else if (mimeType == 'text/plain') {
      final fileContent = utf8.decode(base64.decode(imageValue));
      final htmlData = '''
      <html>
        <head>
          <meta charset="UTF-8">
        </head>
        <body>
          $fileContent
        </body>
      </html>
    ''';
      return SingleChildScrollView(
        child: Html(data: htmlData),
      );
    } else if (mimeType == 'application/x-sh') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.file_present,
              size: Responsive.isMobileSmall(context) ||
                      Responsive.isMobileMedium(context) ||
                      Responsive.isMobileLarge(context)
                  ? 50
                  : Responsive.isTabletPortrait(context)
                      ? 70
                      : 60,
              color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "SH Files cannot be previewed..",
            style: TextStyle(
              color: Colors.black54,
              fontSize: Responsive.isMobileSmall(context) ||
                      Responsive.isMobileMedium(context) ||
                      Responsive.isMobileLarge(context)
                  ? 18
                  : Responsive.isTabletPortrait(context)
                      ? 25
                      : 26,
            ),
            textScaler: TextScaler.linear(1),
          ),
        ],
      );
    } else if (mimeType == 'video/mp4' &&
        _videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    } else if (mimeType == 'audio/mpeg' || mimeType == 'audio/x-wav') {
      return Container(
        color: Colors.black,
        child: Column(children: <Widget>[
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              mimeType != 'audio/x-wav'
                  ? "assets/images/mp3-file.jpg"
                  : "assets/images/wav.png",
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
                formatTime(position) ?? "",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 16
                        : Responsive.isTabletPortrait(context)
                            ? 20
                            : 21),
                textScaler: TextScaler.linear(1),
              ),
              Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  await audioplayer.seek(position);

                  await audioplayer.resume;
                },
                activeColor: Colors.blue,
              ),
              Text(
                formatTime(duration - position) ?? "",
                style: TextStyle(
                    fontSize: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 16
                        : Responsive.isTabletPortrait(context)
                            ? 20
                            : 21,
                    color: Colors.white),
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
                    setState(() {
                      if (isPlaying) {
                        audioplayer.pause();
                      } else {
                        audioplayer.resume();
                      }
                    });
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
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
          SizedBox(height: 10),
        ]),
      );
    }
    return Center(child: CircularProgressIndicator(color: Colors.amber));
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return BlocProvider(
                                create: (context) =>
                                    DocumentBloc(username, token),
                                child: SearchedDocumentListScreen(
                                    searchValue: trimmedValue),
                              );
                            },
                          ),
                        );
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
