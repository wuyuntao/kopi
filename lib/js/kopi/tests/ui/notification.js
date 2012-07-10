(function() {

  define("kopi/tests/ui/notification", function(require, exports, module) {
    var bubbles, dialogs, indicators, overlays;
    overlays = require("kopi/ui/notification/overlays");
    indicators = require("kopi/ui/notification/indicators");
    bubbles = require("kopi/ui/notification/bubbles");
    dialogs = require("kopi/ui/notification/dialogs");
    return $(function() {
      $("#show-overlay").click(function() {
        overlays.show();
        console.log("Hide overlay in 3 seconds.");
        return setTimeout((function() {
          return overlays.hide();
        }), 3000);
      });
      $("#show-indicator").click(function() {
        indicators.show();
        console.log("Hide indicator in 3 seconds.");
        return setTimeout((function() {
          return indicators.hide();
        }), 3000);
      });
      $("#show-bubble").click(function() {
        return bubbles.show("Hello world!", {
          lock: true,
          transparent: false,
          duration: 3000
        });
      });
      return $("#show-dialog").click(function() {
        return dialogs.instance().title("Hello world!").content("This is a dialog!").action("Confirm", function() {
          return console.log("Action button clicked");
        }).close("Cancel", function() {
          return console.log("Close button clicked");
        }).show();
      });
    });
  });

}).call(this);
