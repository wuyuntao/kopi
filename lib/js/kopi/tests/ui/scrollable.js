(function() {
  define("kopi/tests/ui/scrollable", function(require, exports, module) {
    var s, scrollable;

    scrollable = require("kopi/ui/scrollable");
    s = new scrollable.Scrollable({
      scrollX: false,
      damping: 0.5
    });
    return s.skeleton(".scrollable").render();
  });

}).call(this);
