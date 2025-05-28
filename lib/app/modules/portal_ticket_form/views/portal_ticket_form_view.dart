import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_color.dart';
import '../controllers/portal_ticket_form_controller.dart';
import 'components/app_bar.dart';
import 'components/choose_document.dart';
import 'components/form_button.dart';
import 'components/text_field.dart';

class PortalTicketFormView extends GetView<PortalTicketFormController> {
  PortalTicketFormView({super.key});
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PortalAppBar(),
      body: PortalBody(context),
    );
  }

  Center PortalBody(BuildContext context) {
    return Center(
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
                  buildTextField(
                    controller: controller.userEmailController,
                    label: 'User Email',
                    icon: Icons.email,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    controller: controller.ticketTitleController,
                    label: 'Ticket Title',
                    icon: Icons.title,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    controller: controller.createdByController,
                    label: 'Created By',
                    icon: Icons.edit_document,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    controller: controller.customerNameController,
                    label: 'Customer Name',
                    icon: Icons.person,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    controller: controller.customerReferenceController,
                    label: 'Customer Reference/PO',
                    icon: Icons.room_preferences,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: buildTextField(
                          controller: controller.serialNoController,
                          label: 'Serial No',
                          icon: Icons.numbers,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildTextField(
                          controller: controller.modelNoController,
                          label: 'Model No',
                          icon: Icons.model_training,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    controller: controller.faultAreaController,
                    label: 'Fault Area',
                    icon: Icons.error,
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    controller: controller.descriptionController,
                    label: 'Description',
                    icon: Icons.description,
                  ),
                  const SizedBox(height: 16),
                  SelectionMenu(),
                      const SizedBox(height: 16),
                      Text(
                    "Attach Documents",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ChooseDocument(controller),
                  const SizedBox(height: 28),
                  SubmitButton(controller,formKey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  

  

  Obx SelectionMenu() {
    return Obx(() => DropdownButtonFormField<String>(
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
    ));
  }
}
