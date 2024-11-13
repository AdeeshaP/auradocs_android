import 'dart:convert';
import 'package:auradocs_android/API-Services/api_service.dart';
import 'package:auradocs_android/Bloc/document_bloc.dart';
import 'package:auradocs_android/Bloc/document_event.dart';
import 'package:auradocs_android/Bloc/document_state.dart';
import 'package:auradocs_android/Models/users.dart';
import 'package:auradocs_android/screens/Document-Search/search_list.dart';
import 'package:auradocs_android/screens/Sign/sign_doc_viewer.dart';
import 'package:auradocs_android/screens/Sliders/landing_page.dart';
import 'package:auradocs_android/screens/contact_us_screen.dart';
import 'package:auradocs_android/screens/home_screen.dart';
import 'package:auradocs_android/utils/alert_dialogs.dart';
import 'package:auradocs_android/utils/constants.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignAvailableDocuments extends StatefulWidget {
  const SignAvailableDocuments({super.key});

  @override
  State<SignAvailableDocuments> createState() => _SignAvailableDocumentsState();
}

class _SignAvailableDocumentsState extends State<SignAvailableDocuments> {
  late SharedPreferences _storage;
  Map<String, dynamic>? userObj;
  String username = "";
  String token = "";
  TextEditingController searchController = TextEditingController();
  String compnyCode = "";
  int aproval_id = 0;
  String assigned_by = "";
  int doc_id = 0;
  int templateId = 0;
  List<dynamic> files = [];
  int startIndex = 0;
  int currentshowIndex = 1;
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
    super.dispose();
  }

  void okRecognition() {
    closeDialog(context);
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

    context.read<DocumentBloc>().add(FetchSignDocuments(username, token));
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
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(width: 10),
                                      Icon(FontAwesomeIcons.penToSquare,
                                          color: Colors.white,
                                          size: Responsive.isMobileSmall(
                                                      context) ||
                                                  Responsive.isMobileMedium(
                                                      context) ||
                                                  Responsive.isMobileLarge(
                                                      context)
                                              ? 20
                                              : 25),
                                      SizedBox(
                                          width: Responsive.isMobileSmall(
                                                      context) ||
                                                  Responsive.isMobileMedium(
                                                      context) ||
                                                  Responsive.isMobileLarge(
                                                      context)
                                              ? 8
                                              : 15),
                                      Text(
                                        "Sign Documents",
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
                                                      ? 24
                                                      : 25,
                                          fontWeight: FontWeight.bold,
                                        ),
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
                                    )),
                              ],
                            ),
                            color: Colors.amber[700],
                          ),
                        ),
                        Container(
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
                          child: BlocBuilder<DocumentBloc, DocumentState>(
                              builder: (context, state) {
                            if (state is DocumentLoading) {
                              return Column(
                                children: [
                                  SizedBox(height: size.height * 0.4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      CircularProgressIndicator(
                                          color: Colors.amber),
                                      SizedBox(
                                        width: Responsive.isMobileSmall(
                                                    context) ||
                                                Responsive.isMobileMedium(
                                                    context) ||
                                                Responsive.isMobileLarge(
                                                    context)
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
                                                        Responsive
                                                            .isMobileLarge(
                                                                context)
                                                    ? 18
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? 24
                                                        : 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              );
                            } else if (state is SignListLoaded ||
                                state is PartialSignListLoaded) {
                              final docs = state is SignListLoaded
                                  ? state.signDocs
                                  : (state as PartialSignListLoaded).signDocs;

                              final pages = state is SignListLoaded
                                  ? state.totalPages
                                  : (state as PartialSignListLoaded).totalPages;

                              if (docs == null || docs.isEmpty) {
                                return Column(
                                  children: [
                                    SizedBox(height: size.height * 0.3),
                                    Icon(
                                      FontAwesomeIcons.penToSquare,
                                      size: Responsive.isMobileSmall(
                                                  context) ||
                                              Responsive.isMobileMedium(
                                                  context) ||
                                              Responsive.isMobileLarge(context)
                                          ? size.width * 0.24
                                          : Responsive.isTabletPortrait(
                                                  context)
                                              ? size.width * 0.2
                                              : size.width * 0.1,
                                      color: Colors.grey[300],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "No documents available to sign",
                                      style: TextStyle(
                                        fontSize: Responsive.isMobileSmall(
                                                    context) ||
                                                Responsive.isMobileMedium(
                                                    context) ||
                                                Responsive.isMobileLarge(
                                                    context)
                                            ? size.width * 0.05
                                            : Responsive.isTabletPortrait(
                                                    context)
                                                ? size.width * 0.04
                                                : size.width * 0.025,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return Container(
                                height: Responsive.isMobileSmall(context)
                                    ? size.width * 1.6
                                    : Responsive.isMobileMedium(context) ||
                                            Responsive.isMobileLarge(context)
                                        ? size.width * 1.65
                                        : Responsive.isTabletPortrait(context)
                                            ? size.height * 0.86
                                            : size.height * 0.86,
                                child: Stack(
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.all(10),
                                      itemCount: (docs.length - startIndex)
                                          .clamp(0, 7),
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final item = docs[startIndex + index];

                                        aproval_id = item['aproval_id'];
                                        assigned_by = item['assigned_by'];
                                        doc_id = item['doc_id'];

                                        return Column(
                                          children: [
                                            SizedBox(height: 3),
                                            GestureDetector(
                                              onTap: () {
                                                if (docs.length > 0) {
                                                  files = docs;
                                                }

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SignDocViewScreen(
                                                      fileNames: files,
                                                      indexOfCurrent:
                                                          startIndex + index,
                                                      approvalId: aproval_id,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: 65,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black45,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Colors.grey[200],
                                                ),
                                                width: double.infinity,
                                                child: SingleChildScrollView(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 8,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8),
                                                              child: Text(
                                                                "$doc_id",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: Responsive.isMobileSmall(context) ||
                                                                          Responsive.isMobileMedium(
                                                                              context) ||
                                                                          Responsive.isMobileLarge(
                                                                              context)
                                                                      ? 15
                                                                      : Responsive.isTabletPortrait(
                                                                              context)
                                                                          ? 17
                                                                          : 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          8),
                                                              child: Text(
                                                                "Assigned By : $assigned_by",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: Responsive.isMobileSmall(context) ||
                                                                          Responsive.isMobileMedium(
                                                                              context) ||
                                                                          Responsive.isMobileLarge(
                                                                              context)
                                                                      ? 14
                                                                      : Responsive.isTabletPortrait(
                                                                              context)
                                                                          ? 15
                                                                          : 15,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 10),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            if (docs.length >
                                                                0) {
                                                              files = docs;
                                                            }

                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        SignDocViewScreen(
                                                                  fileNames:
                                                                      files,
                                                                  indexOfCurrent:
                                                                      startIndex +
                                                                          index,
                                                                  approvalId:
                                                                      aproval_id,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Icon(
                                                            FontAwesomeIcons
                                                                .penToSquare,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),
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
                                                              7)
                                                          .clamp(
                                                              0, docs.length);
                                                      currentshowIndex -= 1;
                                                    });

                                                    if (pages! > 5) {
                                                      int pageIndexToScrollTo =
                                                          ((startIndex ~/ 7) -
                                                                  1) *
                                                              40;

                                                      _scrollController
                                                          .animateTo(
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
                                              scrollDirection: Axis.horizontal,
                                              controller: _scrollController,
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
                                                          startIndex =
                                                              index * 7;
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
                                                                  .circular(10),
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
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            (index + 1)
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontSize: Responsive.isMobileSmall(context) ||
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
                                                                      : 25,
                                                              color: currentshowIndex ==
                                                                      index + 1
                                                                  ? Colors
                                                                      .white // Highlighted box text color
                                                                  : Colors
                                                                      .black87,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            textAlign: TextAlign
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
                                            onPressed: (startIndex + 7) <
                                                    docs.length
                                                ? () {
                                                    setState(() {
                                                      startIndex = (startIndex +
                                                              7)
                                                          .clamp(
                                                              0, docs.length);
                                                      currentshowIndex += 1;
                                                    });
                                                    if (pages > 5) {
                                                      int pageIndexToScrollTo =
                                                          ((startIndex ~/ 7) -
                                                                  1) *
                                                              40;

                                                      _scrollController
                                                          .animateTo(
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
                                  ],
                                ),
                              );
                            } else if (state is DocumentError) {
                              return Center(child: Text(state.message));
                            } else {
                              return Center(child: Text('Unexpected state'));
                            }
                          }),
                        ),
                      ],
                    )
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
                                  fontSize: Responsive.isMobileSmall(
                                              context) ||
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
