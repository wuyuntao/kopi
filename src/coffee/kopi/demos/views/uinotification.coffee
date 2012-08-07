define "kopi/demos/views/uinotification", (require, exports, module) ->

  View = require("kopi/views").View
  navigation = require("kopi/ui/navigation")
  viewswitchers = require "kopi/ui/viewswitchers"
  reverse = require("kopi/app/router").reverse
  templates = require("kopi/demos/templates/uinotification")
  Button = require("kopi/ui/buttons").Button
  notification = require("kopi/ui/notification")

  class UINotificationView extends View

    constructor: ->
      super
      backButton = new navigation.NavButton
        url: reverse("ui")
        titleText: "Back"
      @nav = new navigation.Nav
        title: "Notification"
        leftButton: backButton
      @view = new viewswitchers.View
        template: templates.notification

      @indicatorButton = new Button
        titleText: "Show indicator"
      @indicatorButton.on Button.CLICK_EVENT, ->
        notification.indicator().show()
        setTimeout (-> notification.indicator().hide()), 3000

      @bubbleButton = new Button
        titleText: "Show bubble"
      @bubbleButton.on Button.CLICK_EVENT, ->
        notification.bubble().show "This is a bubble",
          lock: true,
          duration: 3000

      @dialogButton = new Button
        titleText: "Show dialog"
      @dialogButton.on Button.CLICK_EVENT, ->
        notification.dialog()
          .title("This is a dialog")
          .content("Say something...")
          .show(lock: true)

    oncreate: ->
      @app.navbar.add(@nav)
      @nav.skeleton()
      @app.viewSwitcher.add(@view)
      @view.skeleton()
      @indicatorButton.skeletonTo($(".indicator-section", @view.element))
      @bubbleButton.skeletonTo($(".bubble-section", @view.element))
      @dialogButton.skeletonTo($(".dialog-section", @view.element))
      super

    onstart: ->
      @app.navbar.show(@nav)
      @app.viewSwitcher.show(@view)
      @nav.render()
      @view.render()
      @indicatorButton.render()
      @bubbleButton.render()
      @dialogButton.render()
      super

    ondestroy: ->
      @indicatorButton.destroy()
      @bubbleButton.destroy()
      @dialogButton.destroy()
      @nav.destroy()
      @view.destroy()
      super

  UINotificationView: UINotificationView
