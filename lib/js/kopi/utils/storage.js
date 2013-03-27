(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define("kopi/utils/storage", function(require, exports, module) {
    /*
    A storage interface for browsers does not support WebStorage
    */

    var MemoryStorage;
    MemoryStorage = (function() {

      function MemoryStorage() {
        this._keys = [];
        this._values = {};
      }

      MemoryStorage.prototype.length = function() {
        return this._keys.length;
      };

      MemoryStorage.prototype.key = function(index) {
        return this._keys[index];
      };

      MemoryStorage.prototype.getItem = function(key) {
        return this._values[key];
      };

      MemoryStorage.prototype.setItem = function(key, value) {
        if (__indexOf.call(this._keys, key) < 0) {
          this._keys.push(key);
        }
        this._values[key] = value;
      };

      MemoryStorage.prototype.removeItem = function(key) {
        this._keys.splice(this._keys.indexOf(key), 1);
        this._values[key] = void 0;
      };

      MemoryStorage.prototype.clear = function() {
        this._keys = [];
        this._values = {};
      };

      return MemoryStorage;

    })();
    return {
      memoryStorage: new MemoryStorage()
    };
  });

}).call(this);
