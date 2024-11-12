import 'dart:convert';
import 'dart:io';
import 'package:app_version_update/app_version_update.dart';
import 'package:auradocs_android/API-Services/api_service.dart';
import 'package:auradocs_android/Models/users.dart';
import 'package:auradocs_android/screens/Bookmarks/bookmarks_list.dart';
import 'package:auradocs_android/screens/Direct-Scan/file_scan.dart';
import 'package:auradocs_android/screens/File-Picker/file_picker_screen.dart';
import 'package:auradocs_android/screens/History/history_tables.dart';
import 'package:auradocs_android/screens/Login/enable_local_auth_bottomsheet.dart';
import 'package:auradocs_android/screens/Pending-Docs/pending_doc_list.dart';
import 'package:auradocs_android/screens/Shared/shared_with_me.dart';
import 'package:auradocs_android/screens/Sign/sign_doc_list.dart';
import 'package:auradocs_android/screens/contact_us_screen.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/constants.dart';
import 'Sliders/landing_page.dart';
import 'Workflow/workflow_dashboard.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final User user;
  final String code;

  HomePage({
    super.key,
    required this.user,
    required this.code,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _currentPage = 0;
  final _controller = PageController(initialPage: 0);
  late SharedPreferences _storage;
  final _secureStorage = const FlutterSecureStorage();
  Map<String, dynamic>? userObj;
  String username = "";
  String token = "";
  String compnyCode = "";
  List authentication = [];
  Map<String, dynamic>? responsedata;
  VersionStatus? versionstatus;
  bool isStrechedDropDown = false;
  bool isCheckBoxMarked = false;
  TextEditingController searchController = TextEditingController();
  final String KEY_USERNAME = "KEY_USERNAME";
  final String KEY_PASSWORD = "KEY_PASSWORD";
  final String KEY_COMPANY = "KEY_COMPANY";
  final String KEY_LOCAL_AUTH_ENABLED = "KEY_LOCAL_AUTH_ENABLED";
  final String REQUIRE_BIOMETRIC_LOGIN_SELECT_YES =
      "REQUIRE_BIOMETRIC_LOGIN_SELECT_YES";
  var localAuth = LocalAuthentication();
  final value = new NumberFormat("#,##,000", "en_US");
  TextEditingController imporatntWordsSearchController1 =
      TextEditingController();
  TextEditingController imporatntWordsSearchController2 =
      TextEditingController();
  TextEditingController advanceSearchValueController = TextEditingController();
  TextEditingController searchFromController = TextEditingController();
  TextEditingController searchToController = TextEditingController();
  DateTime? searchStartDate;
  DateTime? searchEndDate;
  bool _validate = false;
  String templateType = "";
  String fieldVal = "";
  int indexFieldId = 0;
  int templateId = 0;
  List<dynamic> textFieldvalues2 = [];
  List<TextEditingController> _controllers = [];
  String _selectedValue = "Please Select";
  List<Map<String, dynamic>> docCounts = [];
  int todoHistoryCount = 0,
      accountHistoryCount = 0,
      downloadHistoryCount = 0,
      indexHistoryCount = 0,
      bookmarkcount = 0,
      todoListCount = 0,
      sharedCount = 0,
      pendingCount = 0,
      accessCount = 0,
      signCount = 0,
      approvalsCount = 0;
  File? _scannedImage;
  int totalIndexedDocCount = 0;
  int myTotalIndexedDocCount = 0;
  int totalViewedDocCount = 0;
  int pendingDocCount = 0;
  List<Map<String, dynamic>>? templatevalues = [];
  List<Map<String, dynamic>>? fieldsValues = [];
  List<String> dropdownOneValues = [];
  List<dynamic> dropdownTwoValues = [];
  List<String> dropdownOneWithSelect = ["Select Template"];
  bool isSecondDropdownVisible = false;
  bool isBothDropdownsSelected = false;
  bool checkedValue1 = false;
  bool checkedValue2 = false;
  ScrollController _scrollController = ScrollController();
  String trimmedValue = "";
  GlobalKey _toolTipKey = GlobalKey();

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
    compnyCode = _storage.getString('code')!;

    String? authListJson = _storage.getString('authentication');
    authentication =
        authListJson != null ? List<String>.from(jsonDecode(authListJson)) : [];

    setState(() {
      username = userObj!["value"]["userName"];
      ApiService.companyCode = compnyCode;
    });

    setState(() {
      getNotificationCount();
      getTotalIndexedDocumentsCount();
      getPendingDocCount();
      getTotalViewedDocumentsCount();
      getMyTotalIndexedDocumentsCount();
    });

    Future.delayed(Duration(seconds: 2), () {
      _requestFingerprintAuthentication();
    });

    await getVersionStatus().then((value) {
      _verifyVersion();
    });

    await getTemplatesDropdown();
  }

  Future<void> getNotificationCount() async {
    var response = await ApiService.getNotifciationsCount(username, token);

    if (response.statusCode == 200) {
      responsedata = jsonDecode(response.body);

      setState(() {
        docCounts = List<Map<String, dynamic>>.from(responsedata!['value']);
      });

      for (var item in docCounts) {
        switch (item['Type']) {
          case 'Index History':
            indexHistoryCount = item['Count'];
            break;
          case 'Account History':
            accountHistoryCount = item['Count'];
            break;
          case 'Bookmarked Documents':
            bookmarkcount = item['Count'];
            break;
          case 'To-Do History':
            todoHistoryCount = item['Count'];
            break;
          case 'Shared With Me':
            sharedCount = item['Count'];
            break;
          case 'Pending Documents':
            pendingCount = item['Count'];
            break;
          case 'Download History':
            downloadHistoryCount = item['Count'];
            break;
          case 'Approvals':
            approvalsCount = item['Count'];
            break;
          case 'To-Do List':
            todoListCount = item['Count'];
            break;
          case 'Sign Count':
            signCount = item['Count'];
            break;
        }
      }
    }
  }

  // ------------- Get the count of Total Indexed Docuemnt Count API ----------------- //
  Future<void> getTotalIndexedDocumentsCount() async {
    var response = await ApiService.getTotalIndexedDocCount(username, token);
    if (response.statusCode == 200) {
      responsedata = jsonDecode(response.body);

      setState(() {
        totalIndexedDocCount = responsedata!['value'];
      });
    }
  }

  // ------------- Get the count of Total Indexed Docuemnt Count API ----------------- //
  Future<void> getPendingDocCount() async {
    var response = await ApiService.getPendingFoldersCount(username, token);
    if (response.statusCode == 200) {
      responsedata = jsonDecode(response.body);

      setState(() {
        pendingDocCount = responsedata!['value'];
      });
    }
  }

  // ------------- Get the count of Total Indexed Docuemnt Count API ----------------- //
  Future<void> getMyTotalIndexedDocumentsCount() async {
    var response = await ApiService.getMyTotalIndexedDocCount(username, token);
    if (response.statusCode == 200) {
      responsedata = jsonDecode(response.body);

      setState(() {
        myTotalIndexedDocCount = responsedata!['value'];
      });
    }
  }

  // ------------- Get the count of Total Viewed Docuemnt Count API ----------------- //
  Future<void> getTotalViewedDocumentsCount() async {
    var response = await ApiService.getTotalViewedDocCount(username, token);
    if (response.statusCode == 200) {
      responsedata = jsonDecode(response.body);

      setState(() {
        totalViewedDocCount = responsedata!['value'];
      });
    }
  }

  // --------GET App Version Status--------------//
  Future<VersionStatus> getVersionStatus() async {
    NewVersionPlus? newVersion =
        NewVersionPlus(androidId: "com.auradot.auradocs");
    VersionStatus? status = await newVersion.getVersionStatus();
    setState(() {
      versionstatus = status;
    });
    return versionstatus!;
  }

  Future<void> _verifyVersion() async {
    AppVersionUpdate.checkForUpdates(
      appleId: '1470368269',
      playStoreId: 'com.auradot.auradocs',
      country: 'us',
    ).then((result) async {
      if (result.canUpdate!) {
        await AppVersionUpdate.showAlertUpdate(
          appVersionResult: result,
          context: context,
          backgroundColor: Colors.grey[200],
          title: 'Update auraDOCS ?',
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 24
                : Responsive.isTabletPortrait(context)
                    ? 28
                    : 27,
          ),
          content: "auraDOCS recommends that you update to the new version. " +
              "You still have auraDOCS ${versionstatus!.localVersion} and new version (${versionstatus!.storeVersion})" +
              " is available in playstore.",
          contentTextStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: Responsive.isMobileSmall(context) ||
                      Responsive.isMobileMedium(context) ||
                      Responsive.isMobileLarge(context)
                  ? 16
                  : Responsive.isTabletPortrait(context)
                      ? 25
                      : 24,
              height: 1.44444),
          updateButtonText: 'UPDATE',
          updateTextStyle: TextStyle(
            fontSize: Responsive.isMobileSmall(context)
                ? 14
                : Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 16
                    : Responsive.isTabletPortrait(context)
                        ? 18
                        : 18,
          ),
          updateButtonStyle: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            foregroundColor: WidgetStateProperty.all(Colors.white),
            backgroundColor: WidgetStateProperty.all(Colors.green[900]),
            minimumSize: Responsive.isMobileSmall(context)
                ? WidgetStateProperty.all(Size(90, 40))
                : Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? WidgetStateProperty.all(Size(100, 45))
                    : Responsive.isTabletPortrait(context)
                        ? WidgetStateProperty.all(Size(160, 60))
                        : WidgetStateProperty.all(Size(140, 50)),
          ),
          cancelButtonText: 'NO THANKS',
          cancelButtonStyle: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            ),
            foregroundColor: WidgetStateProperty.all(Colors.white),
            backgroundColor: WidgetStateProperty.all(Colors.red[900]),
            minimumSize: Responsive.isMobileSmall(context)
                ? WidgetStateProperty.all(Size(90, 40))
                : Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? WidgetStateProperty.all(Size(100, 45))
                    : Responsive.isTabletPortrait(context)
                        ? WidgetStateProperty.all(Size(160, 60))
                        : WidgetStateProperty.all(Size(140, 50)),
          ),
          cancelTextStyle: TextStyle(
            fontSize: Responsive.isMobileSmall(context)
                ? 14
                : Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 16
                    : Responsive.isTabletPortrait(context)
                        ? 18
                        : 18,
          ),
        );
      }
    });
  }

  _requestFingerprintAuthentication() async {
    String yesOrNo =
        await _secureStorage.read(key: "REQUIRE_BIOMETRIC_LOGIN_SELECT_YES") ??
            "false";

    print("yesOrNo $yesOrNo");

    if (await localAuth.canCheckBiometrics) {
      if (yesOrNo == "false") {
        await showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return EnableLocalAuthModalBottomSheet(action: _onEnableLocalAuth);
          },
        );
      }
    }
  }

  void _onEnableLocalAuth() async {
    await _secureStorage.write(key: KEY_LOCAL_AUTH_ENABLED, value: "true");
    await _secureStorage.write(
        key: REQUIRE_BIOMETRIC_LOGIN_SELECT_YES, value: "true");
  }

  pickImageFromCamera() async {
    var image = await DocumentScannerFlutter.launch(context,
        source: ScannerFileSource.CAMERA,
        labelsConfig: {
          ScannerLabelsConfig.ANDROID_NEXT_BUTTON_LABEL: "Next",
          ScannerLabelsConfig.ANDROID_OK_LABEL: "OK",
        });
    if (image != null) {
      _scannedImage = image;
      setState(() {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return DirectScan(file1: _scannedImage);
        }));
      });
    }
  }

  // -------- GET API - Template dropdown item -------------//
  Future<void> getTemplatesDropdown() async {
    _storage = await SharedPreferences.getInstance();
    userObj = jsonDecode(_storage.getString('user_data')!);
    if (!mounted) return;
    setState(() {
      ApiService.companyCode = _storage.getString('code')!;
      username = userObj!["value"]["userName"];
      token = _storage.getString('token')!;
    });

    var response = await ApiService.getAvalableTemplatesLists(username, token);
    var templatelist = jsonDecode(response.body);
    if (!mounted) return;
    setState(() {
      templatevalues = List<Map<String, dynamic>>.from(templatelist['value']);
      dropdownOneValues =
          templatevalues!.map((e) => e.values.first.toString()).toList();
    });

    for (var x in dropdownOneValues) {
      dropdownOneWithSelect.add(x);
    }
  }

  //-------- GET API - Template Fileds for new dropdown  -------------//

  Future<void> getFieldsForDropdown(int tempId) async {
    print("passed template id $tempId");

    var response3 = await ApiService.getAvailableTemplateById(tempId, token);
    Map<String, dynamic> body = jsonDecode(response3.body);

    List<dynamic> values = body['value'];
    List<Map<String, dynamic>> items = values
        .map((e) => {
              'indexFieldName': e['indexFieldName'],
              'indexFieldDisplayAs': e['indexFieldDisplayAs']
            })
        .toList();

    setState(() {
      fieldsValues = items;
    });

    print('fieldsValues $fieldsValues');
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // Map of roles to their respective widgets, titles, and icons
    Map<String, Map<String, dynamic>> featureMap = {
      "ROLE_MOBILE_SCAN": {
        "title": "Scan",
        "icon": Icons.camera,
        "count": 0,
        "action": pickImageFromCamera,
        "isUnderDevelopment": false,
      },
      "ROLE_MOBILE_UPLOAD": {
        "title": "Upload",
        "icon": Icons.file_upload,
        "count": 0,
        "screen": FilePickerScreen(),
        "isUnderDevelopment": false,
      },
      "ROLE_MOBILE_INDEXING": {
        "title": "Indexing",
        "icon": Icons.pending_actions,
        "count": pendingCount,
        "screen": PendingDocsListScreen(),
        "isUnderDevelopment": false,
      },
      "ROLE_MOBILE_AD_SEARCH": {
        "title": "Advanced Search",
        "icon": FontAwesomeIcons.searchengin,
        "count": 0,
        "action": showAdvancedSearchPopup2,
        "isUnderDevelopment": false,
      },
      "ROLE_MOBILE_APPROVALS": {
        "title": "Approvals",
        "icon": Icons.approval,
        "count": approvalsCount,
        // "screen": ApprovalsScreen(),
        "screen": null,
        "isUnderDevelopment": true,
      },
      "ROLE_MOBILE_SHARED": {
        "title": "Shared",
        "icon": FontAwesomeIcons.shareFromSquare,
        "count": sharedCount,
        "screen": SharedWithMe(),
        "isUnderDevelopment": false,
      },
      "ROLE_MOBILE_SIGN": {
        "title": "Sign",
        "icon": FontAwesomeIcons.signature,
        "count": signCount,
        "screen": SignAvailableDocuments(),
        "isUnderDevelopment": false,
      },
      "ROLE_MOBILE_TODO": {
        "title": "To-Do",
        "icon": FontAwesomeIcons.listCheck,
        "count": todoListCount,
        "screen": null,
        "isUnderDevelopment": true,
      },
      "ROLE_MOBILE_HISTORY": {
        "title": "History",
        "icon": Icons.history,
        "count": indexHistoryCount +
            accountHistoryCount +
            downloadHistoryCount +
            todoHistoryCount,
        "screen": HistoryTables(),
        "isUnderDevelopment": false,
      },
      "ROLE_MOBILE_FAVORITE": {
        "title": "Favorite",
        "icon": Icons.star,
        "count": bookmarkcount,
        "screen": FavoriteDocListScreen(),
        "isUnderDevelopment": false,
      },
      "ROLE_MOBILE_WORKFLOW": {
        "title": "Workflow",
        "icon": Icons.keyboard_double_arrow_right,
        "count": 0,
        "screen": WorkflowDashboard(),
        // "screen": null,
        "isUnderDevelopment": false,
      },
      "ROLE_MOBILE_ACCESS_REQUEST": {
        "title": "Access",
        "icon": Icons.desktop_mac_outlined,
        "count": 0,
        "screen": null,
        "isUnderDevelopment": true,
      },
    };

    // Dynamically generate grid items based on the authentication list
    List<Widget> gridItems = authentication.map((role) {
      if (featureMap.containsKey(role)) {
        return gridViewTab(
          size,
          featureMap[role]!['title'],
          featureMap[role]!['screen'],
          featureMap[role]!['icon'],
          featureMap[role]!['count'],
          featureMap[role]!['action'],
          featureMap[role]!['isUnderDevelopment'],
        );
      }
      return Container();
    }).toList();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        SystemNavigator.pop();
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
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
                    Column(
                      children: [
                        SizedBox(
                            height: Responsive.isMobileSmall(context)
                                ? 10
                                : Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? 15
                                    : Responsive.isTabletPortrait(context)
                                        ? 15
                                        : 15),
                        Container(
                          height: Responsive.isMobileSmall(context) ||
                                  Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? size.height * 0.7
                              : Responsive.isTabletLandscape(context) ||
                                      Responsive.isTabletPortrait(context)
                                  ? size.height * 0.7
                                  : size.height * 0.65,
                          child: authentication.length > 0
                              ? Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: GridView.count(
                                    scrollDirection: Axis.vertical,
                                    physics: ScrollPhysics(),
                                    shrinkWrap: true,
                                    crossAxisCount: 3,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: Responsive.isMobileSmall(
                                                context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 8
                                        : Responsive.isTabletLandscape(
                                                    context) ||
                                                Responsive.isTabletPortrait(
                                                    context)
                                            ? 5
                                            : 10,
                                    mainAxisSpacing: Responsive.isMobileSmall(
                                                context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 12
                                        : Responsive.isTabletLandscape(
                                                    context) ||
                                                Responsive.isTabletPortrait(
                                                    context)
                                            ? 2
                                            : 10,
                                    children: gridItems,
                                    // [
                                    //   directScanTab(
                                    //     size,
                                    //     "Scan",
                                    //     Icons.camera,
                                    //   ),
                                    //   gridViewTab(
                                    //     size,
                                    //     "Upload",
                                    //     AuradocsFilePickerScreen(),
                                    //     FontAwesomeIcons.fileArrowUp,
                                    //     0,
                                    //   ),
                                    //   gridViewTab(
                                    //     size,
                                    //     "Indexing",
                                    //     PendingDOCXListScreen(),
                                    //     Icons.pending_actions,
                                    //     pendingCount,
                                    //   ),
                                    //   AdvSearchTab(
                                    //     size,
                                    //     "Advanced Search",
                                    //     FontAwesomeIcons.searchengin,
                                    //   ),
                                    //   // gridViewTab(
                                    //   //   size,
                                    //   //   "Approvals",
                                    //   //   ApprovalsScreen(),
                                    //   //   Icons.approval,
                                    //   //   0,
                                    //   // ),
                                    //   NotImplementingFeature(
                                    //     size,
                                    //     "Approvals",
                                    //     Icons.approval,
                                    //     0,
                                    //   ),
                                    //   gridViewTab(
                                    //     size,
                                    //     "Shared",
                                    //     SharedWithMeScreen(),
                                    //     FontAwesomeIcons.shareFromSquare,
                                    //     sharedCount,
                                    //   ),
                                    //   gridViewTab(
                                    //     size,
                                    //     "Sign",
                                    //     DocumentSignatureScreen(),
                                    //     // SigningTskListScreen(
                                    //     //     token: token, username: username),
                                    //     FontAwesomeIcons.signature,
                                    //     0,
                                    //   ),
                                    //   // NotImplementingFeature(
                                    //   //   size,
                                    //   //   "Sign",
                                    //   //   FontAwesomeIcons.signature,
                                    //   //   0,
                                    //   // ),
                                    //   // gridViewTab(
                                    //   //     size,
                                    //   //     "To-Do",
                                    //   //     TasksListScreen(),
                                    //   //     FontAwesomeIcons.listCheck,
                                    //   //     0),
                                    //   NotImplementingFeature(
                                    //     size,
                                    //     "To-Do",
                                    //     FontAwesomeIcons.listCheck,
                                    //     0,
                                    //   ),
                                    //   gridViewTab(
                                    //     size,
                                    //     "History",
                                    //     HistoryDummy(),
                                    //     FontAwesomeIcons.clockRotateLeft,
                                    //     indexHistoryCount +
                                    //         accountHistoryCount +
                                    //         downloadHistoryCount +
                                    //         todoHistoryCount,
                                    //   ),
                                    //   gridViewTab(
                                    //     size,
                                    //     "Favorite",
                                    //     BookmarkListScreen(),
                                    //     FontAwesomeIcons.star,
                                    //     bookmarkcount,
                                    //   ),
                                    //   // gridViewTab(
                                    //   //   size,
                                    //   //   "Access",
                                    //   //   AccessRequestsScreen(),
                                    //   //   Icons.desktop_mac_outlined,
                                    //   //   accessCount,
                                    //   // ),
                                    //   gridViewTab(
                                    //     size,
                                    //     "Workflow",
                                    //     WorkflowDashboard(),
                                    //     Icons.keyboard_double_arrow_right,
                                    //     0,
                                    //   ),
                                    //   NotImplementingFeature(
                                    //     size,
                                    //     "Access",
                                    //     Icons.desktop_mac_outlined,
                                    //     0,
                                    //   ),

                                    // ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "You don’t have access to features yet.",
                                        // "You currently don’t have any features available."
                                        style: TextStyle(
                                          fontSize: Responsive.isMobileSmall(
                                                      context) ||
                                                  Responsive.isMobileMedium(
                                                      context) ||
                                                  Responsive.isMobileLarge(
                                                      context)
                                              ? size.width * 0.06
                                              : Responsive.isTabletPortrait(
                                                      context)
                                                  ? size.width * 0.04
                                                  : size.width * 0.03,
                                          color: Colors.black54,
                                        ),
                                        textScaler: TextScaler.linear(1),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 20),
                                      Icon(Icons.no_encryption,
                                          color: Colors.grey, size: 50),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                    // AdvancedSearchBox(_isAdvanceSearchVisible),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            width: double.infinity,
            height: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 90
                : Responsive.isTabletPortrait(context)
                    ? 120
                    : 110,
            child: PageView(
              controller: _controller,
              onPageChanged: (int index) {
                if (!mounted) return;
                setState(() {
                  _currentPage = index;
                });
              },
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: Responsive.isMobileSmall(context) ||
                              Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context)
                          ? 90
                          : Responsive.isTabletPortrait(context)
                              ? 120
                              : 110,
                      color: Color.fromARGB(255, 58, 74, 124),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text("TOTAL INDEXED DOCUMENTS",
                              style: TextStyle(
                                fontSize: Responsive.isMobileSmall(context)
                                    ? 15
                                    : Responsive.isMobileMedium(context)
                                        ? 16
                                        : Responsive.isMobileLarge(context)
                                            ? 17
                                            : Responsive.isTabletPortrait(
                                                    context)
                                                ? 23
                                                : 25,
                                color: Colors.white,
                              ),
                              textScaler: TextScaler.linear(1)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: _currentPage == 0
                                      ? Colors.grey
                                      : Colors.white,
                                ),
                                iconSize: Responsive.isMobileSmall(context) ||
                                        Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? 30
                                    : Responsive.isTabletPortrait(context)
                                        ? 40
                                        : 45,
                                onPressed: () {
                                  if (_currentPage > 0) {
                                    _controller.animateToPage(_currentPage - 1,
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.easeIn);
                                  }
                                },
                              ),
                              Text(
                                  totalIndexedDocCount < 100
                                      ? "${totalIndexedDocCount}"
                                      : value.format(totalIndexedDocCount),
                                  style: TextStyle(
                                    fontSize: Responsive.isMobileSmall(context)
                                        ? 32
                                        : Responsive.isMobileMedium(context)
                                            ? 35
                                            : Responsive.isMobileLarge(context)
                                                ? 38
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 45
                                                    : 45,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textScaler: TextScaler.linear(1)),
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: _currentPage == 3
                                      ? Colors.grey
                                      : Colors.white,
                                ),
                                iconSize: Responsive.isMobileSmall(context) ||
                                        Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? 30
                                    : Responsive.isTabletPortrait(context)
                                        ? 40
                                        : 45,
                                // color: Colors.white,
                                onPressed: () {
                                  if (_currentPage < 3) {
                                    _controller.animateToPage(_currentPage + 1,
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.easeIn);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: Responsive.isMobileSmall(context) ||
                              Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context)
                          ? 90
                          : Responsive.isTabletPortrait(context)
                              ? 120
                              : 110,
                      color: Colors.orange[700],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text("MY INDEXED COUNT",
                              style: TextStyle(
                                fontSize: Responsive.isMobileSmall(context)
                                    ? 15
                                    : Responsive.isMobileMedium(context)
                                        ? 16
                                        : Responsive.isMobileLarge(context)
                                            ? 17
                                            : Responsive.isTabletPortrait(
                                                    context)
                                                ? 23
                                                : 25,
                                color: Colors.white,
                              ),
                              textScaler: TextScaler.linear(1)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: _currentPage == 0
                                      ? Colors.grey
                                      : Colors.white,
                                ),
                                iconSize: Responsive.isMobileSmall(context) ||
                                        Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? 30
                                    : Responsive.isTabletPortrait(context)
                                        ? 40
                                        : 45,
                                onPressed: () {
                                  if (_currentPage > 0) {
                                    _controller.animateToPage(_currentPage - 1,
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.easeIn);
                                  }
                                },
                              ),
                              Text(
                                  myTotalIndexedDocCount < 100
                                      ? "${myTotalIndexedDocCount}"
                                      : value.format(myTotalIndexedDocCount),
                                  style: TextStyle(
                                    fontSize: Responsive.isMobileSmall(context)
                                        ? 32
                                        : Responsive.isMobileMedium(context)
                                            ? 35
                                            : Responsive.isMobileLarge(context)
                                                ? 38
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 45
                                                    : 45,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textScaler: TextScaler.linear(1)),
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: _currentPage == 3
                                      ? Colors.grey
                                      : Colors.white,
                                ),
                                iconSize: Responsive.isMobileSmall(context) ||
                                        Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? 30
                                    : Responsive.isTabletPortrait(context)
                                        ? 40
                                        : 45,
                                // color: Colors.white,
                                onPressed: () {
                                  if (_currentPage < 3) {
                                    _controller.animateToPage(_currentPage + 1,
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.easeIn);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Container(
                      height: Responsive.isMobileSmall(context) ||
                              Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context)
                          ? 90
                          : Responsive.isTabletPortrait(context)
                              ? 120
                              : 110,
                      width: double.infinity,
                      color: Colors.lightGreen[600],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text("TOTAL VIEWED DOCUMENTS",
                              style: TextStyle(
                                fontSize: Responsive.isMobileSmall(context)
                                    ? 15
                                    : Responsive.isMobileMedium(context)
                                        ? 16
                                        : Responsive.isMobileLarge(context)
                                            ? 17
                                            : Responsive.isTabletPortrait(
                                                    context)
                                                ? 23
                                                : 25,
                                color: Colors.white,
                              ),
                              textScaler: TextScaler.linear(1)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: _currentPage == 0
                                      ? Colors.grey
                                      : Colors.white,
                                ),
                                iconSize: Responsive.isMobileSmall(context) ||
                                        Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? 30
                                    : Responsive.isTabletPortrait(context)
                                        ? 40
                                        : 45,
                                onPressed: () {
                                  if (_currentPage > 0) {
                                    _controller.animateToPage(_currentPage - 1,
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.easeIn);
                                  }
                                },
                              ),
                              Text(
                                  totalViewedDocCount < 100
                                      ? "${totalViewedDocCount}"
                                      : value.format(totalViewedDocCount),
                                  style: TextStyle(
                                    fontSize: Responsive.isMobileSmall(context)
                                        ? 32
                                        : Responsive.isMobileMedium(context)
                                            ? 35
                                            : Responsive.isMobileLarge(context)
                                                ? 38
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 45
                                                    : 45,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textScaler: TextScaler.linear(1)),
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: _currentPage == 3
                                      ? Colors.grey
                                      : Colors.white,
                                ),
                                iconSize: Responsive.isMobileSmall(context) ||
                                        Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? 30
                                    : Responsive.isTabletPortrait(context)
                                        ? 40
                                        : 45,
                                onPressed: () {
                                  if (_currentPage < 3) {
                                    _controller.animateToPage(_currentPage + 1,
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.easeIn);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PendingDocsListScreen(),
                            ));
                      },
                      child: Container(
                        height: Responsive.isMobileSmall(context) ||
                                Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? 90
                            : Responsive.isTabletPortrait(context)
                                ? 120
                                : 110,
                        width: double.infinity,
                        color: Colors.red[500],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text("PENDING DOCUMENTS",
                                style: TextStyle(
                                  fontSize: Responsive.isMobileSmall(context)
                                      ? 15
                                      : Responsive.isMobileMedium(context)
                                          ? 16
                                          : Responsive.isMobileLarge(context)
                                              ? 17
                                              : Responsive.isTabletPortrait(
                                                      context)
                                                  ? 23
                                                  : 25,
                                  color: Colors.white,
                                ),
                                textScaler: TextScaler.linear(1)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    color: _currentPage == 0
                                        ? Colors.grey
                                        : Colors.white,
                                  ),
                                  iconSize: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 30
                                      : Responsive.isTabletPortrait(context)
                                          ? 40
                                          : 45,
                                  onPressed: () {
                                    if (_currentPage > 0) {
                                      _controller.animateToPage(
                                          _currentPage - 1,
                                          duration: Duration(milliseconds: 400),
                                          curve: Curves.easeIn);
                                    }
                                  },
                                ),
                                Text(
                                    pendingDocCount < 100
                                        ? "${pendingDocCount}"
                                        : value.format(pendingDocCount),
                                    style: TextStyle(
                                      fontSize: Responsive.isMobileSmall(
                                              context)
                                          ? 32
                                          : Responsive.isMobileMedium(context)
                                              ? 35
                                              : Responsive.isMobileLarge(
                                                      context)
                                                  ? 38
                                                  : Responsive.isTabletPortrait(
                                                          context)
                                                      ? 45
                                                      : 45,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textScaler: TextScaler.linear(1)),
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    color: _currentPage == 3
                                        ? Colors.grey
                                        : Colors.white,
                                  ),
                                  iconSize: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 30
                                      : Responsive.isTabletPortrait(context)
                                          ? 40
                                          : 45,
                                  onPressed: () {
                                    if (_currentPage < 3) {
                                      _controller.animateToPage(
                                          _currentPage + 1,
                                          duration: Duration(milliseconds: 400),
                                          curve: Curves.easeIn);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Default state if none matches
          ),
        ),
      ),
    );
  }

  // -------------------  Not Implementing Featire Tooltip ------------------

  Widget NotImplementingFeature(
      Size size, String heading, IconData x, int notificationCount) {
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      message: "This feature is under development.",
      showDuration: Duration(seconds: 2),
      child: Container(
        height: Responsive.isMobileSmall(context)
            ? size.width * 0.1
            : Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 300
                : Responsive.isTabletLandscape(context) ||
                        Responsive.isTabletPortrait(context)
                    ? size.width * 0.3
                    : size.width * 0.3,
        width: size.width / 3,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Tooltip(
                  triggerMode: TooltipTriggerMode.tap,
                  message: "This feature is under development.",
                  showDuration: Duration(seconds: 2),
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                      x,
                      size: Responsive.isMobileSmall(context)
                          ? 40
                          : Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? 45
                              : Responsive.isTabletPortrait(context)
                                  ? 55
                                  : 60,
                      color: Colors.black54,
                    ),
                  ),
                ),
                if (notificationCount > 0)
                  Positioned(
                    top: -5,
                    right: -10,
                    child: Container(
                      height: Responsive.isMobileSmall(context) ||
                              Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context)
                          ? 25
                          : Responsive.isTabletLandscape(context) ||
                                  Responsive.isTabletPortrait(context)
                              ? 40
                              : 25,
                      width: Responsive.isMobileSmall(context) ||
                              Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context)
                          ? 25
                          : Responsive.isTabletLandscape(context) ||
                                  Responsive.isTabletPortrait(context)
                              ? 40
                              : 25,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          notificationCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.isMobileSmall(context) ||
                                    Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 12
                                : Responsive.isTabletLandscape(context) ||
                                        Responsive.isTabletPortrait(context)
                                    ? 16
                                    : 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(
                height: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 10
                    : Responsive.isTabletPortrait(context) ||
                            Responsive.isTabletLandscape(context)
                        ? 15
                        : 5),
            Text("$heading",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: Responsive.isMobileSmall(context)
                      ? 14
                      : Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context)
                          ? 15
                          : Responsive.isTabletPortrait(context)
                              ? 20
                              : 22,
                ),
                textScaler: TextScaler.linear(1)),
          ],
        ),
      ),
    );
  }

  // -------------------  Grid Tile Component ------------------

  Widget gridViewTab(Size size, String heading, Widget? screen, IconData x,
      int notificationCount, VoidCallback? action, bool isUnderDevelopment) {
    return GestureDetector(
      onTap: () {
        if (isUnderDevelopment) {
          // Show a tooltip or dialog indicating the feature is under development
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                insetPadding:
                    EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                title: Text(
                  'Feature Coming Soon',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                content: Text(
                  'This feature is currently under development. Please check back later.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text(
                      "OK",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ],
              );
            },
          );
        } else if (action != null) {
          action(); // Call the function if provided
        } else if (screen != null) {}
      },
      child: Container(
        height: Responsive.isMobileSmall(context)
            ? size.width * 0.1
            : Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 300
                : Responsive.isTabletLandscape(context) ||
                        Responsive.isTabletPortrait(context)
                    ? size.width * 0.3
                    : size.width * 0.3,
        width: size.width / 3,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                      x,
                      size: Responsive.isMobileSmall(context)
                          ? 40
                          : Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? 45
                              : Responsive.isTabletPortrait(context)
                                  ? 55
                                  : 60,
                      color: Colors.black54,
                    ),
                  ),
                  onTap: () {
                    if (isUnderDevelopment) {
                      // Show a tooltip or dialog indicating the feature is under development
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            insetPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            title: Text(
                              'Feature Coming Soon',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                            content: Text(
                              'This feature is currently under development. Please check back later.',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.justify,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "OK",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (action != null) {
                      action(); // Call the function if provided
                    } else if (screen != null) {}
                  },
                ),
                if (notificationCount > 0)
                  Positioned(
                    top: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? -5
                        : -2,
                    right: -10,
                    child: Container(
                      height: Responsive.isMobileSmall(context) ||
                              Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context)
                          ? 25
                          : Responsive.isTabletLandscape(context) ||
                                  Responsive.isTabletPortrait(context)
                              ? 30
                              : 25,
                      width: Responsive.isMobileSmall(context) ||
                              Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context)
                          ? 25
                          : Responsive.isTabletLandscape(context) ||
                                  Responsive.isTabletPortrait(context)
                              ? 30
                              : 25,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          notificationCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.isMobileSmall(context) ||
                                    Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 12
                                : Responsive.isTabletLandscape(context) ||
                                        Responsive.isTabletPortrait(context)
                                    ? 16
                                    : 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textScaler: TextScaler.linear(1),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(
                height: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 10
                    : Responsive.isTabletPortrait(context) ||
                            Responsive.isTabletLandscape(context)
                        ? 15
                        : 5),
            Text("$heading",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: Responsive.isMobileSmall(context)
                      ? 12
                      : Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context)
                          ? 13.8
                          : Responsive.isTabletPortrait(context)
                              ? 20
                              : 21,
                ),
                textScaler: TextScaler.linear(1)),
          ],
        ),
      ),
    );
  }

  // -------------------  Advanced Search Component ------------------

  Widget AdvSearchTab(Size size, String heading, IconData x) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          child: Container(
            height: Responsive.isMobileSmall(context)
                ? size.width * 0.1
                : Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 300
                    : Responsive.isTabletLandscape(context) ||
                            Responsive.isTabletPortrait(context)
                        ? size.width * 0.3
                        : size.width * 0.3,
            width: size.width / 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                      x,
                      size: Responsive.isMobileSmall(context)
                          ? 40
                          : Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? 45
                              : Responsive.isTabletPortrait(context)
                                  ? 55
                                  : 60,
                      color: Colors.black54,
                    ),
                  ),
                  onTap: showAdvancedSearchPopup2,
                  // onTap: () {},
                ),
                SizedBox(
                    height: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 10
                        : Responsive.isTabletPortrait(context) ||
                                Responsive.isTabletLandscape(context)
                            ? 15
                            : 5),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 1),
                  height: Responsive.isMobileSmall(context) ||
                          Responsive.isMobileMedium(context) ||
                          Responsive.isMobileLarge(context)
                      ? 20
                      : Responsive.isTabletPortrait(context) ||
                              Responsive.isTabletLandscape(context)
                          ? 70
                          : 40,
                  child: Text("Advanced Search",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: Responsive.isMobileSmall(context)
                            ? 12
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 13
                                : Responsive.isTabletPortrait(context)
                                    ? 20
                                    : 21,
                      ),
                      textAlign: TextAlign.center,
                      textScaler: TextScaler.linear(1)),
                ),
              ],
            ),
          ),
          onTap: showAdvancedSearchPopup2,
          // onTap: () {},
        ),
      ],
    );
  }

  // ------------------- Direct Scan Component ------------------

  Widget directScanTab(Size size, String heading, IconData x) {
    return GestureDetector(
      child: Container(
        height: Responsive.isMobileSmall(context)
            ? size.width * 0.1
            : Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 300
                : Responsive.isTabletPortrait(context)
                    ? size.width * 0.3
                    : size.width * 0.3,
        width: size.width / 3,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                      x,
                      size: Responsive.isMobileSmall(context)
                          ? 40
                          : Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? 45
                              : Responsive.isTabletPortrait(context)
                                  ? 55
                                  : 60,
                      color: Colors.black54,
                    ),
                  ),
                  onTap: () {
                    pickImageFromCamera();
                  },
                ),
              ],
            ),
            SizedBox(
                height: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 10
                    : Responsive.isTabletPortrait(context) ||
                            Responsive.isTabletLandscape(context)
                        ? 15
                        : 5),
            Text("$heading",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: Responsive.isMobileSmall(context)
                      ? 15
                      : Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context)
                          ? 15
                          : Responsive.isTabletPortrait(context)
                              ? 21
                              : 25,
                ),
                textScaler: TextScaler.linear(1)),
          ],
        ),
      ),
      onTap: () {
        pickImageFromCamera();
      },
    );
  }

  _scrollToMaxValue() {
    if (_scrollController.positions.length > 0) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

// ----------- CURRENTLY USING ADVANCED SEARCH POPUP-------------------

  void showAdvancedSearchPopup2() {
    showDialog(
        barrierColor: Color.fromARGB(177, 18, 17, 17),
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState2) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              backgroundColor: Colors.white,
              content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: _scrollController,
                child: Column(
                  children: [
                    Container(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Advanced Search",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                    textScaler: TextScaler.linear(1)),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    setState2(() {
                                      isSecondDropdownVisible = false;
                                      isBothDropdownsSelected = false;
                                      templateType = "";
                                      templateId = 0;
                                      fieldVal = "";
                                    });
                                  },
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      radius: 14.0,
                                      child: Icon(Icons.close,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Template : ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14),
                                    textScaler: TextScaler.linear(1)),
                              ),
                            ),
                            SizedBox(height: 10),
                            MediaQuery(
                              data: MediaQuery.of(context)
                                  .copyWith(textScaler: TextScaler.linear(1)),
                              child: DropdownButtonFormField(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(12),
                                  labelText: "Template Name",
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: Responsive.isMobileSmall(
                                                context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 14
                                        : Responsive.isTabletPortrait(context)
                                            ? 15
                                            : 16,
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0)),
                                ),
                                value: templateType == "" ? null : templateType,
                                onChanged: (newValue) async {
                                  int index =
                                      dropdownOneWithSelect.indexOf(newValue!);
                                  int selectedTemplateKey = int.parse(
                                      templatevalues![index - 1].keys.first);
                                  setState2(() {
                                    templateType = newValue;
                                    templateId = selectedTemplateKey;
                                  });

                                  await getFieldsForDropdown(templateId);

                                  setState2(() {
                                    isSecondDropdownVisible = true;
                                  });
                                  print(
                                      "isSecondDropdownVisible $isSecondDropdownVisible");
                                },
                                items: dropdownOneWithSelect
                                    .map<DropdownMenuItem<String>>((value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        textScaler: TextScaler.linear(1)),
                                  );
                                }).toList(),
                              ),
                            ),

                            SizedBox(height: 10),
                            Divider(thickness: 1),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Field : ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14),
                                    textScaler: TextScaler.linear(1)),
                              ),
                            ),
                            // if (isSecondDropdownVisible == true)
                            MediaQuery(
                              data: MediaQuery.of(context)
                                  .copyWith(textScaler: TextScaler.linear(1)),
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(12),
                                  labelText: "Field",
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: Responsive.isMobileSmall(
                                                context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 14
                                        : Responsive.isTabletPortrait(context)
                                            ? 15
                                            : 16,
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0)),
                                ),
                                value: fieldVal == "" ? null : fieldVal,
                                onChanged: (value) {
                                  setState2(() {
                                    fieldVal = value!;
                                    isBothDropdownsSelected = true;
                                  });

                                  Map<String, dynamic>? selectedItem =
                                      fieldsValues!.firstWhere((item) =>
                                          item['indexFieldName'].toString() ==
                                          value);

                                  print(
                                      'Selected value: ${selectedItem['indexFieldDisplayAs']}');
                                  print(
                                      'IndexFieldName value: ${selectedItem['indexFieldName']}');

                                  setState2(() {
                                    indexFieldId =
                                        selectedItem['indexFieldName'];
                                  });

                                  if (isBothDropdownsSelected == true)
                                    WidgetsBinding.instance
                                        .addPostFrameCallback(
                                            (_) => _scrollToMaxValue());

                                  print("seelcted field $fieldVal");
                                },
                                items: fieldsValues!
                                    .map((item) => DropdownMenuItem(
                                          child: Text(
                                              item['indexFieldDisplayAs'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              textScaler: TextScaler.linear(1)),
                                          value:
                                              item['indexFieldName'].toString(),
                                        ))
                                    .toList(),
                                //     );
                                //   }
                                // }
                              ),
                            ),
                            SizedBox(height: 10),
                            Divider(thickness: 1),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Search Value : ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14),
                                    textScaler: TextScaler.linear(1)),
                              ),
                            ),
                            // if (isBothDropdownsSelected == true)
                            MediaQuery(
                              data: MediaQuery.of(context)
                                  .copyWith(textScaler: TextScaler.linear(1)),
                              child: TextFormField(
                                controller: advanceSearchValueController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(12),
                                  hintText: "Search Value",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: Responsive.isMobileSmall(
                                                context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 14
                                        : Responsive.isTabletPortrait(context)
                                            ? 15
                                            : 16,
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: Responsive.isMobileSmall(
                                                context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 14
                                        : Responsive.isTabletPortrait(context)
                                            ? 15
                                            : 16,
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0)),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Divider(thickness: 1),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 100,
                                    height: 40,
                                    child: ElevatedButton(
                                      child: Text('RESET',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                          ),
                                          textScaler: TextScaler.linear(1)),
                                      onPressed: () {
                                        setState2(() {
                                          _controllers.forEach((tcontroller) =>
                                              tcontroller.clear());

                                          advanceSearchValueController.clear();
                                          templateType =
                                              dropdownOneWithSelect[0];
                                          fieldVal = "";
                                          fieldsValues = [];
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        backgroundColor: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  SizedBox(
                                    width: 110,
                                    height: 40,
                                    child: ElevatedButton(
                                      child: Text('SEARCH',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                          textScaler: TextScaler.linear(1)),
                                      onPressed: () async {
                                        Navigator.pop(context);

                                        // Navigator.of(context).push(
                                        //   MaterialPageRoute(
                                        //     builder: (context) {
                                        //       return BlocProvider(
                                        //         create: (context) =>
                                        //             DocumentBloc(
                                        //                 username, token),
                                        //         child:
                                        //             AdvancedSearchedListScreen(
                                        //           searchValue:
                                        //               advanceSearchValueController
                                        //                   .text,
                                        //           templateId: templateId,
                                        //           templateName: templateType,
                                        //           fieldId: indexFieldId == 0
                                        //               ? ""
                                        //               : indexFieldId.toString(),
                                        //         ),
                                        //       );
                                        //     },
                                        //   ),
                                        // );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        backgroundColor:
                                            Color.fromARGB(255, 63, 143, 240),
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
                  ],
                ),
              ),
            );
          });
        });
  }

//-----------**********------  DISPLAY TEXT FIELDS ----------*********----------------

  // -------------- Display Normal Text Field-----------------//

  Widget displayTextFormFields(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        style: TextStyle(fontSize: 14, height: 0.03),
        autovalidateMode: AutovalidateMode.always,
        textInputAction: TextInputAction.next,
        controller: _controllers[index],
        onSaved: (newValue) {
          _controllers[index].text == newValue;
          FocusScope.of(context).unfocus();
        },
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            labelText: textFieldvalues2[index]['indexFieldRequiredYN'] == 'Y'
                ? "\* " + textFieldvalues2[index]['indexFieldDisplayAs']
                : textFieldvalues2[index]['indexFieldDisplayAs'],
            hintStyle: TextStyle(
              fontSize: 1,
            )),
        validator: (value) {
          if (textFieldvalues2[index]['indexFieldRequiredYN'] == 'Y' &&
              value!.isEmpty &&
              _validate) {
            return '${textFieldvalues2[index]['indexFieldDisplayAs']} is required';
          }
          return null;
        },
        keyboardType: textFieldvalues2[index]['indexFieldType'] == 'Text' ||
                textFieldvalues2[index]['indexFieldType'] == 'OCR' ||
                textFieldvalues2[index]['indexFieldType'] == "Folder-Name" ||
                textFieldvalues2[index]['indexFieldType'] == "Select"
            ? TextInputType.text
            : TextInputType.datetime,
      ),
    );
  }

  // -------------- Display DateTime Picker-----------------//
  Widget displayDateTimePicker(int index) {
    return GestureDetector(
      onTap: () => _selectDate(context, index),
      child: AbsorbPointer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: TextFormField(
            style: TextStyle(height: 0.02),
            controller: _controllers[index],
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              suffixIcon: Icon(
                Icons.calendar_month,
                size: 25,
              ),
              labelText: textFieldvalues2[index]['indexFieldRequiredYN'] == 'Y'
                  ? "\* " + textFieldvalues2[index]['indexFieldDisplayAs']
                  : textFieldvalues2[index]['indexFieldDisplayAs'],
              border: OutlineInputBorder(),
              errorText: _validate &&
                      textFieldvalues2[index]['indexFieldRequiredYN'] == 'Y' &&
                      _controllers[index].text.isEmpty
                  ? '${textFieldvalues2[index]['indexFieldDisplayAs']} is required'
                  : null,
            ),
            validator: (value) {
              if (textFieldvalues2[index]['indexFieldRequiredYN'] == 'Y' &&
                  value!.isEmpty &&
                  _validate) {
                return '${textFieldvalues2[index]['indexFieldDisplayAs']} is required';
              }
              return null;
            },
            keyboardType: TextInputType.datetime,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.amber,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _controllers[index].text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // ----------------------- Display pd_data dropdown ---------------//
  Widget displayPdDataDropdowns(int index) {
    if (textFieldvalues2[index]['pd_data'] != null &&
        textFieldvalues2[index]['pd_data'].isNotEmpty) {
      _selectedValue = textFieldvalues2[index]['pd_data'][0]['templateId'];
    }

    List<dynamic> dropdownValues = ["Please Select"];

    var pdDataList = textFieldvalues2[index]['pd_data'];
    if (pdDataList != null) {
      for (var pdData in pdDataList) {
        dropdownValues.add(pdData['templateId']);
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: SizedBox(
        height: 60,
        child: DropdownButtonFormField(
          hint: Text("Please Select..."),
          // child: DropdownButton<String>(
          decoration: InputDecoration(
            labelText: textFieldvalues2[index]['indexFieldRequiredYN'] == 'Y'
                ? "\* " + textFieldvalues2[index]['indexFieldDisplayAs']
                : textFieldvalues2[index]['indexFieldDisplayAs'],
            border: OutlineInputBorder(),
          ),
          value: _selectedValue,
          onChanged: (newValue) {
            setState(() {
              _selectedValue = newValue!;
              _controllers[index].text = newValue.toString();
            });
          },
          items: textFieldvalues2[index]['pd_data']
              .map<DropdownMenuItem<String>>((pdDataValue) {
            return DropdownMenuItem<String>(
              value: pdDataValue['templateId'],
              child: Text(
                pdDataValue['templateId'],
                style: TextStyle(
                  fontSize: 13.5,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // -------------- Display Checkbox-----------------//

  Widget displayCheckbox(int index) {
    return CheckboxListTile(
      title: Text(
        textFieldvalues2[index]['indexFieldDisplayAs'],
        style: TextStyle(fontSize: 16.0, color: Colors.black54),
      ),
      value: isCheckBoxMarked,
      onChanged: (bool? value) {
        setState(() {
          isCheckBoxMarked = value!;
        });
      },
      activeColor: Colors.amber,
      checkColor: Colors.black,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget ImportantWordsSearchTwo() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 0),
      child: TextFormField(
        controller: imporatntWordsSearchController2,
        style: TextStyle(fontSize: 11, height: 0.03, color: Colors.black),
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Type the importance words",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }

  Widget ImporatntWordsSearchOne() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 0),
      child: TextFormField(
        controller: imporatntWordsSearchController1,
        style: TextStyle(fontSize: 11, height: 0.04, color: Colors.black),
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Type the importance words",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }

  Widget DateRangeSearch(BuildContext context, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 0),
      child: Row(
        children: [
          Flexible(
            child: TextFormField(
              style: TextStyle(fontSize: 12, height: 0.05, color: Colors.black),
              controller: searchFromController,
              readOnly: true,
              onTap: () async {
                DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2001),
                    lastDate: DateTime(2222));
                if (selectedDate != null) {
                  setState(() {
                    searchStartDate = selectedDate;
                    searchFromController.text =
                        DateFormat('yyyy-MM-dd').format(searchStartDate!);
                  });
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "From Date",
                labelStyle: TextStyle(
                  color: Colors.black45,
                  fontSize: Responsive.isMobileSmall(context) ||
                          Responsive.isMobileMedium(context)
                      ? size.width * 0.035
                      : Responsive.isMobileLarge(context)
                          ? size.width * 0.037
                          : Responsive.isTabletPortrait(context)
                              ? size.width * 0.016
                              : size.width * 0.06,
                ),
                hintText: "Enter date",
                errorText: _validate && searchFromController.text.isEmpty
                    ? 'From Date cannot be empty.'
                    : null,
                prefixIcon: Icon(Icons.calendar_month, size: 25),
              ),
            ),
          ),
          SizedBox(width: 10),
          // ---------------End Date Text Field ------------//
          Flexible(
            child: TextFormField(
              controller: searchToController,
              readOnly: true,
              onTap: () async {
                DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2001),
                    lastDate: DateTime(2222));
                if (selectedDate != null) {
                  setState(() {
                    searchEndDate = selectedDate;
                    searchToController.text =
                        DateFormat('yyyy-MM-dd').format(searchEndDate!);
                  });
                }
              },
              style: TextStyle(fontSize: 12, height: 0.05, color: Colors.black),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "To Date",
                labelStyle: TextStyle(
                  color: Colors.black45,
                  fontSize: Responsive.isMobileSmall(context) ||
                          Responsive.isMobileMedium(context)
                      ? size.width * 0.035
                      : Responsive.isMobileLarge(context)
                          ? size.width * 0.037
                          : Responsive.isTabletPortrait(context)
                              ? size.width * 0.016
                              : size.width * 0.06,
                ),
                hintText: "Enter date",
                errorText: _validate && searchToController.text.isEmpty
                    ? 'To Date cannot be empty.'
                    : null,
                prefixIcon: Icon(Icons.calendar_month, size: 25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget FromCountToCountSearch() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextFormField(
              style: TextStyle(fontSize: 12, height: 0.05, color: Colors.black),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.black54, fontSize: 12),
                hintText: "From (1574)",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ),
          SizedBox(width: 10),
          Flexible(
            child: TextFormField(
              style: TextStyle(fontSize: 12, height: 0.05, color: Colors.black),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "To (3651)",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget SearchResetButtons() {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: 15),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         SizedBox(
  //           width: 100,
  //           height: 40,
  //           child: ElevatedButton(
  //             child: Text(
  //               'RESET',
  //               style: GoogleFonts.alegreya(
  //                 textStyle: Theme.of(context).textTheme.bodyMedium,
  //                 fontSize: 15,
  //                 fontWeight: FontWeight.w700,
  //                 color: Colors.black,
  //               ),
  //             ),
  //             onPressed: () {
  //               setState(() {
  //                 _controllers.forEach((tcontroller) => tcontroller.clear());
  //               });
  //             },
  //             style: ElevatedButton.styleFrom(
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(5),
  //               ),
  //               backgroundColor: Colors.grey[400],
  //             ),
  //           ),
  //         ),
  //         SizedBox(width: 10),
  //         SizedBox(
  //           width: 110,
  //           height: 40,
  //           child: ElevatedButton(
  //             child: Text(
  //               'SEARCH',
  //               style: GoogleFonts.alegreya(
  //                 textStyle: Theme.of(context).textTheme.bodyMedium,
  //                 fontSize: 15,
  //                 fontWeight: FontWeight.w700,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             onPressed: () async {
  //               Navigator.pop(context);
  //               Navigator.of(context).push(
  //                 MaterialPageRoute(
  //                   builder: (context) => AdvancedSearchedListScreen(
  //                     searchValue: advanceSearchValueController.text,
  //                     templateId: templateId,
  //                     templateName: templateType,
  //                     fieldId: indexFieldId,
  //                   ),
  //                 ),
  //               );
  //             },
  //             style: ElevatedButton.styleFrom(
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(5),
  //               ),
  //               backgroundColor: Color.fromARGB(255, 63, 143, 240),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
