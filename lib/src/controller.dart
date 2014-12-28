part of app.controller;

abstract class Controller {
  final HttpRequestBody _requestBody;
  final Completer _completer = new Completer();
  ContentType _contentType = ContentType.HTML;

  Controller(this._requestBody, {ContentType contentType}) {
    if (contentType is ContentType) {
      this._contentType = contentType;
    }
    this._requestBody.request.response
      ..headers.contentType = this._contentType;
    this._completer.future.whenComplete(this._onComplete);
  }

  void run();

  int get statusCode => this._requestBody.request.response.statusCode;

  void set statusCode(int statusCode) {
    this._requestBody.request.response.statusCode = statusCode;
  }

  void write(Object obj) {
    this._requestBody.request.response.write(obj);
  }

  void close() {
    this._requestBody.request.response.close();
  }

  void error(e) {
    this
      ..write(e)
      ..statusCode = 500;
  }

  void response() {
    this._completer.complete();
  }

  void _onComplete() {
    this.close();
  }
}

abstract class ViewController extends Controller {
  View view;

  ViewController(HttpRequestBody body): super(body) {
    if (!(this.view is View)) {
      throw new UnimplementedError('The View is not defined. please implements this.');
    }

  }

  void setParam(String key, Object value) {
    this.view.setParam(key, value);
  }

  void setParams(Map<String, Object> params) {
    this.view.setParams(params);
  }

  void response() {
    this.render().whenComplete(() => this._completer.complete());
  }

  Future<String> render() {
    var completer = new Completer();
    this.view.render().then((String output) {
      this.write(output);
      completer.complete();
    });
    return completer.future;
  }
}

abstract class JsonController extends Controller {
  JsonController(HttpRequestBody body): super(body, contentType: ContentType.JSON);

  void response({Object data}) {
    new Future<String>(() => new JsonEncoder().convert(data))
    .then((String json) => this.write(json))
    .catchError((e) => this.error(e))
    .whenComplete(() => this._completer.complete());
  }
}

abstract class WebSocketController {
  WebSocket _socket;
  Message _message;

  WebSocketController(this._socket, this._message);

  void run();

  void add(Message message) {
    this._socket.add(message.toJson());
  }

  void broadcast(Message message) {
    print("broadcast ${message}");
    WebSocketConnectionsHandler.broadcast(message);
  }
}