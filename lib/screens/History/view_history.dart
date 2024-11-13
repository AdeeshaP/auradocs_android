import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:auradocs_android/API-Services/api_service.dart';
import 'package:auradocs_android/Bloc/document_bloc.dart';
import 'package:auradocs_android/Models/users.dart';
import 'package:auradocs_android/screens/Document-Search/search_list.dart';
import 'package:auradocs_android/screens/Sliders/landing_page.dart';
import 'package:auradocs_android/screens/contact_us_screen.dart';
import 'package:auradocs_android/screens/full-screen-viewer/full_screen_viewer.dart';
import 'package:auradocs_android/screens/home_screen.dart';
import 'package:auradocs_android/utils/alert_dialogs.dart';
import 'package:auradocs_android/utils/constants.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:chewie/chewie.dart';
import 'package:csv/csv.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:video_player/video_player.dart';

class AccountIndexDownloadHistoryFileViewer extends StatefulWidget {
  const AccountIndexDownloadHistoryFileViewer({
    super.key,
    required this.initialIndex,
    required this.docIds,
  });

  final List<String> docIds;
  final int initialIndex;

  @override
  State<AccountIndexDownloadHistoryFileViewer> createState() =>
      _AccountIndexDownloadHistoryFileViewerState();
}

class _AccountIndexDownloadHistoryFileViewerState
    extends State<AccountIndexDownloadHistoryFileViewer> {
  double _scale = 1.0;
  String textFileContent = "";
  late SharedPreferences _storage;
  Map<String, dynamic>? userObj;
  String username = "";
  String token = "";
  String compnyCode = "";
  List authentication = [];
  final AudioPlayer audioplayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Map<String, dynamic>? responsedata;
  Uint8List? imageValueBytes;
  List<dynamic> indexValues = [];
  String metadata = "";
  String mimeType = "";
  String templaetName = "";
  String operation = "";
  Uint8List? bytesImage;
  List<int> bytes = [];
  int documentId = 0;
  File? _pdffile;
  File? _mp3File;
  List<dynamic> valList = [];
  int indx = 0;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool isBookMarked = false;
  List<dynamic> valueList = [];
  List<dynamic> completedTasks = [];
  List<dynamic> pendingTaskById = [];
  String requestUser1 = "";
  String approvedUser1 = "";
  String approvedDate1 = "";
  String remark1 = "";
  String comment1 = "";
  String requestUser2 = "";
  String approvedUser2 = "";
  String approvedDate2 = "";
  String remark2 = "";
  String comment2 = "";
  int templateId = 0;
  int taskId = 0;
  String? pendingTaskStatus;
  String completedTaskstatus = "";
  String pendingstatus = "";
  TextEditingController commentController = new TextEditingController();
  TextEditingController searchController = TextEditingController();
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  File? _mp4File;
  String trimmedValue = "";
  GlobalKey _toolTipKey = GlobalKey();
  late List<String> docIds;

  @override
  void initState() {
    super.initState();
    docIds = widget.docIds;
    indx = widget.initialIndex;
    print("doc Id s ${docIds}");
    print("tapped index is ${widget.initialIndex}");

    viewIndexedDocument(docIds[indx], indx);
  }

  @override
  void dispose() {
    audioplayer.dispose();
    super.dispose();
  }

// -------- GET API - get selected document to view -------------//
  Future<void> viewIndexedDocument(String docId, int index) async {
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
        documentId = int.parse(docId);
      });
    }
    var response =
        await ApiService.openViewerSearch(documentId, username, token);

    print(response.statusCode);

    if (response.statusCode == 200) {
      responsedata = jsonDecode(response.body);

      print(responsedata);
      if (mounted) {
        setState(() {
          valList = responsedata!['value'];
          mimeType = valList[0]['ImageValue']['mimetype'];
          metadata = valList[0]['ImageValue']['metadata'];
          imageValueBytes = base64.decode(metadata);
          bytesImage = base64.decode(metadata.split('\n').join());
          indexValues = valList[0]['IndexValues'];
          templaetName = valList[0]['templateName'];
          operation = "VIEW";
        });
      }
    } else if (response.statusCode == 403) {
      showWarningDialogPopupThree(
        context,
        Icons.warning_amber_sharp,
        "You don't have enough privileges to view this document.",
        backToNextDocument,
        Color.fromARGB(255, 237, 172, 10),
        docIds.length > indx + 1 ? "NEXT" : "OK",
      );
    } else if (response.statusCode == 500) {
      showWarningDialogPopupThree(
        context,
        Icons.warning,
        "Server error! Please contact auraDOCS administrator.",
        backToNextDocument,
        Color.fromARGB(255, 237, 172, 10),
        docIds.length > index + 1 ? "NEXT" : "OK",
      );
    }
    setState(() {
      addAccessTrackOperation();
      getBookMarkDocument();
      getCompletedTasks();
      getSelectedPendingTaskByDocId();
    });

    if (mimeType == 'video/mp4') {
      Directory tempDirec = await getTemporaryDirectory();
      _mp4File = File('${tempDirec.path}/temp1.mp4');
      await _mp4File!.writeAsBytes(imageValueBytes!);
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
  }

  // -------- POST API - send operation to web -------------//

  Future<void> addAccessTrackOperation() async {
    var response1 = await ApiService.passAccessTrackAction(
      documentId.toString(),
      username,
      operation,
      templaetName,
      token,
    );

    if (response1.statusCode == 200) {
      print("$operation passed to server");
    } else if (response1.statusCode == 500 || response1.statusCode == 501) {
      showWarningDialogPopup(
        context,
        Icons.warning,
        "Internal server error! Please contact auraDOCS administrator.",
        okRecognition,
        Color.fromARGB(255, 237, 172, 10),
      );
    }
  }

  //---------- GET API - Bookmark the veiwed document -------------
  Future<void> addBookMarkDocument() async {
    _storage = await SharedPreferences.getInstance();
    userObj = jsonDecode(_storage.getString('user_data')!);
    token = _storage.getString('token')!;
    if (!mounted) return;
    setState(() {
      username = userObj!["value"]["userName"];
    });

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
    var response6 = await ApiService.getBookmark(documentId, username, token);

    if (response6.statusCode == 200) {
      setState(() {
        isBookMarked = true;
      });
    } else if (response6.statusCode == 404) {
      setState(() {
        isBookMarked = false;
      });
    }
  }

  // --------GET API -  get Completed Tasks -------------//

  Future<void> getCompletedTasks() async {
    var response2 = await ApiService.getCompletedTaskByDocId(documentId, token);
    if (response2 != null && response2.statusCode == 200) {
      responsedata = jsonDecode(response2.body);

      if (!mounted) return;
      setState(() {
        completedTasks = responsedata!['value'];
      });
    } else if (response2.statusCode == 500) {
      showWarningDialogPopup(
        context,
        Icons.warning,
        "Server error! Please contact auraDOCS administrator.",
        okRecognition,
        Color.fromARGB(255, 237, 172, 10),
      );
    }
  }

  // --------GET API -  Selected Pending Task By DocId -------------//

  Future<void> getSelectedPendingTaskByDocId() async {
    var response3 = await ApiService.getSelectedPendingTaskByDocId(
        username, documentId, token);
    if (response3 != null && response3.statusCode == 200) {
      responsedata = jsonDecode(response3.body);

      if (mounted)
        setState(() {
          pendingTaskById = responsedata!['value'];
        });
    } else if (response3.statusCode == 500) {
      showWarningDialogPopup(
        context,
        Icons.warning,
        "Server error! Please contact auraDOCS administrator.",
        okRecognition,
        Color.fromARGB(255, 237, 172, 10),
      );
    }
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

  void okRecognition() {
    closeDialog(context);
  }

  void backToNextDocument() {
    closeDialog(context);
    if (docIds.length > indx + 1) {
      setState(() {
        indx += 1;
      });
      viewIndexedDocument(docIds[indx], indx);
    } else {
      okRecognitionAndGoBackScreen();
    }
  }

  void okRecognitionAndGoBackScreen() {
    // closeDialog(context);
    Navigator.pop(context);
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
          resizeToAvoidBottomInset: false,
          body: Container(
            width: size.width,
            child: Column(children: <Widget>[
              getSearchBoxWidget(),
              Divider(height: 8),
              Stack(
                children: [
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
                                  Icon(
                                    Icons.check_sharp,
                                    color: Colors.white,
                                    size: Responsive.isMobileSmall(context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
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
                                        : 15,
                                  ),
                                  Text(
                                    "View",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          Responsive.isMobileSmall(context)
                                              ? 16
                                              : Responsive.isMobileMedium(
                                                          context) ||
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
                                horizontal: 8, vertical: 2.0),
                            child: Container(
                              color: Color.fromARGB(218, 1, 5, 25),
                              height: Responsive.isMobileSmall(context)
                                  ? size.height * 0.6
                                  : Responsive.isMobileMedium(context)
                                      ? size.height * 0.61
                                      : Responsive.isMobileLarge(context)
                                          ? size.height * 0.67
                                          : Responsive.isTabletPortrait(context)
                                              ? size.height * 0.65
                                              : size.height * 0.55,
                              child: Column(
                                children: [
                                  Container(
                                    height: Responsive.isMobileSmall(context) ||
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
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 25
                                                      : Responsive
                                                              .isTabletPortrait(
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
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 25
                                                      : Responsive
                                                              .isTabletPortrait(
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
                                                    base64String: metadata,
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
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 27
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? 30
                                                          : 29,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
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
                                            : Responsive.isMobileMedium(context)
                                                ? size.height * 0.5
                                                : Responsive.isMobileLarge(
                                                        context)
                                                    ? size.height * 0.56
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? size.height * 0.55
                                                        : size.height * 0.5,
                                        width: size.width * 0.9,
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
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 25),
                                    width: double.infinity,
                                    height: Responsive.isMobileSmall(context)
                                        ? size.width * 0.08
                                        : Responsive.isMobileMedium(context) ||
                                                Responsive.isMobileLarge(
                                                    context)
                                            ? size.width * 0.09
                                            : Responsive.isTabletPortrait(
                                                    context)
                                                ? size.width * 0.06
                                                : size.width * 0.06,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        IconButton(
                                            icon: Icon(Icons.arrow_back_ios),
                                            iconSize: Responsive.isMobileSmall(
                                                        context) ||
                                                    Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 16
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 22
                                                    : 22,
                                            color: indx == 0
                                                ? Colors.grey
                                                : Colors.white,
                                            onPressed: () async {
                                              if (indx != 0) {
                                                if (mounted)
                                                  setState(() {
                                                    indx -= 1;
                                                  });
                                                if (mounted)
                                                  setState(() {
                                                    viewIndexedDocument(
                                                        docIds[indx], indx);
                                                    documentId =
                                                        int.parse(docIds[indx]);
                                                  });
                                              }
                                            }),
                                        Text(
                                          docIds[indx],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: Responsive
                                                          .isMobileSmall(
                                                              context) ||
                                                      Responsive.isMobileMedium(
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
                                          textScaler: TextScaler.linear(1),
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
                                                  ? 22
                                                  : 22,
                                          color: docIds.last != docIds[indx]
                                              ? Colors.white
                                              : Colors.grey,
                                          onPressed: () async {
                                            if (docIds.last != docIds[indx]) {
                                              if (mounted)
                                                setState(() {
                                                  indx += 1;
                                                });
                                              if (mounted)
                                                setState(() {
                                                  viewIndexedDocument(
                                                      docIds[indx], indx);
                                                  documentId =
                                                      int.parse(docIds[indx]);
                                                });
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
                                  Icon(Icons.assignment,
                                      color: Colors.white,
                                      size: Responsive.isMobileSmall(context) ||
                                              Responsive.isMobileMedium(
                                                  context) ||
                                              Responsive.isMobileLarge(context)
                                          ? 25
                                          : 28),
                                  SizedBox(
                                    width: Responsive.isMobileSmall(context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 5
                                        : 15,
                                  ),
                                  Text(
                                    "Document Details",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          Responsive.isMobileSmall(context)
                                              ? 16
                                              : Responsive.isMobileMedium(
                                                          context) ||
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
                            padding: const EdgeInsets.all(0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 1),
                                  child: Container(
                                    height: Responsive.isMobileSmall(context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 48
                                        : Responsive.isTabletPortrait(context)
                                            ? 60
                                            : 65,
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    width: double.infinity,
                                    child: displayIconsBar(),
                                  ),
                                ),
                                Container(
                                  height: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.66
                                      : Responsive.isTabletPortrait(context)
                                          ? size.height * 0.7
                                          : size.height * 0.6,
                                  child: Scrollbar(
                                    thickness: 6,
                                    child: SingleChildScrollView(
                                      scrollDirection: scrollDirection,
                                      child: Column(
                                        children: <Widget>[
                                          indexValues.isNotEmpty
                                              ? Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 1),
                                                  child: Container(
                                                    height: indexValues.length >
                                                            2
                                                        ? Responsive
                                                                    .isMobileSmall(
                                                                        context) ||
                                                                Responsive
                                                                    .isMobileMedium(
                                                                        context) ||
                                                                Responsive
                                                                    .isMobileLarge(
                                                                        context)
                                                            ? 55.0 *
                                                                indexValues
                                                                    .length
                                                            : Responsive
                                                                    .isTabletPortrait(
                                                                        context)
                                                                ? 80.0 *
                                                                    indexValues
                                                                        .length
                                                                : 55.0 *
                                                                    indexValues
                                                                        .length
                                                        : Responsive
                                                                    .isMobileSmall(
                                                                        context) ||
                                                                Responsive
                                                                    .isMobileMedium(
                                                                        context) ||
                                                                Responsive
                                                                    .isMobileLarge(
                                                                        context)
                                                            ? 55.0 *
                                                                indexValues
                                                                    .length
                                                            : Responsive
                                                                    .isTabletPortrait(
                                                                        context)
                                                                ? 80.0 *
                                                                    indexValues
                                                                        .length
                                                                : 60.0 *
                                                                    indexValues
                                                                        .length,
                                                    padding:
                                                        EdgeInsets.only(top: 8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1.0),
                                                    ),
                                                    width: double.infinity,
                                                    child:
                                                        SingleChildScrollView(
                                                      scrollDirection:
                                                          scrollDirection,
                                                      child: Column(
                                                        children: <Widget>[
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          3,
                                                                      horizontal:
                                                                          10),
                                                              child: Text(
                                                                templaetName,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: Responsive.isMobileSmall(context) ||
                                                                          Responsive.isMobileMedium(
                                                                              context) ||
                                                                          Responsive.isMobileLarge(
                                                                              context)
                                                                      ? 18
                                                                      : Responsive.isTabletPortrait(
                                                                              context)
                                                                          ? 24
                                                                          : 22,
                                                                  color: Colors
                                                                      .black54,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                                textScaler:
                                                                    TextScaler
                                                                        .linear(
                                                                            1),
                                                              ),
                                                            ),
                                                          ),
                                                          Divider(
                                                              color:
                                                                  borderColor,
                                                              thickness: 1),
                                                          ListView.builder(
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            shrinkWrap: true,
                                                            itemCount:
                                                                indexValues
                                                                    .length,
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    int index) {
                                                              var key =
                                                                  indexValues[
                                                                          index]
                                                                      .keys
                                                                      .first
                                                                      .toString();
                                                              var value =
                                                                  indexValues[
                                                                          index]
                                                                      .values
                                                                      .first
                                                                      .toString();

                                                              return Column(
                                                                children: <Widget>[
                                                                  Padding(
                                                                    padding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            6,
                                                                        horizontal:
                                                                            8),
                                                                    child: Row(
                                                                      children: [
                                                                        Expanded(
                                                                          flex:
                                                                              4,
                                                                          child:
                                                                              Text(
                                                                            key,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Color.fromARGB(221, 17, 17, 17),
                                                                              fontWeight: FontWeight.w500,
                                                                              fontSize: Responsive.isMobileSmall(context) || Responsive.isMobileMedium(context) || Responsive.isMobileLarge(context)
                                                                                  ? 14
                                                                                  : Responsive.isTabletPortrait(context)
                                                                                      ? 17
                                                                                      : 17,
                                                                            ),
                                                                            textScaler:
                                                                                TextScaler.linear(1),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              5,
                                                                          child:
                                                                              Text(
                                                                            value,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.black54,
                                                                              fontSize: Responsive.isMobileSmall(context) || Responsive.isMobileMedium(context) || Responsive.isMobileLarge(context)
                                                                                  ? 14
                                                                                  : Responsive.isTabletPortrait(context)
                                                                                      ? 17
                                                                                      : 17,
                                                                              fontWeight: FontWeight.w400,
                                                                            ),
                                                                            textScaler:
                                                                                TextScaler.linear(1),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Divider(
                                                                      height: Responsive.isMobileSmall(context) ||
                                                                              Responsive.isMobileMedium(context) ||
                                                                              Responsive.isMobileLarge(context)
                                                                          ? 2
                                                                          : 6),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(
                                                  height: size.height * 0.02),

                                          // -------------------------COMPLETED TASKS -------------------------//
                                          // completedTasks.isNotEmpty
                                          //     ? Padding(
                                          //         padding: EdgeInsets.only(
                                          //             left: 8, right: 8, top: 4),
                                          //         child: Container(
                                          //           height: size.height * 0.08,
                                          //           padding:
                                          //               EdgeInsets.only(top: 5),
                                          //           decoration: BoxDecoration(
                                          //             color: Colors.white,
                                          //             border: Border.all(
                                          //                 color: borderColor,
                                          //                 width: 1.0),
                                          //           ),
                                          //           width: double.infinity,
                                          //           child: SingleChildScrollView(
                                          //             scrollDirection:
                                          //                 scrollDirection,
                                          //             child: ListView.builder(
                                          //               physics:
                                          //                   NeverScrollableScrollPhysics(),
                                          //               shrinkWrap: true,
                                          //               itemCount:
                                          //                   completedTasks.length,
                                          //               itemBuilder:
                                          //                   (BuildContext context,
                                          //                       int index) {
                                          //                 final item =
                                          //                     completedTasks[
                                          //                         index];
                                          //                 approvedUser1 = item[
                                          //                     'approvedUser'];
                                          //                 remark1 =
                                          //                     item['remark'];
                                          //                 completedTaskstatus =
                                          //                     item['status'];
                                          //                 comment1 =
                                          //                     item['comment'];

                                          //                 return Column(
                                          //                   crossAxisAlignment:
                                          //                       CrossAxisAlignment
                                          //                           .start,
                                          //                   children: [
                                          //                     Row(
                                          //                       children: [
                                          //                         Expanded(
                                          //                           flex: 7,
                                          //                           child:
                                          //                               Padding(
                                          //                             padding: EdgeInsets.symmetric(
                                          //                                 horizontal:
                                          //                                     8,
                                          //                                 vertical:
                                          //                                     3),
                                          //                             child: Text(
                                          //                               "Approved By : $approvedUser1",
                                          //                               style:
                                          //                                   TextStyle(
                                          //                                 fontSize:
                                          //                                     14,
                                          //                                 color: Colors
                                          //                                     .black87,
                                          //                               ),
                                          //                             ),
                                          //                           ),
                                          //                         ),
                                          //                         Expanded(
                                          //                           flex: 4,
                                          //                           child:
                                          //                               Padding(
                                          //                             padding: EdgeInsets.symmetric(
                                          //                                 horizontal:
                                          //                                     8,
                                          //                                 vertical:
                                          //                                     3),
                                          //                             child: Row(
                                          //                               mainAxisAlignment:
                                          //                                   MainAxisAlignment
                                          //                                       .start,
                                          //                               children: [
                                          //                                 Container(
                                          //                                   height:
                                          //                                       8,
                                          //                                   width:
                                          //                                       8,
                                          //                                   decoration:
                                          //                                       BoxDecoration(
                                          //                                     color: completedTaskstatus == "accepted"
                                          //                                         ? Colors.green
                                          //                                         : completedTaskstatus == "pending"
                                          //                                             ? Colors.orange
                                          //                                             : Colors.red,
                                          //                                     shape:
                                          //                                         BoxShape.circle,
                                          //                                     border:
                                          //                                         Border.all(
                                          //                                       color: completedTaskstatus == "accepted"
                                          //                                           ? Colors.green
                                          //                                           : completedTaskstatus == "pending"
                                          //                                               ? Colors.orange
                                          //                                               : Colors.red,
                                          //                                     ),
                                          //                                   ),
                                          //                                 ),
                                          //                                 SizedBox(
                                          //                                     width:
                                          //                                         5),
                                          //                                 Text(
                                          //                                   completedTaskstatus,
                                          //                                   style:
                                          //                                       GoogleFonts.lato(
                                          //                                     textStyle:
                                          //                                         Theme.of(context).textTheme.headlineMedium,
                                          //                                     fontSize:
                                          //                                         14,
                                          //                                     fontWeight:
                                          //                                         FontWeight.w900,
                                          //                                     color: completedTaskstatus == "accepted"
                                          //                                         ? Colors.green
                                          //                                         : completedTaskstatus == "pending"
                                          //                                             ? Colors.orange[300]
                                          //                                             : Colors.red,
                                          //                                   ),
                                          //                                 ),
                                          //                               ],
                                          //                             ),
                                          //                           ),
                                          //                         ),
                                          //                       ],
                                          //                     ),
                                          //                     Padding(
                                          //                       padding: EdgeInsets
                                          //                           .symmetric(
                                          //                               horizontal:
                                          //                                   8,
                                          //                               vertical:
                                          //                                   3),
                                          //                       child: Text(
                                          //                         "Comment : $comment1",
                                          //                         style:
                                          //                             TextStyle(
                                          //                           fontSize: 14,
                                          //                           color: Colors
                                          //                               .black87,
                                          //                         ),
                                          //                       ),
                                          //                     ),
                                          //                     Divider(height: 4),
                                          //                   ],
                                          //                 );
                                          //               },
                                          //             ),
                                          //           ),
                                          //         ),
                                          //       )
                                          //     : Container(),

                                          // -------------------------PENDING TASKS TEXT FIELDS-------------------------//
                                          // pendingTaskById.isNotEmpty
                                          //     ? Padding(
                                          //         padding: EdgeInsets.symmetric(
                                          //             horizontal: 7, vertical: 5),
                                          //         child: Container(
                                          //           width: double.infinity,
                                          //           child: ListView.builder(
                                          //             scrollDirection:
                                          //                 scrollDirection,
                                          //             shrinkWrap: true,
                                          //             itemCount: 1,
                                          //             // itemCount: pendingTaskById.length,
                                          //             itemBuilder:
                                          //                 (BuildContext context,
                                          //                     int index) {
                                          //               List<String>
                                          //                   pendingTaskStatuses =
                                          //                   [
                                          //                 'pending',
                                          //                 'accepted',
                                          //                 'rejected'
                                          //               ];
                                          //               final item2 =
                                          //                   pendingTaskById[
                                          //                       index];

                                          //               pendingstatus =
                                          //                   item2['status'];
                                          //               taskId = item2['id'];

                                          //               if (pendingstatus ==
                                          //                   "pending") {
                                          //                 return Form(
                                          //                   key: _formKey2,
                                          //                   child: Column(
                                          //                     children: [
                                          //                       Padding(
                                          //                         padding: EdgeInsets
                                          //                             .symmetric(
                                          //                                 vertical:
                                          //                                     4),
                                          //                         child:
                                          //                             DecoratedBox(
                                          //                           decoration:
                                          //                               BoxDecoration(
                                          //                             borderRadius:
                                          //                                 BorderRadius
                                          //                                     .circular(2),
                                          //                             border: Border.all(
                                          //                                 color: Colors
                                          //                                     .grey),
                                          //                           ),
                                          //                           child:
                                          //                               Padding(
                                          //                             padding: EdgeInsets.symmetric(
                                          //                                 horizontal:
                                          //                                     8.0),
                                          //                             child: DropdownButtonFormField<
                                          //                                 String>(
                                          //                               autovalidateMode:
                                          //                                   AutovalidateMode
                                          //                                       .always,
                                          //                               decoration:
                                          //                                   InputDecoration(
                                          //                                 enabledBorder:
                                          //                                     UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                                          //                               ),
                                          //                               icon: Icon(
                                          //                                   Icons
                                          //                                       .arrow_drop_down),
                                          //                               elevation:
                                          //                                   2,
                                          //                               validator: (value) => _validate &&
                                          //                                       value == null
                                          //                                   ? 'Status is required'
                                          //                                   : null,
                                          //                               isExpanded:
                                          //                                   true,
                                          //                               hint:
                                          //                                   Text(
                                          //                                 "Select the status..",
                                          //                                 style:
                                          //                                     TextStyle(
                                          //                                   color:
                                          //                                       Colors.black54,
                                          //                                   fontSize:
                                          //                                       15,
                                          //                                 ),
                                          //                               ),
                                          //                               value:
                                          //                                   pendingTaskStatus,
                                          //                               onChanged:
                                          //                                   (String?
                                          //                                       newValue1) {
                                          //                                 setState(
                                          //                                     () {
                                          //                                   pendingTaskStatus =
                                          //                                       newValue1!;
                                          //                                 });
                                          //                                 print(
                                          //                                     "pendingTaskStatus $pendingTaskStatus");
                                          //                               },
                                          //                               items: pendingTaskStatuses
                                          //                                   .map(
                                          //                                       (value1) {
                                          //                                 return DropdownMenuItem<
                                          //                                     String>(
                                          //                                   value:
                                          //                                       value1,
                                          //                                   child:
                                          //                                       Text(
                                          //                                     value1,
                                          //                                     style:
                                          //                                         TextStyle(color: Colors.black87, fontSize: 16),
                                          //                                   ),
                                          //                                 );
                                          //                               }).toList(),
                                          //                             ),
                                          //                           ),
                                          //                         ),
                                          //                       ),
                                          //                       Padding(
                                          //                         padding: EdgeInsets
                                          //                             .symmetric(
                                          //                                 vertical:
                                          //                                     5),
                                          //                         child:
                                          //                             TextFormField(
                                          //                           maxLines: 3,
                                          //                           autovalidateMode:
                                          //                               AutovalidateMode
                                          //                                   .always,
                                          //                           textInputAction:
                                          //                               TextInputAction
                                          //                                   .next,
                                          //                           controller:
                                          //                               commentController,
                                          //                           onSaved:
                                          //                               (newValue) {
                                          //                             commentController
                                          //                                     .text ==
                                          //                                 newValue;
                                          //                           },
                                          //                           decoration:
                                          //                               InputDecoration(
                                          //                             contentPadding: EdgeInsets.symmetric(
                                          //                                 vertical:
                                          //                                     1,
                                          //                                 horizontal:
                                          //                                     5),
                                          //                             border: OutlineInputBorder(
                                          //                                 borderRadius:
                                          //                                     BorderRadius.circular(2)),
                                          //                             labelText:
                                          //                                 "Comment",
                                          //                           ),
                                          //                           validator:
                                          //                               (valuex) {
                                          //                             if (valuex!
                                          //                                     .isEmpty &&
                                          //                                 _validate) {
                                          //                               return 'Comment is required';
                                          //                             }
                                          //                             return null;
                                          //                           },
                                          //                           keyboardType:
                                          //                               TextInputType
                                          //                                   .text,
                                          //                         ),
                                          //                       ),
                                          //                       SizedBox(
                                          //                           height: 10),
                                          //                       SizedBox(
                                          //                         width: Responsive.isMobileSmall(context) ||
                                          //                                 Responsive.isMobileMedium(
                                          //                                     context) ||
                                          //                                 Responsive.isMobileLarge(
                                          //                                     context) ||
                                          //                                 Responsive.isTabletPortrait(
                                          //                                     context)
                                          //                             ? size.width *
                                          //                                 0.25
                                          //                             : size.width *
                                          //                                 0.2,
                                          //                         height: Responsive.isMobileSmall(context) ||
                                          //                                 Responsive.isMobileMedium(
                                          //                                     context) ||
                                          //                                 Responsive.isMobileLarge(
                                          //                                     context)
                                          //                             ? size.width *
                                          //                                 0.1
                                          //                             : Responsive.isTabletPortrait(
                                          //                                     context)
                                          //                                 ? size.width *
                                          //                                     0.06
                                          //                                 : size.width *
                                          //                                     0.05,
                                          //                         child:
                                          //                             TextButton(
                                          //                           child: Text(
                                          //                             'Submit',
                                          //                             style:
                                          //                                 TextStyle(
                                          //                               fontWeight:
                                          //                                   FontWeight
                                          //                                       .bold,
                                          //                               fontSize: Responsive.isMobileSmall(context) ||
                                          //                                       Responsive.isMobileMedium(context) ||
                                          //                                       Responsive.isMobileLarge(context)
                                          //                                   ? 15
                                          //                                   : Responsive.isTabletPortrait(context)
                                          //                                       ? 18
                                          //                                       : 20,
                                          //                               color: Colors
                                          //                                   .white,
                                          //                             ),
                                          //                           ),
                                          //                           onPressed:
                                          //                               () {
                                          //                             setState(
                                          //                                 () {
                                          //                               _validate =
                                          //                                   true;
                                          //                             });
                                          //                             if (_formKey2
                                          //                                 .currentState!
                                          //                                 .validate()) {
                                          //                               updatePendingTasksStatus(
                                          //                                   taskId,
                                          //                                   pendingTaskStatus!,
                                          //                                   commentController
                                          //                                       .text);
                                          //                             }
                                          //                           },
                                          //                           style:
                                          //                               ButtonStyle(
                                          //                             backgroundColor:
                                          //                                 MaterialStateProperty
                                          //                                     .all(
                                          //                               Color.fromARGB(
                                          //                                   255,
                                          //                                   237,
                                          //                                   172,
                                          //                                   10),
                                          //                             ),
                                          //                           ),
                                          //                         ),
                                          //                       ),
                                          //                       SizedBox(
                                          //                           height: 20),
                                          //                     ],
                                          //                   ),
                                          //                 );
                                          //               }
                                          //               return null;
                                          //             },
                                          //           ),
                                          //         ),
                                          //       )
                                          //     : SizedBox(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // AdvancedSearchBox(_isAdvanceSearchVisible),
                ],
              ),
            ]),
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

    if (mimeType == 'image/jpg') {
      ImageGallerySaver.saveImage(bytesImage!);

      File file8 = File('$downldDir/$documentId.jpg');
      List<int> imgBytes = base64.decode(metadata);
      await file8.writeAsBytes(imgBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image downloaded successfully..'),
        ),
      );
    } else if (mimeType == 'image/jpeg') {
      ImageGallerySaver.saveImage(bytesImage!);

      File file7 = File('$downldDir/$documentId.jpeg');
      List<int> imgBytes = base64.decode(metadata);
      await file7.writeAsBytes(imgBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image downloaded successfully..'),
        ),
      );
    } else if (mimeType == 'image/png') {
      ImageGallerySaver.saveImage(bytesImage!);

      File file6 = File('$downldDir/$documentId.png');
      List<int> imgBytes = base64.decode(metadata);
      await file6.writeAsBytes(imgBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image downloaded successfully..'),
        ),
      );
    } else if (mimeType == 'image/gif') {
      ImageGallerySaver.saveImage(bytesImage!);

      File file6 = File('$downldDir/$documentId.gif');
      List<int> imgBytes = base64.decode(metadata);
      await file6.writeAsBytes(imgBytes);

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
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // Container(
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(5),
          //     color: Color.fromARGB(179, 1, 1, 36),
          //   ),
          //   width: Responsive.isMobileSmall(context) ||
          //           Responsive.isMobileMedium(context) ||
          //           Responsive.isMobileLarge(context)
          //       ? 35
          //       : Responsive.isTabletPortrait(context)
          //           ? 45
          //           : 45,
          //   height: Responsive.isMobileSmall(context) ||
          //           Responsive.isMobileMedium(context) ||
          //           Responsive.isMobileLarge(context)
          //       ? 30
          //       : Responsive.isTabletPortrait(context)
          //           ? 40
          //           : 40,
          //   child: IconButton(
          //     padding: EdgeInsets.zero,
          //     onPressed: () {
          //       // print(widget.fileNames[indx]['ImageId']);
          //     },
          //     icon: Icon(
          //       Icons.shopping_cart_rounded,
          //       color: Colors.white,
          //       size: Responsive.isMobileSmall(context) ||
          //               Responsive.isMobileMedium(context) ||
          //               Responsive.isMobileLarge(context)
          //           ? 18
          //           : Responsive.isTabletPortrait(context)
          //               ? 25
          //               : 25,
          //     ),
          //   ),
          // ),
          // Container(
          //   margin: EdgeInsets.only(left: 5),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(5),
          //     color: Color.fromARGB(179, 1, 1, 36),
          //   ),
          //   width: Responsive.isMobileSmall(context) ||
          //           Responsive.isMobileMedium(context) ||
          //           Responsive.isMobileLarge(context)
          //       ? 35
          //       : Responsive.isTabletPortrait(context)
          //           ? 45
          //           : 45,
          //   height: Responsive.isMobileSmall(context) ||
          //           Responsive.isMobileMedium(context) ||
          //           Responsive.isMobileLarge(context)
          //       ? 30
          //       : Responsive.isTabletPortrait(context)
          //           ? 40
          //           : 40,
          //   child: IconButton(
          //     padding: EdgeInsets.zero,
          //     onPressed: () {},
          //     icon: Icon(
          //       Icons.note_alt_outlined,
          //       color: Colors.white,
          //       size: Responsive.isMobileSmall(context) ||
          //               Responsive.isMobileMedium(context) ||
          //               Responsive.isMobileLarge(context)
          //           ? 20
          //           : Responsive.isTabletPortrait(context)
          //               ? 27
          //               : 27,
          //     ),
          //   ),
          // ),
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
          // Container(
          //   margin: EdgeInsets.only(left: 5),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(5),
          //     color: Color.fromARGB(179, 1, 1, 36),
          //   ),
          //   width: Responsive.isMobileSmall(context) ||
          //           Responsive.isMobileMedium(context) ||
          //           Responsive.isMobileLarge(context)
          //       ? 35
          //       : Responsive.isTabletPortrait(context)
          //           ? 45
          //           : 45,
          //   height: Responsive.isMobileSmall(context) ||
          //           Responsive.isMobileMedium(context) ||
          //           Responsive.isMobileLarge(context)
          //       ? 30
          //       : Responsive.isTabletPortrait(context)
          //           ? 40
          //           : 40,
          //   child: IconButton(
          //     padding: EdgeInsets.zero,
          //     onPressed: () {},
          //     icon: Icon(
          //       Icons.print_outlined,
          //       color: Colors.white,
          //       size: Responsive.isMobileSmall(context) ||
          //               Responsive.isMobileMedium(context) ||
          //               Responsive.isMobileLarge(context)
          //           ? 20
          //           : Responsive.isTabletPortrait(context)
          //               ? 27
          //               : 27,
          //     ),
          //   ),
          // ),
          // Container(
          //   margin: EdgeInsets.only(left: 5),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(5),
          //     color: Color.fromARGB(179, 1, 1, 36),
          //   ),
          //   width: Responsive.isMobileSmall(context) ||
          //           Responsive.isMobileMedium(context) ||
          //           Responsive.isMobileLarge(context)
          //       ? 35
          //       : Responsive.isTabletPortrait(context)
          //           ? 45
          //           : 45,
          //   height: Responsive.isMobileSmall(context) ||
          //           Responsive.isMobileMedium(context) ||
          //           Responsive.isMobileLarge(context)
          //       ? 30
          //       : Responsive.isTabletPortrait(context)
          //           ? 40
          //           : 40,
          //   child: IconButton(
          //     padding: EdgeInsets.zero,
          //     onPressed: () {},
          //     icon: Icon(
          //       Icons.delete_rounded,
          //       color: Colors.white,
          //       size: Responsive.isMobileSmall(context) ||
          //               Responsive.isMobileMedium(context) ||
          //               Responsive.isMobileLarge(context)
          //           ? 20
          //           : Responsive.isTabletPortrait(context)
          //               ? 27
          //               : 27,
          //     ),
          //   ),
          // ),
          // Container(
          //   margin: EdgeInsets.only(left: 5),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(5),
          //     color: Color.fromARGB(179, 1, 1, 36),
          //   ),
          //   width: Responsive.isMobileSmall(context) ||
          //           Responsive.isMobileMedium(context) ||
          //           Responsive.isMobileLarge(context)
          //       ? 35
          //       : Responsive.isTabletPortrait(context)
          //           ? 45
          //           : 45,
          //   height: Responsive.isMobileSmall(context) ||
          //           Responsive.isMobileMedium(context) ||
          //           Responsive.isMobileLarge(context)
          //       ? 30
          //       : Responsive.isTabletPortrait(context)
          //           ? 40
          //           : 40,
          //   child: IconButton(
          //     padding: EdgeInsets.zero,
          //     onPressed: () {},
          //     icon: Icon(
          //       Icons.file_open_outlined,
          //       color: Colors.white,
          //       size: Responsive.isMobileSmall(context) ||
          //               Responsive.isMobileMedium(context) ||
          //               Responsive.isMobileLarge(context)
          //           ? 20
          //           : Responsive.isTabletPortrait(context)
          //               ? 27
          //               : 27,
          //     ),
          //   ),
          // ),
          // Container(
          //   margin: EdgeInsets.only(left: 5),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(5),
          //     color: Color.fromARGB(179, 1, 1, 36),
          //   ),
          //   width: Responsive.isMobileSmall(context) ||
          //           Responsive.isMobileMedium(context) ||
          //           Responsive.isMobileLarge(context)
          //       ? 35
          //       : Responsive.isTabletPortrait(context)
          //           ? 45
          //           : 45,
          //   height: Responsive.isMobileSmall(context) ||
          //           Responsive.isMobileMedium(context) ||
          //           Responsive.isMobileLarge(context)
          //       ? 30
          //       : Responsive.isTabletPortrait(context)
          //           ? 40
          //           : 40,
          //   child: IconButton(
          //     padding: EdgeInsets.zero,
          //     onPressed: () {},
          //     icon: Icon(
          //       Icons.feed_outlined,
          //       color: Colors.white,
          //       size: Responsive.isMobileSmall(context) ||
          //               Responsive.isMobileMedium(context) ||
          //               Responsive.isMobileLarge(context)
          //           ? 23
          //           : Responsive.isTabletPortrait(context)
          //               ? 29
          //               : 29,
          //     ),
          //   ),
          // ),
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

  // Widget displayIconsBar() {
  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: Row(
  //       children: <Widget>[
  //         Container(
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(5),
  //             color: Color.fromARGB(179, 1, 1, 36),
  //           ),
  //           width: Responsive.isMobile(context) ? 36 : 45,
  //           height: Responsive.isMobile(context) ? 32 : 45,
  //           child: IconButton(
  //             padding: EdgeInsets.zero,
  //             onPressed: () {},
  //             icon: Icon(
  //               Icons.shopping_cart_rounded,
  //               color: Colors.white,
  //               size: Responsive.isMobile(context) ? 18 : 35,
  //             ),
  //           ),
  //         ),
  //         Container(
  //           margin:
  //               EdgeInsets.only(left: Responsive.isMobile(context) ? 5 : 12),
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(5),
  //             color: Color.fromARGB(179, 1, 1, 36),
  //           ),
  //           width: Responsive.isMobile(context) ? 36 : 45,
  //           height: Responsive.isMobile(context) ? 32 : 45,
  //           child: IconButton(
  //             padding: EdgeInsets.zero,
  //             onPressed: () {},
  //             icon: Icon(
  //               Icons.note_alt_outlined,
  //               color: Colors.white,
  //               size: Responsive.isMobile(context) ? 20 : 35,
  //             ),
  //           ),
  //         ),
  //         Container(
  //           margin:
  //               EdgeInsets.only(left: Responsive.isMobile(context) ? 5 : 12),
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(5),
  //             color: Color.fromARGB(179, 1, 1, 36),
  //           ),
  //           width: Responsive.isMobile(context) ? 36 : 45,
  //           height: Responsive.isMobile(context) ? 32 : 45,
  //           child: IconButton(
  //             padding: EdgeInsets.zero,
  //             onPressed: () {
  //               downloadFileToStorage();
  //             },
  //             icon: Icon(
  //               Icons.file_download,
  //               color: Colors.white,
  //               size: Responsive.isMobile(context) ? 20 : 35,
  //             ),
  //           ),
  //         ),
  //         Container(
  //           margin:
  //               EdgeInsets.only(left: Responsive.isMobile(context) ? 5 : 12),
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(5),
  //             color: Color.fromARGB(179, 1, 1, 36),
  //           ),
  //           width: Responsive.isMobile(context) ? 36 : 45,
  //           height: Responsive.isMobile(context) ? 32 : 45,
  //           child: IconButton(
  //             padding: EdgeInsets.zero,
  //             onPressed: () {},
  //             icon: Icon(
  //               Icons.print_outlined,
  //               color: Colors.white,
  //               size: Responsive.isMobile(context) ? 20 : 35,
  //             ),
  //           ),
  //         ),
  //         Container(
  //           margin:
  //               EdgeInsets.only(left: Responsive.isMobile(context) ? 5 : 12),
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(5),
  //             color: Color.fromARGB(179, 1, 1, 36),
  //           ),
  //           width: Responsive.isMobile(context) ? 36 : 45,
  //           height: Responsive.isMobile(context) ? 32 : 45,
  //           child: IconButton(
  //             padding: EdgeInsets.zero,
  //             onPressed: () {},
  //             icon: Icon(
  //               Icons.delete_rounded,
  //               color: Colors.white,
  //               size: Responsive.isMobile(context) ? 20 : 35,
  //             ),
  //           ),
  //         ),
  //         Container(
  //           margin:
  //               EdgeInsets.only(left: Responsive.isMobile(context) ? 5 : 12),
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(5),
  //             color: Color.fromARGB(179, 1, 1, 36),
  //           ),
  //           width: Responsive.isMobile(context) ? 36 : 50,
  //           height: Responsive.isMobile(context) ? 32 : 50,
  //           child: IconButton(
  //             padding: EdgeInsets.zero,
  //             onPressed: () {},
  //             icon: Icon(
  //               Icons.file_open_outlined,
  //               color: Colors.white,
  //               size: Responsive.isMobile(context) ? 20 : 35,
  //             ),
  //           ),
  //         ),
  //         Container(
  //           margin:
  //               EdgeInsets.only(left: Responsive.isMobile(context) ? 5 : 12),
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(5),
  //             color: Color.fromARGB(179, 1, 1, 36),
  //           ),
  //           width: Responsive.isMobile(context) ? 36 : 45,
  //           height: Responsive.isMobile(context) ? 32 : 45,
  //           child: IconButton(
  //             padding: EdgeInsets.zero,
  //             onPressed: () {},
  //             icon: Icon(
  //               Icons.feed_outlined,
  //               color: Colors.white,
  //               size: Responsive.isMobile(context) ? 23 : 35,
  //             ),
  //           ),
  //         ),
  //         Container(
  //           margin:
  //               EdgeInsets.only(left: Responsive.isMobile(context) ? 5 : 12),
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(5),
  //             color: Color.fromARGB(179, 1, 1, 36),
  //           ),
  //           width: Responsive.isMobile(context) ? 36 : 45,
  //           height: Responsive.isMobile(context) ? 32 : 45,
  //           child: IconButton(
  //             padding: EdgeInsets.zero,
  //             onPressed: () {
  //               if (!isBookMarked) {
  //                 addBookMarkDocument();
  //                 isBookMarked = true;
  //               }
  //             },
  //             icon: isBookMarked
  //                 ? Icon(
  //                     Icons.star,
  //                     color: Colors.amber,
  //                     size: Responsive.isMobile(context) ? 22 : 35,
  //                   )
  //                 : Icon(
  //                     Icons.star_border,
  //                     color: Colors.white,
  //                     size: Responsive.isMobile(context) ? 22 : 35,
  //                   ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // -------- PROCESS MP3 ------------//
  Future<void> setAudio() async {
    audioplayer.setReleaseMode(ReleaseMode.stop);

    Directory tempDir = await getTemporaryDirectory();
    _mp3File = File('${tempDir.path}/temp.mp3');
    bytes = base64.decode(metadata);
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
    var random = Random.secure();
    var randomInt = random.nextInt(10000);
    Directory tempDir = await getTemporaryDirectory();
    _pdffile = File('${tempDir.path}/sample_$randomInt.pdf');
    List<int> imageValueBytes = base64.decode(metadata);
    await _pdffile!.writeAsBytes(imageValueBytes);
    print('PDF file written to ${_pdffile!.path}');

    return _pdffile!;
  }

  Widget displayFile(String mimetype) {
    Size size = MediaQuery.of(context).size;

    if (mimetype == 'image/jpg' ||
        mimetype == 'image/jpeg' ||
        mimetype == 'image/png' ||
        mimetype == 'image/gif') {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Image.memory(
          bytesImage!,
          fit: BoxFit.fill,
        ),
      );
    } else if (mimetype == 'application/pdf') {
      return FutureBuilder<File>(
        future: _getPDFFile(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return SfPdfViewer.file(
              _pdffile!,
              key: _pdfViewerKey,
              canShowPaginationDialog: false,
            );
          } else if (snapshot.hasError) {
            return Text('Error loading PDF file');
          } else {
            return CircularProgressIndicator(color: Colors.amber);
          }
        },
      );
    } else if (mimetype == 'text/plain') {
      final fileContent = utf8.decode(base64.decode(metadata));
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
    } else if (mimetype == 'text/csv') {
      final csvBytes = base64Decode(metadata);
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
                textScaler: TextScaler.linear(1),
              )),
            ),
            rows: List.generate(
              csvData.length - 1,
              (rowIndex) => DataRow(
                cells: List.generate(
                  csvData.first.length,
                  (cellIndex) => DataCell(Text(
                    csvData[rowIndex + 1][cellIndex].toString(),
                    textScaler: TextScaler.linear(1),
                  )),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (mimetype == 'video/mp4') {
      if (_videoPlayerController != null &&
          _videoPlayerController!.value.isInitialized) {
        return Chewie(controller: _chewieController!);
      }
    } else if (mimetype == 'audio/mpeg' || mimetype == 'audio/x-wav') {
      setAudio();
      return Container(
        color: Colors.white,
        child: Column(children: <Widget>[
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              mimeType != 'audio/x-wav'
                  ? "assets/images/mp3-file.jpg"
                  : "assets/images/wav.png",
              width: size.width * 0.2,
              height: size.width * 0.2,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              width: 300,
              child: Slider(
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
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                formatTime(position) ?? "",
                style: TextStyle(fontSize: 16),
                textScaler: TextScaler.linear(1),
              ),
              CircleAvatar(
                radius: 20,
                child: IconButton(
                  onPressed: () async {
                    if (isPlaying) {
                      await audioplayer.pause();
                    } else {
                      await audioplayer.resume();
                    }
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 24,
                  ),
                ),
              ),
              Text(
                formatTime(duration - position) ?? "",
                style: TextStyle(fontSize: 16),
                textScaler: TextScaler.linear(1),
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
                      showDuration: Duration(seconds: 2),
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
