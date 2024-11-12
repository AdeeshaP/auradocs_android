import 'dart:convert';
import 'dart:io';
import 'package:auradocs_android/screens/File-Picker/upload_file_list.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilePickerScreen extends StatefulWidget {
  const FilePickerScreen({super.key});

  @override
  State<FilePickerScreen> createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<FilePickerScreen> {
  File? fileImage;
  String username = "";
  String token = "";
  String compnyCode = "";
  late SharedPreferences _storage;
  Map<String, dynamic>? userObj;
  TextEditingController searchController = TextEditingController();
  final picker = ImagePicker();
  List<File> selectedImages = [];
  String trimmedValue = "";
  // GlobalKey _toolTipKey = GlobalKey();
  List authentication = [];

  @override
  void initState() {
    super.initState();
    getSharedPrefrences();
  }

  Future<void> getSharedPrefrences() async {
    _storage = await SharedPreferences.getInstance();
    userObj = jsonDecode(_storage.getString('user_data')!);
    token = _storage.getString('token')!;

    username = userObj!["value"]["userName"];
    compnyCode = _storage.getString('code')!;
    String? authListJson = _storage.getString('authentication');
    authentication =
        authListJson != null ? List<String>.from(jsonDecode(authListJson)) : [];
  }

  Future getImages() async {
    final pickedFile = await picker.pickMultiImage(
        imageQuality: 100, maxHeight: 1000, maxWidth: 1000);
    List<XFile> xfilePick = pickedFile;

    setState(
      () {
        if (xfilePick.isNotEmpty) {
          for (var i = 0; i < xfilePick.length; i++) {
            selectedImages.add(File(xfilePick[i].path));
          }
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return UploadFileListScreen(fileNames2: selectedImages);
          }));
        } else {
          // ScaffoldMessenger.of(context).showSnackBar(
          //     const SnackBar(content: Text('Nothing is selected')));
        }
      },
    );
  }

  getMultipleFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      withReadStream: true,
      allowedExtensions: [
        'pdf',
        'mp3',
        'mp4',
        'docx',
        'txt',
        'csv',
        'doc',
        'pptx',
        'xls',
        'xlsx',
        'ppt',
        'sh',
        'odt',
        'wav'
      ],
    );

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      setState(() {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return UploadFileListScreen(fileNames2: files);
        }));
      });
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //   content: Text('Please select atleast 1 file'),
      // ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
