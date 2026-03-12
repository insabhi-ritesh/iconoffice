import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';

class SignatureAndPdfController extends GetxController {
  final Rx<File?> selectedPdf = Rx<File?>(null);
  final storage = GetStorage();

  String _getTicketKey(String ticketNo) {
    return 'saved_pdf_path_$ticketNo';
  }

  void loadSavedPdf(String ticketNo) {
    final key = _getTicketKey(ticketNo);
    final savedPath = storage.read<String>(key);
    if (savedPath != null && File(savedPath).existsSync()) {
      selectedPdf.value = File(savedPath);
    } else {
      selectedPdf.value = null;
    }
  }

  Future<void> savePdfPath(String path, String ticketNo) async {
    final key = _getTicketKey(ticketNo);
    await storage.write(key, path);
  }

  Future<void> clearSavedPdf(String ticketNo) async {
    final key = _getTicketKey(ticketNo);
    await storage.remove(key);
    selectedPdf.value = null;
  }
}