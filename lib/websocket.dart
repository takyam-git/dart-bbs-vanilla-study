library app.websocket;

import "dart:io";

import "message.dart";

class WebSocketConnectionsHandler {
  static Set<WebSocket> _connections = new Set<WebSocket>();

  static add(WebSocket socket) {
    _connections.add(socket);
    socket.done.then((_) => remove(socket));
  }

  static remove(WebSocket socket) {
    _connections.remove(socket);
  }

  static broadcast(Message message) {
    _connections
    .where((WebSocket socket) => socket.readyState == WebSocket.OPEN)
    .forEach((WebSocket socket) => socket.add(message.toJson()));
  }
}