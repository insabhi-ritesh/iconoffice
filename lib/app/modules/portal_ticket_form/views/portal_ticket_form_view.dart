
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/fontSize.dart';
import '../../../common/app_color.dart';
import '../controllers/portal_ticket_form_controller.dart';

class PortalTicketFormView extends GetView<PortalTicketFormController> {
  PortalTicketFormView({super.key});
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Support Ticket', 
            style: TextStyle(color: AppColorList.WhiteText)
          ),
          backgroundColor: AppColorList.AppButtonColor,
          iconTheme: IconThemeData(color: AppColorList.WhiteText),
        centerTitle: true,
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Card(
            color: AppColorList.ContainerBackground,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Ticket Registration",
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: controller.userEmailController,
                      label: 'User Email',
                      icon: Icons.email,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: controller.ticketTitleController,
                      label: 'Ticket Title',
                      icon: Icons.title,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: controller.createdByController,
                      label: 'Created By',
                      icon: Icons.edit_document,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: controller.customerNameController,
                      label: 'Customer Name',
                      icon: Icons.person,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: controller.customerReferenceController,
                      label: 'Customer Reference/PO',
                      icon: Icons.room_preferences,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: controller.serialNoController,
                            label: 'Serial No',
                            icon: Icons.numbers,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: controller.modelNoController,
                            label: 'Model No',
                            icon: Icons.model_training,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: controller.faultAreaController,
                      label: 'Fault Area',
                      icon: Icons.error,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: controller.descriptionController,
                      label: 'Description',
                      icon: Icons.description,
                    ),
                    const SizedBox(height: 16),
                    Obx(() => DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Select State',
                            prefixIcon: Icon(Icons.list),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColorList.AppBackGroundColor
                          ),
                          value: controller.selectedOption.value,
                          items: controller.dropdownOptions.map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            controller.selectedOption.value = newValue;
                          },
                          validator: (value) =>
                              value == null ? 'Please select an option' : null,
                        )),
                        const SizedBox(height: 16),
                        Text(
                      "Attach Documents",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.attach_file),
                          label: Text("Choose Documents"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorList.AppButtonColor,
                            foregroundColor: AppColorList.WhiteText,
                          ),
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                              allowMultiple: true,
                            );
                            if (result != null) {
                              controller.setSelectedFiles(result.files);
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        if (controller.selectedFiles.isNotEmpty)
                          ...controller.selectedFiles.map((file) => Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColorList.AppTextColor),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                                  leading: Icon(Icons.insert_drive_file),
                                  title: Text(file.name),
                                  subtitle: Text('${(file.size / 1024).toStringAsFixed(2)} KB'),
                                  trailing: IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      controller.removeSelectedFile(file);
                                    },
                                  ),
                                ),
                          )),
                        if (controller.selectedFiles.isEmpty)
                          Text(
                            "No documents selected.",
                            style: TextStyle(color: AppColorList.AppText,
                              fontSize: AppFontSize.size3,
                              fontWeight: AppFontWeight.font3
                            ),
                          ),
                      ],
                    )),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        label: Text('Submit',
                          style: TextStyle(color: AppColorList.WhiteText),
                        ),
                        icon: Icon(
                          Icons.send,
                          color: AppColorList.WhiteText, 
                          size: 20
                        ),
                        
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorList.AppButtonColor,
                          iconColor: AppColorList.WhiteText,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: TextStyle(fontSize: AppFontSize.size2),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            controller.CreateTicket();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: AppColorList.AppBackGroundColor
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
