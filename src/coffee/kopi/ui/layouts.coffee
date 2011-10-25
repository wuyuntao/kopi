kopi.module("kopi.ui.layouts")
  .require("kopi.exceptions")
  .require("kopi.settings")
  .require("kopi.ui.panels")
  .require("kopi.ui.navigation")
  .define (exports, exceptions, settings, panels, navigation) ->

    class Layout

      constructor: (panels={}) ->
        this.panels = panels

      add: (name, panel) ->
        unless panel instanceof panels.Panel
          throw new exceptions.ValueError("Only panel can be added to layout")
        this.panels[name] = panel
        this

      remove: (name) ->
        this.panels[name] = undefined
        this

    # A factory method to create layout
    layout = (panels=[]) -> new Layout(panels)

    # Default layout with a top navbar and content panel
    defaultLayout = ->
      new Layout
        navbar: new navigation.Navbar(settings.kopi.ui.layout.navbar)
        panel: new panels.Panel(settings.kopi.ui.layout.panel)

    exports.Layout = Layout
    exports.layout = layout
    exports.default = defaultLayout
