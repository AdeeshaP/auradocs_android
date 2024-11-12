import 'dart:io';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DirectScan extends StatefulWidget {
  DirectScan({
    super.key,
    required this.file1,
  });

  File? file1;

  @override
  State<DirectScan> createState() => _DirectScanState();
}

class _DirectScanState extends State<DirectScan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
