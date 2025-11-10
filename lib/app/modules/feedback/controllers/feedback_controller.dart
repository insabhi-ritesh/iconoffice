// lib/app/modules/feedback/controllers/feedback_controller.dart
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class FeedbackController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final descriptionController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString selectedFileName = 'No file selected'.obs;
  File? selectedFile;

  static const int maxImageSizeKB = 200;
  static const int maxVideoSizeMB = 5;

  static const String odooUrl = 'https://emp.sltecherpsolution.com';
  static const String database = 'SLTECHERPSOLUTION';
  static const String username = 'mobileapp';
  static const String password = 'insabhi2025';
  static const int fixedUserId = 36;

  late OdooClient client;
  String? _restoredSessionId;

  @override
  void onInit() {
    super.onInit();
    _initializeClient();
    _restoreSession();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void _initializeClient() {
    client = OdooClient(odooUrl);
  }

  Future<void> _restoreSession() async {
    final saved = GetStorage().read<String>('odoo_session_id');
    if (saved != null && saved.isNotEmpty) {
      _restoredSessionId = saved;
    }
  }

  Future<void> _saveSessionId(String sid) async {
    await GetStorage().write('odoo_session_id', sid);
    _restoredSessionId = sid;
  }

  // ──────────────────────────────────────────────────────────────
  // FILE PICKER – IMAGES: compress | VIDEOS: no compress, size check only
  // ──────────────────────────────────────────────────────────────
  void selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media, // shows ALL images & videos
        allowCompression: false,
      );

      if (result == null || result.files.isEmpty) {
        Get.snackbar('Cancelled', 'No file selected');
        return;
      }

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final fileSize = file.lengthSync();
      final extension = fileName.split('.').last.toLowerCase();

      // Detect file type
      final isImage = ['jpg', 'jpeg', 'png', 'webp'].contains(extension);
      final isVideo = ['mp4', 'mov', 'avi', 'mkv', '3gp', 'webm'].contains(extension);

      if (!isImage && !isVideo) {
        Get.snackbar('Invalid', 'Only images and videos are allowed');
        return;
      }

      // ───── IMAGE: compress if > 200 KB ─────
      if (isImage) {
        if (fileSize > maxImageSizeKB * 1024) {
          Get.snackbar('Compressing', 'Image is large, compressing...');
          final compressed = await _compressImage(file);
          if (compressed == null) {
            Get.snackbar('Error', 'Failed to compress image');
            return;
          }
          selectedFile = compressed;
          selectedFileName.value = 'Compressed_$fileName';
        } else {
          selectedFile = file;
          selectedFileName.value = fileName;
        }
      }

      // ───── VIDEO: NO compression, only size check ─────
      else if (isVideo) {
        if (fileSize > maxVideoSizeMB * 1024 * 1024) {
          Get.snackbar(
            'Limit Exceeded',
            'Video exceeds ${maxVideoSizeMB} MB limit. Please attach a smaller video.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
          return;
        }
        selectedFile = file;
        selectedFileName.value = fileName;
      }

      // Success
      Get.snackbar('Selected', selectedFileName.value,
          backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar('Error', 'File picker failed: $e');
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return null;

      int quality = 85;
      List<int>? compressed;

      do {
        compressed = img.encodeJpg(image, quality: quality);
        quality -= 10;
      } while (compressed.length > maxImageSizeKB * 1024 && quality > 10);

      final tempDir = Directory.systemTemp;
      final compressedFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await compressedFile.writeAsBytes(compressed);

      return compressedFile;
    } catch (e) {
      return null;
    }
  }

  Future<void> submitFeedback() async {
    if (nameController.text.trim().isEmpty &&
        emailController.text.trim().isEmpty &&
        descriptionController.text.trim().isEmpty) {
      Get.snackbar('Error', 'At least one field must be filled',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      if (!(await _checkSession())) {
        final dynamic session = await client.authenticate(database, username, password);
        String? sid;
        try {
          if (session is String) {
            sid = session;
          } else {
            sid = (session.id != null) ? session.id.toString() : null;
            if (sid == null) {
              sid = (session.sessionId != null) ? session.sessionId.toString() : null;
            }
            if (sid == null) {
              sid = (session.sid != null) ? session.sid.toString() : null;
            }
            if (sid == null) {
              final dynamic j = session.toJson();
              if (j is Map && j.containsKey('id')) {
                sid = j['id']?.toString();
              } else if (j is Map && j.containsKey('session_id')) {
                sid = j['session_id']?.toString();
              }
            }
          }
        } catch (_) {
          sid = null;
        }
        if (sid != null && sid.isNotEmpty) {
          await _saveSessionId(sid);
        }
      }

      final leadVals = {
        'name': nameController.text.trim().isNotEmpty
            ? nameController.text.trim()
            : 'Feedback from Mobile App',
        'email_from': emailController.text.trim(),
        'description': descriptionController.text.trim(),
        'user_id': fixedUserId,
        'stage_id': 1,
      };

      final dynamic result = await client.callKw({
        'model': 'crm.lead',
        'method': 'create',
        'args': [leadVals],
        'kwargs': {},
      });

      final int leadId = result is List ? result.first as int : result as int;

      if (selectedFile != null) {
        final bytes = await selectedFile!.readAsBytes();
        final attVals = {
          'name': path.basename(selectedFile!.path),
          'type': 'binary',
          'datas': base64Encode(bytes),
          'res_model': 'crm.lead',
          'res_id': leadId,
          'public': false,
        };

        await client.callKw({
          'model': 'ir.attachment',
          'method': 'create',
          'args': [attVals],
          'kwargs': {},
        });
      }

      Get.snackbar(
        'Success',
        'Feedback submitted successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      await Future.delayed(const Duration(seconds: 2));
      _clearForm();
      Get.back();

    } on OdooException catch (e) {
      Get.snackbar('Odoo Error', e.message,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _checkSession() async {
    try {
      await client.callKw({
        'model': 'res.users',
        'method': 'search_count',
        'args': [[]],
        'kwargs': {},
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  void _clearForm() {
    nameController.clear();
    emailController.clear();
    descriptionController.clear();
    selectedFile = null;
    selectedFileName.value = 'No file selected';
  }
}