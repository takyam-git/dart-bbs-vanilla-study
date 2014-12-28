part of app.controller;

class NotFoundController extends ViewController {
  final View view = new NotFoundView();

  NotFoundController(HttpRequestBody body): super(body);

  void run() {
    this.response();
  }
}