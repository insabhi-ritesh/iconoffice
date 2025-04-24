class ResUser {
  final String name;
  final String email;
  final String login;
  final String phone;
  final String image;
  final String session_id;


  ResUser({
    required this.name,
    required this.email,
    required this.login,
    required this.phone,
    required this.image,
    required this.session_id,
  });

  factory ResUser.fromJson(dynamic json) {
    return ResUser(
      name: json['name'] != false ? json['name'] ?? '' : '',
      email: json['email'] != false ? json['email'] ?? '' : '',
      login: json['login'] != false ? json['login'] ?? '' : '',
      phone:
          json['phone'] != false && json['phone'] != null ? json['phone'] : '',
      image: json['image'] != false ? json['image'] ?? '' : '',
      session_id: json['session_id'] != false ? json['session_id'] ?? '' : '',
    );
  }
}
