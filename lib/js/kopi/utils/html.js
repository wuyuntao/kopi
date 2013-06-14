(function() {
  define("kopi/utils/html", function(require, exports, module) {
    var $, exceptions, prop, removeClass, replaceClass, scope;

    $ = require("jquery");
    exceptions = require("kopi/exceptions");
    /*
    Get micro data property from HTML elements.
    Ref: http://diveintohtml5.org/extensibility.html#property-values
    
    @param  {HTML Element}  element
    @return {String}
    */

    prop = function(element) {
      element = $(element);
      if (!element.length) {
        throw new exceptions.NoSuchElementError(element);
      }
      if (element.attr('itemattr')) {
        return element[element.attr('itemattr')];
      }
      switch (element.attr('tagName')) {
        case "meta":
          return element.attr('content');
        case "audio":
        case "video":
        case "embed":
        case "iframe":
        case "image":
        case "source":
          return element[0].src;
        case "a":
        case "area":
        case "link":
          return element[0].href;
        case "object":
          return element.attr('data');
        case "time":
          return element.attr('datatime');
        case "input":
          return element.val();
        default:
          return element.html();
      }
    };
    /*
    Get micro data from HTML elements
    */

    scope = function(element) {
      var data;

      element = $(element);
      if (!element.length) {
        throw new exceptions.NoSuchElementError(element);
      }
      if (element.prop('itemscope')) {
        throw new Error("Element does not have 'itemscope' attribute");
      }
      data = {};
      return $('[itemprop]', element).each(function() {
        var el;

        el = $(this);
        return data[el.attr('itemprop')] = prop(el);
      });
    };
    /*
    Replace specified CSS class for the set of matched elements
    */

    replaceClass = function(element, regexp, replacement) {
      var elem, _i, _len;

      element = $(element);
      if (!element.length) {
        throw new exceptions.NoSuchElementError(element);
      }
      for (_i = 0, _len = element.length; _i < _len; _i++) {
        elem = element[_i];
        if (elem.nodeType === 1) {
          elem.className = elem.className.replace(regexp, replacement);
        }
      }
    };
    /*
    A fast method to remove CSS class from element
    */

    removeClass = function(element, regexp) {
      return replaceClass(element, regexp, "");
    };
    return {
      prop: prop,
      scope: scope,
      replaceClass: replaceClass,
      removeClass: removeClass
    };
  });

}).call(this);
