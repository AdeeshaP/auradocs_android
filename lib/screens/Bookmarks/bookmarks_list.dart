import 'dart:convert';
import 'dart:io';
import 'package:auradocs_android/API-Services/api_service.dart';
import 'package:auradocs_android/Bloc/document_event.dart';
import 'package:auradocs_android/Models/users.dart';
import 'package:auradocs_android/screens/Bookmarks/view_bookmarked_doc.dart';
import 'package:auradocs_android/screens/Sliders/landing_page.dart';
import 'package:auradocs_android/screens/home_screen.dart';
import 'package:auradocs_android/utils/alert_dialogs.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Bloc/document_bloc.dart';
import '../../Bloc/document_state.dart';
import '../../utils/constants.dart';
import '../contact_us_screen.dart';

class FavoriteDocListScreen extends StatefulWidget {
  const FavoriteDocListScreen({super.key});

  @override
  State<FavoriteDocListScreen> createState() => _FavoriteDocListScreenState();
}

class _FavoriteDocListScreenState extends State<FavoriteDocListScreen> {
  late SharedPreferences _storage;
  Map<String, dynamic>? userObj;
  String username = "";
  String token = "";
  Map<String, dynamic>? responsedata;
  Uint8List? bytes;
  dynamic metadata;
  File? pdffile;
  List<dynamic> files = [];
  int bookmarkId = 0;
  int documentId = 0;
  String templateId = "";
  int deleingIndex = -1;
  TextEditingController searchController = TextEditingController();
  String compnyCode = "";
  int startIndex = 0;
  int currentshowIndex = 1;
  ScrollController _scrollController = ScrollController();
  bool isForward = false;
  bool isReverse = false;
  String trimmedValue = "";
  GlobalKey _toolTipKey = GlobalKey();
  List authentication = [];

  @override
  void initState() {
    super.initState();
    getSharedPreferences();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void okRecognition() {
    closeDialog(context);
  }

  Future<void> getSharedPreferences() async {
    _storage = await SharedPreferences.getInstance();
    userObj = jsonDecode(_storage.getString('user_data')!);
    token = _storage.getString('token')!;
    username = userObj!["value"]["userName"];
    compnyCode = _storage.getString('code')!;
    String? authListJson = _storage.getString('authentication');
    authentication =
        authListJson != null ? List<String>.from(jsonDecode(authListJson)) : [];

    context.read<DocumentBloc>().add(FetchFavoriteDocs(username, token));
  }

  // -------- GET API - Delete selecetd grid item -------------//
  Future<void> removeBookMarkedDoc(int bookmarkID) async {
    _storage = await SharedPreferences.getInstance();
    userObj = jsonDecode(_storage.getString('user_data')!);
    token = _storage.getString('token')!;

    setState(() {
      username = userObj!["value"]["userName"];
      bookmarkId = bookmarkID;
    });

    if (bookmarkId != "") {
      var response = await ApiService.removeBookmark(
        bookmarkId,
        token,
      );

      if (response.statusCode == 200) {
        responsedata = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('Bookmark removed successfully..'),
          ),
        );
      }
    }
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
          resizeToAvoidBottomInset: false,
          body: Container(
            width: size.width,
            child: Column(
              children: <Widget>[
                getSearchBoxWidget(),
                Divider(height: 8),
                Stack(
                  children: <Widget>[
                    Column(
                      children: [
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                    flex: 12,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Icon(
                                          Icons.star,
                                          color: Colors.white,
                                          size: Responsive.isMobileSmall(
                                                      context) ||
                                                  Responsive.isMobileMedium(
                                                      context) ||
                                                  Responsive.isMobileLarge(
                                                      context)
                                              ? 25
                                              : 28,
                                        ),
                                        SizedBox(
                                            width: Responsive.isMobileSmall(
                                                        context) ||
                                                    Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 5
                                                : 15),
                                        Text(
                                          "Favorites",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: Responsive.isMobileSmall(
                                                    context)
                                                ? 16
                                                : Responsive.isMobileMedium(
                                                            context) ||
                                                        Responsive
                                                            .isMobileLarge(
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
                                    )),
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
                                      size: Responsive.isMobileSmall(context) ||
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
                          } else if (state is FavoriteListLoaded ||
                              state is PartialFavoriteListLoaded) {
                            final docs = state is FavoriteListLoaded
                                ? state.bookmarks
                                : (state as PartialFavoriteListLoaded)
                                    .bookmarks;

                            final pages = state is FavoriteListLoaded
                                ? state.totalPages
                                : (state as PartialFavoriteListLoaded)
                                    .totalPages;

                            if (docs == null) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: size.height * 0.25,
                                  ),
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
                                    "No Favorite Documents",
                                    style: TextStyle(
                                      fontSize: Responsive.isMobileSmall(
                                                  context) ||
                                              Responsive.isMobileMedium(
                                                  context) ||
                                              Responsive.isMobileLarge(context)
                                          ? size.width * 0.06
                                          : Responsive.isTabletPortrait(context)
                                              ? size.width * 0.04
                                              : size.width * 0.03,
                                      color: Colors.black54,
                                    ),
                                    textScaler: TextScaler.linear(1),
                                  ),
                                ],
                              );
                            }
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                color: Colors.transparent,
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
                                      itemCount: (docs.length - startIndex)
                                          .clamp(0, 4),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final item = docs[startIndex + index];
                                        String mimeType = item['ImageValue']
                                                    ['mimetype'] ==
                                                null
                                            ? ""
                                            : item['ImageValue']['mimetype'];
                                        metadata =
                                            item['ImageValue']['metadata'];
                                        if (metadata != null)
                                          bytes = base64Decode(
                                              item['ImageValue']['metadata']
                                                  .split(',')
                                                  .last);

                                        templateId = item['templateId'];
                                        bookmarkId = item['bookMarkId'];
                                        documentId = item['documentId'];
                                        List<dynamic> indexValues =
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
                                                        BookmarkedDocumentViewScreen(
                                                      fileNames: files,
                                                      indexOfCurrent:
                                                          startIndex + index,
                                                      removeBookmarkCallBack:
                                                          () async {
                                                        await removeBookMarkedDoc(
                                                            item['bookMarkId']);
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: Responsive
                                                            .isMobileSmall(
                                                                context) ||
                                                        Responsive
                                                            .isMobileMedium(
                                                                context) ||
                                                        Responsive
                                                            .isMobileLarge(
                                                                context)
                                                    ? 120
                                                    : Responsive.isTabletLandscape(
                                                                context) ||
                                                            Responsive
                                                                .isTabletPortrait(
                                                                    context)
                                                        ? 180
                                                        : 120,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black54,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Colors.grey[200],
                                                ),
                                                width: double.infinity,
                                                child: Row(
                                                  children: <Widget>[
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
                                                          : 4,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                                width:
                                                                    size.width *
                                                                        0.17,
                                                                height:
                                                                    size.width *
                                                                        0.17,
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            5,
                                                                        vertical:
                                                                            10),
                                                                child: displayFileIconImage(
                                                                    mimeType)),
                                                            Text(
                                                              documentId
                                                                  .toString(),
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: Responsive.isMobileSmall(context) ||
                                                                        Responsive.isMobileMedium(
                                                                            context) ||
                                                                        Responsive.isMobileLarge(
                                                                            context)
                                                                    ? 13
                                                                    : Responsive.isTabletPortrait(
                                                                            context)
                                                                        ? 20
                                                                        : 22,
                                                              ),
                                                              textScaler:
                                                                  TextScaler
                                                                      .linear(
                                                                          1),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 6),
                                                    Expanded(
                                                      flex: 6,
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
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
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: Responsive.isMobileSmall(context) ||
                                                                          Responsive.isMobileMedium(
                                                                              context) ||
                                                                          Responsive.isMobileLarge(
                                                                              context)
                                                                      ? 13
                                                                      : Responsive.isTabletPortrait(
                                                                              context)
                                                                          ? 20
                                                                          : 22,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                                textScaler:
                                                                    TextScaler
                                                                        .linear(
                                                                            1),
                                                              ),
                                                              SizedBox(
                                                                  height: Responsive.isMobileSmall(context) ||
                                                                          Responsive.isMobileMedium(
                                                                              context) ||
                                                                          Responsive.isMobileLarge(
                                                                              context)
                                                                      ? 5
                                                                      : Responsive.isTabletPortrait(
                                                                              context)
                                                                          ? 10
                                                                          : 15),
                                                              ...indexValues.map(
                                                                  (indexValue) {
                                                                final String
                                                                    key =
                                                                    indexValue
                                                                        .keys
                                                                        .first;
                                                                final String value = indexValue
                                                                            .values
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
                                                                              ? 16
                                                                              : 18,
                                                                    ),
                                                                    textScaler:
                                                                        TextScaler
                                                                            .linear(1),
                                                                  ),
                                                                );
                                                              }),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          IconButton(
                                                            color:
                                                                Colors.red[700],
                                                            icon: Icon(
                                                              Icons.delete,
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
                                                                  : 40,
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              setState(() {
                                                                deleingIndex =
                                                                    index;
                                                              });

                                                              await removeBookMarkedDoc(
                                                                  item[
                                                                      'bookMarkId']);

                                                              setState(() {
                                                                docs.removeAt(
                                                                    deleingIndex);
                                                              });
                                                            },
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    right: 4),
                                                            child: Text(
                                                              "Delete",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontSize: Responsive.isMobileSmall(context) ||
                                                                        Responsive.isMobileMedium(
                                                                            context) ||
                                                                        Responsive.isMobileLarge(
                                                                            context)
                                                                    ? 11
                                                                    : 16,
                                                                color: Colors
                                                                    .red[900],
                                                              ),
                                                              textScaler:
                                                                  TextScaler
                                                                      .linear(
                                                                          1),
                                                            ),
                                                          ),
                                                          SizedBox(height: 10),
                                                        ],
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
                                      child: SingleChildScrollView(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.arrow_back),
                                              onPressed: startIndex > 0
                                                  ? () {
                                                      setState(() {
                                                        startIndex =
                                                            (startIndex - 4)
                                                                .clamp(0,
                                                                    docs.length);
                                                        currentshowIndex -= 1;
                                                      });
                                                      if (pages! > 5) {
                                                        int pageIndexToScrollTo =
                                                            ((startIndex ~/ 4) -
                                                                    1) *
                                                                40;

                                                        _scrollController
                                                            .animateTo(
                                                          pageIndexToScrollTo
                                                              .toDouble(), // Assuming each box is 40.0 in width
                                                          duration: Duration(
                                                              milliseconds:
                                                                  500),
                                                          curve:
                                                              Curves.easeInOut,
                                                        );
                                                      }
                                                    }
                                                  : null,
                                            ),
                                            Flexible(
                                              child: SingleChildScrollView(
                                                controller: _scrollController,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: List.generate(
                                                      pages!, (index) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5.0),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            startIndex =
                                                                index * 4;
                                                            currentshowIndex =
                                                                index + 1;
                                                          });
                                                        },
                                                        child: Container(
                                                          width: 40,
                                                          height: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color: currentshowIndex ==
                                                                    index + 1
                                                                ? Colors
                                                                    .blue // Highlighted box color
                                                                : const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    207,
                                                                    196,
                                                                    196),
                                                          ),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              (index + 1)
                                                                  .toString(),
                                                              style: TextStyle(
                                                                fontSize: Responsive.isMobileSmall(context) ||
                                                                        Responsive.isMobileMedium(
                                                                            context) ||
                                                                        Responsive.isMobileLarge(
                                                                            context)
                                                                    ? 18
                                                                    : Responsive.isTabletPortrait(
                                                                            context)
                                                                        ? 25
                                                                        : 25,
                                                                color: currentshowIndex ==
                                                                        index +
                                                                            1
                                                                    ? Colors
                                                                        .white // Highlighted box text color
                                                                    : Colors
                                                                        .black87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                              textScaler:
                                                                  TextScaler
                                                                      .linear(
                                                                          1),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
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
                                                        startIndex =
                                                            (startIndex + 4)
                                                                .clamp(0,
                                                                    docs.length);
                                                        currentshowIndex += 1;
                                                      });

                                                      if (pages > 5) {
                                                        int pageIndexToScrollTo =
                                                            ((startIndex ~/ 4) -
                                                                    1) *
                                                                40;

                                                        _scrollController
                                                            .animateTo(
                                                          pageIndexToScrollTo
                                                              .toDouble(), // Assuming each box is 40.0 in width
                                                          duration: Duration(
                                                              milliseconds:
                                                                  500),
                                                          curve:
                                                              Curves.easeInOut,
                                                        );
                                                      }
                                                    }
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (state is DocumentError) {
                            return Center(child: Text(state.message));
                          } else {
                            return Center(child: Text('Unexpected state'));
                          }
                        }),
                      ],
                    ),
                    // AdvancedSearchBox(_isAdvanceSearchVisible),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.no_sim_sharp,
          size: 38,
        ),
        Text(
          'Unsupported file',
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
          textScaler: TextScaler.linear(1),
        ),
      ],
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
