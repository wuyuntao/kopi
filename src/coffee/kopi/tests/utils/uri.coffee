kopi.module("kopi.tests.utils.uri")
  .require("kopi.tests.base")
  .require("kopi.utils.uri")
  .define (exports, base, uri) ->

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
        equal uri.join('/foo/bar', '../search'), 'search'

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

      test "unjoin absolute urls", ->
        equal uri.unjoin("http://www.google.com/foo/bar", "http://www.google.com/search"), "../search"
        equal uri.unjoin("http://www.google.com/foo/bar", "http://www.google.com/search/path"), "../search/path"

      test "unjoin relative urls", ->
        equal uri.unjoin("foo/bar", "foo/search"), "search"

      test "unjoin scheme", ->
        equal uri.unjoin("http://www.google.com/foo/bar", "ftp://www.google.com/search"),
          "ftp://www.google.com/search"

      test "unjoin domain", ->
        equal uri.unjoin("http://www.google.com/foo/bar", "http://www.bing.com/search"),
          "http://www.bing.com/search"
        equal uri.unjoin("http://www.google.com:80/foo/", "http://www.google.com/bar"),
          "http://www.google.com/bar"

      test "unjoin dirname", ->
        equal uri.unjoin("http://www.google.com/foo", "http://www.google.com/bar"), "bar"
        equal uri.unjoin("http://www.google.com/foo/", "http://www.google.com/bar"), "../bar"
        equal uri.unjoin("http://www.google.com/foo", "http://www.google.com/foo"), "foo"
        equal uri.unjoin("http://www.google.com/foo/", "http://www.google.com/foo"), "../foo"
        equal uri.unjoin("http://www.google.com/foo", "http://www.google.com/bar/search"), "bar/search"
        equal uri.unjoin("http://www.google.com/foo/", "http://www.google.com/bar/search"), "../bar/search"
        equal uri.unjoin("http://www.google.com/foo/bar", "http://www.google.com/search/path"), "../search/path"
        equal uri.unjoin("http://www.google.com/foo/bar/", "http://www.google.com/search/path"),
          "../../search/path"
        equal uri.unjoin("http://www.google.com/foo", "http://www.google.com/bar"), "bar"

      test "unjoin query", ->
        equal uri.unjoin("http://www.google.com/foo;para?query#frag", "http://www.google.com/foo"), "foo"
        equal uri.unjoin("http://localhost/tests/kopi?notrycatch=true", "http://localhost/alpha/1"), "../alpha/1"

      test "unjoin fragment", ->
        equal uri.unjoin("http://www.google.com/foo", "http://www.google.com/foo;para?query#frag"),
          "foo;para?query#frag"
