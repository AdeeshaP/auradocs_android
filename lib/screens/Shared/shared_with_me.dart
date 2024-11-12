import 'dart:convert';
import 'package:auradocs_android/Bloc/document_bloc.dart';
import 'package:auradocs_android/Bloc/document_event.dart';
import 'package:auradocs_android/Bloc/document_state.dart';
import 'package:auradocs_android/Models/users.dart';
import 'package:auradocs_android/screens/Shared/shared_docs_viewer.dart';
import 'package:auradocs_android/screens/Sliders/landing_page.dart';
import 'package:auradocs_android/screens/home_screen.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../API-Services/api_service.dart';
import '../../utils/alert_dialogs.dart';
import '../../utils/constants.dart';
import '../contact_us_screen.dart';

class SharedWithMe extends StatefulWidget {
  const SharedWithMe({super.key});

  @override
  State<SharedWithMe> createState() => _SharedWithMeState();
}

class _SharedWithMeState extends State<SharedWithMe> {
  late SharedPreferences _storage;
  Map<String, dynamic>? userObj;
  String username = "";
  String token = "";
  String compnyCode = "";
  TextEditingController searchController = TextEditingController();
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

  Future<void> getSharedPreferences() async {
    _storage = await SharedPreferences.getInstance();
    userObj = jsonDecode(_storage.getString('user_data')!);
    token = _storage.getString('token')!;
    username = userObj!["value"]["userName"];
    compnyCode = _storage.getString('code')!;
    String? authListJson = _storage.getString('authentication');
    authentication =
        authListJson != null ? List<String>.from(jsonDecode(authListJson)) : [];

    context.read<DocumentBloc>().add(FetchSharedWithMeDocs(username, token));
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
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background_three.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: <Widget>[
                getSearchBoxWidget(),
                Divider(height: 8),
                Stack(
                  children: <Widget>[
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                  flex: 10,
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.share,
                                        color: Colors.white,
                                        size:
                                            Responsive.isMobileSmall(context) ||
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
                                        width:
                                            Responsive.isMobileSmall(context) ||
                                                    Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 5
                                                : 10,
                                      ),
                                      Text(
                                        "Shared With Me",
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
                                      )
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
                                                Responsive.isMobileLarge(
                                                    context)
                                            ? 25
                                            : Responsive.isTabletLandscape(
                                                        context) ||
                                                    Responsive.isTabletPortrait(
                                                        context)
                                                ? 35
                                                : 25,
                                      ),
                                    )),
                              ],
                            ),
                            color: Colors.amber[700],
                          ),
                        ),
                        SizedBox(height: 10),
                        BlocBuilder<DocumentBloc, DocumentState>(
                            builder: (context, state) {
                          if (state is DocumentLoading) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.3),
                              child: CircularProgressIndicator(
                                  color: Colors.amber),
                            );
                          } else if (state is SharedDocumentLoaded ||
                              state is PartialSharedDocumentLoaded) {
                            final docs = state is SharedDocumentLoaded
                                ? state.sharedDocs
                                : (state as PartialSharedDocumentLoaded)
                                    .sharedDocs;

                            if (docs == null) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.25),
                                child: Container(
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.assignment,
                                        size:
                                            Responsive.isMobileSmall(context) ||
                                                    Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? size.width * 0.24
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? size.width * 0.2
                                                    : size.width * 0.15,
                                        color: Colors.grey[300],
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "No Shared Documents",
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
                                                  : size.width * 0.03,
                                          color: Colors.black54,
                                        ),
                                        textScaler: TextScaler.linear(1),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: Responsive.isMobileSmall(
                                              context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.036
                                      : Responsive.isTabletLandscape(context) ||
                                              Responsive.isTabletPortrait(
                                                  context)
                                          ? size.width * 0.08
                                          : MediaQuery.of(context).size.width *
                                              0.035,
                                  showBottomBorder: true,
                                  dividerThickness: 2,
                                  headingRowColor:
                                      WidgetStateProperty.all(Colors.grey[300]),
                                  dataRowColor:
                                      WidgetStateProperty.all(Colors.white),
                                  columns: [
                                    DataColumn(
                                        label: Text(
                                      'File ID',
                                      style: TextStyle(
                                        fontSize: Responsive.isMobileSmall(
                                                context)
                                            ? 13
                                            : Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 14
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 17
                                                    : 19,
                                      ),
                                      textScaler: TextScaler.linear(1),
                                    )),
                                    DataColumn(
                                        label: Text(
                                      '   Time',
                                      style: TextStyle(
                                        fontSize: Responsive.isMobileSmall(
                                                context)
                                            ? 13
                                            : Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 14
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 17
                                                    : 19,
                                      ),
                                      textScaler: TextScaler.linear(1),
                                    )),
                                    DataColumn(
                                        label: Text(
                                      '   From',
                                      style: TextStyle(
                                        fontSize: Responsive.isMobileSmall(
                                                context)
                                            ? 13
                                            : Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 14
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 17
                                                    : 19,
                                      ),
                                      textScaler: TextScaler.linear(1),
                                    )),
                                    DataColumn(
                                        label: Text(
                                      '   To',
                                      style: TextStyle(
                                        fontSize: Responsive.isMobileSmall(
                                                context)
                                            ? 13
                                            : Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 14
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 17
                                                    : 19,
                                      ),
                                      textScaler: TextScaler.linear(1),
                                    )),
                                    DataColumn(
                                        label: Text(
                                      '   View',
                                      style: TextStyle(
                                        fontSize: Responsive.isMobileSmall(
                                                context)
                                            ? 13
                                            : Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 14
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 17
                                                    : 19,
                                      ),
                                      textScaler: TextScaler.linear(1),
                                    )),
                                  ],
                                  rows: docs
                                      .map(
                                        (data) => DataRow(
                                          cells: [
                                            DataCell(
                                              Text(
                                                data['id'].toString(),
                                                style: TextStyle(
                                                  fontSize: Responsive
                                                          .isMobileSmall(
                                                              context)
                                                      ? 12
                                                      : Responsive.isMobileMedium(
                                                                  context) ||
                                                              Responsive
                                                                  .isMobileLarge(
                                                                      context)
                                                          ? 13
                                                          : Responsive
                                                                  .isTabletPortrait(
                                                                      context)
                                                              ? 16
                                                              : 18,
                                                ),
                                                textScaler:
                                                    TextScaler.linear(1),
                                              ),
                                            ),
                                            DataCell(
                                              Tooltip(
                                                message:
                                                    data['time'].toString(),
                                                triggerMode:
                                                    TooltipTriggerMode.tap,
                                                showDuration:
                                                    Duration(seconds: 2),
                                                padding: EdgeInsets.all(5),
                                                height: 35,
                                                textStyle: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.normal),
                                                decoration: BoxDecoration(
                                                    color: Colors.amber),
                                                child: Text(
                                                  DateFormat("dd/MM/yy").format(
                                                    DateFormat("MMM dd,yyyy")
                                                        .parse(data["time"]),
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: Responsive
                                                            .isMobileSmall(
                                                                context)
                                                        ? 12
                                                        : Responsive.isMobileMedium(
                                                                    context) ||
                                                                Responsive
                                                                    .isMobileLarge(
                                                                        context)
                                                            ? 13
                                                            : Responsive
                                                                    .isTabletPortrait(
                                                                        context)
                                                                ? 16
                                                                : 18,
                                                  ),
                                                  textScaler:
                                                      TextScaler.linear(1),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Tooltip(
                                                message:
                                                    data['from'].toString(),
                                                triggerMode:
                                                    TooltipTriggerMode.tap,
                                                showDuration:
                                                    Duration(seconds: 2),
                                                padding: EdgeInsets.all(5),
                                                height: 35,
                                                textStyle: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.normal),
                                                decoration: BoxDecoration(
                                                    color: Colors.amber),
                                                child: Text(
                                                  data['from']
                                                              .toString()
                                                              .length >
                                                          9
                                                      ? '${data['from'].toString().substring(0, 9)}...'
                                                      : data['from'],
                                                  style: TextStyle(
                                                    fontSize: Responsive
                                                            .isMobileSmall(
                                                                context)
                                                        ? 12
                                                        : Responsive.isMobileMedium(
                                                                    context) ||
                                                                Responsive
                                                                    .isMobileLarge(
                                                                        context)
                                                            ? 13
                                                            : Responsive
                                                                    .isTabletPortrait(
                                                                        context)
                                                                ? 16
                                                                : 18,
                                                  ),
                                                  textScaler:
                                                      TextScaler.linear(1),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Tooltip(
                                                message: data['to'].toString(),
                                                triggerMode:
                                                    TooltipTriggerMode.tap,
                                                showDuration:
                                                    Duration(seconds: 2),
                                                padding: EdgeInsets.all(5),
                                                height: 35,
                                                textStyle: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.normal),
                                                decoration: BoxDecoration(
                                                    color: Colors.amber),
                                                child: Text(
                                                  data['to'].toString().length >
                                                          6
                                                      ? '${data['to'].toString().substring(0, 6)}...'
                                                      : data['to'],
                                                  style: TextStyle(
                                                    fontSize: Responsive
                                                            .isMobileSmall(
                                                                context)
                                                        ? 12
                                                        : Responsive.isMobileMedium(
                                                                    context) ||
                                                                Responsive
                                                                    .isMobileLarge(
                                                                        context)
                                                            ? 13
                                                            : Responsive
                                                                    .isTabletPortrait(
                                                                        context)
                                                                ? 16
                                                                : 18,
                                                  ),
                                                  textScaler:
                                                      TextScaler.linear(1),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              GestureDetector(
                                                child: Center(
                                                  child: Icon(
                                                    Icons.visibility,
                                                    size: 18,
                                                  ),
                                                ),
                                                onTap: () {
                                                  List<String> docIds = docs
                                                      .map((item) =>
                                                          item['docid']
                                                              .toString())
                                                      .toList();
                                                  int index =
                                                      docs.indexOf(data);

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SharedDocsViewerScreen(
                                                        docIds: docIds,
                                                        initialIndex: index,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList(),
                                ));
                          } else if (state is DocumentError) {
                            return Center(child: Text(state.message));
                          } else {
                            return Center(child: Text('Unexpected state'));
                          }
                        }),
                      ],
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
