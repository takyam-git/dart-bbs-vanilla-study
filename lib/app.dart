import "dart:io";
import "dart:async";
import "dart:collection";
import "package:http_server/http_server.dart";
import "package:route/server.dart";
import "package:route/pattern.dart";
import "package:route/url_pattern.dart";

import "initializer.dart";
import "controller.dart";
import "message.dart";
import "websocket.dart";

class App {

  final HashMap<String, UrlPattern> urlPatterns = {
      "index": new UrlPattern(r"/"),
      "login": new UrlPattern(r"/login"),
      "logout": new UrlPattern(r"/logout"),
  };

  void run() {
    Initializer.initialize().then((_) => this.launchServer());
  }

  void launchServer() {
    var assetsUrlPatterns = [new UrlPattern(r"/assets/(.*)")];
    var staticFiles = new VirtualDirectory(r"web/assets", pathPrefix: r"/assets")
      ..followLinks = false
      ..allowDirectoryListing = false;
    var myPackageUrlPatterns = [new UrlPattern(r"/assets/dart/packages/takyam-bbs-vanilla/message.dart")];
    var myPackageFiles = new VirtualDirectory(r"lib", pathPrefix: r"/assets/dart/packages/takyam-bbs-vanilla")
      ..followLinks = false
      ..allowDirectoryListing = false;
    runZoned(() {
      HttpServer.bind('0.0.0.0', 3000).then((HttpServer server) {
        var router = new Router(server)
        //serve client-server shared dart files
          ..serve(matchAny(myPackageUrlPatterns)).listen(myPackageFiles.serveRequest)
        //serve static files
          ..serve(matchAny(assetsUrlPatterns), method: "GET").listen(staticFiles.serveRequest)
        //serve websocket
          ..serve(new UrlPattern(r"/ws(.*)")).transform(new WebSocketTransformer()).listen(this.serveWebSocket)
        //serve via controllers
          ..defaultStream.transform(new HttpBodyHandler()).listen(this.serveRequest);
      });
    }, onError:(e, StackTrace stackTrace) {
      print('おお！さーばーよ！死んでしまうとはなさけない！: ${e} ${stackTrace}');
    });
  }

  void serveRequest(HttpRequestBody body) {
    runZoned(() {
      Controller controller;
      if (this._isUrlMatched("index", body, method: "GET")) {
        controller = new IndexController(body);
      } else {
        controller = new NotFoundController(body);
      }
      controller.run();
    }, onError: (e, StackTrace stackTrace) {
      print('おお！なんたることか！このリクエストはしんでしまった！: ${e} ${stackTrace}');
      body.request.response
        ..statusCode = 500
        ..headers.add(HttpHeaders.CONTENT_TYPE, "text/plain")
        ..write("Request failed, please retry later.")
        ..close();
    });
  }

  void serveWebSocket(WebSocket socket) {
    WebSocketConnectionsHandler.add(socket);
    print(identityHashCode(socket));
//    print(socket._serviceId);
    runZoned(() {
      socket.map((Object obj) {
        return new Message.fromJson(obj);
      }).listen((Message message) {

        WebSocketController controller;
        if (message.type == MessageType.NEW_MESSAGE) {
          controller = new NewMessageController(socket, message);
        } else if (message.type == MessageType.GET_MESSAGES) {
          controller = new GetMessagesController(socket, message);
        } else {
          throw new ArgumentError("Unknown Type passed");
        }
        controller.run();
      }).onError((error) {
        print(error);
      });
    }, onError: (error) {
      print(error);
    });
  }

  /**
   * [_isUrlMatched] checks request url is pattern matched with [patternKey] UrlPattern.
   */
  bool _isUrlMatched(String patternKey, HttpRequestBody body, {String method}) {
    return matchesFull(this.urlPatterns[patternKey], body.request.uri.path) &&
    (method == null || body.request.method.toUpperCase() == method.toUpperCase());
  }
}
