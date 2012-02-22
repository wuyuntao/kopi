define "kopi/utils", (require, exports, module) ->

  $ = require "jquery"

  ###
  产生唯一 ID

  @param  {String}  prefix  前缀
  ###
  counter = 0
  guid = (prefix='kopi') -> prefix + '-' + counter++

  ###
  判断对象是否为 Promise 对象

  @param  {Object}  obj
  ###
  isPromise = (obj) ->
    !!(obj.then and obj.done and obj.fail and obj.pipe and
      not obj.reject and not obj.resolve)

  ###
  A helper method to convert a sync method response to promise
  ###
  forcePromise = (obj) ->
    return obj if isPromise(obj)

    deferred = new $.Deferred()
    if obj is false then deferred.reject() else deferred.resolve()
    deferred.promise()

  # Is the given value a regular expression?
  isRegExp    = (obj) -> !!(obj and obj.exec and (obj.ignoreCase or obj.ignoreCase is false))

  guid: guid
  isPromise: isPromise
  isRegExp: isRegExp
