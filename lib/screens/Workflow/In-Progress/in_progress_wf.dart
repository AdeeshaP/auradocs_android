import 'dart:convert';
import 'package:auradocs_android/API-Services/api_service.dart';
import 'package:auradocs_android/Bloc/document_bloc.dart';
import 'package:auradocs_android/Models/users.dart';
import 'package:auradocs_android/screens/Document-Search/search_list.dart';
import 'package:auradocs_android/screens/Sliders/landing_page.dart';
import 'package:auradocs_android/screens/Workflow/In-Progress/view_inprogress_wf_task.dart';
import 'package:auradocs_android/screens/Workflow/workflow_dashboard.dart';
import 'package:auradocs_android/screens/contact_us_screen.dart';
import 'package:auradocs_android/screens/home_screen.dart';
import 'package:auradocs_android/utils/alert_dialogs.dart';
import 'package:auradocs_android/utils/constants.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InProgressScreen extends StatefulWidget {
  const InProgressScreen({super.key});

  @override
  State<InProgressScreen> createState() => _InProgressScreenState();
}

class _InProgressScreenState extends State<InProgressScreen> {
  late SharedPreferences _storage;
  Map<String, dynamic>? userObj;
  String username = "";
  String token = "";
  TextEditingController searchController = TextEditingController();
  String compnyCode = "";
  String trimmedValue = "";
  GlobalKey _toolTipKey = GlobalKey();
  List authentication = [];
  bool isLoading = true;
  bool haveData = false;
  List<dynamic> valueList = [];
  Map<String, dynamic>? responsedata;
  int _currentStartIndex = 0;

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

    print("Authentication2: $authentication");
    getInProgressWorkflows();
  }

  Future<void> getInProgressWorkflows() async {
    var response = await ApiService.getInProgressTasksForWF(username, token);

    if (response.statusCode == 200) {
      responsedata = jsonDecode(response.body);
      setState(() {
        valueList = responsedata?['value']['pendingTasksList'] ?? [];
        haveData = true;
        isLoading = false;
      });
    } else if (response.statusCode == 404) {
      setState(() {
        isLoading = false;
      });
    } else if (response.statusCode == 500) {
      showWarningDialogPopup(
        context,
        Icons.warning,
        "Server error! Please contact auraDOCS administrator.",
        okRecognition,
        Color.fromARGB(255, 237, 172, 10),
      );
    }
  }

  String formatDate(String dateString) {
    try {
      DateTime dateTime =
          DateFormat("MMMM dd, yyyy hh:mm:ss a").parse(dateString);
      return DateFormat("MM/dd/yyyy").format(dateTime); // Short format
    } catch (e) {
      return dateString; // Return original if parsing fails
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
          MaterialPageRoute(builder: (context) => WorkflowDashboard()),
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
                                    Icon(Icons.spoke_rounded,
                                        color: Colors.white,
                                        size: Responsive.isMobileSmall(
                                                    context) ||
                                                Responsive.isMobileMedium(
                                                    context) ||
                                                Responsive.isMobileLarge(
                                                    context)
                                            ? 25
                                            : 28),
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
                                      "In Progress",
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
                                        builder: (context) =>
                                            WorkflowDashboard(),
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
                          color: const Color.fromARGB(255, 255, 209, 59),
                        ),
                      ),
                      SizedBox(height: 10),
                      isLoading
                          ? Container(
                              height: Responsive.isMobileSmall(context) ||
                                      Responsive.isMobileMedium(context) ||
                                      Responsive.isMobileLarge(context)
                                  ? 300
                                  : 350,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.3),
                                child: CircularProgressIndicator(
                                  color: Colors.amber,
                                ),
                              ),
                            )
                          : haveData == false
                              ? Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Container(
                                    height: Responsive.isMobileSmall(
                                                context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 300
                                        : 350,
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
                                          "No Workflows.",
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
                                )
                              : Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  height: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.height * 0.75
                                      : size.height * 0.75,
                                  width: size.width,
                                  child: PaginatedDataTable(
                                    arrowHeadColor: Colors.black,
                                    headingRowColor: WidgetStateProperty.all(
                                        Colors.grey[300]),
                                    horizontalMargin: 7,
                                    dataRowMinHeight: 40,
                                    dataRowMaxHeight: 42,
                                    rowsPerPage: 10,
                                    source: WorkflowDataTableSource(
                                        valueList, formatDate, context),
                                    onPageChanged: (startIndex) {
                                      setState(() {
                                        _currentStartIndex = startIndex;
                                      });
                                      print(_currentStartIndex);
                                    },
                                    columnSpacing: Responsive.isMobileSmall(
                                                context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? size.width * 0.06
                                        : Responsive.isTabletLandscape(
                                                    context) ||
                                                Responsive.isTabletPortrait(
                                                    context)
                                            ? size.width * .06
                                            : size.width * 0.035,
                                    columns: [
                                      DataColumn(
                                          label: Text(
                                        // 'WF',
                                        'Doc Id',
                                        style: TextStyle(
                                          fontSize: Responsive.isMobileSmall(
                                                  context)
                                              ? 12.7
                                              : Responsive.isMobileMedium(
                                                          context) ||
                                                      Responsive.isMobileLarge(
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
                                        'Task',
                                        style: TextStyle(
                                          fontSize: Responsive.isMobileSmall(
                                                  context)
                                              ? 12.7
                                              : Responsive.isMobileMedium(
                                                          context) ||
                                                      Responsive.isMobileLarge(
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
                                        'Assigned\nDate',
                                        style: TextStyle(
                                          fontSize: Responsive.isMobileSmall(
                                                  context)
                                              ? 12.7
                                              : Responsive.isMobileMedium(
                                                          context) ||
                                                      Responsive.isMobileLarge(
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
                                          'Action',
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
                                    ],
                                  ),
                                ),
                    ])
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
                                  fontSize: Responsive.isMobileSmall(
                                              context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.044
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.020
                                          : size.width * 0.015,
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

class WorkflowDataTableSource extends DataTableSource {
  final List<dynamic> data;
  final String Function(String) formatDate;
  final BuildContext context; // Store the BuildContext

  WorkflowDataTableSource(this.data, this.formatDate, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;

    final task = data[index];
    return DataRow(
      cells: [
        DataCell(
          Tooltip(
            message: "Leave process",
            triggerMode: TooltipTriggerMode.tap,
            showDuration: Duration(seconds: 2),
            padding: EdgeInsets.all(5),
            height: 35,
            textStyle: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.normal),
            decoration: BoxDecoration(color: Colors.amber),
            child: Text(
              // '${"Leave Process".substring(0, 7)}...',
              task['docId'].toString(),
              style: TextStyle(
                fontSize: Responsive.isMobileSmall(context)
                    ? 12
                    : Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 13
                        : Responsive.isTabletPortrait(context)
                            ? 16
                            : 18,
              ),
              textScaler: TextScaler.linear(1),
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: task['name'].toString(),
            triggerMode: TooltipTriggerMode.tap,
            showDuration: Duration(seconds: 2),
            padding: EdgeInsets.all(5),
            height: 35,
            textStyle: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.normal),
            decoration: BoxDecoration(color: Colors.amber),
            child: Text(
              task['name'].toString().length > 7
                  ? '${task['name'].toString().substring(0, 7)}...'
                  : task['name'],
              style: TextStyle(
                fontSize: Responsive.isMobileSmall(context)
                    ? 12
                    : Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 13
                        : Responsive.isTabletPortrait(context)
                            ? 16
                            : 18,
              ),
              textScaler: TextScaler.linear(1),
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: task['createdDate'].toString(),
            triggerMode: TooltipTriggerMode.tap,
            showDuration: Duration(seconds: 2),
            padding: EdgeInsets.all(5),
            height: 35,
            textStyle: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.normal),
            decoration: BoxDecoration(color: Colors.amber),
            child: Text(
              formatDate(task['createdDate'] ?? ''),
              style: TextStyle(
                fontSize: Responsive.isMobileSmall(context)
                    ? 12
                    : Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 13
                        : Responsive.isTabletPortrait(context)
                            ? 16
                            : 18,
              ),
              textScaler: TextScaler.linear(1),
            ),
          ),
        ),
        DataCell(
          GestureDetector(
            child: Center(
              child: Icon(
                Icons.monitor,
                size: 18,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewInProgressWFTask(
                    indexOfCurrent: index,
                    taskName: task['name'].toString(),
                    taskId: task['id'],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
