// Generated by CoffeeScript 1.7.1
var t, watcher,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

Niro.Watcher = Niro.Class.extend('Watcher', function() {
  this.constructor = function(container) {
    this.container = container;
    Object.defineProperty(this.container, 'x-niro-observed', {
      enumerable: false,
      value: true
    });
    this.watching = [];
    this.observing = [];
    return this.handlers = {};
  };
  this.on = function(event, deep, handler) {
    var path, sections, _base;
    if (handler == null) {
      handler = deep;
    }
    if (_.isFunction(deep)) {
      deep = false;
    }
    ((_base = this.handlers)[event] != null ? _base[event] : _base[event] = []).push({
      handler: handler,
      deep: deep
    });
    path = event.substr(0, event.lastIndexOf(':'));
    sections = _.getContainerAndProperty(this.container, path);
    if (!deep) {
      return this.observeProperty(sections);
    } else {
      return this.observeObject(sections);
    }
  };
  this.observeProperty = function(options) {
    var path, value;
    path = options.path;
    if (__indexOf.call(this.observing, path) >= 0) {
      return;
    }
    value = options.property;
    Object.defineProperty(options.container, options.propertyPath, {
      get: function() {
        return value;
      },
      set: (function(_this) {
        return function(newValue) {
          _.delay(0, function() {
            return _this.dispatch("" + path + ":change");
          });
          return value = newValue;
        };
      })(this)
    });
    return this.observing.push(path);
  };
  this.keysChanged = function(options, keys, newKeys) {
    var added, called, deleted, event, item, _i, _j, _len, _len1;
    deleted = keys.filter(function(item) {
      return __indexOf.call(newKeys, item) < 0;
    });
    added = newKeys.filter(function(item) {
      return __indexOf.call(keys, item) < 0;
    });
    called = false;
    for (_i = 0, _len = added.length; _i < _len; _i++) {
      item = added[_i];
      event = _.joinPath(options.path, item) + ':added';
      called = this.dispatch(event);
    }
    for (_j = 0, _len1 = deleted.length; _j < _len1; _j++) {
      item = deleted[_j];
      event = _.joinPath(options.path, item) + ':deleted';
      this.dispatch(event);
    }
    if (called) {
      return log('need');
    }
  };
  this.observeObject = function(options) {
    var keys;
    keys = Object.keys(options.property);
    return _.interval(500, (function(_this) {
      return function() {
        var newKeys;
        newKeys = Object.keys(options.property);
        if (("" + keys) !== ("" + newKeys)) {
          _this.keysChanged(options, keys, newKeys);
          return keys = newKeys;
        }
      };
    })(this));
  };
  return this.dispatch = function(event, deep) {
    var called, handler, handlers, parts, path, pathParts, _called, _event, _i, _len;
    if (deep == null) {
      deep = false;
    }
    parts = event.split(':');
    event = parts.pop();
    path = parts.join(':');
    pathParts = _.splitPath(path);
    called = false;
    while (pathParts.length) {
      _event = _.joinPath(pathParts) + (":" + event);
      handlers = this.handlers[_event];
      if (handlers) {
        for (_i = 0, _len = handlers.length; _i < _len; _i++) {
          handler = handlers[_i];
          if (deep && handler.deep || !deep) {
            called = true;
            handler.handler(_event);
          }
        }
      }
      if (deep && event !== 'change') {
        _called = this.dispatch(_.joinPath(pathParts) + ':change', true);
        if (_called) {
          called = _called;
        }
      }
      pathParts.pop();
      deep = true;
    }
    return called;
  };
});

t = {
  data: {
    name: 'connor'
  }
};

watcher = new Niro.Watcher(t);

watcher.on('data.name:change', function() {
  return log('name changed');
});

watcher.on('data:change', true, function() {
  return log('going deep');
});

watcher.on('data:change', function() {
  return log('shallow');
});
