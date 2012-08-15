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
      (@__emitter__ or= $(this))[method].apply(this, arguments)
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
    on:   proxy "on"

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
      (@__emitter__ or= $(this)).off.apply(this, arguments)
      # Release `this.__emitter__` if all event listeners are removed
      delete @__emitter__ if arguments.length == 0
      this

  ###!
  Exports `EventEmitter`
  ###
  EventEmitter: EventEmitter
