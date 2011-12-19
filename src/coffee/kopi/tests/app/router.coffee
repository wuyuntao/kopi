kopi.module("kopi.tests.app.router")
  .require("kopi.tests.base")
  .require("kopi.app.router")
  .define (exports, base, router) ->

    class View

    module("Route")

    test "static route", ->
      router.view(View).route('/book/')
      result = router.match('/book/?test=false')
      equals(result.route.route, '/book/')
      equals(result.args[0].path, '/book/')
      equals(result.args[0].query, '?test=false')

    test "dynamic route", ->
      router.view(View).route('/book/:id/')
      result = router.match('/book/1/?test=true')

      equals(result.route.route, '/book/:id/')
      equals(result.args[0].path, '/book/1/')
      equals(result.args[0].query, '?test=true')
      equals(result.args[1], '1')

    test "regex", ->
      router.view(View).route('/note/:#\\d+#/')
      result = router.match('/note/2/?test=false&lang=en')

      equals(result.route.route, '/note/:#\\d+#/')
      equals(result.args[0].path, '/note/2/')
      equals(result.args[0].query, '?test=false&lang=en')
      equals(result.args[1], '2')

    test "dynamic with regex", ->
      router.view(View).route('/comment/:id#\\d+#/')
      result = router.match('/comment/3/?test&lang=en')

      equals(result.route.route, '/comment/:id#\\d+#/')
      equals(result.args[0].path, '/comment/3/')
      equals(result.args[0].query, '?test&lang=en')
      equals(result.args[1], '3')
