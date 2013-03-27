(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define("kopi/utils/text", function(require, exports, module) {
    var ABERRANT_PLURAL_MAP, StringProto, VOWELS, camelize, capitalFn, capitalize, constantize, contains, dasherize, endsWith, format, isString, isWhitespace, lowerCaseFn, lowercase, pluralize, reCapitalLetter, reFirstLetter, reLeading, reLower, reSymbol, reTrailing, reUnderscore, reUpper, startsWith, strDash, strSymbol, strUnderscore, trim, truncate, underscore, upperCaseFn, whiteSpaces;
    StringProto = String.prototype;
    reCapitalLetter = /(?:^|[_-])(.)/g;
    reUnderscore = /_+/g;
    reFirstLetter = /^(.)/;
    capitalFn = function(c) {
      return c.replace(reUnderscore, '').toUpperCase();
    };
    upperCaseFn = function(c) {
      return c.toUpperCase();
    };
    lowerCaseFn = function(c) {
      return c.toLowerCase();
    };
    /*
    Convert string to UpperCamelCase.
    If `upperCase` is set to true, produce lowerCamelCase
    
    @param    {String}  word        要转换的字符串
    @param    {Boolean} upperCase   第一个字母是否大写
    @return   {String}
    */

    camelize = function(word, upperCase) {
      if (upperCase == null) {
        upperCase = true;
      }
      word = ("" + word).replace(reCapitalLetter, capitalFn);
      if (!upperCase) {
        word = word.replace(reFirstLetter, lowerCaseFn);
      }
      return word;
    };
    /*
    Convert a copy of string which first letter capitalized
    */

    capitalize = function(word) {
      return word.replace(reFirstLetter, upperCaseFn);
    };
    /*
    Convert a copy of string which first letter lowercased
    */

    lowercase = function(word) {
      return word.replace(reFirstLetter, lowerCaseFn);
    };
    /*
    Try to find a constant with the name specified
    
    @param  {String}  name
    @param  {Object}  scope
    */

    constantize = function(name, scope) {
      var item, _i, _len, _ref;
      if (scope == null) {
        scope = window;
      }
      _ref = name.split('.');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        scope = scope[item];
      }
      return scope;
    };
    /*
    If value in the string
    */

    contains = function(string, sub) {
      return string.indexOf(sub) >= 0;
    };
    /*
    Simple text template
    
    @param  {String}  string
    @param  {Hash}    params
    */

    format = function(string, params) {
      var name, value;
      if (!params) {
        return string;
      }
      for (name in params) {
        value = params[name];
        string = string.replace(new RegExp("\{" + name + "\}", 'gi'), value);
      }
      return string;
    };
    isString = function(string) {
      return !!(string === '' || (string && string.charCodeAt && string.substr));
    };
    /*
    Return plural form of given lowercase singular word (English only). Based on
    ActiveState recipe http://code.activestate.com/recipes/413172/
    */

    ABERRANT_PLURAL_MAP = {
      appendix: 'appendices',
      barracks: 'barracks',
      cactus: 'cacti',
      child: 'children',
      criterion: 'criteria',
      deer: 'deer',
      echo: 'echoes',
      elf: 'elves',
      embargo: 'embargoes',
      focus: 'foci',
      fungus: 'fungi',
      goose: 'geese',
      hero: 'heroes',
      hoof: 'hooves',
      index: 'indices',
      knife: 'knives',
      leaf: 'leaves',
      life: 'lives',
      man: 'men',
      mouse: 'mice',
      nucleus: 'nuclei',
      person: 'people',
      phenomenon: 'phenomena',
      potato: 'potatoes',
      self: 'selves',
      syllabus: 'syllabi',
      tomato: 'tomatoes',
      torpedo: 'torpedoes',
      veto: 'vetoes',
      woman: 'women'
    };
    VOWELS = ['a', 'e', 'i', 'o', 'u'];
    pluralize = function(singular) {
      var len, plural, root, suffix, _ref, _ref1, _ref2;
      if (!singular) {
        return '';
      }
      plural = ABERRANT_PLURAL_MAP[singular];
      if (plural) {
        return plural;
      }
      root = singular;
      len = singular.length;
      try {
        if (singular[len - 1] === 'y' && (_ref = singular[len - 2], __indexOf.call(VOWELS, _ref) < 0)) {
          root = singular.slice(0, len - 1);
          suffix = 'ies';
        } else if (singular[len - 1] === 's') {
          if (_ref1 = singular[len - 2], __indexOf.call(VOWELS, _ref1) >= 0) {
            if (singular.slice(len - 3, len) === 'ius') {
              root = singular.slice(0, len - 2);
              suffix = 'i';
            } else {
              root = singular.slice(0, len - 1);
              suffix = 'ses';
            }
          } else {
            suffix = 'es';
          }
        } else if ((_ref2 = singular.slice(len - 2, len)) === 'ch' || _ref2 === 'sh') {
          suffix = 'es';
        } else {
          suffix = 's';
        }
      } catch (e) {
        suffix = 's';
      }
      plural = root + suffix;
      return plural;
    };
    /*
    Prefix checker
    */

    startsWith = function(string, prefix) {
      return string.lastIndexOf(prefix, 0) === 0;
    };
    /*
    Suffix checker
    */

    endsWith = function(string, suffix) {
      var len;
      len = string.length - suffix.length;
      return len >= 0 && string.indexOf(suffix, len) === len;
    };
    /*
    Remove leading and trailing white spaces from string
    */

    whiteSpaces = ['\\s', '00A0', '1680', '180E', '2000-\\u200A', '200B', '2028', '2029', '202F', '205F', '3000'].join('\\u');
    if (StringProto.trim) {
      trim = function(string) {
        return StringProto.trim.call(string);
      };
    } else {
      reLeading = new RegExp("^[" + whiteSpaces + "]+");
      reTrailing = new RegExp("[" + whiteSpaces + "]+$");
      trim = function(string) {
        return string.replace(reLeading, "").replace(reTrailing, "");
      };
    }
    isWhitespace = function(string) {
      return !trim(string);
    };
    /*
    限定字符串长度
    */

    truncate = function(text, length) {
      if (text && text.length > length) {
        return text.substr(0, length - 3) + "...";
      } else {
        return text;
      }
    };
    reUpper = /([A-Z]+)([A-Z][a-z\d])/g;
    reLower = /([a-z\d])([A-Z])/g;
    reSymbol = /[-_\.]+/g;
    strUnderscore = "$1_$2";
    strSymbol = "_";
    /*
    把类名转换成小写的格式，参考 Rails 同名方法
    
    @param    {String}  word        要转换的字符串
    @param    {String}  symbol      单词之间的连接符
    @return   {String}
    */

    underscore = function(word, symbol) {
      if (symbol == null) {
        symbol = strSymbol;
      }
      return word.replace(reUpper, strUnderscore).replace(reLower, strUnderscore).replace(reSymbol, symbol).toLowerCase();
    };
    strDash = '-';
    dasherize = function(word) {
      return underscore(word, strDash);
    };
    return {
      camelize: camelize,
      capitalize: capitalize,
      constantize: constantize,
      contains: contains,
      format: format,
      isString: isString,
      pluralize: pluralize,
      startsWith: startsWith,
      endsWith: endsWith,
      trim: trim,
      isWhitespace: isWhitespace,
      truncate: truncate,
      underscore: underscore,
      dasherize: dasherize,
      lowercase: lowercase
    };
  });

}).call(this);
