import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../common/app_color.dart';
import '../../../../common/fontSize.dart';
import '../../../../models/timesheet.dart';
import '../../controllers/ticket_detail_page_controller.dart';
import 'enabled_button.dart';
import 'product_search_result.dart';
import 'user_search_result.dart';
import 'package:intl/intl.dart';

Widget buildTimesheetForm(
    TicketDetailPageController controller,
    BuildContext context,
    String ticketNo1,
    String State,
) {
  // Add a form key to the controller if not already present
  if (controller.formKey == null) {
    controller.formKey = GlobalKey<FormState>();
  }

  return Obx(() {
    return Form(
      key: controller.formKey,
      autovalidateMode: controller.autoValidate.value
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      child: Column(
        children: [
          ...controller.timesheetInputs.asMap().entries.map((entry) {
            TimesheetInput timesheet = entry.value;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextFormField(
                      onChanged: (value) => controller.searchQuery.value = value,
                      controller: controller.productName,
                      decoration: const InputDecoration(labelText: 'Search Product'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Product is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColorList.AppText,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: buildProductSearchResults(controller),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Description"),
                      controller: controller.productName,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Product';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Hours"),
                      controller: controller.hours,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter hours';
                        }
                        final double? hours = double.tryParse(value);
                        if (hours == null || hours <= 0) {
                          return 'Please enter a valid number of hours';
                        }
                        return null;
                      },
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Resolution"),
                      controller: controller.resolution,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a resolution';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      onChanged: (value) => controller.userQuery.value = value,
                      decoration: const InputDecoration(labelText: "User"),
                      controller: controller.resUser,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a user';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColorList.AppText,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: buildUserSearchResults(controller),
                    ),
                    IsEnabledButton(controller),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Date: "),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: Get.context!,
                              initialDate: timesheet.date,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              controller.updateDate(picked);
                              timesheet.date = picked;
                              controller.update();
                            }
                          },
                          child: Container(
                            width: 100,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColorList.AppText, width: 0.4),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              controller.selectedDate.value != null
                                  ? DateFormat('dd MMMM yyyy').format(controller.selectedDate.value!)
                                  : DateFormat('dd MMMM yyyy').format(timesheet.date),
                              style: const TextStyle(fontWeight: AppFontWeight.font6),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.removeTimesheet(),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          }).toList(),
          controller.form.value == false
              ? ElevatedButton(
                  onPressed: controller.addNewTimesheet,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 40),
                  ),
                  child: const Text(
                    "Add Timesheet Entry",
                    style: TextStyle(
                      fontSize: AppFontSize.size4,
                      fontWeight: AppFontWeight.font3,
                      color: AppColorList.AppText,
                    ),
                  ),
                )
              : SizedBox.shrink(),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // Set autoValidate to true to show errors immediately
              controller.autoValidate.value = true;
              if (controller.formKey!.currentState!.validate()) {
                controller.submitTimesheets(
                  ticketNo1,
                  controller.selectedDate.value,
                  controller.selectedState.value,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 40),
            ),
            child: const Text(
              "Submit All Timesheets",
              style: TextStyle(
                fontSize: AppFontSize.size4,
                fontWeight: AppFontWeight.font3,
                color: AppColorList.AppText,
              ),
            ),
          ),
        ],
      ),
    );
  });
}