class Chat {
  final String username;
  final String chatId;

  Chat({
    required this.username,
    required this.chatId,
  });

  @override
  String toString() => '{ username: $username, chatId: $chatId }';
}
