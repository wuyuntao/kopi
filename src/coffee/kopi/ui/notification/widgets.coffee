kopi.module("kopi.ui.notification.widgets")
  .require("kopi.settings")
  .require("kopi.utils.text")
  .require("kopi.ui.widgets")
  .define (exports, settings, text, widgets) ->

    class Widget extends widgets.Widget

      kls = this

      kls.SHOW = "show"
      kls.HIDE = "hide"
      kls.TRANSPARENT = "transparent"
      kls.NOTIFICATION = "notification"

      kls.configure
        autoSkeleton: true

      actions = [kls.SHOW, kls.HIDE, kls.TRANSPARENT]

      for action in actions
        ((a) =>
          this["#{a}Class"] = ->
            this["_#{a}Class"] or= this.cssClass(a, this.NOTIFICATION)
        )(action)

      # 是否在前台显示
      active: false

      constructor: (element, options) ->
        unless element
          this.constructor.prefix or= text.underscore(this.constructor.name)
          element = settings.kopi.ui.notification[this.constructor.prefix]
        super(element, options)
        this.hidden = true

      # show: ->
      # hidden: ->

    exports.Widget = Widget
