(function() {

  define("kopi/tests/ui/draggable", function(require, exports, module) {
    var d, draggable;
    draggable = require("kopi/ui/draggable");
    return d = new draggable.Draggable().skeleton(".draggable").render();
  });

}).call(this);
