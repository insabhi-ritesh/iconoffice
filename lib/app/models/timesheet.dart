
class TimesheetInput {
  final String productId;
  late final String description;
  late final double hours;
  late final DateTime date;

  TimesheetInput({
    required this.productId,
    this.description = '',
    this.hours = 0.0,
    required this.date,
  });

  // Validation: productId and description must not be empty, hours > 0
  bool isValid() {
    return productId.isNotEmpty && description.isNotEmpty && hours > 0;
  }

  factory TimesheetInput.fromJson(Map<String, dynamic> json) {
    return TimesheetInput(
      productId: json['productId']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      hours: (json['hours'] is num) ? (json['hours'] as num).toDouble() : 0.0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'description': description,
      'hours': hours,
      'date': date.toIso8601String(),
    };
  }
}


class GetProduct {
  final int id;
  final String name;

  GetProduct({
    required this.id,
    required this.name,
  });

  factory GetProduct.fromJson(Map<String,dynamic> json){
    return GetProduct(
      id: json['id'] != false && json['id'] != null ? json['id'] : '', 
      name: json['name'] != false && json['name'] != null ? json['name'] : '',
    );
  }
}