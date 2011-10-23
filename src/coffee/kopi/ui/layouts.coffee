kopi.module("kopi.ui.layouts")
  .require("kopi.exceptions")
  .require("kopi.settings")
  .require("kopi.ui.containers")
  .require("kopi.ui.navigation")
  .define (exports, exceptions, settings, containers, navigation) ->

    class Layout

      constructor: (containers={}) ->
        this.containers = containers

      add: (name, container) ->
        unless container instanceof containers.Container
          throw new exceptions.ValueError("Only container can be added to layout")
        this.containers[name] = container
        this

      remove: (name) ->
        this.containers[name] = undefined
        this

    # A factory method to create layout
    layout = (containers=[]) -> new Layout(containers)

    # Default layout with a top navbar and content container
    defaultLayout = ->
      new Layout
        navbar: new navigation.Navbar(settings.kopi.ui.layout.navbar)
        container: new containers.Container(settings.kopi.ui.layout.container)

    exports.Layout = Layout
    exports.layout = layout
    exports.default = defaultLayout
