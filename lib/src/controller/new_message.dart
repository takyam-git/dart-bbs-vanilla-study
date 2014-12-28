part of app.controller;

class NewMessageController extends WebSocketController {
  NewMessageController(WebSocket socket, Message message): super(socket, message);

  void run() {
    if (!this._message.containsKey("body") || !(this._message["body"] is String)) {
      throw new FormatException("Invalid Format");
    }
    String author = this._message.containsKey("author") ? this._message["author"] : "名無し";
    var messageEntity = new MessageEntity(author, this._message["body"]);
    MessageRepository.save(messageEntity).then((_) {
      this.broadcast(new Message(MessageType.NEW_MESSAGE, {
          "author": messageEntity["author"],
          "body": messageEntity["body"],
      }));
    });
  }
}