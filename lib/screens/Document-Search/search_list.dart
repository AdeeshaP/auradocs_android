import 'dart:async';
import 'dart:convert';
import 'package:auradocs_android/Bloc/document_bloc.dart';
import 'package:auradocs_android/Bloc/document_event.dart';
import 'package:auradocs_android/Bloc/document_state.dart';
import 'package:auradocs_android/Models/users.dart';
import 'package:auradocs_android/screens/home_screen.dart';
import 'package:auradocs_android/utils/constants.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API-Services/api_service.dart';
import '../../utils/alert_dialogs.dart';
import '../Sliders/landing_page.dart';
import '../contact_us_screen.dart';
import 'view_searched_doc.dart';

class SearchedDocumentListScreen extends StatefulWidget {
  SearchedDocumentListScreen({super.key, required this.searchValue});

  final String searchValue;

  @override
  State<SearchedDocumentListScreen> createState() =>
      _SearchedDocumentListScreenState();
}

class _SearchedDocumentListScreenState
    extends State<SearchedDocumentListScreen> {
  late SharedPreferences _storage;
  Map<String, dynamic>? userObj;
  String username = "";
  String token = "";
  Uint8List? bytes;
  dynamic metadata;
  TextEditingController searchController = TextEditingController();
  List<dynamic> files = [];
  bool onClicked = false;
  List<Map<String, dynamic>>? values;
  String? templateType;
  int templateId = 0;
  List<dynamic> textFieldvalues2 = [];
  String compnyCode = "";
  int startIndex = 0;
  int currentshowIndex = 1;
  int currentPage = 0;
  ScrollController _scrollController = ScrollController();
  String trimmedValue = "";
  GlobalKey _toolTipKey = GlobalKey();
  List authentication = [];

  @override
  void initState() {
    super.initState();
    getSharedPrefrences();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> getSharedPrefrences() async {
    _storage = await SharedPreferences.getInstance();
    userObj = jsonDecode(_storage.getString('user_data')!);

    username = userObj!["value"]["userName"];
    token = _storage.getString('token')!;
    compnyCode = _storage.getString('code')!;
    String? authListJson = _storage.getString('authentication');
    authentication =
        authListJson != null ? List<String>.from(jsonDecode(authListJson)) : [];

    if (widget.searchValue.isNotEmpty) {
      context
          .read<DocumentBloc>()
          .add(FetchSearchDocuments(widget.searchValue, token));
    }
  }

  void okRecognition() {
    closeDialog(context);
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
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: <Widget>[
                getSearchBoxWidget(),
                Divider(height: 5),
                Stack(
                  children: [
                    Column(children: [
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
                                      Icons.content_paste_search,
                                      color: Colors.white,
                                      size: Responsive.isMobileSmall(context) ||
                                              Responsive.isMobileMedium(
                                                  context) ||
                                              Responsive.isMobileLarge(context)
                                          ? 25
                                          : Responsive.isTabletPortrait(context)
                                              ? 28
                                              : 30,
                                    ),
                                    SizedBox(
                                      width: Responsive.isMobileSmall(
                                                  context) ||
                                              Responsive.isMobileMedium(
                                                  context) ||
                                              Responsive.isMobileLarge(context)
                                          ? 5
                                          : 10,
                                    ),
                                    Text(
                                      "Search Results",
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
                                    size: 25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          color: Colors.amber[700],
                        ),
                      ),
                      BlocBuilder<DocumentBloc, DocumentState>(
                        builder: (context, state) {
                          if (state is DocumentLoading) {
                            return Column(
                              children: [
                                SizedBox(height: size.height * 0.4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                                  : Responsive.isTabletPortrait(
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
                          } else if (state is SearchDocumentLoaded ||
                              state is PartialSearchDocumentLoaded) {
                            final docs = state is SearchDocumentLoaded
                                ? state.searchDocs
                                : (state as PartialSearchDocumentLoaded)
                                    .searchDocs;

                            final pages = state is SearchDocumentLoaded
                                ? state.totalPages
                                : (state as PartialSearchDocumentLoaded)
                                    .totalPages;

                            if (docs == null) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.assignment,
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
                                    "No documents matched with your search value.",
                                    style: TextStyle(
                                      fontSize: Responsive.isMobileSmall(
                                                  context) ||
                                              Responsive.isMobileMedium(
                                                  context) ||
                                              Responsive.isMobileLarge(context)
                                          ? size.width * 0.05
                                          : Responsive.isTabletPortrait(context)
                                              ? size.width * 0.04
                                              : size.width * 0.03,
                                      color: Colors.black54,
                                    ),
                                    textScaler: TextScaler.linear(1),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            }
                            return Container(
                              color: Colors.white60,
                              width: size.width,
                              height: Responsive.isMobileSmall(context)
                                  ? size.height * 0.77
                                  : Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 1.65
                                      : Responsive.isTabletPortrait(context)
                                          ? size.height * 0.8
                                          : size.height * 0.75,
                              child: Stack(
                                children: [
                                  ListView.builder(
                                    scrollDirection: scrollDirection,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.all(10),
                                    itemCount:
                                        (docs.length - startIndex).clamp(0, 4),
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final item = docs[startIndex + index];
                                      final String mimeType =
                                          item['ImageValue']['mimetype'] == null
                                              ? ""
                                              : item['ImageValue']['mimetype'];
                                      metadata = item['ImageValue']['metadata'];
                                      if (metadata != null)
                                        bytes = base64Decode(item['ImageValue']
                                                ['metadata']
                                            .split(',')
                                            .last);
                                      final String templateId =
                                          item['templateId'];
                                      final String imageId = item['ImageId'];
                                      final List<dynamic> indexValues =
                                          item['IndexValues'];
                                      return Column(
                                        children: [
                                          SizedBox(height: 10),
                                          GestureDetector(
                                            onTap: () {
                                              if (docs.length > 0) {
                                                files = docs;
                                              }
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ViewSearchedDocumentScreen(
                                                    fileNames: files,
                                                    searchValue:
                                                        searchController.text,
                                                    indexOfCurrent:
                                                        startIndex + index,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black54,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                // color: Colors.amber[600],
                                                color: Colors.grey[200],
                                              ),
                                              height: size.width * 0.3,
                                              width: double.infinity,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: Responsive
                                                                .isMobileSmall(
                                                                    context) ||
                                                            Responsive
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
                                                            : 3,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(3),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            width: size.width *
                                                                0.17,
                                                            height: size.width *
                                                                0.17,
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        4,
                                                                    vertical:
                                                                        5),
                                                            child:
                                                                displayFileIconImage(
                                                                    mimeType),
                                                          ),
                                                          SizedBox(height: 5),
                                                          Text(
                                                            "$imageId",
                                                            style: TextStyle(
                                                              fontSize: Responsive.isMobileSmall(context) ||
                                                                      Responsive
                                                                          .isMobileMedium(
                                                                              context) ||
                                                                      Responsive
                                                                          .isMobileLarge(
                                                                              context)
                                                                  ? 13
                                                                  : Responsive.isTabletPortrait(
                                                                          context)
                                                                      ? 18
                                                                      : 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            textScaler:
                                                                TextScaler
                                                                    .linear(1),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 6),
                                                  Expanded(
                                                    flex: Responsive
                                                                .isMobileSmall(
                                                                    context) ||
                                                            Responsive
                                                                .isMobileMedium(
                                                                    context) ||
                                                            Responsive
                                                                .isMobileLarge(
                                                                    context)
                                                        ? 7
                                                        : Responsive
                                                                .isTabletPortrait(
                                                                    context)
                                                            ? 7
                                                            : 9,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 4.0),
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Text(
                                                              " $templateId",
                                                              style: TextStyle(
                                                                fontSize: Responsive.isMobileSmall(context) ||
                                                                        Responsive.isMobileMedium(
                                                                            context) ||
                                                                        Responsive.isMobileLarge(
                                                                            context)
                                                                    ? 13
                                                                    : Responsive.isTabletPortrait(
                                                                            context)
                                                                        ? 18
                                                                        : 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                              textScaler:
                                                                  TextScaler
                                                                      .linear(
                                                                          1),
                                                            ),
                                                            SizedBox(height: 5),
                                                            ...indexValues.map(
                                                                (indexValue) {
                                                              final String key =
                                                                  indexValue
                                                                      .keys
                                                                      .first;
                                                              final String
                                                                  value =
                                                                  indexValue.values
                                                                              .first ==
                                                                          null
                                                                      ? ""
                                                                      : indexValue
                                                                          .values
                                                                          .first;
                                                              return Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            5,
                                                                        vertical:
                                                                            2),
                                                                child: Text(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  textDirection:
                                                                      TextDirection
                                                                          .ltr,
                                                                  "$key  :  $value ",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize: Responsive.isMobileSmall(context) ||
                                                                            Responsive.isMobileMedium(context) ||
                                                                            Responsive.isMobileLarge(context)
                                                                        ? 11
                                                                        : Responsive.isTabletPortrait(context)
                                                                            ? 14
                                                                            : 15,
                                                                  ),
                                                                  textScaler:
                                                                      TextScaler
                                                                          .linear(
                                                                              1),
                                                                ),
                                                              );
                                                            }),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.arrow_back),
                                          onPressed: startIndex > 0
                                              ? () {
                                                  setState(() {
                                                    startIndex = (startIndex -
                                                            4)
                                                        .clamp(0, docs.length);
                                                    currentshowIndex -= 1;
                                                  });
                                                  if (pages! > 5) {
                                                    int pageIndexToScrollTo =
                                                        ((startIndex ~/ 4) -
                                                                1) *
                                                            40;

                                                    _scrollController.animateTo(
                                                      pageIndexToScrollTo
                                                          .toDouble(), // Assuming each box is 40.0 in width
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                      curve: Curves.easeInOut,
                                                    );
                                                  }
                                                }
                                              : null,
                                        ),
                                        Flexible(
                                          child: SingleChildScrollView(
                                            controller: _scrollController,
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: List.generate(pages!,
                                                  (index) {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        startIndex = index * 4;
                                                        currentshowIndex =
                                                            index + 1;
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: currentshowIndex ==
                                                                index + 1
                                                            ? Colors
                                                                .blue // Highlighted box color
                                                            : const Color
                                                                .fromARGB(255,
                                                                207, 196, 196),
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          (index + 1)
                                                              .toString(),
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
                                                                : Responsive.isTabletPortrait(
                                                                        context)
                                                                    ? 25
                                                                    : 25,
                                                            color: currentshowIndex ==
                                                                    index + 1
                                                                ? Colors
                                                                    .white // Highlighted box text color
                                                                : Colors
                                                                    .black87,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                          textScaler:
                                                              TextScaler.linear(
                                                                  1),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.arrow_forward),
                                          onPressed: (startIndex + 4) <
                                                  docs.length
                                              ? () {
                                                  setState(() {
                                                    startIndex = (startIndex +
                                                            4)
                                                        .clamp(0, docs.length);
                                                    currentshowIndex += 1;
                                                  });
                                                  if (pages > 5) {
                                                    int pageIndexToScrollTo =
                                                        ((startIndex ~/ 4) -
                                                                1) *
                                                            40;

                                                    _scrollController.animateTo(
                                                      pageIndexToScrollTo
                                                          .toDouble(), // Assuming each box is 40.0 in width
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                      curve: Curves.easeInOut,
                                                    );
                                                  }
                                                }
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Positioned(
                                  //   left: 0,
                                  //   right: 0,
                                  //   bottom: 0,
                                  //   child: Container(
                                  //     child: Row(
                                  //       mainAxisAlignment:
                                  //           MainAxisAlignment.center,
                                  //       children: [
                                  //         IconButton(
                                  //           icon: Icon(Icons.arrow_back),
                                  //           onPressed: startIndex > 0
                                  //               ? () {
                                  //                   setState(() {
                                  //                     startIndex =
                                  //                         (startIndex - 3)
                                  //                             .clamp(
                                  //                                 0,
                                  //                                 valueList
                                  //                                     .length);
                                  //                     currentshowIndex =
                                  //                         currentshowIndex -
                                  //                             1;
                                  //                   });
                                  //                 }
                                  //               : null,
                                  //         ),
                                  //         SizedBox(width: 5),
                                  //         Container(
                                  //           width: 40,
                                  //           height: 40,
                                  //           decoration: BoxDecoration(
                                  //               borderRadius:
                                  //                   BorderRadius.circular(
                                  //                       10),
                                  //               color: const Color.fromARGB(
                                  //                   255, 207, 196, 196)),
                                  //           child: Align(
                                  //             alignment: Alignment.center,
                                  //             child: Text(
                                  //                 currentshowIndex
                                  //                     .toString(),
                                  //                 style: TextStyle(
                                  //                     fontSize: Responsive
                                  //                                 .isMobileSmall(
                                  //                                     context) ||
                                  //                             Responsive
                                  //                                 .isMobileMedium(
                                  //                                     context) ||
                                  //                             Responsive
                                  //                                 .isMobileLarge(
                                  //                                     context)
                                  //                         ? 18
                                  //                         : Responsive
                                  //                                 .isTabletPortrait(
                                  //                                     context)
                                  //                             ? 25
                                  //                             : 25,
                                  //                     color: Colors.black87,
                                  //                     fontWeight:
                                  //                         FontWeight.bold),
                                  //                 textAlign:
                                  //                     TextAlign.center),
                                  //           ),
                                  //         ),
                                  //         SizedBox(width: 5),
                                  //         IconButton(
                                  //           icon: Icon(Icons.arrow_forward),
                                  //           onPressed: (startIndex + 3) <
                                  //                   valueList.length
                                  //               ? () {
                                  //                   setState(() {
                                  //                     startIndex =
                                  //                         (startIndex + 3)
                                  //                             .clamp(
                                  //                                 0,
                                  //                                 valueList
                                  //                                     .length);
                                  //                     currentshowIndex =
                                  //                         currentshowIndex +
                                  //                             1;
                                  //                   });
                                  //                 }
                                  //               : null,
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            );
                          } else if (state is DocumentError) {
                            return Center(child: Text(state.message));
                          } else {
                            return Center(child: Text('Unexpected state'));
                          }
                        },
                      ),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ),
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

  Widget displayFileIconImage(String mimeType2) {
    if (mimeType2 == 'image/jpeg') {
      return Image.asset('assets/icons/jpg-file.png');
    } else if (mimeType2 == 'image/png') {
      return Image.asset('assets/icons/png-file.png');
    } else if (mimeType2 == 'image/gif') {
      return Image.asset('assets/icons/gif-file.png');
    } else if (mimeType2 == 'application/pdf') {
      return Image.asset('assets/icons/pdf-file.png');
    } else if (mimeType2 == 'video/mp4') {
      return Image.asset('assets/icons/mp4-file.png');
    } else if (mimeType2 == 'audio/mpeg') {
      return Image.asset('assets/icons/mp3-file.png');
    } else if (mimeType2 == 'text/plain') {
      return Image.asset('assets/icons/txt-file.png');
    } else if (mimeType2 == 'image/tiff') {
      return Image.asset('assets/icons/tiff-file.png');
    } else if (mimeType2 ==
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
      return Image.asset('assets/icons/docx-file.png');
    } else if (mimeType2 == 'application/msword') {
      return Image.asset('assets/icons/doc-file.png');
    } else if (mimeType2 == 'application/vnd.ms-excel') {
      return Image.asset('assets/icons/xls-file.png');
    } else if (mimeType2 ==
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
      return Image.asset('assets/icons/xlsx-file.png');
    } else if (mimeType2 == 'application/vnd.ms-powerpoint') {
      return Image.asset('assets/icons/ppt-file.png');
    } else if (mimeType2 ==
        'application/vnd.openxmlformats-officedocument.presentationml.presentation') {
      return Image.asset('assets/icons/pptx-file.png');
    } else if (mimeType2 == 'text/csv') {
      return Image.asset('assets/icons/csv-file.png');
    } else if (mimeType2 == 'application/x-sh') {
      return Image.asset('assets/icons/sh-file.png');
    } else if (mimeType2 == 'audio/wav') {
      return Image.asset('assets/icons/wav-file.png');
    }
    return Icon(
      Icons.no_sim_sharp,
      size: 50,
    );
  }

  Future<void> userLogout() async {
    var response = await ApiService.logoutUser(username, token);

    if (response.statusCode == 403) {
      _storage.clear();
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
