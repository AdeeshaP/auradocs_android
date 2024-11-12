import 'dart:convert';
import 'package:auradocs_android/API-Services/api_service.dart';
import 'package:auradocs_android/screens/File-Picker/file_picker_screen.dart';
import 'package:auradocs_android/screens/Pending-Docs/pending_doc_list.dart';
import 'package:auradocs_android/screens/contact_us_screen.dart';
import 'package:auradocs_android/screens/home_screen.dart';
import 'package:auradocs_android/utils/alert_dialogs.dart';
import 'package:auradocs_android/utils/constants.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/users.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../Sliders/landing_page.dart';

// ignore: must_be_immutable
class UploadFileListScreen extends StatefulWidget {
  UploadFileListScreen({
    super.key,
    required this.fileNames2,
  });

  // File? file1;
  final List<File> fileNames2;

  @override
  State<UploadFileListScreen> createState() => _UploadFileListScreenState();
}

class _UploadFileListScreenState extends State<UploadFileListScreen> {
  late SharedPreferences _storage;
  Map<String, dynamic>? userObj;
  String username = "";
  String token = "";
  String compnyCode = "";
  String folderName = "";
  Uint8List? imageValueBytes;
  String mimeType = "";
  List<int> bytes = [];
  bool isLoading = true;
  String? templateType;
  int templateId = 0;
  TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  String pth2 = "";
  String pendingFolderName = "";
  TextEditingController emailContoller = new TextEditingController();
  TextEditingController foldercontroller = new TextEditingController();
  List<File?> mediaAttachments = [];
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
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
    if (mounted)
      setState(() {
        username = userObj!["value"]["userName"];
        token = _storage.getString('token')!;
        compnyCode = _storage.getString('code')!;
        mediaAttachments = widget.fileNames2;

        String? authListJson = _storage.getString('authentication');
        authentication = authListJson != null
            ? List<String>.from(jsonDecode(authListJson))
            : [];

        print("Authentication2: $authentication");
      });

    emailContoller.text = username;
    getViewedFileData();
  }

  Future<void> getViewedFileData() async {
    List paths = mediaAttachments.map((e) => e?.path).toList();
    print(paths);

    for (String? path in paths) {
      if (path != null) {
        List<int> bytesOfImg = await File(path).readAsBytes();
        String extensionX = p.extension(path).substring(1);
        String mimeType = '';

        print(extensionX);

        mimeType = lookupMimeType(path)!;

        String viewedFileBase64String = base64.encode(bytesOfImg);

        final fileName = path.split('/').last;

        print("File submitted: $fileName");
        print("MIME Type: $mimeType");
        print("Base64 String: $viewedFileBase64String");
      }
    }
  }

  Future<void> uploadDocumentsToPendingList() async {
    showProgressDialog(context);

    List<Map<String, dynamic>> payloadImageList = [];

    pendingFolderName = foldercontroller.text;

    for (int i = 0; i < mediaAttachments.length; i++) {
      String filePath = mediaAttachments[i]?.path ?? '';
      List<int> bytesOfImg = await File(filePath).readAsBytes();
      // String mimeType = lookupMimeType(filePath)!;
      String viewedFileBase64String = base64.encode(bytesOfImg);
      String fileName = filePath.split('/').last;

      Map<String, dynamic> payloadImage = {};

      String nameWithoutExtension = p.basenameWithoutExtension(fileName);
      String extension2 = p.extension(fileName).substring(1);

      print('Filename without extension: $nameWithoutExtension');
      print('Extension: $extension2');

      payloadImage['mime/type'] = "application/${extension2}";
      payloadImage['valueImage'] = viewedFileBase64String;
      payloadImage['fileName'] = nameWithoutExtension;

      payloadImageList.add(payloadImage);
    }

    final pl = jsonEncode(payloadImageList);

    var response4 =
        await ApiService.uploadFolder(token, username, pendingFolderName, pl);

    print('Response body: ${response4.body}');
    closeDialog(context);

    if (response4.statusCode == 200) {
      shareFileSuccessPopup(
        context,
        widget.fileNames2.length == 1
            ? "File Uploaded Successfully."
            : "Files Uploaded Successfully.",
        'assets/images/success-green-icon.png',
        PendingDocsListScreen(),
        Color.fromARGB(255, 237, 172, 10),
      );
    } else if (response4.statusCode == 500) {
      showWarningDialogPopup(
        context,
        Icons.warning,
        "Server error! Please contact auraDOCS administrator.",
        okRecognition,
        Color.fromARGB(255, 237, 172, 10),
      );
    } else {
      print('Upload failed');
      showWarningDialogPopup(
        context,
        Icons.warning,
        "Upload failed. Folder name is required.",
        okRecognition,
        Color.fromARGB(255, 237, 172, 10),
      );
    }
  }

  String _extension(String filePath) {
    return p.extension(filePath).substring(1);
  }

  Widget setFileIcon(String filePath) {
    String ext = _extension(filePath);
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
            builder: (context) => FilePickerScreen(),
          ),
          (route) => false,
        );
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(children: [
              getSearchBoxWidget(),
              Divider(height: 8),
              SizedBox(
                  height: Responsive.isMobileSmall(context)
                      ? size.height * 0.86
                      : Responsive.isMobileMedium(context)
                          ? size.height * 0.85
                          : Responsive.isMobileLarge(context)
                              ? size.height * 0.85
                              : Responsive.isTabletPortrait(context)
                                  ? size.height * 0.9
                                  : size.height * 0.85,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: _scrollController,
                    child: Column(
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
                                        Icons.ios_share_outlined,
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
                                        "Upload Docs",
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
                                          builder: (context) =>
                                              FilePickerScreen(),
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
                                )
                              ],
                            ),
                            color: Colors.amber[700],
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  height: mediaAttachments.length > 3
                                      ? MediaQuery.of(context).size.height *
                                          0.45
                                      : MediaQuery.of(context).size.height *
                                          0.35,
                                  child: ListView.separated(
                                    scrollDirection: Axis.vertical,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemCount: mediaAttachments.length,
                                    itemBuilder: ((context, index) {
                                      String filePath =
                                          mediaAttachments[index]?.path ?? '';
                                      String fileName =
                                          filePath.split('/').last;

                                      return Container(
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black54),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: ListTile(
                                          dense: true,
                                          leading: Container(
                                            padding: EdgeInsets.all(5),
                                            width: size.width * 0.15,
                                            height: size.width * 0.15,
                                            color: Colors.grey[300],
                                            child: setFileIcon(filePath),
                                          ),
                                          title: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                fileName,
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: Responsive
                                                          .isMobileSmall(
                                                              context)
                                                      ? 13
                                                      : Responsive.isMobileMedium(
                                                                  context) ||
                                                              Responsive
                                                                  .isMobileLarge(
                                                                      context)
                                                          ? 14
                                                          : Responsive
                                                                  .isTabletPortrait(
                                                                      context)
                                                              ? 19
                                                              : 17,
                                                ),
                                                textScaler:
                                                    TextScaler.linear(1),
                                              ),
                                            ],
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          tileColor: Colors.white,
                                          shape: BeveledRectangleBorder(
                                            side: BorderSide(
                                              width: 2,
                                              color: Colors.white,
                                              style: BorderStyle.solid,
                                              strokeAlign: 10,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                      );
                                    }),
                                    separatorBuilder: (context, index) {
                                      return Divider(height: 8);
                                    },
                                    shrinkWrap: true,
                                  ),
                                ),
                                SizedBox(height: 35),
                                Form(
                                  key: _formkey,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        MediaQuery(
                                          data: MediaQuery.of(context).copyWith(
                                            textScaler: TextScaler.linear(1),
                                          ),
                                          child: TextFormField(
                                            autovalidateMode:
                                                AutovalidateMode.always,
                                            autocorrect: true,
                                            controller: emailContoller,
                                            autofocus: false,
                                            onSaved: (value) {
                                              emailContoller.text = value!;
                                            },
                                            enabled: false,
                                            textInputAction:
                                                TextInputAction.next,
                                            keyboardType:
                                                TextInputType.emailAddress,
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
                                                    ? size.width * 0.045
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? size.width * 0.028
                                                        : size.width * 0.045,
                                                height: Responsive
                                                            .isMobileSmall(
                                                                context) ||
                                                        Responsive
                                                            .isMobileMedium(
                                                                context) ||
                                                        Responsive
                                                            .isMobileLarge(
                                                                context)
                                                    ? 0.5
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? size.width * 0.001
                                                        : size.width * 0.005,
                                                color: Colors.black),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.grey[200],
                                              border: OutlineInputBorder(),
                                              labelText: "Username",
                                              labelStyle: TextStyle(
                                                color: Colors.black54,
                                                fontSize: Responsive
                                                            .isMobileSmall(
                                                                context) ||
                                                        Responsive
                                                            .isMobileMedium(
                                                                context) ||
                                                        Responsive
                                                            .isMobileLarge(
                                                                context)
                                                    ? size.width * 0.04
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? size.width * 0.02
                                                        : size.width * 0.04,
                                              ),
                                              prefixIconConstraints:
                                                  BoxConstraints(minWidth: 40),
                                              prefixIcon: Icon(
                                                Icons.person,
                                                size: Responsive.isMobileSmall(
                                                            context) ||
                                                        Responsive
                                                            .isMobileMedium(
                                                                context) ||
                                                        Responsive
                                                            .isMobileLarge(
                                                                context)
                                                    ? size.width * 0.07
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? size.width * 0.035
                                                        : size.width * 0.025,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        MediaQuery(
                                          data: MediaQuery.of(context).copyWith(
                                            textScaler: TextScaler.linear(1),
                                          ),
                                          child: TextFormField(
                                            autovalidateMode:
                                                AutovalidateMode.always,
                                            autocorrect: true,
                                            controller: foldercontroller,
                                            autofocus: false,
                                            onSaved: (value) {
                                              foldercontroller.text = value!;
                                            },
                                            textInputAction:
                                                TextInputAction.next,
                                            keyboardType: TextInputType.text,
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
                                                    ? size.width * 0.045
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? size.width * 0.028
                                                        : size.width * 0.045,
                                                height: Responsive
                                                            .isMobileSmall(
                                                                context) ||
                                                        Responsive
                                                            .isMobileMedium(
                                                                context) ||
                                                        Responsive
                                                            .isMobileLarge(
                                                                context)
                                                    ? 0.05
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? size.width * 0.001
                                                        : size.width * 0.005,
                                                color: Colors.black),
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: "Folder Name",
                                              labelStyle: TextStyle(
                                                color: Colors.black54,
                                                fontSize: Responsive
                                                            .isMobileSmall(
                                                                context) ||
                                                        Responsive
                                                            .isMobileMedium(
                                                                context) ||
                                                        Responsive
                                                            .isMobileLarge(
                                                                context)
                                                    ? size.width * 0.04
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? size.width * 0.02
                                                        : size.width * 0.04,
                                              ),
                                              prefixIconConstraints:
                                                  BoxConstraints(minWidth: 40),
                                              prefixIcon: Icon(
                                                Icons.folder_copy,
                                                color: Colors.grey,
                                                size: Responsive.isMobileSmall(
                                                            context) ||
                                                        Responsive
                                                            .isMobileMedium(
                                                                context) ||
                                                        Responsive
                                                            .isMobileLarge(
                                                                context)
                                                    ? size.width * 0.07
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? size.width * 0.035
                                                        : size.width * 0.025,
                                              ),
                                              hintText: "Enter the folder name",
                                              hintStyle: TextStyle(
                                                  color: Colors.white60,
                                                  fontSize: size.width * 0.04),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20),
                                          child: TextButton.icon(
                                            icon: Icon(
                                              Icons.file_upload,
                                              size: Responsive.isMobileSmall(
                                                      context)
                                                  ? 20
                                                  : Responsive.isMobileMedium(
                                                              context) ||
                                                          Responsive
                                                              .isMobileLarge(
                                                                  context)
                                                      ? 22
                                                      : Responsive
                                                              .isTabletPortrait(
                                                                  context)
                                                          ? 24
                                                          : 25,
                                              color: Colors.white,
                                            ),
                                            label: Text(
                                              "Upload",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: Responsive
                                                        .isMobileSmall(context)
                                                    ? 15
                                                    : Responsive.isMobileMedium(
                                                                context) ||
                                                            Responsive
                                                                .isMobileLarge(
                                                                    context)
                                                        ? 16
                                                        : Responsive
                                                                .isTabletPortrait(
                                                                    context)
                                                            ? size.width * 0.03
                                                            : size.width * 0.06,
                                              ),
                                              textScaler: TextScaler.linear(1),
                                            ),
                                            style: TextButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              backgroundColor: username == ""
                                                  ? Colors.grey
                                                  : Color.fromARGB(
                                                      255, 237, 172, 10),
                                              minimumSize: Size(150, 40),
                                            ),
                                            onPressed: () async {
                                              username == ""
                                                  ? () {}
                                                  : uploadDocumentsToPendingList();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ]),
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
