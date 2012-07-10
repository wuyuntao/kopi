(function() {

  define("kopi/tests/ui/tabs", function(require, exports, module) {
    var options, scrollable, stabBar, tabBar, tabs;
    tabs = require("kopi/ui/tabs");
    scrollable = require("kopi/ui/scrollable");
    tabBar = new tabs.TabBar({
      layout: tabs.TabBar.LAYOUT_HORIZONTAL
    }).add("tab1").text("Tab #1").icon("/images/icon1.png").on("select", function() {
      return console.log(0);
    }).end().add("tab2").text("Tab #2").icon("/images/icon2.png").on("select", function() {
      return console.log(1);
    }).end().add("tab3").text("Tab #3").icon("/images/icon3.png").on("select", function() {
      return console.log(2);
    }).end().add("tab4").text("Tab #4").icon("/images/icon4.png").on("select", function() {
      return console.log(3);
    }).end().add("tab5").text("Tab #5").icon("/images/icon5.png").on("select", function() {
      return console.log(4);
    }).end().skeleton(".tabbar").render();
    options = {
      layout: tabs.TabBar.LAYOUT_HORIZONTAL,
      style: tabs.TabBar.STYLE_FIXED,
      width: 64,
      scrollableOptions: {
        scrollY: false,
        ontouchstart: function() {
          return console.log("start");
        },
        ontouchmove: function() {
          return console.log("move");
        },
        ontouchend: function() {
          return console.log("end");
        }
      }
    };
    stabBar = new tabs.ScrollableTabBar(options).add("tab1").text("Tab #1").icon("/images/icon1.png").on("select", function() {
      return console.log(0);
    }).end().add("tab2").text("Tab #2").icon("/images/icon2.png").on("select", function() {
      return console.log(1);
    }).end().add("tab3").text("Tab #3").icon("/images/icon3.png").on("select", function() {
      return console.log(2);
    }).end().add("tab4").text("Tab #4").icon("/images/icon4.png").on("select", function() {
      return console.log(3);
    }).end().add("tab5").text("Tab #5").icon("/images/icon5.png").on("select", function() {
      return console.log(4);
    }).end().add("tab6").text("Tab #6").icon("/images/icon1.png").on("select", function() {
      return console.log(5);
    }).end().add("tab7").text("Tab #7").icon("/images/icon2.png").on("select", function() {
      return console.log(6);
    }).end().add("tab8").text("Tab #8").icon("/images/icon3.png").on("select", function() {
      return console.log(7);
    }).end().add("tab9").text("Tab #9").icon("/images/icon4.png").on("select", function() {
      return console.log(8);
    }).end().add("tab10").text("Tab #10").icon("/images/icon5.png").on("select", function() {
      return console.log(9);
    }).end().skeleton(".stabbar").scrollable().emit(scrollable.Scrollable.RESIZE_EVENT).end().render();
  });

}).call(this);
