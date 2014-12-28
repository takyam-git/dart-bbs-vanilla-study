library app.message;

import "dart:collection";
import "dart:convert";

class MessageType {
  static const GET_MESSAGES = const MessageType("get messages");
  static const NEW_MESSAGE = const MessageType("new message");

  final String messageType;

  const MessageType(this.messageType);

  factory MessageType.fromString(String type){
    if (type == "new message") {
      return NEW_MESSAGE;
    }
    return new MessageType(type);
  }

  operator ==(Object other) {
    return other is MessageType && (other as MessageType).messageType == this.messageType;
  }

  String toString() {
    return this.messageType;
  }
}

class Message extends Object with MapMixin<String, Object> {
  MessageType _type;
  Map _values = new Map<String, Object>();

  Message(MessageType this._type, [Map<String, Object> values]) {
    if (values is Map) {
      this._values.addAll(values);
    }
  }

  factory Message.fromJson(Object json){
    var jsonObject = new JsonDecoder().convert(json as String);
    if (!(jsonObject is Map)) {
      throw new FormatException("[json:${json}] is not Map type JSON!");
    }
    Map mapObject = jsonObject as Map;
    if (!(mapObject.containsKey("type") && mapObject.containsKey("values")
    && mapObject["type"] is String && mapObject["values"] is Map<String, Object>)) {
      throw new FormatException("[json:${json}] is not Message JSON!");
    }
    return new Message(new MessageType.fromString(mapObject["type"]), mapObject["values"]);
  }

  operator [](String key) => this._values[key];

  operator []=(String key, Object value) => this._values[key] = value;

  void clear() => this._values.clear();

  Object remove(String key) => this._values.remove(key);

  Iterable<String> get keys => this._values.keys;

  MessageType get type => this._type;

  String toJson() => this.toString();

  String toString() {
    return JSON.encode({
        "type": this._type.toString(),
        "values": this._values,
    });
  }
}