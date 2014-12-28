part of app.controller;

class IndexController extends ViewController {
  final View view = new IndexView();

  IndexController(HttpRequestBody body): super(body);

  void run() {
    this.response();
  }
}