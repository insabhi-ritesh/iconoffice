import 'package:flutter/material.dart';
import '../../controllers/pdf_sign_controller.dart';
import 'input_container.dart';

class TextInputContainer extends StatelessWidget {
  final PdfSignController controller;
  const TextInputContainer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: inputContainerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter Text',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.textController,
            decoration: InputDecoration(
              hintText: 'Enter your text here',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              errorText: controller.textError.value.isEmpty ? null : controller.textError.value,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => controller.clearFieldSelection(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => controller.prepareToPlaceField(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Place on Document'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}