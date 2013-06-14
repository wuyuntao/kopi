(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/ui/text", function(require, exports, module) {
    var EllipsisText, Text, klass, widgets;

    klass = require("kopi/utils/klass");
    widgets = require("kopi/ui/widgets");
    Text = (function(_super) {
      var kls, proto;

      __extends(Text, _super);

      kls = Text;

      kls.widgetName("Text");

      kls.configure({
        tagName: 'span'
      });

      proto = kls.prototype;

      klass.accessor(proto, "text", {
        set: function(text, update) {
          if (update == null) {
            update = true;
          }
          this._text = text;
          if (update && this.rendered) {
            this.update();
          }
          return this;
        }
      });

      function Text() {
        Text.__super__.constructor.apply(this, arguments);
        this._text || (this._text = this._options.text);
      }

      Text.prototype.onrender = function() {
        this._draw();
        return Text.__super__.onrender.apply(this, arguments);
      };

      Text.prototype.onupdate = function() {
        this._draw();
        return Text.__super__.onupdate.apply(this, arguments);
      };

      Text.prototype._draw = function() {
        var self;

        self = this;
        if (self._text) {
          self.element.text(self._text);
        }
        return self;
      };

      return Text;

    })(widgets.Widget);
    /*
    A text view support multi-line text truncation
    */

    EllipsisText = (function(_super) {
      var kls;

      __extends(EllipsisText, _super);

      kls = EllipsisText;

      kls.widgetName("EllipsisText");

      kls.VALIGN_NONE = 0;

      kls.VALIGN_TOP = 1;

      kls.VALIGN_BOTTOM = 2;

      kls.VALIGN_MIDDLE = 3;

      kls.configure({
        tagName: 'p',
        lineHeight: 18,
        lines: 3,
        valign: kls.VALIGN_NONE,
        maxTries: 30
      });

      function EllipsisText(options, text) {
        if (text == null) {
          text = "";
        }
        EllipsisText.__super__.constructor.call(this, options);
        options = this._options;
        this._text = text;
        this._maxHeight = options.lineHeight * options.lines;
        this._fullHeight = null;
      }

      EllipsisText.prototype.onskeleton = function() {
        var css, options, self;

        self = this;
        options = self._options;
        self._maxHeight = options.lineHeight * options.lines;
        css = {
          overflow: 'hidden',
          lineHeight: parseInt(options.lineHeight) + 'px',
          maxHeight: parseInt(self._maxHeight) + 'px'
        };
        self.element.css(css);
        return EllipsisText.__super__.onskeleton.apply(this, arguments);
      };

      EllipsisText.prototype.onresize = function() {
        this.update();
        return EllipsisText.__super__.onresize.apply(this, arguments);
      };

      EllipsisText.prototype.onrender = function() {
        this.update();
        return EllipsisText.__super__.onrender.apply(this, arguments);
      };

      EllipsisText.prototype.onupdate = function() {
        this._fill()._truncate()._padding();
        return EllipsisText.__super__.onupdate.apply(this, arguments);
      };

      EllipsisText.prototype._fill = function() {
        this.element.css('padding', 0).text(this._text);
        return this;
      };

      EllipsisText.prototype._truncate = function() {
        var cls, element, height, i, max, middle, min, self, subtext, subtext2, text, _i, _ref;

        cls = this.constructor;
        self = this;
        element = this.element;
        min = 0;
        max = self._text.length - 1;
        text = self._text;
        if (element.innerHeight() <= self._maxHeight) {
          return self;
        }
        for (i = _i = 0, _ref = self._options.maxTries; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          if (max < min) {
            break;
          }
          middle = Math.floor((min + max) / 2);
          subtext = text.substr(0, middle);
          element.text(subtext + '...');
          height = element.innerHeight();
          if (height > self._maxHeight) {
            max = middle;
          } else if (height < self._maxHeight) {
            min = middle;
          } else {
            subtext2 = text.substr(0, middle + 1);
            element.text(subtext2 + '...');
            if (element.innerHeight() > self._maxHeight) {
              element.text(subtext + '...');
              break;
            } else {
              if (min === middle) {
                break;
              }
              min = middle;
            }
          }
        }
        return self;
      };

      EllipsisText.prototype._padding = function() {
        var cls, element, padding, self;

        cls = this.constructor;
        self = this;
        element = self.element;
        padding = self._maxHeight - element.innerHeight();
        if (padding > 0) {
          switch (self._options.valign) {
            case cls.VALIGN_TOP:
              element.css("paddingBottom", padding + "px");
              break;
            case cls.VALIGN_BOTTOM:
              element.css("paddingTop", padding + "px");
              break;
            case cls.VALIGN_MIDDLE:
              padding /= 2;
              element.css({
                paddingTop: padding + "px",
                paddingBottom: padding + "px"
              });
          }
        }
        return self;
      };

      EllipsisText.prototype._height = function(force) {
        var element, self, text;

        if (force == null) {
          force = false;
        }
        self = this;
        element = self.element;
        if (force || !self._fullHeight) {
          text = element.text();
          element.text(self.text);
          self._fullHeight = element.height();
          element.text(text);
        }
        return self._fullHeight;
      };

      return EllipsisText;

    })(Text);
    return {
      Text: Text,
      EllipsisText: EllipsisText
    };
  });

}).call(this);
