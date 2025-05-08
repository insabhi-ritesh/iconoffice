class Ticket {
  final String ticketNo;
  final String priority;
  final String ticketTitle;
  // final int assiTo;
  final String state;
  final String customer;
  final String teamLeader;
  final String temailFrom;
  final String tpartnerName;
  final String tref;
  final String serialNo;
  final String faultArea;
  final String resolution;
  final String Description;
  final String model_number;
  final List<SparePart> spareParts;
  final List<Timesheet> timesheets;

  Ticket({
    required this.ticketNo,
    required this.priority,
    required this.ticketTitle,
    // required this.assiTo,
    required this.state,
    required this.customer,
    required this.teamLeader,
    required this.temailFrom,
    required this.tpartnerName,
    required this.tref,
    required this.serialNo,
    required this.faultArea,
    required this.resolution,
    required this.spareParts,
    required this.timesheets,
    required this.Description,
    required this.model_number,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    var sparePartsList = (json['spare_parts'] as List? ?? [])
        .map((e) => SparePart.fromJson(e))
        .toList();

    var timesheetList = (json['timesheets'] as List? ?? [])
        .map((e) => Timesheet.fromJson(e))
        .toList();

    return Ticket(
      ticketNo: json['ticket_no'] != false && json['ticket_no'] != null ?json['ticket_no'] : '',
      priority: json['priority'] != false && json['priority'] != null ?json['priority'] : '',
      ticketTitle: json['ticket_title'] != false && json['ticket_title'] != null ?json['ticket_title'] : '',
      // assiTo: json['assi_to'] is int ? json['assi_to'] : int.tryParse(json['assi_to'].toString()) ?? 0,
      state: json['state'] != false && json['state'] != null ?json['state'] : '',
      customer: json['customer'] != false && json['customer'] != null ?json['customer'] : '',
      teamLeader: json['team_leader'] != false && json['team_leader'] != null ?json['team_leader'] : '',
      temailFrom: json['temail_from'] != false && json['temail_from'] != null ?json['temail_from'] : '',
      tpartnerName: json['tpartner_name'] != false && json['tpartner_name'] != null ?json['tpartner_name'] : '',
      tref: json['tref'] != false && json['tref'] != null ?json['tref'] : '',
      serialNo: json['serial_no'] != false && json['serial_no'] != null ?json['serial_no'] : '',
      faultArea: json['fault_area'] != false && json['fault_area'] != null ?json['fault_area'] : '',
      resolution: json['resolution'] != false && json['resolution'] != null ?json['resolution'] : '',
      Description: json['description'] != false && json['description'] != null ? json['description'] : '',
      model_number: json['model_number'] != false && json['model_number'] != null ?json['model_number'] : '',
      spareParts: sparePartsList,
      timesheets: timesheetList,
    );
  }
}

class SparePart {
  final String productName;
  final double qtyUsed;
  final String state;

  SparePart({
    required this.productName,
    required this.qtyUsed,
    required this.state,
  });

  factory SparePart.fromJson(Map<String, dynamic> json) {
    return SparePart(
      productName: json['product_name'] != false && json['product_name'].toString().isNotEmpty ? json['product_name'] : '',
      qtyUsed: (json['qty_used'] is num)
          ? (json['qty_used'] as num).toDouble()
          : double.tryParse(json['qty_used'].toString()) ?? 0.0,
      state: json['state'] ?? '',
    );
  }
}

class Timesheet {
  final String timesheetDate;
  final int users;
  final String productId;
  final String timesheetDescription;
  final double hours;

  Timesheet({
    required this.timesheetDate,
    required this.users,
    required this.productId,
    required this.timesheetDescription,
    required this.hours,
  });

  factory Timesheet.fromJson(Map<String, dynamic> json) {
    return Timesheet(
      timesheetDate: json['timesheet_date'] != null && json['timesheet_date'] != false ? json['timesheet_date'] : '',
      users: json['users'] is int ? json['users'] : int.tryParse(json['users'].toString()) ?? 0,
      productId: json['product_id'] != false && json['product'] != null ? json['product_id'] : '',
      timesheetDescription: json['timesheet_description'] != null && json['timesheet_description'] != false ? json['timesheet_description'] : '',
      hours: (json['hours'] is num)
          ? (json['hours'] as num).toDouble()
          : double.tryParse(json['hours'].toString()) ?? 0.0,
    );
  }
}
