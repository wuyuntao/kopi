define "kopi/clients", (require, exports, module) ->

  exceptions = require "kopi/exceptions"
  settings = require "kopi/settings"
  android = require "kopi/clients/android"
  chromium = require "kopi/clients/chromium"
  ios = require "kopi/clients/ios"

  class NativeClientNotSupported extends exceptions.Exception

  ###
  When some clients client is ready
  ###
  ready = (fn) ->
    return unless fn
    # Get enabled clients clients
    for platform, support of settings.kopi.clients
      if support
        module = eval(platform)
        throw new NativeClientNotSupported(platform) if not module
        module.ready fn
    return

  NativeClientNotSupported: NativeClientNotSupported
  ready: ready
