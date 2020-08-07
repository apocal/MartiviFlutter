class ChatMessage {
  String pair;
  String senderUserId;
  String targetUserId;
  String message;
  dynamic serverTime;
  ChatMessage(
      {this.message,
      this.targetUserId,
      this.senderUserId,
      this.pair,
      this.serverTime});
  Map<String, dynamic> toJson() {
    return {
      'pair': pair,
      'senderUserId': senderUserId,
      'targetUserId': targetUserId,
      'message': message,
      'serverTime': serverTime
    };
  }

  ChatMessage.fromJson(Map<String, dynamic> json) {
    pair = json['pari'] as String;
    senderUserId = json['senderUserId'] as String;
    targetUserId = json['targetUserId'] as String;
    message = json['message'] as String;
    serverTime = json['serverTime'];
  }
}
