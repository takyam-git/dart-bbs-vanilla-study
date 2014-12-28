part of app.domain;

List<MessageEntity> messagesStorage = [];

class MessageRepository extends DomainRepository {
  static Future save(MessageEntity message) {
    var completer = new Completer();
    new Future(() => messagesStorage.add(message)).then((_) => completer.complete());
    return completer.future;
  }

  static Future<List<MessageEntity>> getAll() {
    var completer = new Completer();
    new Future(() => messagesStorage).then((List<MessageEntity> messages) => completer.complete(messages));
    return completer.future;
  }
}