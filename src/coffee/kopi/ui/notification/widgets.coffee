define "kopi/ui/notification/widgets", (require, exports, module) ->

  settings = require "kopi/settings"
  text = require "kopi/utils/text"
  widgets = require "kopi/ui/widgets"

  ###
  Base class for notification widgets
  ###
  class Widget extends widgets.Widget

    kls = this

    kls.SHOW = "show"
    kls.HIDE = "hide"
    kls.TRANSPARENT = "transparent"
    kls.NOTIFICATION = "notification"

    kls.configure
      autoSkeleton: true

    actions = [kls.SHOW, kls.HIDE, kls.TRANSPARENT]

    defineMethod = (action) ->
      kls["#{action}Class"] = ->
        this["_#{action}Class"] or= this.cssClass(action, this.NOTIFICATION)

    for action in actions
      defineMethod(action)

    constructor: (options) ->
      super(options)

      this._options.element or= settings.kopi.ui.notification[this.constructor.prefix]
      this.hidden = true

    # show: ->
    # hidden: ->

  Widget: Widget
