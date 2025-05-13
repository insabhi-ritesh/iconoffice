
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../Constants/constant.dart';

class PdfViewerPage extends StatelessWidget {
  final String url;
  final String name;

  const PdfViewerPage({super.key, required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    final fullUrl = url.startsWith('http') ? url : '${Constant.BASE_URL}$url';
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SfPdfViewer.network(fullUrl),
    );
  }
}