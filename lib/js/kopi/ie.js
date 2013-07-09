(function() {

  define("kopi/ie", function() {
    var RE_FUNCTION_NAME, createElement;
    createElement = function() {
      var doc, tag, _i, _len;
      doc = document;
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        tag = arguments[_i];
        doc.createElement(tag);
      }
    };
    createElement('header', 'hgroup', 'nav', 'menu', 'section', 'article', 'aside', 'footer', 'figure', 'figurecaption');
    RE_FUNCTION_NAME = /^\s*function\s*(\w*)\s*\(/;
    if ((createElement.name == null) && (Object.defineProperty != null)) {
      Object.defineProperty(Function.prototype, "name", {
        get: function() {
          var name;
          name = this.toString().match(RE_FUNCTION_NAME)[1];
          Object.defineProperty(this, "name", {
            value: name
          });
          return name;
        }
      });
    }
  });

}).call(this);
