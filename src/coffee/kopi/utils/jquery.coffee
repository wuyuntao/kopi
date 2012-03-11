define "kopi/utils/jquery", (require, exports, module) ->

  $ = require "jquery"
  html = require "kopi/utils/html"

  doc = document

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

  $.fn.tag = ->
    if this.length then this[0].tagName else null

  ###
  Convert widget class to a jQUery-UI-style plugin

  ###
  bridge = (widget) ->
