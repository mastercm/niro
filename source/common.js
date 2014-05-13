// Generated by CoffeeScript 1.7.1
var __slice = [].slice,
  __hasProp = {}.hasOwnProperty;

Niro.Common = (function(exports, global) {
  var slice;
  global.log = console.log.bind(console);
  global.dir = console.dir.bind(console);
  slice = [].slice;
  exports.toArray = function(value) {
    return slice.call(value);
  };
  exports.noop = function() {};
  exports.isFunction = function(value) {
    return typeof value === 'function';
  };
  exports.isArray = function(value) {
    return value instanceof Array;
  };
  exports.isObject = function(value) {
    return value !== null && typeof value === 'object';
  };
  exports.isString = function(value) {
    return typeof value === 'string';
  };
  exports.isNumber = function(value) {
    return typeof value === 'number';
  };
  exports.isRegex = function(value) {
    return value instanceof RegExp;
  };
  exports.isNode = function(value) {
    return value instanceof Node;
  };
  exports.isDate = function(value) {
    return value instanceof Date;
  };
  exports.isBoolean = function(value) {
    return typeof value === 'boolean';
  };
  exports.isCustomObject = function(value) {
    return this.isObject(value) && !this.isRegex(value) && !this.isDate(value) && !this.isNode(value);
  };
  exports.isDictionary = function(value) {
    return this.isObject(value) && !this.isArray(value) && this.isCustomObject(value);
  };
  exports.isCircular = function(value) {
    var error;
    try {
      JSON.stringify(value);
      return false;
    } catch (_error) {
      error = _error;
      return error.stack.indexOf('circular') !== -1;
    }
  };
  exports.escapeRegex = function(string) {
    return string.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1");
  };
  exports.forIn = function(array, handler, context) {
    var index, value, _i, _len;
    if (!this.isArray(array)) {
      throw Error('forIn expected first argument to be an Array, type was ' + typeof array);
    }
    if (!this.isFunction(handler)) {
      throw Error('forIn expected second argument to be a Functon, type was ' + typeof handler);
    }
    if (context && !this.isObject(context)) {
      throw Error('forIn expected third argument (context) to be a Object if it was provided, type was', typeof context);
    }
    for (index = _i = 0, _len = array.length; _i < _len; index = ++_i) {
      value = array[index];
      handler.call(context, value, index, array);
    }
    return array;
  };
  exports.extend = function() {
    var destination, index, position, property, source, sources, value, _i, _len;
    destination = arguments[0], sources = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (!(this.isObject(destination) || this.isFunction(destination))) {
      throw Error('extend expected first arguments to be an Object or FunctionFunctino, type was ' + typeof destination);
    }
    for (index = _i = 0, _len = sources.length; _i < _len; index = ++_i) {
      source = sources[index];
      if (!(this.isObject(source) || this.isFunction(source))) {
        continue;
      }
      for (property in source) {
        if (!__hasProp.call(source, property)) continue;
        value = source[property];
        if (this.isDictionary(value) && this.isObject(position = destination[property])) {
          this.extend(position, value);
        } else {
          destination[property] = value;
        }
      }
    }
    return destination;
  };
  exports.clone = function(object) {
    var instance, property, value;
    if (!object || !this.isObject(object) || this.isRegex(object)) {
      return object;
    }
    if (this.isDate(object)) {
      return new Date(object.getTime());
    }
    instance = new object.constructor;
    for (property in object) {
      if (!__hasProp.call(object, property)) continue;
      value = object[property];
      instance[property] = this.clone(value);
    }
    return instance;
  };
  exports.search = function(object, handler, startPath) {
    var property, value, _results;
    if (!this.isObject(object)) {
      throw Error("search expected first argument (object) to be a Object, type was " + (typeof object));
    }
    if (!this.isFunction(handler)) {
      throw Error("search expected second argument (handler) to be a Fucntion, type was " + (typeof handler));
    }
    if (startPath && !this.isString(startPath)) {
      throw Error("search expected third argument (startPath) to be a String if provided, type was " + (typeof startPath));
    }
    _results = [];
    for (property in object) {
      if (!__hasProp.call(object, property)) continue;
      value = object[property];
      if (property !== 'length') {
        handler(value, property, object);
      }
      if (this.isArray(value) || this.isObject(value) && !this.isCircular(value)) {
        _results.push(this.search(value, handler));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };
  exports.splitPath = function(path) {
    return path.split(/\[|\]|\./).filter(Boolean);
  };
  exports.joinPath = function(parts) {
    var part, path, _i, _len;
    parts = this.isArray(parts) ? parts : this.toArray(arguments);
    path = '';
    for (_i = 0, _len = parts.length; _i < _len; _i++) {
      part = parts[_i];
      if (!isNaN(part)) {
        part = "[" + part + "]";
      } else if (path.length > 0) {
        part = "." + part;
      }
      path += part;
    }
    return path;
  };
  exports.getByPath = function(object, path) {
    var last, part, parts, _i, _len;
    if (!this.isObject(object)) {
      throw Error("getByPath expected first argument (object) to be a Object, type was " + (typeof object));
    }
    if (!path) {
      return object;
    }
    parts = this.splitPath(path);
    last = parts.pop();
    for (_i = 0, _len = parts.length; _i < _len; _i++) {
      part = parts[_i];
      object = object[part] || {};
    }
    return object[last];
  };
  exports.setByPath = function(object, path, value) {
    var last, part, parts, _i, _len;
    if (!this.isObject(object)) {
      throw Error("setByPath expected first argument (object) to be a Object, type was " + (typeof object));
    }
    if (!path) {
      return value;
    }
    parts = this.splitPath(path);
    last = parts.pop();
    for (_i = 0, _len = parts.length; _i < _len; _i++) {
      part = parts[_i];
      object = object[part] != null ? object[part] : object[part] = {};
    }
    return object[last] = value;
  };
  exports.getContainerAndProperty = function(object, path) {
    var container, containerPath, parts, property, propertyPath;
    parts = this.splitPath(path);
    propertyPath = parts.pop();
    containerPath = this.joinPath(parts);
    container = this.getByPath(object, containerPath);
    property = this.getByPath(container, propertyPath);
    return {
      container: container,
      property: property,
      containerPath: containerPath,
      propertyPath: propertyPath,
      path: path
    };
  };
  exports.delay = function(ms, handler) {
    return global.setTimeout(handler, ms);
  };
  exports.interval = function(ms, handler) {
    return global.setInterval(handler, ms);
  };
  exports.clearDelay = global.clearTimeout.bind(global);
  exports.clearInterval = global.clearInterval.bind(global);
  Number.prototype.toOrdinalString = function() {
    var chars, index, value;
    chars = ['st', 'nd', 'rd'];
    value = "" + this.valueOf();
    index = value.charAt(value.length - 1) - 1;
    return value + (chars[index] || 'th');
  };
  String.prototype.remove = function(item, global) {
    var regex;
    regex = new RegExp(_.escapeRegex(item), global && 'g');
    return this.valueOf().replace(regex, '');
  };
  String.prototype.escape = function() {
    var character, characters, regex, string, _i, _len;
    characters = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    string = this.valueOf();
    for (_i = 0, _len = characters.length; _i < _len; _i++) {
      character = characters[_i];
      regex = new RegExp(_.escapeRegex(character), 'g');
      string = string.replace(regex, '\\' + character);
    }
    return string;
  };
  return global._ = exports;
})({}, window);