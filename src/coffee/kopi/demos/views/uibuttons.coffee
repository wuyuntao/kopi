define "kopi/demos/views/uibuttons", (require, exports, module) ->

  View = require("kopi/views").View
  navigation = require("kopi/ui/navigation")
  viewswitchers = require "kopi/ui/viewswitchers"
  reverse = require("kopi/app/router").reverse
  templates = require("kopi/demos/templates/uibuttons")
  Button = require("kopi/ui/buttons").Button
  Group = require("kopi/ui/groups").Group
  capitalize = require("kopi/utils/text").capitalize

  class UIButtonView extends View

    styles: ["default", "primary", "info", "success", "warning", "danger", "inverse"]

    sizes: ["large", "normal", "small", "mini"]

    constructor: ->
      super
      backButton = new navigation.NavButton
        url: reverse("ui")
        titleText: "Back"
      @nav = new navigation.Nav
        title: "Buttons"
        leftButton: backButton
      @view = new viewswitchers.View
        template: templates.buttons

      @styleGroup = new Group()
      for style in @styles
        button = new Button
          titleText: capitalize(style)
          style: style
        @styleGroup.add(button)

      @sizeGroup = new Group()
      for size in @sizes
        button = new Button
          titleText: capitalize(size)
          size: size
        @sizeGroup.add(button)

    oncreate: ->
      @app.navbar.add(@nav)
      @nav.skeleton()
      @app.viewSwitcher.add(@view)
      @view.skeleton()
      @styleGroup.skeletonTo($(".button-style-section", @view.element))
      @sizeGroup.skeletonTo($(".button-size-section", @view.element))
      super

    onstart: ->
      @app.navbar.show(@nav)
      @app.viewSwitcher.show(@view)
      @nav.render()
      @view.render()
      @styleGroup.render()
      @sizeGroup.render()
      super

    ondestroy: ->
      @styleSection.destroy()
      @sizeGroup.destroy()
      @nav.destroy()
      @view.destroy()
      super

  UIButtonView: UIButtonView
