import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatelessWidget {
  final String url;
  final String? name;

  const PdfViewerPage({super.key, required this.url, this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name ?? 'PDF Document'),
      ),
      body: SfPdfViewer.network(url),
    );
  }
}