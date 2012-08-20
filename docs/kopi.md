# Module Manager

A lightweight [AMD](https://github.com/amdjs/amdjs-api/wiki/AMD) manager.

It provides the minimal AMD API without any dynamic code loading.

## Why

Kopi uses AMD API to write modular JavaScript. So it works perfectly
with full-featured AMD loaders, like [RequireJS](http://requirejs.org)
or [curl.js](https://github.com/unscriptable/curl).

However, in some cases which are sensitive to file sizes and requests,
we prefer to combine and minify all JavaScript files into one file.

By including A minimal AMD manager, A full-featured AMD loader is not
necessary. And it is only *475 bytes* after minified and gzipped.

## Limitations

Since module manager is optimized for single-file javascript, there are
two limitations of module id format.

1. Anomynous module is not supported.
2. Relative ids are not supported either in `define()` or `require()`.
3. Module ids should not include file-name extesions like ".js".


## Define a module.

`define()` function is available as a global variable.

```coffeescript
define(id, dep?, factory?)
```

Either AMD-style or CommonJS-style dependencies are supported.

```coffeescript
define "alpha", ["beta"], (require, exports, module, beta) ->

gamma = require "gamma"

exports.hello = ->
  beta.hello()
  gamma.hello()

```

An module can return an object as its exports

```coffeescript
define "alpha", (require, exports, module) ->

say: -> console.log "say"
hello: -> console.log "hello"

```

Or define module with an object directly

```coffeescript
define "alpha",
say: -> console.log "say"
hello: -> console.log "hello"

``


## Imports a module.

`require()` function is alse available as a global variable

```coffeescript
require(id)
```


