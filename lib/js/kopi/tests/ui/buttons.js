(function() {

  define("kopi/tests/ui/buttons", function(require, exports, module) {
    var button, buttons;
    buttons = require("kopi/ui/buttons");
    button = new buttons.Button({
      hasIcon: false,
      onhover: function() {
        return console.log("hover");
      },
      onhoverout: function() {
        return console.log("hoverout");
      },
      onclick: function() {
        return console.log("click");
      },
      ontouchhold: function() {
        return console.log("touchhold");
      }
    });
    button.title("button").skeleton("#button1").render();
  });

}).call(this);
