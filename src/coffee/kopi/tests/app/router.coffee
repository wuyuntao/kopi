define "kopi/tests/app/router", (require, exports, module) ->

  q = require "qunit"
  base = require "kopi/tests/base"
  router = require "kopi/app/router"

  class View

  q.module("kopi.app.router")

  q.test "static route", ->
    router.view(View).route('/book/')
    request = router.match('/book/?test=false')
    q.equals(request.route.route, '/book/')
    q.equals(request.url.path, '/book/')
    q.equals(request.url.query, '?test=false')

  q.test "dynamic route", ->
    router.view(View).route('/book/:id/')
    request = router.match('/book/1/?test=true')

    q.equals(request.route.route, '/book/:id/')
    q.equals(request.url.path, '/book/1/')
    q.equals(request.url.query, '?test=true')
    q.equals(request.params['id'], '1')

  q.test "dynamic route with regex only", ->
    router.view(View).route('/note/:#\\d+#/')
    request = router.match('/note/2/?test=false&lang=en')

    q.equals(request.route.route, '/note/:#\\d+#/')
    q.equals(request.url.path, '/note/2/')
    q.equals(request.url.query, '?test=false&lang=en')
    q.equals(request.params[0], '2')

  q.test "dynamic route with name and regex", ->
    router.view(View).route('/comment/:id#\\d+#/')
    request = router.match('/comment/3/?test&lang=en')

    q.equals(request.route.route, '/comment/:id#\\d+#/')
    q.equals(request.url.path, '/comment/3/')
    q.equals(request.url.query, '?test&lang=en')
    q.equals(request.params['id'], '3')
