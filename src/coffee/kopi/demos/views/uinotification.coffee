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
      this.nav = new navigation.Nav
        title: "Buttons"
        leftButton: backButton
      this.view = new viewswitchers.View
        template: templates.notification

      this.indicatorButton = new Button
        titleText: "Show indicator"
        size: "large"
      this.indicatorButton.on Button.CLICK_EVENT, ->
        notification.indicator().show()
        setTimeout (-> notification.indicator().hide()), 3000

      this.bubbleButton = new Button
        titleText: "Show bubble"
        size: "large"
      this.bubbleButton.on Button.CLICK_EVENT, ->
        notification.bubble().show "This is a bubble",
          lock: true,
          duration: 10000

      this.dialogButton = new Button
        titleText: "Show dialog"
        size: "large"
      this.dialogButton.on Button.CLICK_EVENT, ->
        notification.dialog()
          .title("This is a dialog")
          .content("Say something...")
          .show(lock: true)

    oncreate: ->
      this.app.navBar.add(this.nav)
      this.nav.skeleton()
      this.app.viewSwitcher.add(this.view)
      this.view.skeleton()
      this.indicatorButton.skeletonTo($(".indicator-section", this.view.element))
      this.bubbleButton.skeletonTo($(".bubble-section", this.view.element))
      this.dialogButton.skeletonTo($(".dialog-section", this.view.element))
      super

    onstart: ->
      this.app.navBar.show(this.nav)
      this.app.viewSwitcher.show(this.view)
      this.nav.render()
      this.view.render()
      this.indicatorButton.render()
      this.bubbleButton.render()
      this.dialogButton.render()
      super

    ondestroy: ->
      this.indicatorButton.destroy()
      this.bubbleButton.destroy()
      this.dialogButton.destroy()
      this.nav.destroy()
      this.view.destroy()
      super

  UINotificationView: UINotificationView
