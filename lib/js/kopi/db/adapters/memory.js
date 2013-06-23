(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/db/adapters/memory", function(require, exports, module) {
    var KeyValueAdapter, MemoryAdapter, storage;
    storage = require("kopi/utils/storage").memoryStorage;
    KeyValueAdapter = require("kopi/db/adapters/kv").KeyValueAdapter;
    MemoryAdapter = (function(_super) {

      __extends(MemoryAdapter, _super);

      function MemoryAdapter() {
        return MemoryAdapter.__super__.constructor.apply(this, arguments);
      }

      MemoryAdapter.support = function() {
        return !!storage;
      };

      MemoryAdapter.prototype._get = function(key, defautValue, fn) {
        var value;
        value = storage.getItem(key);
        value = value != null ? value : defautValue;
        if (fn) {
          fn(null, value);
        }
        return value;
      };

      MemoryAdapter.prototype._set = function(key, value, fn) {
        storage.setItem(key, value);
        if (fn) {
          fn(null);
        }
        return value;
      };

      MemoryAdapter.prototype._remove = function(key, fn) {
        var value;
        value = storage.removeItem(key);
        if (fn) {
          fn(null);
        }
        return value;
      };

      return MemoryAdapter;

    })(KeyValueAdapter);
    return {
      MemoryAdapter: MemoryAdapter
    };
  });

}).call(this);
