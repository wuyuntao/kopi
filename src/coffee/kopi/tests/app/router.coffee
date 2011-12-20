kopi.module("kopi.tests.app.router")
  .require("kopi.tests.base")
  .require("kopi.app.router")
  .define (exports, base, router) ->

    class View

    module("kopi.app.router")

    test "static route", ->
      router.view(View).route('/book/')
      request = router.match('/book/?test=false')
      equals(request.route.route, '/book/')
      equals(request.url.path, '/book/')
      equals(request.url.query, '?test=false')

    test "dynamic route", ->
      router.view(View).route('/book/:id/')
      request = router.match('/book/1/?test=true')

      equals(request.route.route, '/book/:id/')
      equals(request.url.path, '/book/1/')
      equals(request.url.query, '?test=true')
      equals(request.params['id'], '1')

    test "dynamic route with regex only", ->
      router.view(View).route('/note/:#\\d+#/')
      request = router.match('/note/2/?test=false&lang=en')

      equals(request.route.route, '/note/:#\\d+#/')
      equals(request.url.path, '/note/2/')
      equals(request.url.query, '?test=false&lang=en')
      equals(request.params[0], '2')

    test "dynamic route with name and regex", ->
      router.view(View).route('/comment/:id#\\d+#/')
      request = router.match('/comment/3/?test&lang=en')

      equals(request.route.route, '/comment/:id#\\d+#/')
      equals(request.url.path, '/comment/3/')
      equals(request.url.query, '?test&lang=en')
      equals(request.params['id'], '3')
