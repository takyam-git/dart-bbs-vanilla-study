part of app.template;

class Template {
  mustache.Template _template;

  Template(this._template);

  String render([HashMap<String, Object> params]) {
    if (!(params is HashMap)) {
      params = new HashMap<String, Object>();
    }
    return this._template.renderString(params, lenient: true);
  }
}

class Layout extends Template {
  Layout(mustache.Template template): super(template);

  String render([HashMap<String, Object> params]) {
    if (!(params is HashMap)) {
      params = new HashMap<String, Object>();
    }
    if (!params.containsKey("content")) {
      params["content"] = "";
    }
    params["layouts"] = new Layouts();
    return super.render(params);
  }
}

class Templates extends Object with MapMixin<String, Template> {
  static Templates instance;
  HashMap<String, Template> _templates;

  Templates._(){
    this._templates = new HashMap<String, Template>();
  }

  factory Templates() {
    if (Templates.instance == null) {
      Templates.instance = new Templates._();
    }
    return Templates.instance;
  }

  Iterable<String> get keys => this._templates.keys;

  Template remove(String key) => this._templates.remove(key);

  void clear() => this._templates.clear();

  operator []=(String index, Template template) => this._templates[index] = template;

  operator [](String index) => this._templates[index];
}

class Layouts extends Templates {
  static Layouts instance;

  factory Layouts() {
    if (Layouts.instance == null) {
      Layouts.instance = new Layouts._();
    }
    return instance;
  }

  Layouts._(): super._();
}