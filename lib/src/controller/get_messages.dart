part of app.controller;

class GetMessagesController extends WebSocketController {
  GetMessagesController(WebSocket socket, Message message): super(socket, message);

  void run() {
    MessageRepository.getAll().then((List<MessageEntity> messages) {
      this.add(new Message(MessageType.GET_MESSAGES, {
          "messages": messages,
      }));
    });
  }
}