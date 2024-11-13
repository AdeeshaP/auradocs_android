// ignore_for_file: must_be_immutable
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:auradocs_android/API-Services/api_service.dart';
import 'package:auradocs_android/screens/File-sharing/login_modal_bottom_sheet.dart';
import 'package:auradocs_android/screens/Pending-Docs/pending_doc_list.dart';
import 'package:auradocs_android/utils/alert_dialogs.dart';
import 'package:auradocs_android/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:share_handler/share_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;

class ShareingFilesReceiveScreen extends StatefulWidget {
  ShareingFilesReceiveScreen({
    Key? key,
    required this.sharedMedia,
    required this.userName,
    required this.token,
    required this.code,
  }) : super(key: key);

  SharedMedia sharedMedia;
  String userName;
  String token;
  String code;

  @override
  State<ShareingFilesReceiveScreen> createState() =>
      _ShareingFilesReceiveScreenState();
}

class _ShareingFilesReceiveScreenState
    extends State<ShareingFilesReceiveScreen> {
  Map<String, dynamic>? userObj;
  TextEditingController emailContoller = new TextEditingController();
  TextEditingController foldercontroller = new TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String user = "";
  String tokenOfUser = "";
  String compnayCode = "";
  String filename = "";
  String filename2 = "";
  String mimeType = "";
  Uint8List? bytesImage;
  VideoPlayerController? _videoPlayerController;
  AudioPlayer audioplayer = AudioPlayer();
  String textFileContent = "";
  bool isPlaying = false;
  String viewdFileBase64String = "";
  List<SharedAttachment?> mediaAttachments = [];
  List<List<dynamic>> csvData = [];
  File? pdfFile;
  File? inageFile;
  String pth2 = "";
  String pendingFName = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    getViewedFileData();
  }

  @override
  void dispose() {
    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
    }
    audioplayer.dispose();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    ShareHandler.instance.sharedMediaStream.listen((SharedMedia media) {
      setState(() {
        widget.sharedMedia = media;
      });
    });

    setState(() {
      user = widget.userName;
      compnayCode = widget.code;
      tokenOfUser = widget.token;
      mediaAttachments = widget.sharedMedia.attachments!;
    });

    if (mounted) {
      setState(() {
        ApiService.companyCode = compnayCode;
      });
    }
    emailContoller.text = user;

    if (user == "") {
      Future.delayed(Duration(seconds: 2), () {
        _showTheStatusIfUserNotLogin();
      });
    }
  }

  _showTheStatusIfUserNotLogin() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return LoginModalBottomSheet();
      },
    );
  }

  void okRecognition() {
    closeDialog(context);
  }

  Future<void> getViewedFileData() async {
    List paths = mediaAttachments.map((e) => e?.path).toList();

    for (String? path in paths) {
      if (path != null) {
        String extensionX = p.extension(path).substring(1);

        if (extensionX == "jpg" || extensionX == "JPG") {
          mimeType = 'image/jpg';
        } else if (extensionX == "jpeg" || extensionX == "JPEG") {
          mimeType = 'image/jpeg';
        } else if (extensionX == "png" || extensionX == "PNG") {
          mimeType = 'image/png';
        } else if (extensionX == "gif" || extensionX == "GIF") {
          mimeType = 'image/gif';
        } else {
          mimeType = lookupMimeType(path)!;
        }
      }
    }
  }

  Future<void> uploadDocumentsToPendingList() async {
    showProgressDialog(context);

    List<Map<String, dynamic>> payloadImageList = [];

    pendingFName = foldercontroller.text;

    for (int i = 0; i < mediaAttachments.length; i++) {
      String filePath = mediaAttachments[i]?.path ?? '';
      List<int> bytesOfImg = await File(filePath).readAsBytes();
      // String mimeType = lookupMimeType(filePath)!;
      String viewedFileBase64String = base64.encode(bytesOfImg);
      String fileName = filePath.split('/').last;

      Map<String, dynamic> payloadImage = {};
      // payloadImage['mime/type'] = mimeType;
      //      // payloadImage['fileName'] = fileName;

      payloadImage['valueImage'] = viewedFileBase64String;

      String nameWithoutExtension = p.basenameWithoutExtension(fileName);

      String extension2 = p.extension(fileName).substring(1);

      payloadImage['mime/type'] = "application/${extension2}";
      payloadImage['fileName'] = nameWithoutExtension;

      payloadImageList.add(payloadImage);
    }
    print("pending F name : $pendingFName");

    final pl = jsonEncode(payloadImageList);

    var response4 =
        await ApiService.uploadFolder(tokenOfUser, user, pendingFName, pl);

    print('Response body: ${response4.body}');
    closeDialog(context);

    print('response4.statusCode: ${response4.statusCode}');

    if (response4.statusCode == 200) {
      shareFileSuccessPopup(
        context,
        mediaAttachments.length == 1
            ? "File Shared Successfully."
            : "Files Shared Successfully.",
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
        "Sharing failed. Folder name is required.",
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
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: Container(
            height: size.height,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background_three.jpg"),
                fit: BoxFit.fill,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20),
                  Image.asset(
                    "assets/images/auradocs_logo-transparent.png",
                    scale: 1,
                    width: 400,
                    height: 80,
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: mediaAttachments.length > 3
                        ? MediaQuery.of(context).size.height * 0.45
                        : MediaQuery.of(context).size.height * 0.35,
                    child: ListView.separated(
                      scrollDirection: Axis.vertical,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: mediaAttachments.length,
                      itemBuilder: ((context, index) {
                        String filePath = mediaAttachments[index]?.path ?? '';
                        String fileName = filePath.split('/').last;

                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(5),
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fileName,
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                    fontSize: Responsive.isMobileSmall(context)
                                        ? 13
                                        : Responsive.isMobileMedium(context) ||
                                                Responsive.isMobileLarge(
                                                    context)
                                            ? 15
                                            : Responsive.isTabletPortrait(
                                                    context)
                                                ? 19
                                                : 17,
                                  ),
                                  textScaler: TextScaler.linear(1),
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
                              borderRadius: BorderRadius.circular(5),
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
                  SizedBox(height: 20),
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
                              autovalidateMode: AutovalidateMode.always,
                              autocorrect: true,
                              controller: emailContoller,
                              autofocus: false,
                              onSaved: (value) {
                                emailContoller.text = value!;
                              },
                              enabled: false,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                  fontSize: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.045
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.028
                                          : size.width * 0.045,
                                  height: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 0.05
                                      : Responsive.isTabletPortrait(context)
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
                                  fontSize: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.04
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.02
                                          : size.width * 0.04,
                                ),
                                prefixIconConstraints:
                                    BoxConstraints(minWidth: 40),
                                prefixIcon: Icon(
                                  Icons.person,
                                  size: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.07
                                      : Responsive.isTabletPortrait(context)
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
                              autovalidateMode: AutovalidateMode.always,
                              autocorrect: true,
                              controller: foldercontroller,
                              autofocus: false,
                              onSaved: (value) {
                                foldercontroller.text = value!;
                              },
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              style: TextStyle(
                                  fontSize: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.045
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.028
                                          : size.width * 0.045,
                                  height: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 0.5
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.001
                                          : size.width * 0.005,
                                  color: Colors.black),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Folder Name",
                                labelStyle: TextStyle(
                                  color: Colors.black54,
                                  fontSize: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.04
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.02
                                          : size.width * 0.04,
                                ),
                                prefixIconConstraints:
                                    BoxConstraints(minWidth: 40),
                                prefixIcon: Icon(
                                  Icons.folder_copy,
                                  color: Colors.grey,
                                  size: Responsive.isMobileSmall(context) ||
                                          Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.07
                                      : Responsive.isTabletPortrait(context)
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
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: TextButton.icon(
                              icon: Icon(
                                Icons.ios_share_outlined,
                                size: Responsive.isMobileSmall(context)
                                    ? 20
                                    : Responsive.isMobileMedium(context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 22
                                        : Responsive.isTabletPortrait(context)
                                            ? 24
                                            : 25,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Share",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: Responsive.isMobileSmall(context)
                                      ? 15
                                      : Responsive.isMobileMedium(context) ||
                                              Responsive.isMobileLarge(context)
                                          ? 16
                                          : Responsive.isTabletPortrait(context)
                                              ? size.width * 0.03
                                              : size.width * 0.06,
                                ),
                                textScaler: TextScaler.linear(1),
                              ),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                backgroundColor: user == ""
                                    ? Colors.grey
                                    : Color.fromARGB(255, 237, 172, 10),
                                minimumSize: Size(150, 40),
                              ),
                              onPressed: () async {
                                user == ""
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
        ),
      ),
    );
  }
}
