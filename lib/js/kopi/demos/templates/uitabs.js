(function() {
  define("kopi/demos/templates/uitabs", function(require, exports, module) {
    var SimpleTemplate;

    SimpleTemplate = require("kopi/ui/templates").SimpleTemplate;
    return {
      tab1: new SimpleTemplate("<div class=\"kopi-inner\">\n  <h2>Tab #1</h2>\n</div> "),
      tab2: new SimpleTemplate("<div class=\"kopi-inner\">\n  <h2>Tab #2</h2>\n</div> "),
      tab3: new SimpleTemplate("<div class=\"kopi-inner\">\n  <h2>Tab #3</h2>\n</div> "),
      tab4: new SimpleTemplate("<div class=\"kopi-inner\">\n  <h2>Tab #4</h2>\n</div> "),
      tab5: new SimpleTemplate("<div class=\"kopi-inner\">\n  <h2>Tab #5</h2>\n</div> ")
    };
  });

}).call(this);
