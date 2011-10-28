kopi.module("kopi.ui.notification.widgets")
  .require("kopi.settings")
  .require("kopi.utils.text")
  .require("kopi.ui.widgets")
  .define (exports, settings, text, widgets) ->

    class Widget extends widgets.Widget

      cls = this

      cls.SHOW = "show"
      cls.HIDE = "hide"
      cls.TRANSPARENT = "transparent"
      cls.NOTIFICATION = "notification"

      this.defaults
        autoSkeleton: true

      actions = [SHOW, HIDE, TRANSPARENT]

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

    exports.Widget = Widget
