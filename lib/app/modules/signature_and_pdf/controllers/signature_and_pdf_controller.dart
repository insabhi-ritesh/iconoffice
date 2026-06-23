import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';

class SignatureAndPdfController extends GetxController {
  final Rx<File?> selectedPdf = Rx<File?>(null);
  final Rx<String?> signedPdfPath = Rx<String?>(null);
  final storage = GetStorage();

  String _getTicketKey(String ticketNo) => 'saved_pdf_path_$ticketNo';
  String _getSignedKey(String ticketNo) => 'signed_pdf_path_$ticketNo';

  void loadSavedPdf(String ticketNo) {
    final savedPath = storage.read<String>(_getTicketKey(ticketNo));
    if (savedPath != null && File(savedPath).existsSync()) {
      selectedPdf.value = File(savedPath);
    } else {
      selectedPdf.value = null; // ← clears if deleted externally
    }

    final signedPath = storage.read<String>(_getSignedKey(ticketNo));
    if (signedPath != null && File(signedPath).existsSync()) {
      signedPdfPath.value = signedPath;
    } else {
      signedPdfPath.value = null;
    }
  }

  Future<void> savePdfPath(String path, String ticketNo) async {
    await storage.write(_getTicketKey(ticketNo), path);
  }

  Future<void> saveSignedPdfPath(String path, String ticketNo) async {
    await storage.write(_getSignedKey(ticketNo), path);
    signedPdfPath.value = path;
  }

  Future<void> clearSavedPdf(String ticketNo) async {
    await storage.remove(_getTicketKey(ticketNo));
    selectedPdf.value = null;
  }

  // ← NEW: called from ticket_sections delete icon
  Future<void> clearSignedPdf(String ticketNo) async {
    await storage.remove(_getSignedKey(ticketNo));
    signedPdfPath.value = null;
  }
}
