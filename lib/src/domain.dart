part of app.domain;

abstract class DomainEntity extends Object with MapMixin {
  Map<String, Object> _properties;

  DomainEntity._([Map<String, Object> properties]) {
    this._properties = new Map<String, Object>();
    if (properties is Map<String, Object>) {
      this._properties.addAll(properties);
    }
  }

  operator [](String key) => this._properties[key];

  operator []=(String key, Object value) => this._properties[key] = value;

  Iterable<String> get keys => this._properties.keys;

  Object remove(String key) => this._properties.remove(key);

  void clear() => this._properties.clear();
}

abstract class DomainRepository {

}