class NotificationItem {
  final String ticketNo;
  final String priority;
  final String name;

  NotificationItem({
    required this.ticketNo,
    required this.priority,
    required this.name,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      ticketNo: json['name'] ?? '', // SR-012843 is ticketNo
      priority: json['priority'] ?? '',
      name: json['ticket_no'] ?? '', // fallback
    );
  }
}