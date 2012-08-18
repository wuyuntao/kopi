###!
# Common utilities

@author Wu Yuntao <wyt.brandon@gmail.com>
@license MIT

###

define "kopi/utils", (require, exports, module) ->

  $ = require "jquery"

  ###
  Generate unique ID

  @param  {String}  prefix
  @return {String}
  ###
  counter = 0
  guid = (prefix='kopi') -> prefix + '-' + counter++

  ###
  Is the given value a promise object?

  @param  {Object}  obj
  @return {Boolean}
  ###
  isPromise = (obj) ->
    !!(obj.then and obj.done and obj.fail and obj.pipe and
      not obj.reject and not obj.resolve)

  ###
  A helper method to convert a sync method response to promise

  @param  {Object}  obj
  @return {Promise}
  ###
  forcePromise = (obj) ->
    return obj if isPromise(obj)

    deferred = new $.Deferred()
    if obj is false then deferred.reject() else deferred.resolve()
    deferred.promise()

  ###
  Is the given value a regular expression?

  @param {RegExp} obj
  @return {Boolean}
  ###
  isRegExp    = (obj) -> !!(obj and obj.exec and (obj.ignoreCase or obj.ignoreCase is false))

  ###!
  Exports
  ###
  guid: guid
  isPromise: isPromise
  isRegExp: isRegExp
