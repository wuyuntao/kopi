(function() {

  define("kopi/tests/all", function(require, exports, module) {
    var router, scrollable, text, touchable, uri;
    uri = require("kopi/tests/utils/uri");
    scrollable = require("kopi/tests/ui/scrollable");
    text = require("kopi/tests/ui/text");
    touchable = require("kopi/tests/ui/touchable");
    return router = require("kopi/tests/app/router");
  });

}).call(this);
