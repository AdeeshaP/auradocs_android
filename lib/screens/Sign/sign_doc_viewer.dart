import 'dart:convert';
import 'dart:io';
import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart';
import 'package:auradocs_android/API-Services/api_service.dart';
import 'package:auradocs_android/Bloc/document_bloc.dart';
import 'package:auradocs_android/Models/users.dart';
import 'package:auradocs_android/screens/Document-Search/search_list.dart';
import 'package:auradocs_android/screens/Sign/sign_doc_list.dart';
import 'package:auradocs_android/screens/Sign/signing_pad.dart';
import 'package:auradocs_android/screens/Sliders/landing_page.dart';
import 'package:auradocs_android/screens/contact_us_screen.dart';
import 'package:auradocs_android/screens/full-screen-viewer/full_screen_viewer.dart';
import 'package:auradocs_android/screens/home_screen.dart';
import 'package:auradocs_android/utils/alert_dialogs.dart';
import 'package:auradocs_android/utils/constants.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class SignDocViewScreen extends StatefulWidget {
  const SignDocViewScreen({
    super.key,
    required this.fileNames,
    required this.indexOfCurrent,
    required this.approvalId,
  });

  final List<dynamic> fileNames;
  final int indexOfCurrent;
  final int approvalId;

  @override
  State<SignDocViewScreen> createState() => _SignDocViewScreenState();
}

class _SignDocViewScreenState extends State<SignDocViewScreen> {
  double _scale = 1.0;
  late SharedPreferences _storage;
  Map<String, dynamic>? userObj;
  String username = "";
  String token = "";
  String compnyCode = "";
  Map<String, dynamic>? responsedata;
  Uint8List? imageValueBytes;
  String metadata = "";
  String mimeType = "";
  Uint8List? bytesImage;
  List<int> bytes = [];
  int documentId = 0;
  int approvalID = 0;
  int signId = 0;
  String pdfUrl = "";
  String assignedBy = "";
  List<dynamic> valList = [];
  bool isBookMarked = false;
  List<dynamic> valueList = [];
  String assigendUser1 = "";
  String docName = "";
  TextEditingController searchController = TextEditingController();
  int fileIndex = 0;
  String trimmedValue = "";
  GlobalKey _toolTipKey = GlobalKey();
  Map<String, dynamic>? documentObj;
  late PDFDocument doc;
  bool isLoadingPdf = true;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  List<dynamic> signatures = [];
  List authentication = [];

  @override
  void initState() {
    super.initState();
    fileIndex = widget.indexOfCurrent;
    approvalID = widget.approvalId;
    viewDocumentSign(widget.fileNames[fileIndex]['doc_id'], fileIndex);
  }

  @override
  void dispose() {
    super.dispose();
  }

// -------- GET API - get selected document to view -------------//
  Future<void> viewDocumentSign(int docId, int fileIndex2) async {
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
        documentId = docId;
      });
    }
    var response = await ApiService.viewDocumentToSign(token, documentId);

    responsedata = jsonDecode(response.body);
    print("responsedata $responsedata");

    if (responsedata!['status'] == 200) {
      if (mounted) {
        setState(() {
          documentObj = responsedata!['value'];
          assignedBy = documentObj!['assigned_by'];
          documentId = documentObj!['doc_id'];
          pdfUrl = documentObj!['image_url'];
          signatures = documentObj!['signatures'];
        });

        doc = await PDFDocument.fromURL(pdfUrl);

        if (mounted) {
          setState(() {
            isLoadingPdf = false;
          });
        }
      }
    } else if (responsedata!['status'] == 403) {
      showWarningDialogPopupThree(
        context,
        Icons.warning_amber_sharp,
        "You don't have enough privileges to view this document.",
        backToNextDocument,
        Color.fromARGB(255, 237, 172, 10),
        widget.fileNames.length > fileIndex2 + 1 ? "NEXT" : "OK",
      );
    } else if (responsedata!['status'] == 404 || responsedata!['code'] == 404) {
      showWarningDialogPopupThree(
        context,
        Icons.warning_amber_sharp,
        "No signatures to add this pdf.",
        backToNextDocument,
        Color.fromARGB(255, 237, 172, 10),
        widget.fileNames.length > fileIndex2 + 1 ? "NEXT" : "OK",
      );
    } else if (responsedata!['status'] == 500) {
      showWarningDialogPopupThree(
        context,
        Icons.warning,
        "Server error! Please contact auraDOCS administrator.",
        backToNextDocument,
        Color.fromARGB(255, 237, 172, 10),
        widget.fileNames.length > fileIndex2 + 1 ? "NEXT" : "OK",
      );
    }

    setState(() {
      getBookMarkDocument();
    });

    print("assigned by $assignedBy");
    print("documentId $documentId");
    print("length of signatures ${signatures.length}");
  }

  //---------- GET API - Bookmark added to the veiwed document -------------
  Future<void> addBookMarkDocument() async {
    _storage = await SharedPreferences.getInstance();
    userObj = jsonDecode(_storage.getString('user_data')!);
    token = _storage.getString('token')!;
    if (mounted) {
      setState(() {
        username = userObj!["value"]["userName"];
      });
    }

    var response2 = await ApiService.addBookmark(documentId, username, token);

    if (response2.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bookmark added succesfully..'),
        ),
      );
    }
  }

  //---------- GET API - get the status of veiwed document -------------
  Future<void> getBookMarkDocument() async {
    var response3 = await ApiService.getBookmark(documentId, username, token);

    if (response3.statusCode == 200) {
      if (mounted) {
        setState(() {
          isBookMarked = true;
        });
      }
    } else if (response3.statusCode == 404) {
      if (mounted) {
        setState(() {
          isBookMarked = false;
        });
      }
    }
  }

  void okRecognition() {
    closeDialog(context);
  }

  void backToNextDocument() {
    closeDialog(context);
    if (widget.fileNames.length > fileIndex + 1) {
      setState(() {
        fileIndex += 1;
      });
      viewDocumentSign(widget.fileNames[fileIndex]['doc_id'], fileIndex);
    } else {
      okRecognitionAndGoBackScreen();
    }
  }

  void okRecognitionAndGoBackScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => DocumentBloc(username, token),
          child: SignAvailableDocuments(),
        ),
      ),
    );
  }

  void _zoomIn() {
    setState(() {
      _scale *= 1.2;
    });
  }

  void _zoomOut() {
    setState(() {
      _scale /= 1.2;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        new Future(() => true);
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                getSearchBoxWidget(),
                Divider(height: 8),
                Stack(
                  children: <Widget>[
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
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
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
                                    Icon(Icons.check_sharp,
                                        color: Colors.white,
                                        size:
                                            Responsive.isMobileSmall(context) ||
                                                    Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 25
                                                : 28),
                                    SizedBox(
                                        width:
                                            Responsive.isMobileSmall(context) ||
                                                    Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 5
                                                : 15),
                                    Text(
                                      "View",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: Responsive.isMobileSmall(
                                                context)
                                            ? 16
                                            : Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 18
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 24
                                                    : 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                color: Color.fromARGB(255, 233, 104, 44),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2.0),
                              child: Container(
                                color: Color.fromARGB(218, 1, 5, 25),
                                height: Responsive.isMobileSmall(context)
                                    ? size.height * 0.6
                                    : Responsive.isMobileMedium(context)
                                        ? size.height * 0.61
                                        : Responsive.isMobileLarge(context)
                                            ? size.height * 0.67
                                            : Responsive.isTabletPortrait(
                                                    context)
                                                ? size.height * 0.65
                                                : size.height * 0.55,
                                child: Column(
                                  children: [
                                    Container(
                                      height: Responsive.isMobileSmall(
                                                  context) ||
                                              Responsive.isMobileMedium(
                                                  context) ||
                                              Responsive.isMobileLarge(context)
                                          ? size.height * 0.06
                                          : Responsive.isTabletPortrait(context)
                                              ? size.height * 0.048
                                              : size.height * 0.055,
                                      color: Colors.black26,
                                      child: Row(
                                        children: <Widget>[
                                          SizedBox(width: size.width * 0.07),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                            width: 38,
                                            height: 25,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () {},
                                              icon: Icon(
                                                Icons.search,
                                                color: Colors.white,
                                                size: Responsive.isMobileSmall(
                                                            context) ||
                                                        Responsive
                                                            .isMobileMedium(
                                                                context) ||
                                                        Responsive
                                                            .isMobileLarge(
                                                                context)
                                                    ? 22
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? 30
                                                        : 29,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: Responsive.isMobileSmall(
                                                        context) ||
                                                    Responsive.isMobileMedium(
                                                        context)
                                                ? size.width * 0.34
                                                : Responsive.isMobileLarge(
                                                        context)
                                                    ? size.width * 0.36
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? size.width * 0.6
                                                        : size.width * 0.7,
                                          ),
                                          // Zoom-in or Zoom-out
                                          Container(
                                            color: Colors.black26,
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: _zoomIn,
                                                  icon: Icon(
                                                    Icons.add,
                                                    color: Colors.grey[200],
                                                    size: Responsive
                                                                .isMobileSmall(
                                                                    context) ||
                                                            Responsive
                                                                .isMobileMedium(
                                                                    context) ||
                                                            Responsive
                                                                .isMobileLarge(
                                                                    context)
                                                        ? 22
                                                        : Responsive
                                                                .isTabletPortrait(
                                                                    context)
                                                            ? 30
                                                            : 29,
                                                  ),
                                                ),
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: _zoomOut,
                                                  icon: Icon(
                                                    Icons.remove,
                                                    color: Colors.grey[200],
                                                    size: Responsive
                                                                .isMobileSmall(
                                                                    context) ||
                                                            Responsive
                                                                .isMobileMedium(
                                                                    context) ||
                                                            Responsive
                                                                .isMobileLarge(
                                                                    context)
                                                        ? 22
                                                        : Responsive
                                                                .isTabletPortrait(
                                                                    context)
                                                            ? 30
                                                            : 29,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Full Screen mode button

                                          SizedBox(
                                            width: Responsive.isMobileSmall(
                                                    context)
                                                ? 10
                                                : Responsive.isMobileMedium(
                                                        context)
                                                    ? 12
                                                    : Responsive.isMobileLarge(
                                                            context)
                                                        ? 23
                                                        : Responsive
                                                                .isTabletPortrait(
                                                                    context)
                                                            ? 35
                                                            : 35,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                            width: 40,
                                            height: 40,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        FullScreenViewer(
                                                      base64String: metadata,
                                                      mimeT: mimeType,
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: Icon(
                                                Icons.fullscreen,
                                                color: Colors.white,
                                                size: Responsive.isMobileSmall(
                                                        context)
                                                    ? 20
                                                    : Responsive.isMobileMedium(
                                                                context) ||
                                                            Responsive
                                                                .isMobileLarge(
                                                                    context)
                                                        ? 25
                                                        : Responsive
                                                                .isTabletPortrait(
                                                                    context)
                                                            ? 30
                                                            : 29,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: Container(
                                          color: Colors.white,
                                          height: Responsive.isMobileSmall(
                                                  context)
                                              ? size.height * 0.49
                                              : Responsive.isMobileMedium(
                                                      context)
                                                  ? size.height * 0.5
                                                  : Responsive.isMobileLarge(
                                                          context)
                                                      ? size.height * 0.55
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? size.height * 0.55
                                                          : size.height * 0.41,
                                          width: size.width * 0.9,
                                          child: ClipRRect(
                                            clipBehavior: Clip.hardEdge,
                                            child: Transform.scale(
                                              scale: _scale,
                                              child: isLoadingPdf
                                                  ? Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                      color: Colors.amber,
                                                    ))
                                                  : SfPdfViewer.network(
                                                      pdfUrl,
                                                      key: _pdfViewerKey,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 25),
                                      width: double.infinity,
                                      height: Responsive.isMobileSmall(
                                                  context) ||
                                              Responsive.isMobileMedium(context)
                                          ? size.width * 0.1
                                          : Responsive.isMobileLarge(context)
                                              ? size.width * 0.11
                                              : Responsive.isTabletPortrait(
                                                      context)
                                                  ? size.width * 0.08
                                                  : size.width * 0.04,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          IconButton(
                                              icon: Icon(Icons.arrow_back_ios),
                                              iconSize: Responsive
                                                          .isMobileSmall(
                                                              context) ||
                                                      Responsive.isMobileMedium(
                                                          context) ||
                                                      Responsive.isMobileLarge(
                                                          context)
                                                  ? 16
                                                  : Responsive.isTabletPortrait(
                                                          context)
                                                      ? 20
                                                      : 20,
                                              color: fileIndex == 0
                                                  ? borderColor
                                                  : Colors.white,
                                              onPressed: () async {
                                                if (fileIndex != 0) {
                                                  if (mounted) {
                                                    setState(() {
                                                      fileIndex -= 1;
                                                    });
                                                  }
                                                  if (mounted)
                                                    setState(() {
                                                      viewDocumentSign(
                                                          widget.fileNames[
                                                                  fileIndex]
                                                              ['doc_id'],
                                                          fileIndex);
                                                      documentId = widget
                                                              .fileNames[
                                                          fileIndex]['doc_id'];
                                                    });
                                                }
                                              }),
                                          Text(
                                            documentId.toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: Responsive
                                                            .isMobileSmall(
                                                                context) ||
                                                        Responsive
                                                            .isMobileMedium(
                                                                context)
                                                    ? 14
                                                    : Responsive.isMobileLarge(
                                                            context)
                                                        ? 16
                                                        : Responsive
                                                                .isTabletPortrait(
                                                                    context)
                                                            ? 18
                                                            : 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.arrow_forward_ios),
                                            iconSize: Responsive.isMobileSmall(
                                                        context) ||
                                                    Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 16
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 20
                                                    : 20,
                                            color: widget.fileNames.last !=
                                                    widget.fileNames[fileIndex]
                                                ? Colors.white
                                                : borderColor,
                                            onPressed: () async {
                                              if (widget.fileNames.last !=
                                                  widget.fileNames[fileIndex]) {
                                                if (mounted) {
                                                  setState(() {
                                                    fileIndex += 1;
                                                  });
                                                }
                                                if (mounted)
                                                  setState(() {
                                                    viewDocumentSign(
                                                        widget.fileNames[
                                                                fileIndex]
                                                            ['doc_id'],
                                                        fileIndex);
                                                    documentId = widget
                                                            .fileNames[
                                                        fileIndex]['doc_id'];
                                                  });
                                                print(documentId);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // --------- DOCUMENT DETAILS SECTION ------------- //
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
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
                                              Responsive.isMobileMedium(
                                                  context) ||
                                              Responsive.isMobileLarge(context)
                                          ? 25
                                          : 28,
                                    ),
                                    SizedBox(
                                        width:
                                            Responsive.isMobileSmall(context) ||
                                                    Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 5
                                                : 15),
                                    Text(
                                      "Document Details",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: Responsive.isMobileSmall(
                                                context)
                                            ? 16
                                            : Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 18
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 24
                                                    : 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                color: Color.fromARGB(255, 233, 104, 44),
                              ),
                            ),
                            Column(children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 1),
                                child: Container(
                                  height: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 48
                                      : Responsive.isTabletPortrait(context)
                                          ? 60
                                          : 65,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: borderColor, width: 1.0),
                                  ),
                                  width: double.infinity,
                                  child: displayIconsBar(),
                                ),
                              ),
                              Container(
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 8, right: 8, top: 5),
                                      child: Container(
                                        height: 50,
                                        padding: EdgeInsets.only(top: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: borderColor, width: 1.0),
                                        ),
                                        width: double.infinity,
                                        child: SingleChildScrollView(
                                          scrollDirection: scrollDirection,
                                          child: Column(
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 3,
                                                      horizontal: 10),
                                                  child: Text(
                                                    "Assigned by : " +
                                                        assignedBy,
                                                    style: TextStyle(
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
                                                              ? 24
                                                              : 22,
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 1),
                                child: Container(
                                  height: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 70
                                      : Responsive.isTabletPortrait(context)
                                          ? 60
                                          : 65,
                                  width: double.infinity,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: borderColor, width: 1.0),
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: List.generate(signatures.length,
                                          (index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              fixedSize: Size(110, 40),
                                              backgroundColor: Color.fromARGB(
                                                  255, 245, 114, 54),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                              ),
                                            ),
                                            onPressed: () {
                                              print(
                                                  "sign_id: ${signatures[index]['id']}");
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => SigningPad(
                                                    docId: documentId,
                                                    approvalId: approvalID,
                                                    signIds: signatures[index]
                                                        ['id'],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              "Add Sign ${index + 1}",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  downloadFileToStorage() async {
    var downldDir = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);

    var documentDir = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOCUMENTS);

    var musicDir = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_MUSIC);

    if (mimeType == 'image/jpg' ||
        mimeType == 'image/jpeg' ||
        mimeType == 'image/png' ||
        mimeType == 'image/gif') {
      ImageGallerySaver.saveImage(bytesImage!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image downloaded successfully..'),
        ),
      );
    } else if (mimeType == 'application/pdf') {
      File file3 = File('$documentDir/$documentId.pdf');
      List<int> pdfBytes = base64.decode(metadata);
      await file3.writeAsBytes(pdfBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF file downloaded successfully..'),
        ),
      );
    } else if (mimeType == 'text/plain') {
      File file3 = File('$downldDir/$documentId.txt');
      List<int> txtBytes = base64.decode(metadata);
      await file3.writeAsBytes(txtBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Text file downloaded successfully..'),
        ),
      );
    } else if (mimeType == 'text/csv') {
      File file3 = File('$downldDir/$documentId.csv');
      List<int> csvBytes = base64.decode(metadata);
      await file3.writeAsBytes(csvBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV file downloaded successfully..'),
        ),
      );
    } else if (mimeType == 'audio/mpeg') {
      File file3 = File('$musicDir/$documentId.mp3');
      List<int> mp3Bytes = base64.decode(metadata);
      await file3.writeAsBytes(mp3Bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mp3 file downloaded successfully..'),
        ),
      );
    }
  }

  Widget displayIconsBar() {
    return SingleChildScrollView(
      scrollDirection: scrollDirection,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Color.fromARGB(179, 1, 1, 36),
            ),
            width: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 35
                : Responsive.isTabletPortrait(context)
                    ? 45
                    : 45,
            height: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 30
                : Responsive.isTabletPortrait(context)
                    ? 40
                    : 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              icon: Icon(
                Icons.shopping_cart_rounded,
                color: Colors.white,
                size: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 18
                    : Responsive.isTabletPortrait(context)
                        ? 25
                        : 25,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Color.fromARGB(179, 1, 1, 36),
            ),
            width: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 35
                : Responsive.isTabletPortrait(context)
                    ? 45
                    : 45,
            height: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 30
                : Responsive.isTabletPortrait(context)
                    ? 40
                    : 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              icon: Icon(
                Icons.note_alt_outlined,
                color: Colors.white,
                size: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 20
                    : Responsive.isTabletPortrait(context)
                        ? 27
                        : 27,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Color.fromARGB(179, 1, 1, 36),
            ),
            width: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 35
                : Responsive.isTabletPortrait(context)
                    ? 45
                    : 45,
            height: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 30
                : Responsive.isTabletPortrait(context)
                    ? 40
                    : 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                downloadFileToStorage();
              },
              icon: Icon(
                Icons.file_download,
                color: Colors.white,
                size: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 20
                    : Responsive.isTabletPortrait(context)
                        ? 27
                        : 27,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Color.fromARGB(179, 1, 1, 36),
            ),
            width: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 35
                : Responsive.isTabletPortrait(context)
                    ? 45
                    : 45,
            height: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 30
                : Responsive.isTabletPortrait(context)
                    ? 40
                    : 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              icon: Icon(
                Icons.print_outlined,
                color: Colors.white,
                size: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 20
                    : Responsive.isTabletPortrait(context)
                        ? 27
                        : 27,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Color.fromARGB(179, 1, 1, 36),
            ),
            width: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 35
                : Responsive.isTabletPortrait(context)
                    ? 45
                    : 45,
            height: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 30
                : Responsive.isTabletPortrait(context)
                    ? 40
                    : 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              icon: Icon(
                Icons.delete_rounded,
                color: Colors.white,
                size: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 20
                    : Responsive.isTabletPortrait(context)
                        ? 27
                        : 27,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Color.fromARGB(179, 1, 1, 36),
            ),
            width: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 35
                : Responsive.isTabletPortrait(context)
                    ? 45
                    : 45,
            height: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 30
                : Responsive.isTabletPortrait(context)
                    ? 40
                    : 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              icon: Icon(
                Icons.file_open_outlined,
                color: Colors.white,
                size: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 20
                    : Responsive.isTabletPortrait(context)
                        ? 27
                        : 27,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Color.fromARGB(179, 1, 1, 36),
            ),
            width: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 35
                : Responsive.isTabletPortrait(context)
                    ? 45
                    : 45,
            height: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 30
                : Responsive.isTabletPortrait(context)
                    ? 40
                    : 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              icon: Icon(
                Icons.feed_outlined,
                color: Colors.white,
                size: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 23
                    : Responsive.isTabletPortrait(context)
                        ? 29
                        : 29,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Color.fromARGB(179, 1, 1, 36),
            ),
            width: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 35
                : Responsive.isTabletPortrait(context)
                    ? 45
                    : 45,
            height: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 30
                : Responsive.isTabletPortrait(context)
                    ? 40
                    : 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (!isBookMarked) {
                  addBookMarkDocument();
                  isBookMarked = true;
                }
              },
              icon: isBookMarked
                  ? Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: Responsive.isMobileSmall(context) ||
                              Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context)
                          ? 22
                          : Responsive.isTabletPortrait(context)
                              ? 28
                              : 28,
                    )
                  : Icon(
                      Icons.star_border,
                      color: Colors.white,
                      size: Responsive.isMobileSmall(context) ||
                              Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context)
                          ? 22
                          : Responsive.isTabletPortrait(context)
                              ? 28
                              : 28,
                    ),
            ),
          ),
        ],
      ),
    );
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
                                        ? 24
                                        : 25,
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
                                          ? size.width * 0.020
                                          : size.width * 0.015,
                                ),
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
