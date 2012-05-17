// Generated by CoffeeScript 1.3.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  define("kopi/db/adapters/memory", function(require, exports, module) {
    var MemoryAdapter, storage, webstorage;
    storage = require("kopi/utils/storage");
    webstorage = require("kopi/db/adapters/webstorage");
    storage = storage.memoryStorage;
    MemoryAdapter = (function(_super) {

      __extends(MemoryAdapter, _super);

      MemoryAdapter.name = 'MemoryAdapter';

      function MemoryAdapter() {
        return MemoryAdapter.__super__.constructor.apply(this, arguments);
      }

      MemoryAdapter.prototype.support = function() {
        return !!storage;
      };

      MemoryAdapter.prototype._get = function(key, value) {
        storage.getItem(key) || value;
        return this;
      };

      MemoryAdapter.prototype._set = function(key, value) {
        return storage.setItem(key, value);
      };

      MemoryAdapter.prototype._remove = function(key) {
        storage.removeItem(key);
        return this;
      };

      return MemoryAdapter;

    })(kv.KeyValueAdapter);
    return {
      MemoryAdapter: MemoryAdapter
    };
  });

}).call(this);