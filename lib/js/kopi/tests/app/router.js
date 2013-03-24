(function() {

  define("kopi/tests/app/router", function(require, exports, module) {
    var View, q, router;
    q = require("qunit");
    router = require("kopi/app/router");
    View = (function() {

      function View() {}

      return View;

    })();
    q.module("kopi.app.router");
    q.test("static route", function() {
      var request;
      router.view(View).route('/book/');
      request = router.match('/book/?test=false');
      q.equal(request.route.route, '/book/');
      q.equal(request.url.path, '/book/');
      return q.equal(request.url.query, '?test=false');
    });
    q.test("dynamic route", function() {
      var request;
      router.view(View).route('/book/:id/');
      request = router.match('/book/1/?test=true');
      q.equal(request.route.route, '/book/:id/');
      q.equal(request.url.path, '/book/1/');
      q.equal(request.url.query, '?test=true');
      return q.equal(request.params['id'], '1');
    });
    q.test("dynamic route with regex only", function() {
      var request;
      router.view(View).route('/note/:#\\d+#/');
      request = router.match('/note/2/?test=false&lang=en');
      q.equal(request.route.route, '/note/:#\\d+#/');
      q.equal(request.url.path, '/note/2/');
      q.equal(request.url.query, '?test=false&lang=en');
      return q.equal(request.params[0], '2');
    });
    return q.test("dynamic route with name and regex", function() {
      var request;
      router.view(View).route('/comment/:id#\\d+#/');
      request = router.match('/comment/3/?test&lang=en');
      q.equal(request.route.route, '/comment/:id#\\d+#/');
      q.equal(request.url.path, '/comment/3/');
      q.equal(request.url.query, '?test&lang=en');
      return q.equal(request.params['id'], '3');
    });
  });

}).call(this);
