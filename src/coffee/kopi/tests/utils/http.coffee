define "kopi/tests/utils/http", (require, exports, module) ->

  q = require "qunit"
  http = require "kopi/utils/http"

  q.module "kopi.utils.http"

  urls = [
    "/images/icon1.png"
    "/images/icon2.png"
    "/images/icon3.png"
    "/images/icon4.png"
    "/images/icon5.png"
  ]

  # TODO Need better tests
  q.test "queued requests", ->
    http.queue.configure
      concurrency: 1
    http.queue.on http.RequestQueue.EMPTY_EVENT, (e) ->
      q.equal 1, 1
      q.start()

    q.stop()

    for url, i in urls
      req = http.request
        url: url
        queue: true
    http.queue.abort(req)
