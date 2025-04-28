class TicketDetail {
  final String ticketNo1;
  final String priority1;
  final String ticketTitle1;
  // final int assiTo;
  final String state1;
  final String customer1;
  final String teamLeader1;
  final String temailFrom1;
  final String tpartnerName1;
  final String tref1;
  final String serialNo1;
  final String faultArea1;
  final String resolution1;
  final List<SparePartDetail> spareParts1;
  final List<Timesheet> timesheets1;

  TicketDetail({
    required this.ticketNo1,
    required this.priority1,
    required this.ticketTitle1,
    // required this.assiTo,
    required this.state1,
    required this.customer1,
    required this.teamLeader1,
    required this.temailFrom1,
    required this.tpartnerName1,
    required this.tref1,
    required this.serialNo1,
    required this.faultArea1,
    required this.resolution1,
    required this.spareParts1,
    required this.timesheets1,
  });

  factory TicketDetail.fromJson(Map<String, dynamic> json) {
    var sparePartsList = (json['spare_parts'] as List? ?? [])
        .map((e) => SparePartDetail.fromJson(e))
        .toList();

    var timesheetList = (json['timesheets'] as List? ?? [])
        .map((e) => Timesheet.fromJson(e))
        .toList();

    return TicketDetail(
      ticketNo1: json['ticket_no'] != false && json['ticket_no'] != null ?json['ticket_no'] : '',
      priority1: json['priority'] != false && json['priority'] != null ?json['priority'] : '',
      ticketTitle1: json['ticket_title'] != false && json['ticket_title'] != null ?json['ticket_title'] : '',
      // assiTo: json['assi_to'] is int ? json['assi_to'] : int.tryParse(json['assi_to'].toString()) ?? 0,
      state1: json['ticket_title'] != false && json['ticket_title'] != null ?json['ticket_title'] : '',
      customer1: json['customer'] != false && json['customer'] != null ?json['customer'] : '',
      teamLeader1: json['team_leader'] != false && json['team_leader'] != null ?json['team_leader'] : '',
      temailFrom1: json['temail_from'] != false && json['temail_from'] != null ?json['temail_from'] : '',
      tpartnerName1: json['tpartner_name'] != false && json['tpartner_name'] != null ?json['tpartner_name'] : '',
      tref1: json['tref'] != false && json['tref'] != null ?json['tref'] : '',
      serialNo1: json['serial_no'] != false && json['serial_no'] != null ?json['serial_no'] : '',
      faultArea1: json['fault_area'] != false && json['fault_area'] != null ?json['fault_area'] : '',
      resolution1: json['resolution'] != false && json['resolution'] != null ?json['resolution'] : '',
      spareParts1: sparePartsList,
      timesheets1: timesheetList,
    );
  }
}

class SparePartDetail {
  final String productName1;
  final double qtyUsed1;
  final String state1;

  SparePartDetail({
    required this.productName1,
    required this.qtyUsed1,
    required this.state1,
  });

  factory SparePartDetail.fromJson(Map<String, dynamic> json) {
    return SparePartDetail(
      productName1: json['product_name'] != false && json['product_name'].toString().isNotEmpty ? json['product_name'] : '',
      qtyUsed1: (json['qty_used'] is num)
          ? (json['qty_used'] as num).toDouble()
          : double.tryParse(json['qty_used'].toString()) ?? 0.0,
      state1: json['state'] ?? '',
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
      timesheetDate: json['timesheet_date'] ?? '',
      users: json['users'] is int ? json['users'] : int.tryParse(json['users'].toString()) ?? 0,
      productId: json['product_id'] != false && json['product'] != null ? json['product_id'] : '',
      timesheetDescription: json['timesheet_description'] ?? '',
      hours: (json['hours'] is num)
          ? (json['hours'] as num).toDouble()
          : double.tryParse(json['hours'].toString()) ?? 0.0,
    );
  }
}
