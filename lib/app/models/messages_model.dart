class HelpdeskMessageResponse {
  final bool success;
  final String message;
  final List<HelpdeskMessage> data;

  HelpdeskMessageResponse ({
    required this.success,
    required this.message,
    required this.data
  });

  factory HelpdeskMessageResponse.fromJson(Map<String, dynamic> json) {
    return HelpdeskMessageResponse(
      success: json['success'],
      message: json['message'] != false && json['message'] != null ? json['message'] : "",
      data: (json['data'] as List<dynamic>?)
        ?.map((e) => HelpdeskMessage.fromJson(e))
        .toList() ??
        [],
      // message: json['message'] ?? '',
    );
  }
}

class HelpdeskMessage {
  final int id;
  final String author;
  final String body;
  final String date;
  final List<Attachment> attchements;

  HelpdeskMessage ({
    required this.id,
    required this.author,
    required this.body,
    required this.date,
    required this.attchements,
  });

  factory HelpdeskMessage.fromJson(Map<String, dynamic> json) {
    return HelpdeskMessage(
      id: json['id'] != null && json['id'] != false ? json['id'] : 0,
      author: json['author'] != null && json['author'] != false ? json['author'] : "",
      body: json['body'] != null && json['body'] != false ? json['body'] : "",
      date: json['date'] != null && json['date'] != false ? json['date'] : "",
      attchements: (json['attachments'] as List<dynamic>?)
      ?.map((e) => Attachment.fromJson(e)).toList() ?? [],
    );
  }
}

class Attachment {
  final int id;
  final String name;
  final String url;

  Attachment({
    required this.id,
    required this.name,
    required this.url,
  });

  factory Attachment.fromJson(Map<String, dynamic> json){
    return Attachment(
      id: json['id'] != null && json['id'] != false ? json['id'] : 0,
      name: json['name'] != null && json['name'] != false ? json['name'] : "",
      url: json['url'] != null && json['url'] != false ? json['url'] : "",
    );
  }
}