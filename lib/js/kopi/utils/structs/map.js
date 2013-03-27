(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/utils/structs/map", function(require, exports, module) {
    var Map, weakmap;
    weakmap = require("kopi/utils/structs/weakmap");
    /*
    Similar in style to weak maps.
    */

    Map = (function(_super) {

      __extends(Map, _super);

      function Map() {
        return Map.__super__.constructor.apply(this, arguments);
      }

      return Map;

    })(weakmap.WeakMap);
    return {
      Map: Map
    };
  });

}).call(this);
