(function() {
  define("kopi/demos/templates/uibuttons", function(require, exports, module) {
    var SimpleTemplate;

    SimpleTemplate = require("kopi/ui/templates").SimpleTemplate;
    return {
      buttons: new SimpleTemplate("<div class=\"kopi-inner\">\n  <h2>Buttons</h2>\n  <p>Description</p>\n  <div class=\"button-style-section\">\n  </div>\n  <h2>Buttons</h2>\n  <p>Description</p>\n  <div class=\"button-size-section\">\n  </div>\n</div> ")
    };
  });

}).call(this);
