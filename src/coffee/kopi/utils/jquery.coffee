###
这个模块只提供 jQuery 插件格式的 Shortcuts

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
