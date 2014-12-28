part of app.initializer;

class Initializer {
  static Future initialize() {
    var completer = new Completer();

    List<Future> waits = [];

    waits.add(Initializer.initializeTemplates());

    Future.wait(waits).then((_) => completer.complete());
    return completer.future;
  }

  static Future initializeTemplates() {
    var completer = new Completer();

    //get singleton instances
    var templates = new Templates();
    var layouts = new Layouts();

    //load all templates in web/templates
    var templateCompleter = new Completer();
    _TemplateFileLoader.load(r"web/templates").then((HashMap<String, mustache.Template> _templates) {
      _templates.forEach((String key, mustache.Template template) {
        templates[key] = new Template(template);
      });
      templateCompleter.complete();
    });

    //load all layouts in web/layouts
    var layoutCompleter = new Completer();
    _TemplateFileLoader.load(r"web/layouts").then((HashMap<String, mustache.Template> _layouts) {
      _layouts.forEach((String key, mustache.Template template) {
        layouts[key] = new Layout(template);
      });
      layoutCompleter.complete();
    });

    Future.wait([templateCompleter.future, layoutCompleter.future]).then((_) => completer.complete());

    return completer.future;
  }
}

/**
 * _TemplateFileLoader is a loader that load all template files in [rootPath].
 */
class _TemplateFileLoader {
  static Future<HashMap<String, mustache.Template>> load(String rootDirectoryPath) {
    var completer = new Completer();

    HashMap<String, mustache.Template> templates = {
    };

    var templatesDirectory = new Directory(rootDirectoryPath);
    List<Future> readList = [];

    //Load all html file in `web/templates`.
    templatesDirectory.list(recursive: true, followLinks: false).where((FileSystemEntity element) {
      //Skip extension if it is not ".html".
      return path.extension(element.path) == ".html";
    }).forEach((FileSystemEntity element) {
      //Check file type.
      FileSystemEntity.isFile(element.path).then((bool isFile) {
        //Skip if it is not File.
        if (!isFile) {
          return;
        }
        //Create and add Completer that read file as String to [readList].
        var readTemplateCompleter = new Completer();
        readList.add(readTemplateCompleter.future);
        (element as File).readAsString().then((String template) {
          //When load completely, parse as mustache and add [mustache.Template] to [_templates].
          //A key is related from "web/templates" and has no extension.
          //For example, "web/templates/foo/bar.html" is convert to "foo/bar".
          String key = path.relative(element.path, from: templatesDirectory.path);
          key = path.withoutExtension(key);
          templates[key] = mustache.parse(template);
          readTemplateCompleter.complete();
          return;
        });
      });
    }).whenComplete(() {
      //Wait complete read templates when ready [readList].
      Future.wait(readList).then((_) {
        //finish.
        completer.complete(templates);
      });
    });
    return completer.future;
  }
}

