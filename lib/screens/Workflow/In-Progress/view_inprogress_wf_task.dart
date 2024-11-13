import 'dart:convert';
import 'package:auradocs_android/API-Services/api_service.dart';
import 'package:auradocs_android/Bloc/document_bloc.dart';
import 'package:auradocs_android/Models/users.dart';
import 'package:auradocs_android/screens/Document-Search/search_list.dart';
import 'package:auradocs_android/screens/Sliders/landing_page.dart';
import 'package:auradocs_android/screens/Workflow/In-Progress/in_progress_wf.dart';
import 'package:auradocs_android/screens/contact_us_screen.dart';
import 'package:auradocs_android/screens/home_screen.dart';
import 'package:auradocs_android/utils/alert_dialogs.dart';
import 'package:auradocs_android/utils/constants.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ViewInProgressWFTask extends StatefulWidget {
  const ViewInProgressWFTask({
    super.key,
    required this.indexOfCurrent,
    required this.taskName,
    required this.taskId,
  });

  final int indexOfCurrent;
  final String taskName;
  final String taskId;

  @override
  State<ViewInProgressWFTask> createState() => _ViewInProgressWFTaskState();
}

class _ViewInProgressWFTaskState extends State<ViewInProgressWFTask> {
  String textFileContent = "";
  late SharedPreferences _storage;
  Map<String, dynamic>? userObj;
  String username = "";
  String token = "";
  List authentication = [];
  List<dynamic> valList = [];
  String operation = "";
  TextEditingController searchController = TextEditingController();
  String compnyCode = "";
  String trimmedValue = "";
  GlobalKey _toolTipKey = GlobalKey();
  List<Widget> _formWidgets = []; // Store form widgets here
  String? selectedRadioValue; // Stores the selected radio button value
  bool? checkboxValue = false; // Stores checkbox state
  Map<String, String?> dropdownValues = {};
  Map<String, TextEditingController> textControllers = {};
  Map<String, dynamic> selectedValues = {};
  Map<String, bool> checkboxValues = {};
  bool checkedValue = false;

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

    getTextFieldsForTask(widget.taskId, token);
  }

  Future<void> getTextFieldsForTask(String taskId, String usertoken) async {
    var response =
        await ApiService.getFormFieldsForWFPendingTask(taskId, usertoken);

    print("what is the response $response");
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      // Check if 'components' attribute exists
      if (responseBody['value'] != null &&
          responseBody['value']['form'] != null) {
        List<dynamic> components = responseBody['value']['form']['components'];

        // Pass components to a function that builds the form
        buildForm(components); // Build the form UI with components
      }
    } else if (response.statusCode == 404) {
      showWarningDialogPopup(
        context,
        Icons.warning,
        "Not Found",
        okRecognition,
        Color.fromARGB(255, 237, 172, 10),
      );
    } else if (response.statusCode == 500) {
      showWarningDialogPopup(
        context,
        Icons.warning,
        "Internal server error! Please contact auraDOCS administrator.",
        okRecognition,
        Color.fromARGB(255, 237, 172, 10),
      );
    }
  }

  void buildForm(List<dynamic> components) {
    setState(() {
      _formWidgets = components.map((component) {
        return createWidget(
            component); // Creates widget based on component type
      }).toList();
    });
  }

  Widget createWidget(Map<String, dynamic> component) {
    switch (component['type']) {
      case 'text':
        // Check if HTML content is present and render using Html widget
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: component['text'] != null
              ? Html(data: component['text'])
              : Text(
                  component['label'] ?? '',
                  style: TextStyle(fontSize: 16),
                ),
        );
      case 'spacer':
        return SizedBox(height: component['height']?.toDouble() ?? 10.0);

      case 'separator':
        return Divider(
          color: Colors.grey,
          thickness: 1.0,
          height: 20.0,
        );
      // case 'html':
      //   // Check if HTML content is present and render using Html widget
      //   return SizedBox(
      //     height: 100, // Adjust height as needed
      //     child: WebView(
      //       initialUrl: Uri.dataFromString(
      //         component['content'],
      //         mimeType: 'text/html',
      //         encoding: Encoding.getByName('utf-8'),
      //       ).toString(),
      //       javascriptMode: JavascriptMode.unrestricted,
      //     ),
      //   );
      case 'datetime':
        // TextEditingController dateController = TextEditingController();
        textControllers[component['key']] = TextEditingController();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5),
          child: TextFormField(
            controller: textControllers[component['key']],
            readOnly: true,
            decoration: InputDecoration(
              labelText: component['dateLabel'] ?? component['label'],
              prefixIcon: Icon(Icons.calendar_month),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                (textControllers[component['key']])!.text =
                    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
              }
            },
          ),
        );
      case 'number':
        // TextEditingController numberController = TextEditingController();
        textControllers[component['key']] = TextEditingController();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5),
          child: TextFormField(
            controller: textControllers[component['key']],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
              labelText: component['label'],
              labelStyle: TextStyle(
                fontSize: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 14
                    : Responsive.isTabletPortrait(context)
                        ? 15
                        : 16,
              ),
            ),
          ),
        );
      case 'textfield':
        // TextEditingController fieldController = TextEditingController();
        textControllers[component['key']] = TextEditingController();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5),
          child: TextFormField(
            controller: textControllers[component['key']],
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
              labelText: component['label'],
              labelStyle: TextStyle(
                fontSize: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 14
                    : Responsive.isTabletPortrait(context)
                        ? 15
                        : 16,
              ),
            ),
          ),
        );
      case 'textarea':
        // TextEditingController areaController = TextEditingController();
        textControllers[component['key']] = TextEditingController();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
          child: TextFormField(
            controller: textControllers[component['key']],
            decoration: InputDecoration(
              labelText: component['label'],
              labelStyle: TextStyle(
                fontSize: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 14
                    : Responsive.isTabletPortrait(context)
                        ? 15
                        : 16,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
            ),
            maxLines: 3,
          ),
        );

      case 'radio':
        selectedValues[component['key']] ??= null;

        return StatefulBuilder(
          builder: (context, _setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(component['label'] ?? '',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ...component['values'].map<Widget>((option) {
                    return RadioListTile(
                      contentPadding: EdgeInsets.zero,
                      title:
                          Text(option['label'], style: TextStyle(fontSize: 14)),
                      value: option['value'],
                      groupValue: selectedValues[component['key']],
                      onChanged: (newValue) {
                        _setState(() {
                          selectedValues[component['key']] = newValue;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      case 'checkbox':
        selectedValues[component['key']] ??= false;

        return StatefulBuilder(
          builder: (context, _setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: CheckboxListTile(
                title: Text(component['label'],
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    )),
                value: selectedValues[component['key']],
                onChanged: (bool? value) {
                  _setState(() {
                    selectedValues[component['key']] = value;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            );
          },
        );

      case 'checklist':
        selectedValues[component['key']] ??= <String>{};

        return StatefulBuilder(builder: (context, setState2) {
          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    component['label'] ?? '',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ...component['values'].map<Widget>((option) {
                    return CheckboxListTile(
                      title:
                          Text(option['label'], style: TextStyle(fontSize: 14)),
                      value: selectedValues[component['key']]
                          .contains(option['value']),
                      onChanged: (bool? isChecked) {
                        setState2(() {
                          if (isChecked == true) {
                            selectedValues[component['key']]
                                .add(option['value']);
                          } else {
                            selectedValues[component['key']]
                                .remove(option['value']);
                          }
                        });
                      },
                    );
                  }).toList(),
                ],
              ));
        });

      case 'select':
        List<dynamic> options = component['values'] ?? [];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5),
          child: DropdownButtonFormField(
            isExpanded: true,
            decoration: InputDecoration(
              labelText: component['label'],
              contentPadding: EdgeInsets.all(12),
              labelStyle: TextStyle(
                fontSize: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 14
                    : Responsive.isTabletPortrait(context)
                        ? 15
                        : 16,
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
            ),
            value: dropdownValues[component['key']], // Initial value
            items: options.map<DropdownMenuItem<String>>((option) {
              return DropdownMenuItem<String>(
                value: option['value'].toString(),
                child: Text(option['label']),
              );
            }).toList(),

            onChanged: (newValue) {
              setState(() {
                dropdownValues[component['key']] = newValue!;
              });
            },
          ),
        );

      case 'image':
        // Check for base64-encoded image data in the 'source' field
        String base64Image = component['source'] ?? '';
        // String label = component['label'] ?? '';

        if (base64Image.isEmpty) {
          return Text('No image available'); // Fallback if source is missing
        }
        // Remove the prefix 'data:image/png;base64,' from the base64 string
        final String base64String = base64Image.split(',').last;
        // Decode the base64 string and display as Image widget
        Uint8List imageBytes = base64Decode(base64String);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
              child: Image.memory(
                imageBytes,
                fit: BoxFit.contain,
              ),
            ),
          ],
        );

      case 'iframe':
        bool allowScripts = component['security']?['allowScripts'] ?? false;
        String url = component['url'] ?? '';

        if (url.isEmpty) {
          return Text('No content available'); // Fallback for missing URL
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5),
          height: component['height'].toDouble(),
          child: WebView(
            gestureRecognizers: Set()
              ..add(
                Factory<VerticalDragGestureRecognizer>(
                  () => VerticalDragGestureRecognizer(),
                ),
              ),
            initialUrl: url,
            javascriptMode: allowScripts
                ? JavascriptMode.unrestricted
                : JavascriptMode.disabled,
          ),
        );
      case 'button':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: ElevatedButton(
            onPressed: () {
              // Define the submit action
            },
            child: Text(
              // component['action'] ?? 'Submit',

              capitalizeFirstLetter(component['action']),
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(120, 40),
              backgroundColor: const Color.fromARGB(255, 194, 176, 176),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      default:
        return Container();
    }
  }

  String capitalizeFirstLetter(String word) {
    if (word.isEmpty) {
      return word; // Return empty string if input is empty
    }
    return word[0].toUpperCase() + word.substring(1);
  }

  void okRecognition() {
    closeDialog(context);
  }

  void okRecognitionAndGoBackScreen() {
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
            height: size.height,
            child: Column(
              children: <Widget>[
                getSearchBoxWidget(),
                Divider(height: 8),
                Stack(
                  children: <Widget>[
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
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
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
                                  Text(
                                    widget.taskName.length > 35
                                        ? '${widget.taskName.substring(0, 35)}...'
                                        : widget.taskName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: Responsive.isMobileSmall(
                                              context)
                                          ? 14
                                          : Responsive.isMobileMedium(
                                                      context) ||
                                                  Responsive.isMobileLarge(
                                                      context)
                                              ? 16
                                              : Responsive.isTabletPortrait(
                                                      context)
                                                  ? 18
                                                  : 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textScaler: TextScaler.linear(1),
                                  ),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              InProgressScreen(),
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
                                              ? 30
                                              : 25,
                                    ),
                                  ),
                                ],
                              ),
                              color: Color.fromARGB(255, 70, 68, 67),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              child: Text(
                                "Complete Task",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: Responsive.isMobileSmall(context)
                                      ? 16
                                      : Responsive.isMobileMedium(context) ||
                                              Responsive.isMobileLarge(context)
                                          ? 18
                                          : Responsive.isTabletPortrait(
                                                  context)
                                              ? 22
                                              : 21,
                                  fontWeight: FontWeight.bold,
                                ),
                                textScaler: TextScaler.linear(1.2),
                              ),
                            ),
                            Container(
                              height: size.height * 0.5,
                              child: ListView(
                                children: _formWidgets,
                              ),
                            ),
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
                                    Icon(
                                      Icons.assignment,
                                      color: Colors.white,
                                      size: Responsive.isMobileSmall(
                                                  context) ||
                                              Responsive.isMobileMedium(
                                                  context) ||
                                              Responsive.isMobileLarge(context)
                                          ? 25
                                          : 35,
                                    ),
                                    SizedBox(
                                      width: Responsive.isMobileSmall(
                                                  context) ||
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
                                color: Color.fromARGB(255, 233, 104, 44),
                              ),
                            ),
                            Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 1),
                                  child: Container(
                                    height: Responsive.isMobileSmall(
                                                context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 48
                                        : Responsive.isTabletPortrait(context)
                                            ? 60
                                            : 65,
                                    padding: EdgeInsets.all(8),
                                    width: double.infinity,
                                    child: displayIconsBar(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "View",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: Responsive.isMobileSmall(
                                                  context)
                                              ? 16
                                              : Responsive.isMobileMedium(
                                                          context) ||
                                                      Responsive.isMobileLarge(
                                                          context)
                                                  ? 17
                                                  : Responsive
                                                          .isTabletPortrait(
                                                              context)
                                                      ? 22
                                                      : 21,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(
                                        Icons.visibility,
                                        size: 25,
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.transparent, width: 1.0),
                                  ),
                                  height: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.66
                                      : Responsive.isTabletPortrait(context)
                                          ? size.height * 0.8
                                          : size.height * 0.6,
                                  // height: 260,
                                  child: Scrollbar(
                                    thickness: 5,
                                    child: SingleChildScrollView(
                                      scrollDirection: scrollDirection,
                                      child: Column(
                                        children: <Widget>[],
                                      ),
                                    ),
                                  ),
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

  Widget displayIconsBar() {
    return SingleChildScrollView(
      scrollDirection: scrollDirection,
      child: Row(
        children: <Widget>[
          Container(
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
              onPressed: () {},
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
              onPressed: () {},
              icon: Icon(
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
