part of app.view;


abstract class View {
  String _layoutKey;
  Layout _layout;
  String _contentKey;
  Template _content;
  HashMap<String, Object> _params;
  List<String> _scripts;
  List<String> _styles;

  View() {
    var layouts = new Layouts();
    if (!layouts.containsKey(this._layoutKey)) {
      throw new UnimplementedError('Layout "${this._layoutKey}" does not defined.');
    }
    var templates = new Templates();
    if (!templates.containsKey(this._contentKey)) {
      throw new UnimplementedError('ContentTemplate "${this._contentKey} does not defined.');
    }
    this._layout = layouts[this._layoutKey];
    this._content = templates[this._contentKey];
    this._params = new HashMap();

    if (!(this._scripts is List)) {
      this._scripts = [];
    }
    if (!(this._styles is List)) {
      this._styles = [];
    }
  }

  void setParam(String key, Object value) {
    this._params[key] = value;
  }

  void setParams(Map<String, Object> params) {
    this._params.addAll(params);
  }

  Future<String> render() {
    return new Future<String>(() {
      return this._layout.render({
          "content": this._content.render(this._params),
          "scripts": this._scripts,
          "styles": this._styles,
      });
    });
  }
}