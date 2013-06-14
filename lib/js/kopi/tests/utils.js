(function() {
  define("kopi/tests/utils", function(require, exports, module) {
    var q, utils;

    q = require("qunit");
    utils = require("kopi/utils");
    q.module("kopi/utils");
    q.test("guid", function() {
      q.equal(utils.guid(), "kopi-0");
      return q.equal(utils.guid("prefix"), "prefix-1");
    });
    return q.test("is regexp", function() {
      return q.equal(utils.isRegExp(/^reg/), true);
    });
  });

}).call(this);
