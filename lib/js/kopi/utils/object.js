(function() {
  var __slice = [].slice,
    __hasProp = {}.hasOwnProperty;

  define("kopi/utils/object", function(require, exports, module) {
    var ObjectProto, accessor, clone, create, defineAsyncProperty, defineProperty, extend, func, isObject, keys, number, text;
    func = require("kopi/utils/func");
    number = require("kopi/utils/number");
    text = require("kopi/utils/text");
    ObjectProto = Object.prototype;
    /*
      Define jQuery-esque hash accessor
    */

    accessor = function(klass, method, property) {
      property || (property = "_" + method);
      klass[method] || (klass[method] = function(name, value) {
        var obj;
        obj = this[property] || (this[property] = {});
        switch (arguments.length) {
          case 0:
            return obj;
          case 1:
            return obj[name];
          default:
            return obj[name] = value;
        }
      });
    };
    clone = function(obj) {
      return extend({}, obj);
    };
    /*
      Creates a new object with the specified prototype object and properties.
    */

    create = Object.create || (Object.create = function(proto) {
      var F;
      if (proto == null) {
        proto = {};
      }
      F = function() {};
      F.prototype = proto;
      return new F();
    });
    /*
      Define custom property. e.g.
      get: book.title
      set: book.title = 1
    */

    defineProperty = Object.defineProperty || (Object.defineProperty = function(obj, field, property) {
      if (property == null) {
        property = {};
      }
      if (property.get) {
        obj.__defineGetter__(field, function() {
          return property.get.call(this);
        });
      }
      if (property.set) {
        obj.__defineSetter__(field, function(value) {
          property.set.call(this, value);
          return value;
        });
      }
      return obj;
    });
    /*
      Define asynchronous property.
    
      Usage
    
        defineAsyncProperty book,
          get: (fn) ->
            asyncGetTitle (error, title) ->
              fn(error, title) if fn
          set: (title, fn) ->
            asyncSetTitle title, (error, title) ->
              fn(error, title) if fn
    
      Get book title asynchronously
    
        book.getTitle (error, title) -> console.log(error, title)
    
      Set book title asynchronously
    
        book.setTitle title, (error, title) -> console.log(error, title)
    */

    defineAsyncProperty = function(obj, field, property) {
      if (property == null) {
        property = {};
      }
      field = text.capitalize(field);
      if (property.get) {
        obj["get" + field] = function() {
          property.get.apply(this, arguments);
          return obj;
        };
      }
      if (property.set) {
        obj["set" + field] = function() {
          property.set.apply(this, arguments);
          return obj;
        };
      }
      return obj;
    };
    extend = function() {
      var method, mixin, mixins, name, obj, _i, _len;
      obj = arguments[0], mixins = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      for (_i = 0, _len = mixins.length; _i < _len; _i++) {
        mixin = mixins[_i];
        if (mixin) {
          for (name in mixin) {
            method = mixin[name];
            obj[name] = method;
          }
        }
      }
      return obj;
    };
    isObject = function(obj) {
      return typeof obj === "object";
    };
    keys = Object.keys || (Object.keys = function(obj) {
      var key, val, _results;
      _results = [];
      for (key in obj) {
        if (!__hasProp.call(obj, key)) continue;
        val = obj[key];
        _results.push(key);
      }
      return _results;
    });
    return {
      ObjectProto: ObjectProto,
      accessor: accessor,
      clone: clone,
      create: create,
      defineProperty: defineProperty,
      extend: extend,
      isObject: isObject,
      keys: keys
    };
  });

}).call(this);
