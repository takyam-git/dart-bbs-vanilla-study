import "dart:html";
import "dart:async";
import "package:takyam-bbs-vanilla/message.dart";

void main() {
  var socket = new WebSocketStream();
  var container = new MessagesContainer();
  InputElement input = querySelector("#messageBody");
  InputElement author = querySelector("#messageAuthor");
  querySelector("#messageForm").onSubmit.where((Event event) {
    return input.value.isNotEmpty;
  }).listen((Event event) {
    event.preventDefault();
    socket.send(new Message(MessageType.NEW_MESSAGE, {
        "author": author.value,
        "body": input.value,
    }));
    input.value = "";
  });
  socket.onOpen.first.then((Event event) {
    socket.send(new Message(MessageType.GET_MESSAGES));
  });
  socket.onMessage.where((Message message) => message.type == MessageType.GET_MESSAGES).listen((Message message) {
    (message["messages"] as List<Map<String, String>>).forEach((element) {
      container.add(element);
    });
  });
  socket.onMessage.where((Message message) => message.type == MessageType.NEW_MESSAGE).listen((Message message) {
    container.add(message);
  });
}

class MessagesContainer {
  DListElement _dom;

  MessagesContainer() {
    this._dom = querySelector("#messages");
  }

  void add(Map message) {
    var title = new Element.tag('dt');
    var body = new Element.tag('dd');
    title.text = message["author"];
    body.text = message["body"];
    this._dom
      ..append(title)
      ..append(body);
  }
}

class WebSocketStream {
  static WebSocketStream instance;

  factory WebSocketStream (){
    if (WebSocketStream.instance == null) {
      WebSocketStream.instance = new WebSocketStream._();
    }
    return WebSocketStream.instance;
  }

  final String _url = "ws://${Uri.base.host}:${Uri.base.port}/ws";
  WebSocket _ws;
  bool _encounteredError = false;
  int _retryWaitSeconds = 1;
  StreamController<Message> _onMessageStream = new StreamController<Message>.broadcast();

  WebSocketStream._(){
    this._initialize();
  }

  void _initialize() {
    this._encounteredError = false;
    this._retryWaitSeconds *= 2;
    this._ws = new WebSocket(this._url)
      ..onOpen.listen(this._onOpen)
      ..onClose.listen(this._onClose)
      ..onError.listen(this._onError)
      ..onMessage.listen(this._onMessage);
  }

  Stream<Event> get onOpen => this._ws.onOpen;

  Stream<CloseEvent> get onClose => this._ws.onClose;

  Stream<Event> get onError => this._ws.onError;

  Stream<Message> get onMessage => this._onMessageStream.stream;

  void send(Message message) {
    this._ws.send(message.toJson());
  }

  void _onOpen(Event event) {
    print('connected!');
  }

  void _onClose(CloseEvent event) {
    this._reconnect();
  }

  void _onError(Event event) {
    this._reconnect();
  }

  void _reconnect() {
    if (!this._encounteredError) {
      new Timer(new Duration(seconds: this._retryWaitSeconds), () => this._initialize());
    }
    this._encounteredError = true;
  }

  void _onMessage(MessageEvent event) {
    try {
      var message = new Message.fromJson(event.data);
      this._onMessageStream.add(message);
    } catch (e) {
      //do nothing
    }
  }
}