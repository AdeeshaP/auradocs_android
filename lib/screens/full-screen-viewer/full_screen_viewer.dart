import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class FullScreenViewer extends StatefulWidget {
  final String base64String;
  final String mimeT;

  FullScreenViewer({required this.base64String, required this.mimeT});

  @override
  State<FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<FullScreenViewer> {
  File? pdffile;
  GlobalKey<SfPdfViewerState> _pdfKey = GlobalKey<SfPdfViewerState>();

  @override
  void initState() {
    super.initState();
    getPdfView();
  }

  Future<File> getPdfView() async {
    Directory tempDir = await getTemporaryDirectory();
    var random = Random.secure();
    var randomInt = random.nextInt(100000);
    var filename = 'sample_$randomInt.pdf';
    pdffile = File('${tempDir.path}/$filename');
    final imageValueBytes = base64.decode(widget.base64String);
    pdffile?.writeAsBytes(imageValueBytes);
    return pdffile!;
  }

  Widget displyFileFullScrenMode() {
    if (widget.mimeT == "application/pdf") {
      return FutureBuilder<File>(
        future: getPdfView(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return SfPdfViewer.file(
              pdffile!,
              key: _pdfKey,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              enableDoubleTapZooming: true,
              canShowPaginationDialog: false,
            );
          } else if (snapshot.hasError) {
            return Text('Error loading PDF file');
          } else {
            return CircularProgressIndicator();
          }
        },
      );
    } else if (widget.mimeT == 'image/jpg' ||
        widget.mimeT == 'image/jpeg' ||
        widget.mimeT == 'image/png' ||
        widget.mimeT == 'image/gif') {
      Uint8List x = base64.decode(widget.base64String.split('\n').join());
      return FullScreenWidget(
        backgroundIsTransparent: false,
        disposeLevel: DisposeLevel.Low,
        child: Image.memory(
          x,
          fit: BoxFit.fill,
        ),
      );
    } else if (widget.mimeT == 'text/plain') {
      final fileContent = utf8.decode(base64.decode(widget.base64String));
      final htmlData = '''
      <html>
        <head>
          <meta charset="UTF-8">
        </head>
        <body>
          $fileContent
        </body>
      </html>
    ''';
      return SingleChildScrollView(
        child: Html(data: htmlData),
      );
    } else if (widget.mimeT == 'text/csv') {
      final csvBytes = base64Decode(widget.base64String);
      final decodedCsv = utf8.decode(csvBytes);
      final csvData = CsvToListConverter().convert(decodedCsv);

      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(width: 1),
            headingRowHeight: 20,
            dataRowMinHeight: 20,
            dataRowMaxHeight: 20,
            columns: List.generate(
              csvData.first.length,
              (index) => DataColumn(
                label: Text(
                  csvData.first[index].toString(),
                  style: TextStyle(fontSize: 11),
                  textScaler: TextScaler.linear(1),
                ),
              ),
            ),
            rows: List.generate(
              csvData.length - 1,
              (rowIndex) => DataRow(
                cells: List.generate(
                  csvData.first.length,
                  (cellIndex) => DataCell(Text(
                    csvData[rowIndex + 1][cellIndex].toString(),
                    style: TextStyle(fontSize: 11),
                    textScaler: TextScaler.linear(1),
                  )),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return CircularProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: displyFileFullScrenMode(),
      ),
    );
  }
}
