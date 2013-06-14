(function() {
  define("kopi/tests/utils/uri", function(require, exports, module) {
    var q, uri;

    q = require("qunit");
    uri = require("kopi/utils/uri");
    q.module("kopi/utils/uri");
    q.test("parse url ", function() {
      var url;

      url = uri.parse('http://www.google.com:80/path?q=query#fragmento');
      q.equals(url.scheme, 'http:');
      q.equals(url.username, '');
      q.equals(url.password, '');
      q.equals(url.port, 80);
      q.equals(url.path, '/path');
      q.equals(url.query, '?q=query');
      return q.equals(url.fragment, '#fragmento');
    });
    q.test("unparse url", function() {
      var url;

      url = {
        scheme: "http:",
        authority: "www.google.com:80",
        path: "/path",
        query: "?q=query",
        fragment: "#fragmento"
      };
      return q.equals(uri.unparse(url), 'http://www.google.com:80/path?q=query#fragmento');
    });
    q.test("join absolute path", function() {
      var base;

      base = 'http://www.google.com:8080/path?q=query#fragmento';
      q.equals(uri.join(base, '/foo'), "http://www.google.com:8080/foo");
      return q.equals(uri.join(base, '/foo/bar'), 'http://www.google.com:8080/foo/bar');
    });
    q.test("join relative path", function() {
      var url;

      url = 'http://www.google.com:8080/path?q=query#fragmento';
      q.equals(uri.join(url, 'foo'), 'http://www.google.com:8080/foo');
      url = 'http://www.google.com:8080/search';
      q.equals(uri.join(url, 'foo/bar'), 'http://www.google.com:8080/foo/bar');
      url = 'http://www.google.com:8080/search/';
      q.equals(uri.join(url, 'foo/bar'), 'http://www.google.com:8080/search/foo/bar');
      q.equals(uri.join('foo', 'bar'), 'bar');
      return q.equals(uri.join('/foo/bar', '../search'), '/search');
    });
    q.test("join domain", function() {
      q.equals(uri.join('https://www.fark.com:443/search/', '//www.google.com/foo/bar'), 'https://www.google.com/foo/bar');
      return q.equals(uri.join('http://www.fark.com/search/', '//www.google.com/'), 'http://www.google.com/');
    });
    q.test("join query", function() {
      q.equals(uri.join('http://www.google.com/search?q=old+search', '?q=new%20search'), 'http://www.google.com/search?q=new%20search');
      return q.equals(uri.join('http://www.google.com/search?q=old+search#hi', '?q=new%20search'), 'http://www.google.com/search?q=new%20search');
    });
    q.test("join fragment", function() {
      q.equals(uri.join('http://www.google.com/foo/bar?q=hi', '#there'), 'http://www.google.com/foo/bar?q=hi#there');
      return q.equals(uri.join('http://www.google.com/foo/bar?q=hi#you', '#there'), 'http://www.google.com/foo/bar?q=hi#there');
    });
    q.test("make absolute url", function() {
      return q.equals(uri.absolute("/test"), "" + (uri.base().domain) + "/test");
    });
    q.test("unjoin absolute urls", function() {
      q.equals(uri.unjoin("http://www.google.com/foo/bar", "http://www.google.com/search"), "../search");
      return q.equals(uri.unjoin("http://www.google.com/foo/bar", "http://www.google.com/search/path"), "../search/path");
    });
    q.test("unjoin relative urls", function() {
      q.equals(uri.unjoin("foo/bar", "foo/search"), "search");
      return q.equals(uri.unjoin('/view/', '/view/atom/1/'), 'atom/1/');
    });
    q.test("unjoin scheme", function() {
      return q.equals(uri.unjoin("http://www.google.com/foo/bar", "ftp://www.google.com/search"), "ftp://www.google.com/search");
    });
    q.test("unjoin domain", function() {
      q.equals(uri.unjoin("http://www.google.com/foo/bar", "http://www.bing.com/search"), "http://www.bing.com/search");
      return q.equals(uri.unjoin("http://www.google.com:80/foo/", "http://www.google.com/bar"), "http://www.google.com/bar");
    });
    q.test("unjoin dirname", function() {
      q.equals(uri.unjoin("http://www.google.com/foo", "http://www.google.com/bar"), "bar");
      q.equals(uri.unjoin("http://www.google.com/foo/", "http://www.google.com/bar"), "../bar");
      q.equals(uri.unjoin("http://www.google.com/foo", "http://www.google.com/foo"), "foo");
      q.equals(uri.unjoin("http://www.google.com/foo/", "http://www.google.com/foo"), "../foo");
      q.equals(uri.unjoin("http://www.google.com/foo", "http://www.google.com/bar/search"), "bar/search");
      q.equals(uri.unjoin("http://www.google.com/foo/", "http://www.google.com/bar/search"), "../bar/search");
      q.equals(uri.unjoin("http://www.google.com/foo/bar", "http://www.google.com/search/path"), "../search/path");
      q.equals(uri.unjoin("http://www.google.com/foo/bar/", "http://www.google.com/search/path"), "../../search/path");
      return q.equals(uri.unjoin("http://www.google.com/foo", "http://www.google.com/bar"), "bar");
    });
    q.test("unjoin query", function() {
      q.equals(uri.unjoin("http://www.google.com/foo;para?query#frag", "http://www.google.com/foo"), "foo");
      return q.equals(uri.unjoin("http://localhost/tests/kopi?notrycatch=true", "http://localhost/alpha/1"), "../alpha/1");
    });
    return q.test("unjoin fragment", function() {
      return q.equals(uri.unjoin("http://www.google.com/foo", "http://www.google.com/foo;para?query#frag"), "foo;para?query#frag");
    });
  });

}).call(this);
