import 'dart:convert';
import 'package:auradocs_android/Bloc/document_bloc.dart';
import 'package:auradocs_android/Bloc/document_event.dart';
import 'package:auradocs_android/Bloc/document_state.dart';
import 'package:auradocs_android/Models/users.dart';
import 'package:auradocs_android/screens/Document-Search/search_list.dart';
import 'package:auradocs_android/screens/History/view_history.dart';
import 'package:auradocs_android/screens/Sliders/landing_page.dart';
import 'package:auradocs_android/screens/contact_us_screen.dart';
import 'package:auradocs_android/screens/home_screen.dart';
import 'package:auradocs_android/utils/alert_dialogs.dart';
import 'package:auradocs_android/utils/constants.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API-Services/api_service.dart';

class HistoryTables extends StatefulWidget {
  const HistoryTables({super.key});

  @override
  State<HistoryTables> createState() => _HistoryTablesState();
}

class _HistoryTablesState extends State<HistoryTables> {
  late SharedPreferences _storage;
  Map<String, dynamic>? userObj;
  String username = "";
  String token = "";
  TextEditingController searchController = TextEditingController();
  String compnyCode = "";
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

    print("Authentication2: $authentication");

    await getBlocData();
  }

  Future<void> getBlocData() async {
    context.read<DocumentBloc>().add(FetchAccountHistory(username, token));
    context.read<DocumentBloc>().add(FetchIndexHistory(username, token));
    context.read<DocumentBloc>().add(FetchToDoHistory(username, token));
    context.read<DocumentBloc>().add(FetchDownloadHistory(username, token));
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
              children: <Widget>[
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
                                      ? size.height * 0.85
                                      : size.height * 0.85,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                color: Colors.amber[700],
                                height: Responsive.isMobileSmall(context) ||
                                        Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? size.width * 0.1
                                    : Responsive.isTabletPortrait(context)
                                        ? size.width * 0.07
                                        : size.width * 0.05,
                                child: Row(
                                  children: [
                                    Wrap(
                                      children: [
                                        Icon(
                                          Icons.account_circle,
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
                                          "Account History",
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
                                    ),
                                    Spacer(),
                                    GestureDetector(
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
                                                ? 30
                                                : 25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            BlocBuilder<DocumentBloc, DocumentState>(
                              builder: (context, state1) {
                                if (state1 is DocumentLoading) {
                                  return Container(
                                    height: Responsive.isMobileSmall(context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 300
                                        : 350,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.height * 0.3),
                                      child: CircularProgressIndicator(
                                          color: Colors.amber),
                                    ),
                                  );
                                } else if (state1 is HistoryLoaded ||
                                    state1 is PartialHistoryLoaded) {
                                  final accountHistory = state1 is HistoryLoaded
                                      ? state1.accountHistory
                                      : (state1 as PartialHistoryLoaded)
                                          .accountHistory;

                                  if (accountHistory == null) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Container(
                                        height:
                                            Responsive.isMobileSmall(context) ||
                                                    Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 200
                                                : 220,
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.account_circle_outlined,
                                              size: Responsive.isMobileSmall(
                                                          context) ||
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
                                            SizedBox(height: 20),
                                            Text(
                                              "No Account History",
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
                                                    ? size.width * 0.05
                                                    : Responsive
                                                            .isTabletPortrait(
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
                                  return Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    height: Responsive.isMobileSmall(context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 300
                                        : 350,
                                    width: size.width,
                                    child: DataTable(
                                        columnSpacing: Responsive.isMobileSmall(
                                                    context) ||
                                                Responsive.isMobileMedium(
                                                    context) ||
                                                Responsive.isMobileLarge(
                                                    context)
                                            ? size.width * 0.036
                                            : Responsive.isTabletLandscape(
                                                        context) ||
                                                    Responsive.isTabletPortrait(
                                                        context)
                                                ? size.width * .06
                                                : size.width * 0.04,
                                        showBottomBorder: true,
                                        dividerThickness: 2,
                                        headingRowColor:
                                            WidgetStateProperty.all(
                                                Colors.grey[300]),
                                        dataRowColor: WidgetStateProperty.all(
                                            Colors.white),
                                        columns: [
                                          DataColumn(
                                              label: Text(
                                            'Document',
                                            style: TextStyle(
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
                                                  ? 12.7
                                                  : Responsive.isMobileMedium(
                                                              context) ||
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 13
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? 15
                                                          : 20,
                                            ),
                                            textScaler: TextScaler.linear(1),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Template',
                                            style: TextStyle(
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
                                                  ? 12.7
                                                  : Responsive.isMobileMedium(
                                                              context) ||
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 13
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? 15
                                                          : 20,
                                            ),
                                            textScaler: TextScaler.linear(1),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Operation',
                                            style: TextStyle(
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
                                                  ? 12.7
                                                  : Responsive.isMobileMedium(
                                                              context) ||
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 13
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? 15
                                                          : 20,
                                            ),
                                            textScaler: TextScaler.linear(1),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            '  Time',
                                            style: TextStyle(
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
                                                  ? 12.7
                                                  : Responsive.isMobileMedium(
                                                              context) ||
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 13
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? 15
                                                          : 20,
                                            ),
                                            textScaler: TextScaler.linear(1),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'View',
                                            style: TextStyle(
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
                                                  ? 12.7
                                                  : Responsive.isMobileMedium(
                                                              context) ||
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 13
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? 15
                                                          : 20,
                                            ),
                                            textScaler: TextScaler.linear(1),
                                          )),
                                        ],
                                        rows: accountHistory
                                            .map(
                                              (data) => DataRow(
                                                cells: [
                                                  //---------  Data Cell for Document Name ------------
                                                  DataCell(
                                                    Responsive.isMobileSmall(
                                                                context) ||
                                                            Responsive
                                                                .isMobileMedium(
                                                                    context) ||
                                                            Responsive
                                                                .isMobileLarge(
                                                                    context)
                                                        ? Tooltip(
                                                            message:
                                                                data['docName']
                                                                    .toString(),
                                                            triggerMode:
                                                                TooltipTriggerMode
                                                                    .tap,
                                                            showDuration:
                                                                Duration(
                                                                    seconds: 2),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5),
                                                            height: 35,
                                                            textStyle: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .amber),
                                                            child: Text(
                                                              data['docName']
                                                                          .toString()
                                                                          .length >
                                                                      6
                                                                  ? '${data['docName'].toString().substring(0, 6)}...'
                                                                  : data['docName']
                                                                      .toString(),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.6),
                                                              textScaler:
                                                                  TextScaler
                                                                      .linear(
                                                                          1),
                                                            ),
                                                          )
                                                        : Responsive
                                                                .isTabletPortrait(
                                                                    context)
                                                            ? Tooltip(
                                                                message: data[
                                                                        'docName']
                                                                    .toString(),
                                                                triggerMode:
                                                                    TooltipTriggerMode
                                                                        .tap,
                                                                waitDuration:
                                                                    Duration(),
                                                                showDuration:
                                                                    Duration(
                                                                        seconds:
                                                                            2),
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                height: 35,
                                                                textStyle: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .amber),
                                                                child: Text(
                                                                  data['docName']
                                                                              .toString()
                                                                              .length >
                                                                          12
                                                                      ? '${data['docName'].toString().substring(0, 12)}...'
                                                                      : data['docName']
                                                                          .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15),
                                                                  textScaler:
                                                                      TextScaler
                                                                          .linear(
                                                                              1),
                                                                ),
                                                              )
                                                            : Tooltip(
                                                                message: data[
                                                                        'docName']
                                                                    .toString(),
                                                                triggerMode:
                                                                    TooltipTriggerMode
                                                                        .tap,
                                                                waitDuration:
                                                                    Duration(),
                                                                showDuration:
                                                                    Duration(
                                                                        seconds:
                                                                            2),
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                height: 35,
                                                                textStyle: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .amber),
                                                                child: Text(
                                                                  data['docName']
                                                                              .toString()
                                                                              .length >
                                                                          20
                                                                      ? '${data['docName'].toString().substring(0, 20)}...'
                                                                      : data['docName']
                                                                          .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          17),
                                                                  textScaler:
                                                                      TextScaler
                                                                          .linear(
                                                                              1),
                                                                ),
                                                              ),
                                                  ),
                                                  //--------------  Data Cell for Template Name----------------
                                                  DataCell(
                                                    Tooltip(
                                                      message:
                                                          data['templateName']
                                                              .toString(),
                                                      triggerMode:
                                                          TooltipTriggerMode
                                                              .tap,
                                                      showDuration:
                                                          Duration(seconds: 2),
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      height: 35,
                                                      textStyle: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                      decoration: BoxDecoration(
                                                          color: Colors.amber),
                                                      child: Text(
                                                        data['templateName']
                                                                    .toString() ==
                                                                ""
                                                            ? "-"
                                                            : data['templateName']
                                                                        .toString()
                                                                        .length >
                                                                    6
                                                                ? '${data['templateName'].toString().substring(0, 6)}...'
                                                                : data[
                                                                    'templateName'],
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
                                                                  ? 12.6
                                                                  : Responsive.isTabletPortrait(
                                                                          context)
                                                                      ? 16
                                                                      : 18,
                                                        ),
                                                        textScaler:
                                                            TextScaler.linear(
                                                                1),
                                                      ),
                                                    ),
                                                  ),
                                                  //-----------  Data Cell for Operation --------------
                                                  DataCell(
                                                    Tooltip(
                                                      message: data["operation"]
                                                          .toString(),
                                                      triggerMode:
                                                          TooltipTriggerMode
                                                              .tap,
                                                      showDuration:
                                                          Duration(seconds: 2),
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      height: 35,
                                                      textStyle: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                      decoration: BoxDecoration(
                                                          color: Colors.amber),
                                                      child: Container(
                                                        child: Center(
                                                          child: Icon(
                                                            data['operation'] ==
                                                                        "VIEW" ||
                                                                    data['operation'] ==
                                                                        "View"
                                                                ? FontAwesomeIcons
                                                                    .eye
                                                                : data['operation'] ==
                                                                        "Index Data"
                                                                    ? FontAwesomeIcons
                                                                        .fileArrowUp
                                                                    : data['operation'] ==
                                                                            "ADD TO FAVORITE"
                                                                        ? FontAwesomeIcons
                                                                            .star
                                                                        : (data['operation']).contains("SHARE INTERNAL")
                                                                            ? FontAwesomeIcons.share
                                                                            : data['operation'] == "ADD SIGN"
                                                                                ? Icons.edit
                                                                                : Icons.phone_iphone_sharp,
                                                            size: 22,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    74,
                                                                    170,
                                                                    78),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // ----------- Data Cell for Access Time ------------
                                                  DataCell(
                                                    Tooltip(
                                                      message: Jiffy(DateTime
                                                              .parse(data[
                                                                  'accessTime']))
                                                          .format(
                                                              "MMMM d, yyyy hh:mm:ss a"),
                                                      triggerMode:
                                                          TooltipTriggerMode
                                                              .tap,
                                                      waitDuration: Duration(),
                                                      showDuration:
                                                          Duration(seconds: 2),
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      height: 35,
                                                      textStyle: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                      decoration: BoxDecoration(
                                                          color: Colors.amber),
                                                      child: Text(
                                                        Jiffy(DateTime.parse(data[
                                                                'accessTime']))
                                                            .format("MM/dd/yy"),
                                                        style: TextStyle(
                                                            fontSize: Responsive
                                                                    .isMobileSmall(
                                                                        context)
                                                                ? 12
                                                                : Responsive.isMobileMedium(
                                                                            context) ||
                                                                        Responsive.isMobileLarge(
                                                                            context)
                                                                    ? 12
                                                                    : Responsive.isTabletPortrait(
                                                                            context)
                                                                        ? 15
                                                                        : 16),
                                                        textScaler:
                                                            TextScaler.linear(
                                                                1),
                                                      ),
                                                    ),
                                                  ),
                                                  //-----------  Data Cell for View Icon --------------
                                                  DataCell(
                                                    GestureDetector(
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.visibility,
                                                          size: 15,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        List<String> docIds =
                                                            accountHistory
                                                                .map((item) => item[
                                                                        'fileId']
                                                                    .toString())
                                                                .toList();
                                                        int index =
                                                            accountHistory
                                                                .indexOf(data);
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                AccountIndexDownloadHistoryFileViewer(
                                                              docIds: docIds,
                                                              initialIndex:
                                                                  index,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                            .toList()),
                                  );
                                } else if (state1 is DocumentError) {
                                  return Center(child: Text(state1.message));
                                } else {
                                  return Center(
                                      child: Text('Unexpected state'));
                                }
                              },
                            ),
                            SizedBox(
                                height: Responsive.isMobileSmall(context) ||
                                        Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? 20
                                    : Responsive.isTabletLandscape(context) ||
                                            Responsive.isTabletPortrait(context)
                                        ? 0
                                        : 20),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8),
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
                                    Wrap(
                                      children: [
                                        Icon(
                                          Icons.assignment,
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
                                          "Index History",
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
                                    ),
                                    Spacer(),
                                    GestureDetector(
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
                                                ? 30
                                                : 25,
                                      ),
                                    ),
                                  ],
                                ),
                                color: Colors.amber[700],
                              ),
                            ),
                            SizedBox(height: 10),
                            BlocBuilder<DocumentBloc, DocumentState>(
                              builder: (context, state) {
                                if (state is DocumentLoading) {
                                  return Container(
                                    height: Responsive.isMobileSmall(context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 300
                                        : 350,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.height * 0.3),
                                      child: CircularProgressIndicator(
                                          color: Colors.amber),
                                    ),
                                  );
                                } else if (state is HistoryLoaded ||
                                    state is PartialHistoryLoaded) {
                                  final indexHistory = state is HistoryLoaded
                                      ? state.indexHistory
                                      : (state as PartialHistoryLoaded)
                                          .indexHistory;

                                  if (indexHistory == null) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Container(
                                        height:
                                            Responsive.isMobileSmall(context) ||
                                                    Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 200
                                                : 220,
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.edit_document,
                                              size: Responsive.isMobileSmall(
                                                          context) ||
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
                                              "No Indexed Documents",
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
                                                    ? size.width * 0.05
                                                    : Responsive
                                                            .isTabletPortrait(
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
                                  return Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      height: Responsive.isMobileSmall(
                                                  context) ||
                                              Responsive.isMobileMedium(
                                                  context) ||
                                              Responsive.isMobileLarge(context)
                                          ? 300
                                          : 350,
                                      width: size.width,
                                      child: DataTable(
                                        columnSpacing: Responsive.isMobileSmall(
                                                    context) ||
                                                Responsive.isMobileMedium(
                                                    context) ||
                                                Responsive.isMobileLarge(
                                                    context)
                                            ? size.width * 0.036
                                            : Responsive.isTabletLandscape(
                                                        context) ||
                                                    Responsive.isTabletPortrait(
                                                        context)
                                                ? size.width * .06
                                                : size.width * 0.035,
                                        showBottomBorder: true,
                                        dividerThickness: 2,
                                        headingRowColor:
                                            WidgetStateProperty.all(
                                                Colors.grey[300]),
                                        dataRowColor: WidgetStateProperty.all(
                                            Colors.white),
                                        columns: [
                                          DataColumn(
                                              label: Text(
                                            'Document',
                                            style: TextStyle(
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
                                                  ? 12.7
                                                  : Responsive.isMobileMedium(
                                                              context) ||
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 13
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? 15
                                                          : 20,
                                            ),
                                            textScaler: TextScaler.linear(1),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Template',
                                            style: TextStyle(
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
                                                  ? 12.7
                                                  : Responsive.isMobileMedium(
                                                              context) ||
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 13
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? 15
                                                          : 20,
                                            ),
                                            textScaler: TextScaler.linear(1),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Operation',
                                            style: TextStyle(
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
                                                  ? 12.7
                                                  : Responsive.isMobileMedium(
                                                              context) ||
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 13
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? 15
                                                          : 20,
                                            ),
                                            textScaler: TextScaler.linear(1),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            ' Time',
                                            style: TextStyle(
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
                                                  ? 12.7
                                                  : Responsive.isMobileMedium(
                                                              context) ||
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 13
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? 15
                                                          : 20,
                                            ),
                                            textScaler: TextScaler.linear(1),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'View',
                                            style: TextStyle(
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
                                                  ? 12.7
                                                  : Responsive.isMobileMedium(
                                                              context) ||
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 13
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? 15
                                                          : 20,
                                            ),
                                            textScaler: TextScaler.linear(1),
                                          )),
                                        ],
                                        rows: indexHistory
                                            .map((data) => DataRow(
                                                  cells: [
                                                    // ----------- Data Cell for Doc Name -----------
                                                    DataCell(
                                                      Responsive.isMobileSmall(
                                                                  context) ||
                                                              Responsive
                                                                  .isMobileMedium(
                                                                      context) ||
                                                              Responsive
                                                                  .isMobileLarge(
                                                                      context)
                                                          ? Tooltip(
                                                              message: data[
                                                                      'docName']
                                                                  .toString(),
                                                              triggerMode:
                                                                  TooltipTriggerMode
                                                                      .tap,
                                                              showDuration:
                                                                  Duration(
                                                                      seconds:
                                                                          2),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5),
                                                              height: 35,
                                                              textStyle: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal),
                                                              decoration:
                                                                  BoxDecoration(
                                                                      color: Colors
                                                                          .amber),
                                                              child: Text(
                                                                data['docName']
                                                                            .toString()
                                                                            .length >
                                                                        6
                                                                    ? '${data['docName'].toString().substring(0, 6)}...'
                                                                    : data['docName']
                                                                        .toString(),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12.6),
                                                                textScaler:
                                                                    TextScaler
                                                                        .linear(
                                                                            1),
                                                              ),
                                                            )
                                                          : Responsive
                                                                  .isTabletPortrait(
                                                                      context)
                                                              ? Tooltip(
                                                                  message: data[
                                                                          'docName']
                                                                      .toString(),
                                                                  triggerMode:
                                                                      TooltipTriggerMode
                                                                          .tap,
                                                                  showDuration:
                                                                      Duration(
                                                                          seconds:
                                                                              2),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5),
                                                                  height: 35,
                                                                  textStyle: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          color:
                                                                              Colors.amber),
                                                                  child: Text(
                                                                    data['docName'].toString().length >
                                                                            12
                                                                        ? '${data['docName'].toString().substring(0, 12)}...'
                                                                        : data['docName']
                                                                            .toString(),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15),
                                                                    textScaler:
                                                                        TextScaler
                                                                            .linear(1),
                                                                  ),
                                                                )
                                                              : Tooltip(
                                                                  message: data[
                                                                          'docName']
                                                                      .toString(),
                                                                  showDuration:
                                                                      Duration(
                                                                          seconds:
                                                                              2),
                                                                  triggerMode:
                                                                      TooltipTriggerMode
                                                                          .tap,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5),
                                                                  height: 35,
                                                                  textStyle: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          color:
                                                                              Colors.amber),
                                                                  child: Text(
                                                                    data['docName'].toString().length >
                                                                            20
                                                                        ? '${data['docName'].toString().substring(0, 20)}...'
                                                                        : data['docName']
                                                                            .toString(),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17),
                                                                    textScaler:
                                                                        TextScaler
                                                                            .linear(1),
                                                                  ),
                                                                ),
                                                    ),
                                                    // ----------- Data Cell for Template Name -----------
                                                    DataCell(
                                                      Tooltip(
                                                        message:
                                                            data['templateName']
                                                                .toString(),
                                                        showDuration: Duration(
                                                            seconds: 2),
                                                        triggerMode:
                                                            TooltipTriggerMode
                                                                .tap,
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        height: 35,
                                                        textStyle: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Colors
                                                                    .amber),
                                                        child: Text(
                                                          data['templateName']
                                                                      .toString()
                                                                      .length >
                                                                  6
                                                              ? '${data['templateName'].toString().substring(0, 6)}...'
                                                              : data[
                                                                  'templateName'],
                                                          style: TextStyle(
                                                            fontSize: Responsive
                                                                    .isMobileSmall(
                                                                        context)
                                                                ? 12
                                                                : Responsive.isMobileMedium(
                                                                            context) ||
                                                                        Responsive.isMobileLarge(
                                                                            context)
                                                                    ? 12.6
                                                                    : Responsive.isTabletPortrait(
                                                                            context)
                                                                        ? 16
                                                                        : 18,
                                                          ),
                                                          textScaler:
                                                              TextScaler.linear(
                                                                  1),
                                                        ),
                                                      ),
                                                    ),
                                                    // ----------- Data Cell for Operation-----------
                                                    DataCell(
                                                      Tooltip(
                                                        message:
                                                            data['operation']
                                                                .toString(),
                                                        showDuration: Duration(
                                                            seconds: 2),
                                                        triggerMode:
                                                            TooltipTriggerMode
                                                                .tap,
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        height: 35,
                                                        textStyle: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Colors
                                                                    .amber),
                                                        child: Container(
                                                          child: Center(
                                                            child: Icon(
                                                              data['operation'] ==
                                                                      "Index Data"
                                                                  ? FontAwesomeIcons
                                                                      .fileArrowUp
                                                                  : FontAwesomeIcons
                                                                      .fileArrowUp,
                                                              color: Colors
                                                                  .blue[400],
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    // ----------- Data Cell for Access Time -----------
                                                    DataCell(
                                                      Tooltip(
                                                        message: Jiffy(DateTime
                                                                .parse(data[
                                                                    'accessTime']))
                                                            .format(
                                                                "MMMM d, yyyy hh:mm:ss a"),
                                                        showDuration: Duration(
                                                            seconds: 2),
                                                        triggerMode:
                                                            TooltipTriggerMode
                                                                .tap,
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        height: 35,
                                                        textStyle: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Colors
                                                                    .amber),
                                                        child: Text(
                                                          Jiffy(DateTime.parse(data[
                                                                  'accessTime']))
                                                              .format(
                                                                  "MM/dd/yy"),
                                                          style: TextStyle(
                                                              fontSize: Responsive
                                                                      .isMobileSmall(
                                                                          context)
                                                                  ? 12
                                                                  : Responsive.isMobileMedium(
                                                                              context) ||
                                                                          Responsive.isMobileLarge(
                                                                              context)
                                                                      ? 12
                                                                      : Responsive.isTabletPortrait(
                                                                              context)
                                                                          ? 16
                                                                          : 18),
                                                          textScaler:
                                                              TextScaler.linear(
                                                                  1),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      GestureDetector(
                                                        child: Center(
                                                          child: Icon(
                                                            Icons.visibility,
                                                            size: 15,
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          List<String> docIds =
                                                              indexHistory
                                                                  .map((item) =>
                                                                      item['fileId']
                                                                          .toString())
                                                                  .toList();
                                                          int index =
                                                              indexHistory
                                                                  .indexOf(
                                                                      data);
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  AccountIndexDownloadHistoryFileViewer(
                                                                docIds: docIds,
                                                                initialIndex:
                                                                    index,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ))
                                            .toList(),
                                      ));
                                } else if (state is DocumentError) {
                                  return Center(child: Text(state.message));
                                } else {
                                  return Center(
                                      child: Text('Unexpected state'));
                                }
                              },
                            ),
                            SizedBox(
                                height: Responsive.isMobileSmall(context) ||
                                        Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? 20
                                    : Responsive.isTabletLandscape(context) ||
                                            Responsive.isTabletPortrait(context)
                                        ? 0
                                        : 20),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8),
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
                                    Wrap(
                                      children: [
                                        Icon(
                                          Icons.task_alt,
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
                                          "To-Do History",
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
                                    ),
                                    Spacer(),
                                    GestureDetector(
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
                                                ? 30
                                                : 25,
                                      ),
                                    ),
                                  ],
                                ),
                                color: Colors.amber[700],
                              ),
                            ),
                            SizedBox(height: 10),
                            BlocBuilder<DocumentBloc, DocumentState>(
                                builder: (context, state) {
                              if (state is DocumentLoading) {
                                return Container(
                                  height: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 300
                                      : 350,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.height * 0.3),
                                    child: CircularProgressIndicator(
                                        color: Colors.amber),
                                  ),
                                );
                              } else if (state is HistoryLoaded ||
                                  state is PartialHistoryLoaded) {
                                final todoHistory = state is HistoryLoaded
                                    ? state.todoHistory
                                    : (state as PartialHistoryLoaded)
                                        .todoHistory;
                                if (todoHistory == null) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Container(
                                      height: Responsive.isMobileSmall(
                                                  context) ||
                                              Responsive.isMobileMedium(
                                                  context) ||
                                              Responsive.isMobileLarge(context)
                                          ? 200
                                          : 220,
                                      width: double.infinity,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.account_circle_outlined,
                                            size: Responsive.isMobileSmall(
                                                        context) ||
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
                                          SizedBox(height: 20),
                                          Text(
                                            "No To-Do History",
                                            style: TextStyle(
                                              fontSize: Responsive
                                                          .isMobileSmall(
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

                                return Container(
                                    height: Responsive.isMobileSmall(context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 300
                                        : 350,
                                    width: size.width,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: DataTable(
                                        columnSpacing: Responsive.isMobileSmall(
                                                    context) ||
                                                Responsive.isMobileMedium(
                                                    context) ||
                                                Responsive.isMobileLarge(
                                                    context)
                                            ? size.width * 0.036
                                            : Responsive.isTabletLandscape(
                                                        context) ||
                                                    Responsive.isTabletPortrait(
                                                        context)
                                                ? size.width * .05
                                                : size.width * 0.04,
                                        showBottomBorder: true,
                                        dividerThickness: 2,
                                        headingRowColor:
                                            WidgetStateProperty.all(
                                                Colors.grey[300]),
                                        dataRowColor: WidgetStateProperty.all(
                                            Colors.white),
                                        columns: [
                                          DataColumn(
                                              label: Text(
                                            'Document',
                                            style: TextStyle(
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
                                                  ? 12.7
                                                  : Responsive.isMobileMedium(
                                                              context) ||
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 13
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? 15
                                                          : 20,
                                            ),
                                            textScaler: TextScaler.linear(1),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Request \nDate',
                                            style: TextStyle(
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
                                                  ? 12.7
                                                  : Responsive.isMobileMedium(
                                                              context) ||
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 13
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? 15
                                                          : 20,
                                            ),
                                            textScaler: TextScaler.linear(1),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Status',
                                            style: TextStyle(
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
                                                  ? 12.7
                                                  : Responsive.isMobileMedium(
                                                              context) ||
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 13
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? 15
                                                          : 20,
                                            ),
                                            textScaler: TextScaler.linear(1),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Request \nBy',
                                            style: TextStyle(
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
                                                  ? 12.7
                                                  : Responsive.isMobileMedium(
                                                              context) ||
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 13
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? 15
                                                          : 20,
                                            ),
                                            textScaler: TextScaler.linear(1),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'View',
                                            style: TextStyle(
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
                                                  ? 13
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
                                                          : 19,
                                            ),
                                            textScaler: TextScaler.linear(1),
                                          )),
                                        ],
                                        rows: todoHistory
                                            .map(
                                              (data) => DataRow(
                                                cells: [
                                                  DataCell(
                                                    Responsive.isMobileSmall(
                                                                context) ||
                                                            Responsive
                                                                .isMobileMedium(
                                                                    context) ||
                                                            Responsive
                                                                .isMobileLarge(
                                                                    context)
                                                        ? Tooltip(
                                                            message:
                                                                data["docName"]
                                                                    .toString(),
                                                            showDuration:
                                                                Duration(
                                                                    seconds: 2),
                                                            triggerMode:
                                                                TooltipTriggerMode
                                                                    .tap,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5),
                                                            height: 35,
                                                            textStyle: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .amber),
                                                            child: Text(
                                                              data['docName']
                                                                          .toString()
                                                                          .length >
                                                                      7
                                                                  ? '${data['docName'].toString().substring(0, 7)}...'
                                                                  : data['docName']
                                                                      .toString(),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.6),
                                                              textScaler:
                                                                  TextScaler
                                                                      .linear(
                                                                          1),
                                                            ),
                                                          )
                                                        : Responsive
                                                                .isTabletPortrait(
                                                                    context)
                                                            ? Tooltip(
                                                                message: data[
                                                                        "docName"]
                                                                    .toString(),
                                                                showDuration:
                                                                    Duration(
                                                                        seconds:
                                                                            2),
                                                                triggerMode:
                                                                    TooltipTriggerMode
                                                                        .tap,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                height: 35,
                                                                textStyle: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .amber),
                                                                child: Text(
                                                                  data['docName']
                                                                              .toString()
                                                                              .length >
                                                                          12
                                                                      ? '${data['docName'].toString().substring(0, 12)}...'
                                                                      : data['docName']
                                                                          .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15),
                                                                  textScaler:
                                                                      TextScaler
                                                                          .linear(
                                                                              1),
                                                                ),
                                                              )
                                                            : Tooltip(
                                                                message: data[
                                                                        "docName"]
                                                                    .toString(),
                                                                showDuration:
                                                                    Duration(
                                                                        seconds:
                                                                            2),
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                triggerMode:
                                                                    TooltipTriggerMode
                                                                        .tap,
                                                                height: 35,
                                                                textStyle: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .amber),
                                                                child: Text(
                                                                  data['docName']
                                                                              .toString()
                                                                              .length >
                                                                          20
                                                                      ? '${data['docName'].toString().substring(0, 20)}...'
                                                                      : data['docName']
                                                                          .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                  ),
                                                                  textScaler:
                                                                      TextScaler
                                                                          .linear(
                                                                              1),
                                                                ),
                                                              ),
                                                  ),
                                                  // ------------- Data Cell for Request Date --------------
                                                  DataCell(
                                                    Tooltip(
                                                      message: Jiffy(DateTime
                                                              .parse(data[
                                                                  'requestDate']))
                                                          .format(
                                                              "MMMM d, yyyy hh:mm:ss a"),
                                                      showDuration:
                                                          Duration(seconds: 2),
                                                      triggerMode:
                                                          TooltipTriggerMode
                                                              .tap,
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      height: 35,
                                                      textStyle: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                      decoration: BoxDecoration(
                                                          color: Colors.amber),
                                                      child: Text(
                                                        Jiffy(DateTime.parse(data[
                                                                'requestDate']))
                                                            .format("MM/dd/yy"),
                                                        style: TextStyle(
                                                            fontSize: Responsive
                                                                    .isMobileSmall(
                                                                        context)
                                                                ? 12
                                                                : Responsive.isMobileMedium(
                                                                            context) ||
                                                                        Responsive.isMobileLarge(
                                                                            context)
                                                                    ? 12
                                                                    : Responsive.isTabletPortrait(
                                                                            context)
                                                                        ? 15
                                                                        : 16),
                                                        textScaler:
                                                            TextScaler.linear(
                                                                1),
                                                      ),
                                                    ),
                                                  ),
                                                  // -------------Data Cell for Status ----------
                                                  DataCell(
                                                    Tooltip(
                                                      message: data['status']
                                                          .toString(),
                                                      showDuration:
                                                          Duration(seconds: 2),
                                                      triggerMode:
                                                          TooltipTriggerMode
                                                              .tap,
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      height: 35,
                                                      textStyle: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                      decoration: BoxDecoration(
                                                          color: Colors.amber),
                                                      child: Container(
                                                        child: Center(
                                                          child: Icon(
                                                            data['status'] ==
                                                                    "accepted"
                                                                ? Icons
                                                                    .check_box
                                                                : Icons.pending,
                                                            color:
                                                                data['status'] ==
                                                                        "accepted"
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .brown,
                                                            size: 22,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // --------------Data Cell for Access Time ---------------
                                                  DataCell(
                                                    Tooltip(
                                                      message:
                                                          data["requestUser"]
                                                              .toString(),
                                                      showDuration:
                                                          Duration(seconds: 2),
                                                      triggerMode:
                                                          TooltipTriggerMode
                                                              .tap,
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      height: 35,
                                                      textStyle: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                      decoration: BoxDecoration(
                                                          color: Colors.amber),
                                                      child: Text(
                                                        data['requestUser']
                                                                    .toString()
                                                                    .length >
                                                                8
                                                            ? '${data['requestUser'].toString().substring(0, 8)}...'
                                                            : data['requestUser']
                                                                .toString(),
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
                                                                  ? 12
                                                                  : Responsive.isTabletPortrait(
                                                                          context)
                                                                      ? 15
                                                                      : 16,
                                                        ),
                                                        textScaler:
                                                            TextScaler.linear(
                                                                1),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    GestureDetector(
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.visibility,
                                                          size: 15,
                                                        ),
                                                      ),
                                                      onTap: () {},
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ));
                              } else if (state is DocumentError) {
                                return Center(child: Text(state.message));
                              } else {
                                return Center(child: Text('Unexpected state'));
                              }
                            }),
                            SizedBox(
                                height: Responsive.isMobileSmall(context) ||
                                        Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? 20
                                    : Responsive.isTabletLandscape(context) ||
                                            Responsive.isTabletPortrait(context)
                                        ? 0
                                        : 20),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8),
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
                                      Wrap(
                                        children: [
                                          Icon(
                                            Icons.download,
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
                                            "Download History",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
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
                                      ),
                                      Spacer(),
                                      GestureDetector(
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
                                                      Responsive
                                                          .isTabletPortrait(
                                                              context)
                                                  ? 30
                                                  : 25,
                                        ),
                                      ),
                                    ]),
                                color: Colors.amber[700],
                              ),
                            ),
                            SizedBox(height: 10),
                            BlocBuilder<DocumentBloc, DocumentState>(
                                builder: (context, state) {
                              if (state is DocumentLoading) {
                                return Container(
                                  height: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 250
                                      : 300,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: CircularProgressIndicator(
                                        color: Colors.amber),
                                  ),
                                );
                              } else if (state is HistoryLoaded ||
                                  state is PartialHistoryLoaded) {
                                final downloadHistory = state is HistoryLoaded
                                    ? state.downloadHistory
                                    : (state as PartialHistoryLoaded)
                                        .downloadHistory;

                                if (downloadHistory == null) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Container(
                                      height: Responsive.isMobileSmall(
                                                  context) ||
                                              Responsive.isMobileMedium(
                                                  context) ||
                                              Responsive.isMobileLarge(context)
                                          ? 200
                                          : 220,
                                      width: double.infinity,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.file_download,
                                            size: Responsive.isMobileSmall(
                                                        context) ||
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
                                            "No Downloaded Documents",
                                            style: TextStyle(
                                              fontSize: Responsive
                                                          .isMobileSmall(
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

                                return Container(
                                  height: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 250
                                      : 300,
                                  width: size.width,
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: DataTable(
                                    columnSpacing: Responsive.isMobileSmall(
                                                context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? size.width * 0.036
                                        : Responsive.isTabletLandscape(
                                                    context) ||
                                                Responsive.isTabletPortrait(
                                                    context)
                                            ? size.width * .06
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.035,
                                    showBottomBorder: true,
                                    dividerThickness: 2,
                                    headingRowColor: WidgetStateProperty.all(
                                        Colors.grey[300]),
                                    dataRowColor:
                                        WidgetStateProperty.all(Colors.white),
                                    columns: [
                                      DataColumn(
                                        label: Text(
                                          'Document',
                                          style: TextStyle(
                                            fontSize: Responsive.isMobileSmall(
                                                    context)
                                                ? 12.7
                                                : Responsive.isMobileMedium(
                                                            context) ||
                                                        Responsive
                                                            .isMobileLarge(
                                                                context)
                                                    ? 13
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? 15
                                                        : 20,
                                          ),
                                          textScaler: TextScaler.linear(1),
                                        ),
                                      ),
                                      DataColumn(
                                          label: Text(
                                        'Template',
                                        style: TextStyle(
                                          fontSize: Responsive.isMobileSmall(
                                                  context)
                                              ? 12.7
                                              : Responsive.isMobileMedium(
                                                          context) ||
                                                      Responsive.isMobileLarge(
                                                          context)
                                                  ? 13
                                                  : Responsive.isTabletPortrait(
                                                          context)
                                                      ? 15
                                                      : 20,
                                        ),
                                        textScaler: TextScaler.linear(1),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        'Operation',
                                        style: TextStyle(
                                          fontSize: Responsive.isMobileSmall(
                                                  context)
                                              ? 12.7
                                              : Responsive.isMobileMedium(
                                                          context) ||
                                                      Responsive.isMobileLarge(
                                                          context)
                                                  ? 13
                                                  : Responsive.isTabletPortrait(
                                                          context)
                                                      ? 15
                                                      : 20,
                                        ),
                                        textScaler: TextScaler.linear(1),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        '  Time',
                                        style: TextStyle(
                                          fontSize: Responsive.isMobileSmall(
                                                  context)
                                              ? 12.7
                                              : Responsive.isMobileMedium(
                                                          context) ||
                                                      Responsive.isMobileLarge(
                                                          context)
                                                  ? 13
                                                  : Responsive.isTabletPortrait(
                                                          context)
                                                      ? 15
                                                      : 20,
                                        ),
                                        textScaler: TextScaler.linear(1),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        'View',
                                        style: TextStyle(
                                          fontSize: Responsive.isMobileSmall(
                                                  context)
                                              ? 13
                                              : Responsive.isMobileMedium(
                                                          context) ||
                                                      Responsive.isMobileLarge(
                                                          context)
                                                  ? 13
                                                  : Responsive.isTabletPortrait(
                                                          context)
                                                      ? 16
                                                      : 19,
                                        ),
                                        textScaler: TextScaler.linear(1),
                                      )),
                                    ],
                                    rows: downloadHistory
                                        .map(
                                          (data) => DataRow(
                                            cells: [
                                              DataCell(
                                                Responsive.isMobileSmall(
                                                            context) ||
                                                        Responsive
                                                            .isMobileMedium(
                                                                context) ||
                                                        Responsive
                                                            .isMobileLarge(
                                                                context)
                                                    ? Tooltip(
                                                        message: data["docName"]
                                                            .toString(),
                                                        showDuration: Duration(
                                                            seconds: 2),
                                                        triggerMode:
                                                            TooltipTriggerMode
                                                                .tap,
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        height: 35,
                                                        textStyle: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Colors
                                                                    .amber),
                                                        child: Text(
                                                          data['docName']
                                                                      .toString()
                                                                      .length >
                                                                  6
                                                              ? '${data['docName'].toString().substring(0, 6)}...'
                                                              : data['docName']
                                                                  .toString(),
                                                          style: TextStyle(
                                                              fontSize: 12.8),
                                                          textScaler:
                                                              TextScaler.linear(
                                                                  1),
                                                        ),
                                                      )
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? Tooltip(
                                                            message:
                                                                data["docName"]
                                                                    .toString(),
                                                            showDuration:
                                                                Duration(
                                                                    seconds: 2),
                                                            triggerMode:
                                                                TooltipTriggerMode
                                                                    .tap,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5),
                                                            height: 35,
                                                            textStyle: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .amber),
                                                            child: Text(
                                                              data['docName']
                                                                          .toString()
                                                                          .length >
                                                                      12
                                                                  ? '${data['docName'].toString().substring(0, 12)}...'
                                                                  : data['docName']
                                                                      .toString(),
                                                              style: TextStyle(
                                                                  fontSize: 16),
                                                              textScaler:
                                                                  TextScaler
                                                                      .linear(
                                                                          1),
                                                            ),
                                                          )
                                                        : Tooltip(
                                                            message:
                                                                data["docName"]
                                                                    .toString(),
                                                            showDuration:
                                                                Duration(
                                                                    seconds: 2),
                                                            triggerMode:
                                                                TooltipTriggerMode
                                                                    .tap,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5),
                                                            height: 35,
                                                            textStyle: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .amber),
                                                            child: Text(
                                                              data['docName']
                                                                          .toString()
                                                                          .length >
                                                                      20
                                                                  ? '${data['docName'].toString().substring(0, 20)}...'
                                                                  : data['docName']
                                                                      .toString(),
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                              ),
                                                              textScaler:
                                                                  TextScaler
                                                                      .linear(
                                                                          1),
                                                            ),
                                                          ),
                                              ),
                                              DataCell(
                                                Tooltip(
                                                  message: data['templateName']
                                                      .toString(),
                                                  showDuration:
                                                      Duration(seconds: 2),
                                                  triggerMode:
                                                      TooltipTriggerMode.tap,
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
                                                    data['templateName']
                                                                .toString()
                                                                .length >
                                                            6
                                                        ? '${data['templateName'].toString().substring(0, 6)}...'
                                                        : data['templateName'],
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
                                                              ? 12.6
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
                                                  message: data['operation']
                                                      .toString(),
                                                  showDuration:
                                                      Duration(seconds: 2),
                                                  padding: EdgeInsets.all(5),
                                                  triggerMode:
                                                      TooltipTriggerMode.tap,
                                                  height: 35,
                                                  textStyle: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                  decoration: BoxDecoration(
                                                      color: Colors.amber),
                                                  child: Container(
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.file_download,
                                                        color: Color.fromARGB(
                                                            255, 243, 97, 13),
                                                        size: 25,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Tooltip(
                                                  message: Jiffy(DateTime.parse(
                                                          data['accessTime']))
                                                      .format(
                                                          "MMMM d, yyyy hh:mm:ss a"),
                                                  showDuration:
                                                      Duration(seconds: 2),
                                                  triggerMode:
                                                      TooltipTriggerMode.tap,
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
                                                    Jiffy(DateTime.parse(
                                                      data['accessTime'],
                                                    )).format("MM/dd/yy"),
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
                                                                ? 12
                                                                : Responsive.isTabletPortrait(
                                                                        context)
                                                                    ? 15
                                                                    : 16),
                                                    textScaler:
                                                        TextScaler.linear(1),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.visibility,
                                                    size: 15,
                                                  ),
                                                  onPressed: () {
                                                    List<String> docIds =
                                                        downloadHistory
                                                            .map((item) =>
                                                                item['fileId']
                                                                    .toString())
                                                            .toList();
                                                    int index = downloadHistory
                                                        .indexOf(data);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            AccountIndexDownloadHistoryFileViewer(
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
                      ),
                      // AdvancedSearchBox(_isAdvanceSearchVisible),
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
