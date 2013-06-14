(function() {
  define("kopi/ie", function() {
    var createElement;

    createElement = function() {
      var doc, tag, _i, _len;

      doc = document;
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        tag = arguments[_i];
        doc.createElement(tag);
      }
    };
    createElement('header', 'hgroup', 'nav', 'menu', 'section', 'article', 'aside', 'footer', 'figure', 'figurecaption');
  });

}).call(this);
