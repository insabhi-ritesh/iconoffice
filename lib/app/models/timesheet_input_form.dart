import 'package:flutter/material.dart';
import 'timesheet.dart';

class TimesheetInputForm {
  final TextEditingController productIdController;
  final TextEditingController descriptionController;
  final TextEditingController hoursController;
  DateTime? date;

  TimesheetInputForm({
    String? productId,
    String? description,
    double? hours,
    DateTime? date,
  })  : productIdController = TextEditingController(text: productId ?? ''),
        descriptionController = TextEditingController(text: description ?? ''),
        hoursController = TextEditingController(text: hours?.toString() ?? ''),
        date = date;

  // Convert form data to TimesheetInput model
  TimesheetInput toModel() {
    return TimesheetInput(
      productId: productIdController.text,
      description: descriptionController.text,
      hours: double.tryParse(hoursController.text) ?? 0.0,
      date: date ?? DateTime.now(),
    );
  }

  // Populate controllers from a TimesheetInput model
  void fromModel(TimesheetInput model) {
    productIdController.text = model.productId;
    descriptionController.text = model.description;
    hoursController.text = model.hours.toString();
    date = model.date;
  }

  void dispose() {
    productIdController.dispose();
    descriptionController.dispose();
    hoursController.dispose();
  }
}