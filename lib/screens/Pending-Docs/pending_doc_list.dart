import 'package:auradocs_android/Bloc/document_bloc.dart';
import 'package:auradocs_android/Bloc/document_event.dart';
import 'package:auradocs_android/Bloc/document_state.dart';
import 'package:auradocs_android/screens/Pending-Docs/view_pending_doc.dart';
import 'package:auradocs_android/screens/Sliders/landing_page.dart';
import 'package:auradocs_android/screens/contact_us_screen.dart';
import 'package:auradocs_android/screens/home_screen.dart';
import 'package:auradocs_android/utils/alert_dialogs.dart';
import 'package:auradocs_android/utils/constants.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../API-Services/api_service.dart';
import '../../Models/users.dart';
import 'package:path/path.dart' as p;
import '../Document-Search/search_list.dart';

class PendingDocsListScreen extends StatefulWidget {
  PendingDocsListScreen({super.key});

  @override
  _PendingDocsListScreenState createState() => _PendingDocsListScreenState();
}

class _PendingDocsListScreenState extends State<PendingDocsListScreen> {
  String username = "";
  String token = "";
  String compnyCode = "";
  late SharedPreferences _storage;
  TextEditingController searchController = TextEditingController();
  Map<String, dynamic>? userObj;
  Map<String, dynamic>? responsedata;
  bool isDragging = false;
  int draggingIndex = -1;
  double binPosition = 0.0;
  String folderName = "";
  String fileName = "";
  bool isExpanded = false;
  String trimmedValue = "";
  GlobalKey _toolTipKey = GlobalKey();
  List authentication = [];

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getSharedPrefs() async {
    _storage = await SharedPreferences.getInstance();
    userObj = jsonDecode(_storage.getString('user_data')!);
    token = _storage.getString('token')!;

    username = userObj!["value"]["userName"];
    compnyCode = _storage.getString('code')!;
    String? authListJson = _storage.getString('authentication');
    authentication =
        authListJson != null ? List<String>.from(jsonDecode(authListJson)) : [];

    context
        .read<DocumentBloc>()
        .add(FetchPendingDocumentsToIndex(username, token));
  }

// -------- GET API - Delete selecetd grid item -------------//
  Future<void> deletePendingDocument(folderN, fileN) async {
    _storage = await SharedPreferences.getInstance();
    userObj = jsonDecode(_storage.getString('user_data')!);
    token = _storage.getString('token')!;

    username = userObj!["value"]["userName"];
    folderN = folderName;
    fileN = fileName;

    print(folderN);
    print(fileN);

    if (fileN != "" && folderN != "") {
      var response = await ApiService.deletePendingDocument(
        username,
        token,
        folderN,
        fileN,
      );

      responsedata = jsonDecode(response.body);
    }
  }

  void okRecognition() {
    closeDialog(context);
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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              user: User(
                  token: token,
                  userName: username,
                  authenticated_features: authentication),
              code: compnyCode,
            ),
          ),
          (route) => true,
        );
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false, //new line
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background_three.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            width: size.width,
            height: double.infinity,
            child: Column(
              children: [
                getSearchBoxWidget(),
                Divider(height: 8),
                Stack(
                  children: [
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            height: Responsive.isMobileSmall(context) ||
                                    Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.1
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.07
                                    : size.width * 0.05,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.pending_actions,
                                        color: Colors.white,
                                        size: Responsive.isMobileSmall(
                                                    context) ||
                                                Responsive.isMobileMedium(
                                                    context) ||
                                                Responsive.isMobileLarge(
                                                    context)
                                            ? 25
                                            : Responsive.isTabletPortrait(
                                                    context)
                                                ? 28
                                                : 30,
                                      ),
                                      SizedBox(
                                        width: Responsive.isMobileSmall(
                                                    context) ||
                                                Responsive.isMobileMedium(
                                                    context) ||
                                                Responsive.isMobileLarge(
                                                    context)
                                            ? 5
                                            : 10,
                                      ),
                                      Text(
                                        "Pending Documents",
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
                                                  : Responsive
                                                          .isTabletPortrait(
                                                              context)
                                                      ? 22
                                                      : 21,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textScaler: TextScaler.linear(1),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HomePage(
                                            user: User(
                                                token: token,
                                                userName: username,
                                                authenticated_features:
                                                    authentication),
                                            code: compnyCode,
                                          ),
                                        ),
                                        (route) => true,
                                      );
                                    },
                                    child: Icon(
                                      Icons.arrow_back_sharp,
                                      color: Colors.white,
                                      size: Responsive.isMobileSmall(
                                                  context) ||
                                              Responsive.isMobileMedium(
                                                  context) ||
                                              Responsive.isMobileLarge(context)
                                          ? 25
                                          : Responsive.isTabletLandscape(
                                                      context) ||
                                                  Responsive.isTabletPortrait(
                                                      context)
                                              ? 35
                                              : 25,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            color: Colors.amber[700],
                          ),
                        ),
                        SizedBox(height: 5),
                        BlocBuilder<DocumentBloc, DocumentState>(
                            builder: (context, state) {
                          if (state is DocumentLoading) {
                            return Column(
                              children: [
                                SizedBox(height: size.height * 0.4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    CircularProgressIndicator(
                                        color: Colors.amber),
                                    SizedBox(
                                      width: Responsive.isMobileSmall(
                                                  context) ||
                                              Responsive.isMobileMedium(
                                                  context) ||
                                              Responsive.isMobileLarge(context)
                                          ? 1
                                          : 10,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 5),
                                      child: Text(
                                        "Loading",
                                        style: TextStyle(
                                          fontSize: Responsive.isMobileSmall(
                                                  context)
                                              ? 15
                                              : Responsive.isMobileMedium(
                                                          context) ||
                                                      Responsive.isMobileLarge(
                                                          context)
                                                  ? 18
                                                  : Responsive
                                                          .isTabletPortrait(
                                                              context)
                                                      ? 24
                                                      : 20,
                                        ),
                                        textScaler: TextScaler.linear(1),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          } else if (state is PendingDocsLoaded) {
                            final documents = state.pendingDocs;
                            final folderExpansionStates =
                                state.folderExpansionStates;

                            if (documents == null || documents.isEmpty) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: size.height * 0.25,
                                  ),
                                  Icon(
                                    Icons.pending_actions,
                                    size: Responsive.isMobileSmall(context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? size.width * 0.24
                                        : Responsive.isTabletPortrait(context)
                                            ? size.width * 0.2
                                            : size.width * 0.15,
                                    color: Colors.grey[300],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "No Pending Documents",
                                    style: TextStyle(
                                      fontSize: Responsive.isMobileSmall(
                                                  context) ||
                                              Responsive.isMobileMedium(
                                                  context) ||
                                              Responsive.isMobileLarge(context)
                                          ? size.width * 0.06
                                          : Responsive.isTabletPortrait(
                                                  context)
                                              ? size.width * 0.04
                                              : size.width * 0.03,
                                      color: Colors.black54,
                                    ),
                                    textScaler: TextScaler.linear(1),
                                  ),
                                ],
                              );
                            }

                            return Stack(
                              children: [
                                SizedBox(
                                  height: Responsive.isMobileSmall(context)
                                      ? size.height * 0.8
                                      : Responsive.isMobileMedium(context)
                                          ? size.height * 0.8
                                          : Responsive.isMobileLarge(context)
                                              ? size.height * 0.8
                                              : Responsive.isTabletPortrait(
                                                      context)
                                                  ? size.height * 0.8
                                                  : size.height * 0.85,
                                  child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: documents.length,
                                    itemBuilder:
                                        (BuildContext context, int index1) {
                                      final Map<String, dynamic> keyValueMap =
                                          documents[index1];
                                      if (keyValueMap.isEmpty) {
                                        return Container();
                                      }
                                      final String key = keyValueMap.keys.first;
                                      // final values = keyValueMap.values.first;
                                      final values = keyValueMap.values.first
                                          .where(hasFileExtension)
                                          .toList();

                                      // print("values $values");

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 1),
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  color: Colors.yellow[500],
                                                  iconSize: Responsive
                                                              .isMobileSmall(
                                                                  context) ||
                                                          Responsive
                                                              .isMobileMedium(
                                                                  context) ||
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 28.0
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? 40
                                                          : 35,
                                                  onPressed: () {
                                                    setState(() {
                                                      folderExpansionStates![
                                                              index1] =
                                                          !folderExpansionStates[
                                                              index1];
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.folder_copy,
                                                    color: Color.fromARGB(
                                                        255, 252, 206, 4),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      folderExpansionStates![
                                                              index1] =
                                                          !folderExpansionStates[
                                                              index1];
                                                    });
                                                  },
                                                  child: Text(
                                                    key,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black,
                                                      fontSize: Responsive
                                                              .isMobileSmall(
                                                                  context)
                                                          ? 15
                                                          : Responsive.isMobileMedium(
                                                                      context) ||
                                                                  Responsive
                                                                      .isMobileLarge(
                                                                          context)
                                                              ? 16.0
                                                              : Responsive
                                                                      .isTabletPortrait(
                                                                          context)
                                                                  ? 20
                                                                  : 22,
                                                    ),
                                                    textScaler:
                                                        TextScaler.linear(1),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Divider(
                                          //   color: Colors.black87,
                                          //   height: 7,
                                          //   thickness: 1,
                                          // ),
                                          if (folderExpansionStates![
                                              index1]) // Only expand files if isExpanded is true
                                            GridView.builder(
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                childAspectRatio: Responsive
                                                        .isMobileSmall(context)
                                                    ? 1.1
                                                    : Responsive
                                                                .isMobileMedium(
                                                                    context) ||
                                                            Responsive
                                                                .isMobileLarge(
                                                                    context) ||
                                                            Responsive
                                                                .isTabletPortrait(
                                                                    context)
                                                        ? 0.9
                                                        : 1,
                                                crossAxisCount: Responsive
                                                        .isMobileSmall(context)
                                                    ? 2
                                                    : Responsive
                                                                .isMobileMedium(
                                                                    context) ||
                                                            Responsive
                                                                .isMobileLarge(
                                                                    context)
                                                        ? 3
                                                        : Responsive
                                                                .isTabletPortrait(
                                                                    context)
                                                            ? 4
                                                            : 5,
                                              ),
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: values.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      fileName = values[index];
                                                      folderName = key;
                                                    });
                                                    // List<dynamic> files =
                                                    //     values.sublist(index);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) {
                                                          return BlocProvider(
                                                            create: (context) =>
                                                                DocumentBloc(
                                                                    username,
                                                                    token),
                                                            child:
                                                                PendingDocumentsViewer(
                                                              fileNames2:
                                                                  values,
                                                              folderName: key,
                                                              removeDocCallBack:
                                                                  () async {
                                                                await deletePendingDocument(
                                                                    folderName,
                                                                    fileName);
                                                                // await getPendingDocuments();
                                                              },
                                                              indexOfFile:
                                                                  index,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  },
                                                  child: Builder(
                                                    builder: (context) =>
                                                        Draggable<String>(
                                                      data: values[index],
                                                      feedback: Material(
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  12.0),
                                                          child: Text(
                                                            values[index],
                                                            style: TextStyle(
                                                              fontSize: Responsive.isMobileSmall(context) ||
                                                                      Responsive
                                                                          .isMobileMedium(
                                                                              context) ||
                                                                      Responsive
                                                                          .isMobileLarge(
                                                                              context)
                                                                  ? 20.0
                                                                  : Responsive
                                                                          .isTabletPortrait(
                                                                              context)
                                                                      ? 25
                                                                      : 25,
                                                            ),
                                                            textScaler:
                                                                TextScaler
                                                                    .linear(1),
                                                          ),
                                                        ),
                                                      ),
                                                      child: Card(
                                                        elevation: 1,
                                                        shape:
                                                            ContinuousRectangleBorder(
                                                          side: BorderSide(
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10,
                                                                vertical: 10),
                                                        child: Container(
                                                          color:
                                                              Colors.grey[200],
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Container(
                                                              color:
                                                                  Colors.white,
                                                              height: 50,
                                                              child: Column(
                                                                children: [
                                                                  displayFileIcon(
                                                                      values[
                                                                          index]),
                                                                  Flexible(
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              5),
                                                                      child:
                                                                          Text(
                                                                        values[
                                                                            index],
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontSize: Responsive.isMobileSmall(context)
                                                                              ? 11
                                                                              : Responsive.isMobileMedium(context)
                                                                                  ? 11.3
                                                                                  : Responsive.isMobileLarge(context)
                                                                                      ? 12.0
                                                                                      : Responsive.isTabletPortrait(context)
                                                                                          ? 13
                                                                                          : 14,
                                                                        ),
                                                                        textScaler:
                                                                            TextScaler.linear(1),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      onDragStarted: () {
                                                        setState(() {
                                                          isDragging = true;
                                                          draggingIndex = index;
                                                          fileName =
                                                              values[index];
                                                          folderName = key;
                                                        });
                                                      },
                                                      onDragEnd:
                                                          (details) async {
                                                        //  ---------------------------
                                                        setState(
                                                          () {
                                                            isDragging = false;
                                                            binPosition = 0.0;
                                                          },
                                                        );
                                                        // ------------New Line-----------
                                                        final RenderBox box =
                                                            context.findRenderObject()
                                                                as RenderBox;
                                                        final Offset position =
                                                            box.localToGlobal(
                                                                Offset.zero);
                                                        if (details.offset.dy >
                                                                position.dy +
                                                                    box.size
                                                                        .height &&
                                                            details.offset.dx >
                                                                position.dx +
                                                                    box.size
                                                                        .width) {
                                                          await deletePendingDocument(
                                                              folderName,
                                                              fileName);
                                                          // getPendingDocuments();
                                                          context
                                                              .read<
                                                                  DocumentBloc>()
                                                              .add(
                                                                  FetchPendingDocumentsToIndex(
                                                                      username,
                                                                      token));
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                if (isDragging)
                                  Positioned(
                                    left: 0.0,
                                    right: 0.0,
                                    bottom: 0,
                                    child: DragTarget<String>(
                                      builder: (context, candidateData,
                                          rejectedData) {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              12,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          // color: Colors.black45,
                                          color: binPosition == 1.0
                                              ? Colors.red
                                              : Colors.black45,
                                          child: Icon(
                                            Icons.delete,
                                            size: Responsive.isMobileSmall(
                                                        context) ||
                                                    Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 50.0
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 60
                                                    : 60,
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                      onWillAcceptWithDetails: (data) {
                                        setState(() {
                                          // binPosition = 0;
                                          binPosition = 1;
                                        });
                                        return true;
                                      },
                                      onLeave: (data) {
                                        setState(() {
                                          binPosition = 0.0;
                                        });
                                      },
                                      onAcceptWithDetails: (data) async {
                                        if (binPosition == 1) {
                                          await deletePendingDocument(
                                              folderName, fileName);
                                          // getPendingDocuments();
                                          context.read<DocumentBloc>().add(
                                              FetchPendingDocumentsToIndex(
                                                  username, token));
                                          setState(() {
                                            documents.removeAt(draggingIndex);
                                            isDragging = false;
                                            draggingIndex = -1;
                                            binPosition = 0.0;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                              ],
                            );
                          } else if (state is DocumentError) {
                            return Center(child: Text(state.message));
                          }
                          return Container();
                        }),
                      ],
                    ),
                    // AdvancedSearchBox(_isAdvanceSearchVisible),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool hasFileExtension(dynamic fileName) {
    if (fileName is String) {
      // Use whatever logic you want to determine if the fileName has an extension.
      // For example, you can check if it contains a dot (.) to indicate an extension.
      return fileName.contains('.');
    }
    return false;
  }

  String _extension(String filePath) {
    return p.extension(filePath).substring(1);
  }

  Widget setFileIcon(String filePath) {
    String ext = _extension(filePath);
    // String mimeType3 = lookupMimeType(filePath)!;
    // print("mt3 $mimeType3");
    print("file apth is $filePath");

    if (ext == 'jpg' || ext == 'JPG') {
      return Image.asset('assets/icons/jpg-file.png');
    } else if (ext == 'jpeg' || ext == 'JPEG') {
      return Image.asset('assets/icons/jpeg-file.png');
    } else if (ext == 'png' || ext == 'PNG') {
      return Image.asset('assets/icons/png-file.png');
    } else if (ext == 'gif' || ext == 'GIF') {
      return Image.asset('assets/icons/gif-file.png');
    } else if (ext == 'pdf' || ext == 'PDF') {
      return Image.asset('assets/icons/pdf-file.png');
    } else if (ext == 'mp4' || ext == 'MP4') {
      return Image.asset('assets/icons/mp4-file.png');
    } else if (ext == 'mp3' || ext == 'MP3') {
      return Image.asset('assets/icons/mp3-file.png');
    } else if (ext == 'txt' || ext == 'TXT') {
      return Image.asset('assets/icons/txt-file.png');
    } else if (ext == 'tiff' || ext == 'TIFF') {
      return Image.asset('assets/icons/tiff-file.png');
    } else if (ext == 'tif' || ext == 'TIF') {
      return Image.asset('assets/icons/tif-file.png');
    } else if (ext == 'docx' || ext == 'DOCX') {
      return Image.asset('assets/icons/docx-file.png');
    } else if (ext == 'doc' || ext == 'DOC') {
      return Image.asset('assets/icons/doc-file.png');
    } else if (ext == 'xls' || ext == 'XLS') {
      return Image.asset('assets/icons/xls-file.png');
    } else if (ext == 'xlsx' || ext == 'XLSX') {
      return Image.asset('assets/icons/xlsx-file.png');
    } else if (ext == 'ppt' || ext == 'PPT') {
      return Image.asset('assets/icons/ppt-file.png');
    } else if (ext == 'pptx' || ext == 'PPTX') {
      return Image.asset('assets/icons/pptx-file.png');
    } else if (ext == 'csv' || ext == 'CSV') {
      return Image.asset('assets/icons/csv-file.png');
    } else if (ext == 'sh' || ext == 'SH') {
      return Image.asset('assets/icons/sh-file.png');
    } else if (ext == 'wav' || ext == 'WAV') {
      return Image.asset('assets/icons/wav-file.png');
    }
    return Text('Unsupported file format');
  }

  Widget displayFileIcon(String filePath) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: Responsive.isMobileSmall(context)
              ? 7
              : Responsive.isMobileMedium(context) ||
                      Responsive.isMobileLarge(context)
                  ? 10
                  : Responsive.isTabletPortrait(context)
                      ? 15
                      : 25,
          horizontal: 5),
      child: Container(
        height: Responsive.isMobileSmall(context)
            ? 30
            : Responsive.isMobileMedium(context)
                ? 40
                : Responsive.isMobileLarge(context)
                    ? 45.0
                    : Responsive.isTabletPortrait(context)
                        ? 55
                        : 60,
        width: Responsive.isMobileSmall(context)
            ? 30
            : Responsive.isMobileMedium(context)
                ? 40
                : Responsive.isMobileLarge(context)
                    ? 45.0
                    : Responsive.isTabletPortrait(context)
                        ? 55
                        : 60,
        child: setFileIcon(filePath),
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
                                  fontSize: Responsive.isMobileSmall(
                                              context) ||
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
