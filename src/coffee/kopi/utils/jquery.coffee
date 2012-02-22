define "kopi/utils/jquery", (require, exports, module) ->

  $ = require "jquery"
  html = require "kopi/utils/html"

  $.fn.itemprop = ->
    return undefined unless this.length
    html.prop(this)

  $.fn.itemscope = ->
    return {} unless this.length
    html.scope(this)

  $.fn.replaceClass = (regexp, replacement) ->
    return this unless this.length
    html.replaceClass(this, regexp, replacement)
    this

  ###
  把 Widget 类转换成 jQuery Plugin，参考 jQuery UI 的 $.widget.bridge 方法

  ###
  bridge = (widget) ->
