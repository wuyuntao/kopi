kopi.module("kopi.tests.utils.uri")
  .require("kopi.utils.uri")
  .define (exports, uri) ->

    $ ->

      module "kopi.utils.uri"

      test "parse url ", ->
        url = uri.parse 'http://www.google.com:80/path?q=query#fragmento'
        equal url.scheme, 'http:'
        equal url.username, ''
        equal url.password, ''
        equal url.port, 80
        equal url.path, '/path'
        equal url.query, '?q=query'
        equal url.fragment, '#fragmento'

      test "unparse url", ->
        url =
          scheme: "http:"
          authority: "www.google.com:80"
          path: "/path"
          query: "?q=query"
          fragment: "#fragmento"
        equal uri.unparse(url), 'http://www.google.com:80/path?q=query#fragmento'

      test "join absolute path", ->
        base = 'http://www.google.com:8080/path?q=query#fragmento'
        equal uri.join(base, '/foo'), "http://www.google.com:8080/foo"
        equal uri.join(base, '/foo/bar'), 'http://www.google.com:8080/foo/bar'

      test "join relative path", ->
        url = 'http://www.google.com:8080/path?q=query#fragmento'
        equal uri.join(url, 'foo'), 'http://www.google.com:8080/foo'

        url = 'http://www.google.com:8080/search'
        equal uri.join(url, 'foo/bar'), 'http://www.google.com:8080/foo/bar'

        url = 'http://www.google.com:8080/search/'
        equal uri.join(url, 'foo/bar'), 'http://www.google.com:8080/search/foo/bar'

        equal uri.join('foo', 'bar'), 'bar'

      test "join domain", ->
        equal uri.join('https://www.fark.com:443/search/', '//www.google.com/foo/bar'),
          'https://www.google.com/foo/bar'

        equal uri.join('http://www.fark.com/search/', '//www.google.com/'),
          'http://www.google.com/'

      test "join query", ->
        equal uri.join('http://www.google.com/search?q=old+search', '?q=new%20search'),
          'http://www.google.com/search?q=new%20search'

        equal uri.join('http://www.google.com/search?q=old+search#hi', '?q=new%20search'),
          'http://www.google.com/search?q=new%20search'

      test "join fragment", ->
        equal uri.join('http://www.google.com/foo/bar?q=hi', '#there'),
         'http://www.google.com/foo/bar?q=hi#there'

        equal uri.join('http://www.google.com/foo/bar?q=hi#you', '#there'),
          'http://www.google.com/foo/bar?q=hi#there'

      test "make absolute url", ->
        equal uri.absolute("/test"), "#{uri.base().domain}/test"