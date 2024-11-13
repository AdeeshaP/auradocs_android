import 'dart:convert';
import 'package:auradocs_android/API-Services/api_service.dart';
import 'package:auradocs_android/Bloc/document_bloc.dart';
import 'package:auradocs_android/Bloc/document_event.dart';
import 'package:auradocs_android/Bloc/document_state.dart';
import 'package:auradocs_android/Models/users.dart';
import 'package:auradocs_android/screens/Document-Search/search_list.dart';
import 'package:auradocs_android/screens/Sliders/landing_page.dart';
import 'package:auradocs_android/screens/Workflow/Active%20Tracking/active_tracking_wf.dart';
import 'package:auradocs_android/screens/Workflow/Completed/completed_wf.dart';
import 'package:auradocs_android/screens/Workflow/In-Progress/in_progress_wf.dart';
import 'package:auradocs_android/screens/Workflow/Start-New/start_new_wf.dart';
import 'package:auradocs_android/screens/Workflow/Suspended/suspended_wf.dart';
import 'package:auradocs_android/screens/contact_us_screen.dart';
import 'package:auradocs_android/screens/home_screen.dart';
import 'package:auradocs_android/utils/constants.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class WorkflowDashboard extends StatefulWidget {
  const WorkflowDashboard({super.key});

  @override
  State<WorkflowDashboard> createState() => _WorkflowDashboardState();
}

class _WorkflowDashboardState extends State<WorkflowDashboard> {
  late SharedPreferences _storage;
  Map<String, dynamic>? userObj;
  String username = "";
  String token = "";
  String compnyCode = "";
  bool isStrechedDropDown = false;
  bool isCheckBoxMarked = false;
  TextEditingController searchController = TextEditingController();
  final value = new NumberFormat("#,##,000", "en_US");
  String trimmedValue = "";
  GlobalKey _toolTipKey = GlobalKey();

  List authentication = [];

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
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

    setState(() {
      ApiService.companyCode = compnyCode;
    });

    context.read<DocumentBloc>().add(FetchWFDashboardCounts(username, token));
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
            height: double.infinity,
            child: Column(
              children: <Widget>[
                getSearchBoxWidget(),
                Divider(height: 8),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        children: [
                          Container(
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
                                          Icons
                                              .keyboard_double_arrow_right_rounded,
                                          color: Colors.white,
                                          size: Responsive.isMobileSmall(
                                                      context) ||
                                                  Responsive.isMobileMedium(
                                                      context) ||
                                                  Responsive.isMobileLarge(
                                                      context)
                                              ? 24
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
                                        "Workflows",
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
                          SizedBox(height: 10),
                          BlocBuilder<DocumentBloc, DocumentState>(
                            builder: (context, state) {
                              if (state is DocumentCountLoading) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.3),
                                  child: CircularProgressIndicator(
                                      color: Colors.amber),
                                );
                              } else if (state is WFDasboardCountLoaded) {
                                final completedWFCount =
                                    int.parse(state.completedTasksCount!);
                                final suspendedWFCount =
                                    int.parse(state.suspendedTasksCount!);
                                final pendingWFCount =
                                    int.parse(state.inProgressTasksCount!);
                                final assignedWFCount =
                                    int.parse(state.assignedTasksCount!);
                                return Column(
                                  children: [
                                    getWorkflowCountBox(
                                      context,
                                      assignedWFCount,
                                      Icons.home,
                                      Color.fromARGB(255, 58, 166, 228),
                                      "Start New Workflow",
                                      StartWorkflowScreen(),
                                    ),
                                    getWorkflowCountBox(
                                      context,
                                      pendingWFCount,
                                      Icons.spoke_rounded,
                                      Color.fromARGB(255, 250, 224, 75),
                                      "In Progress",
                                      InProgressScreen(),
                                    ),
                                    getWorkflowCountBox(
                                      context,
                                      completedWFCount,
                                      FontAwesomeIcons.trophy,
                                      Colors.lightGreen,
                                      "Completed",
                                      CompletedWorkflows(),
                                    ),
                                    getWorkflowCountBox(
                                      context,
                                      suspendedWFCount,
                                      FontAwesomeIcons.link,
                                      Colors.red[500]!,
                                      "Active Workflow Tracking",
                                      ActiveTrackingWorkflows(),
                                    ),
                                    getWorkflowCountBox(
                                      context,
                                      suspendedWFCount,
                                      Icons.pause,
                                      Color.fromARGB(255, 122, 121, 121),
                                      "Suspended",
                                      SuspendedWorkflows(),
                                    ),
                                  ],
                                );
                              } else if (state is DocumentError) {
                                return Center(
                                    child: Text("Error: ${state.message}"));
                              } else {
                                return Center(child: Text('Unexpected state'));
                              }
                            },
                          ),
                        ],
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

  GestureDetector getWorkflowCountBox(BuildContext context, int wfCount,
      IconData icon, Color color, String title, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: 5),
        width: double.infinity,
        height: Responsive.isMobileSmall(context) ||
                Responsive.isMobileMedium(context)
            ? 100
            : Responsive.isMobileLarge(context)
                ? 110
                : Responsive.isTabletPortrait(context)
                    ? 120
                    : 110,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(width: 10),
            Text(title,
                style: TextStyle(
                  fontSize: Responsive.isMobileSmall(context)
                      ? 16
                      : Responsive.isMobileMedium(context)
                          ? 18
                          : Responsive.isMobileLarge(context)
                              ? 19
                              : Responsive.isTabletPortrait(context)
                                  ? 23
                                  : 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textScaler: TextScaler.linear(1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 45,
                  color: Colors.grey[400],
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black45,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    wfCount < 100 ? "${wfCount}" : value.format(wfCount),
                    style: TextStyle(
                      fontSize: Responsive.isMobileSmall(context)
                          ? 15
                          : Responsive.isMobileMedium(context)
                              ? 17
                              : Responsive.isMobileLarge(context)
                                  ? 18
                                  : Responsive.isTabletPortrait(context)
                                      ? 20
                                      : 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textScaler: TextScaler.linear(1),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
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
                        data: MediaQuery.of(context)
                            .copyWith(textScaler: TextScaler.linear(1)),
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
                              child: Text(choice,
                                  style: TextStyle(
                                    fontSize: Responsive.isMobileSmall(
                                                context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? size.width * 0.044
                                        : Responsive.isTabletPortrait(context)
                                            ? size.width * 0.03
                                            : size.width * 0.02,
                                  ),
                                  textScaler: TextScaler.linear(1)),
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

  // Side Menu Bar Options
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
                title: Text('Logout',
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
                    textScaler: TextScaler.linear(1)),
                content: Text('Are you sure you want to logout?',
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
                    textScaler: TextScaler.linear(1)),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Cancel',
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
                        textScaler: TextScaler.linear(1)),
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
                    child: Text('Logout',
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
                        textScaler: TextScaler.linear(1)),
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
