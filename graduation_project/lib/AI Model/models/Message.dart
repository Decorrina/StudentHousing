class Message {
  final String text;
  final bool isUser;
  final List<String>? buttons; // ✅ Optional quick reply buttons

  Message({
    required this.text,
    required this.isUser,
    this.buttons,
  });

  // Optional: to support saving/restoring messages from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'],
      isUser: json['isUser'],
      buttons: json['buttons'] != null ? List<String>.from(json['buttons']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'buttons': buttons,
  };
}
