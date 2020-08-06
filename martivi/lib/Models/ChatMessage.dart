class ChatMessage {
  String pair;
  String senderUserId;
  String targetUserId;
  String message;
  ChatMessage({this.message, this.targetUserId, this.senderUserId, this.pair});
  Map<String, dynamic> toJson() {
    return {
      'pair': pair,
      'senderUserId': senderUserId,
      'targetUserId': targetUserId,
      'message': message
    };
  }

  ChatMessage.fromJson(Map<String, dynamic> json) {
    pair = json['pari'] as String;
    senderUserId = json['senderUserId'] as String;
    targetUserId = json['targetUserId'] as String;
    message = json['message'] as String;
  }
}
