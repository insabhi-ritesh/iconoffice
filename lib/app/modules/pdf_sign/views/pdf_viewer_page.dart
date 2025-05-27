import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatelessWidget {
  final String url;
  final String? name;
  final bool isLocal;

  const PdfViewerPage({
    super.key, 
    required this.url, 
    this.name,
    this.isLocal = true
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name ?? 'PDF Document'),
      ),
      //using this body to display the PDF document 
      //Based on the isLocal flag, it will either load from a file or a network URL
      body: isLocal 
      ? 
      SfPdfViewer.file(File(url))
      : SfPdfViewer.network(url),
    );
  }
}