(function() {
  define("kopi/demos/settings", function(require, exports, module) {
    var settings;

    settings = require("kopi/settings");
    settings.kopi.demos = {
      list: ["item1", "item2", "item3", "item4", "item5", "item6", "item7", "item8", "item9", "item10"]
    };
    return settings;
  });

}).call(this);
