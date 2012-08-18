###!
# A Node.js-style event emitter implemented via jQuery's Event API.

@author Wu Yuntao <wyt.brandon@gmail.com>
@license MIT

###

define "kopi/events", (require, exports, module) ->

  $ = require "jquery"

  # A help method to make a proxy function for `EventEmitter`
  proxy = (method) ->
    ->
      (@__emitter__ or= $(this))[method] arguments...
      this

  ###

  # EventEmitter

  As an event-driven framework, event emitters are heavily used in Kopi. A `Model`
  emits an event when data is saved. A `View` emits an event when it starts.
  A `Widget` emits an event when a gesture is triggered. All classes which emit
  events inherit from `EventEmitter`.

  `EventEmitter` is implemented as a proxy of a private jQuery object called
  `__emitter__` so that some cutstom event features like namespace and propagation
  can be used in `EventEmitter` too.

  ## Usage

  The easiest way to make a class trigger events is to extends it with `EventEmitter`.

    EventEmitter = require("kopi/events").EventEmitter

    class View extends EventEmitter

    view = new View()

  ## Add event listeners

  Add a listener for the event.

    view.on "update", (e) ->
      console.log "view is updated."

  Add a one-time listener for the event. This listener is invoked at most once per object.

    view.once "create", (e) ->
      console.log "view is created"

  ## Remove event listeners

  Remove a listener from the listener array for the specified event

    callback = (e) ->
      console.log "view is updated"
    view.on "update", callback
    # ...
    view.off "update", callback

  Remove all listeners of specified event

    view.off "create"

  Remove all listeners attached on object

    view.off()

  ## Get listeners

  Get attached listeners of specified event

    view.listeners "update"

  @class
  ###
  class EventEmitter

    ###
    A proxy function for `jQuery.triggerHandler()`

    See more details in jQuery Doc. http://api.jquery.com/triggerHandler/

    @public
    @param {String} eventType
    @param {Array} extraParameters
    @return {EventEmitter}
    ###
    emit: proxy "triggerHandler"

    ###
    A proxy function for `jQuery.on()`

    See more details in jQuery Doc. http://api.jquery.com/on/

    @public
    @param {String} eventType
    @param {Function} eventHandler
    @return {EventEmitter}
    ###
    on:   proxy "bind"

    ###
    A proxy function for `jQuery.one()`.

    See more details in jQuery Doc. http://api.jquery.com/one/

    @public
    @param {String} eventType
    @param {Function} eventHandler
    @return {EventEmitter}
    ###
    once: proxy "one"

    ###
    A proxy function for `jQuery.off()`.

    Additionally, `EventEmitter` will release the internal `__emitter__` object
    if you remove all event listeners by using 'eventEmitter.off()'.

    See more details in jQuery Doc. http://api.jquery.com/off/

    @public
    @param {String} eventType
    @return {EventEmitter}
    ###
    off: ->
      (@__emitter__ or= $(this)).unbind arguments...
      # Release `this.__emitter__` if all event listeners are removed
      delete @__emitter__ if arguments.length == 0
      this

    ###
    Returns an array of listeners for given event.

    @public
    @param {String} eventType
    @return {Array}
    ###
    listeners: (event)->
      return [] unless @__emitter__
      events = @__emitter__.data("events")
      unless events then [] else (events[event] or [])

  ###!
  Exports `EventEmitter`
  ###
  EventEmitter: EventEmitter
