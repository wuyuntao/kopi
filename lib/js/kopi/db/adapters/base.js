(function() {
  var __hasProp = {}.hasOwnProperty;

  define("kopi/db/adapters/base", function(require, exports, module) {
    var BaseAdapter, exceptions, klass, models, queries;
    exceptions = require("kopi/exceptions");
    klass = require("kopi/utils/klass");
    models = require("kopi/db/models");
    queries = require("kopi/db/queries");
    /*
      Interface for adapters provides for five methods
      `create`, `retrieve`, `update`, `destroy` and `raw`
    */

    BaseAdapter = (function() {
      var action, kls, notImplementedFn, proto, _i, _len, _ref;

      kls = BaseAdapter;

      klass.configure(kls);

      kls.CREATE = "create";

      kls.RETRIEVE = "retrieve";

      kls.UPDATE = "update";

      kls.DESTROY = "destroy";

      kls.RAW = "raw";

      kls.ACTIONS = [kls.CREATE, kls.RETRIEVE, kls.UPDATE, kls.DESTROY, kls.RAW];

      /*
          Check if adapter is supported by browser
      */


      BaseAdapter.support = function(model) {
        return true;
      };

      function BaseAdapter(options) {
        if (options == null) {
          options = {};
        }
        this.configure(options);
      }

      BaseAdapter.prototype.init = function(model, fn) {
        return this;
      };

      BaseAdapter.prototype._adapterObject = function(obj, fields) {
        var field, key, self;
        self = this;
        if (fields) {
          for (key in fields) {
            if (!__hasProp.call(fields, key)) continue;
            field = fields[key];
            if (typeof obj[key] === 'undefined') {
              obj[key] = field["default"];
            }
          }
          obj[key] = self._adapterValue(obj[key], field);
        }
        return obj;
      };

      BaseAdapter.prototype._modelObject = function(obj, fields) {
        var field, key, self;
        self = this;
        if (fields) {
          for (key in fields) {
            if (!__hasProp.call(fields, key)) continue;
            field = fields[key];
            if (typeof obj[key] === 'undefined') {
              obj[key] = field["default"];
            }
          }
          obj[key] = self._modelValue(obj[key], field);
        }
        return obj;
      };

      /*
          Convert model value to adapter value.
          Could be overriden for specific adapter.
      */


      BaseAdapter.prototype._adapterValue = function(value, field) {
        return this._forceType(value, field);
      };

      /*
          Convert adapter value to model value.
          Could be overriden for specific adapter.
      */


      BaseAdapter.prototype._modelValue = function(value, field) {
        return this._forceType(value, field);
      };

      /*
          Force type conversion for field value
      */


      BaseAdapter.prototype._forceType = function(value, field) {
        if (!(field && field.type)) {
          return value;
        }
        switch (field.type) {
          case models.INTEGER:
            return parseInt(value);
          case models.STRING:
          case models.TEXT:
            return value + "";
          case models.FLOAT:
            return parseFloat(value);
          default:
            return value;
        }
      };

      proto = kls.prototype;

      notImplementedFn = function() {
        throw new exceptions.NotImplementedError();
      };

      _ref = kls.ACTIONS;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        action = _ref[_i];
        proto[action] = notImplementedFn;
      }

      return BaseAdapter;

    })();
    return {
      BaseAdapter: BaseAdapter
    };
  });

}).call(this);
