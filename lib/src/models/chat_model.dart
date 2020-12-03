class ChatModel {
  final int id;
  final String content;
  final DateTime sentAt;
  final String type;
  final int receiverId;
  final int senderId;
  final String chatId;
  final int status;

  bool withBubble = false;

  ChatModel({
    this.id,
    this.content,
    this.type,
    this.receiverId,
    this.senderId,
    this.chatId,
    this.status,
    this.sentAt
  });

  factory ChatModel.fromMap(Map data) {
    return ChatModel(
      id: data["id"],
      content: data["content"],
      sentAt: DateTime.tryParse(data["sent_at"]),
      type: data["type"] ?? "",
      receiverId: data["receiver_id"],
      senderId: data["sender_id"],
      status: data["status"] ?? 0,
      chatId: data["chat_id"] ?? ""
    );
  }
}