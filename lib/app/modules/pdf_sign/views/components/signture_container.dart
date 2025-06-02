
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../../../common/app_color.dart';
import '../../../../common/fontSize.dart';
import '../../controllers/pdf_sign_controller.dart';
import 'input_container.dart';

class SignatureInputContainer extends StatelessWidget {
  final PdfSignController controller;
  const SignatureInputContainer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: inputContainerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Draw Signature', style: TextStyle(fontWeight: AppFontWeight.font6, fontSize: 16)),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: AppColorList.MainShadow),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Signature(
                controller: controller.signatureController,
                backgroundColor: AppColorList.WhiteText,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => controller.signatureController.clear(),
                icon: Icon(Icons.refresh, color: AppColorList.Star1),
                label: Text('Clear', style: TextStyle(color: AppColorList.Star1)),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => controller.clearFieldSelection(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => controller.prepareToPlaceField(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorList.Star1,
                      foregroundColor: AppColorList.WhiteText,
                    ),
                    child: const Text('Place on Document'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
