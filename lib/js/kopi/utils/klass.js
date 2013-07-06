(function() {
  var __hasProp = {}.hasOwnProperty,
    __slice = [].slice;

  define("kopi/utils/klass", function(require, exports, module) {
    var SingletonError, accessor, configure, create, include, object, reader, singleton;
    object = require("kopi/utils/object");
    SingletonError = require("kopi/exceptions").SingletonError;
    /*
    Define CoffeeScript style class which could be useful for
    guys who uses Kopi with JavaScript.
    
    @param {String} name Class name
    @param {Object} parent Constructor function to inherit prototype from
    */

    create = function(name, parent) {
      var ctor, key, klass, value;
      if (parent) {
        klass = function() {
          return parent.constructor.apply(this, arguments);
        };
        klass.__super__ = parent.prototype;
        if (parent) {
          for (key in parent) {
            if (!__hasProp.call(parent, key)) continue;
            value = parent[key];
            klass[key] = value;
          }
        }
      } else {
        klass = function() {};
      }
      klass.name = klass.__name__ = name;
      ctor = function() {
        return this.constructor = klass;
      };
      if (parent) {
        ctor.prototype = parent.prototype;
      }
      klass.prototype = new ctor();
      return klass;
    };
    /*
    Include a mixin object for class
    */

    include = function(klass, mixin) {
      var method, name, _ref;
      for (name in mixin) {
        if (!__hasProp.call(mixin, name)) continue;
        method = mixin[name];
        if (name !== "prototype") {
          klass[name] = method;
        }
      }
      _ref = mixin.prototype;
      for (name in _ref) {
        if (!__hasProp.call(_ref, name)) continue;
        method = _ref[name];
        klass.prototype[name] = method;
      }
      return klass;
    };
    configure = function(klass, options) {
      var _base;
      klass._options || (klass._options = {});
      if (options) {
        klass._options = object.extend({}, klass._options, options);
      }
      object.accessor(klass, "options");
      object.accessor(klass.prototype, "options");
      klass.configure || (klass.configure = function(options) {
        configure(this, options);
        return this;
      });
      (_base = klass.prototype).configure || (_base.configure = function() {
        this._options || (this._options = object.clone(this.constructor._options));
        if (arguments.length) {
          object.extend.apply(object, [this._options].concat(__slice.call(arguments)));
        }
        return this;
      });
    };
    /*
    Define jQuery-esque property accessor
    
    @param  {Object}  klass     class owns the accessor
    @param  {String}  method    name of accessor
    @param  {Object}  property  defines default Value, property name, getter and setter.
    */

    accessor = function(klass, method, property) {
      var name;
      if (property == null) {
        property = {};
      }
      if (method in klass) {
        return;
      }
      name = property.name || ("_" + method);
      property.get || (property.get = function() {
        if (this[name] != null) {
          return this[name];
        } else {
          return property.value;
        }
      });
      property.set || (property.set = function(value) {
        return this[name] = value;
      });
      klass.accessor || (klass.accessor = function(method, property) {
        accessor(this, method, property);
        return this;
      });
      klass[method] || (klass[method] = function() {
        if (arguments.length === 0) {
          return property.get.call(this);
        } else {
          property.set.apply(this, arguments);
          return this;
        }
      });
    };
    /*
    Define jQuery-esque property read-only accessor
    
    @param  {Object}  klass     class owns the accessor
    @param  {String}  method    name of accessor
    @param  {Object}  property  defines default Value, property name, getter and setter.
    */

    reader = function(klass, method, property) {
      var name;
      if (property == null) {
        property = {};
      }
      if (method in klass) {
        return;
      }
      name = property.name || ("_" + method);
      property.get || (property.get = function() {
        return this[name] || (this[name] = property.value);
      });
      klass.reader || (klass.reader = function(method, property) {
        reader(this, method, property);
        return this;
      });
      klass[method] || (klass[method] = function() {
        return property.get.apply(this, arguments);
      });
    };
    /*
    Provide singleton interface for class
    
    @param  {Object}  klass     singleton class
    */

    singleton = function(klass) {
      var instance;
      instance = null;
      klass.instance = function() {
        return instance;
      };
      klass.removeInstance = function() {
        return instance = null;
      };
      return klass.prototype._isSingleton = function() {
        if (instance) {
          throw new SingletonError(klass);
        }
        return instance = this;
      };
    };
    return {
      create: create,
      include: include,
      configure: configure,
      accessor: accessor,
      reader: reader,
      singleton: singleton
    };
  });

}).call(this);
