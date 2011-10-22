###
这个模块提供 jQuery 插件格式的 Shortcuts

###
kopi.module("kopi.utils.jquery")
  .require("kopi.utils.html")
  .define (exports, html) ->

    $.fn.itemprop = ->
      return undefined unless this.length
      html.prop(this)

    $.fn.itemscope = ->
      return {} unless this.length
      html.scope(this)

    $.fn.replaceClass = (regexp, replacement) ->
      return this unless this.length
      html.replaceClass(this, regexp, replacement)

    ###
    把 Widget 类转换成 jQuery Plugin，参考 jQuery UI 的 $.widget.bridge 方法

    ###
    bridge = (widget) ->
