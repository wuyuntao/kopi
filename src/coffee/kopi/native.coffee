define "kopi/native", (require, exports, module) ->

  exceptions = require "kopi/exceptions"
  settings = require "kopi/settings"
  android = require "kopi/native/android"
  chromium = require "kopi/native/chromium"
  ios = require "kopi/native/ios"

  class NativeClientNotSupported extends exceptions.Exception

  ###
  When some native client is ready
  ###
  ready = (fn) ->
    return unless fn
    # Get enabled native clients
    for platform, support of settings.native
      if support
        module = kopi.native[platform]
        throw new NativeClientNotSupported(platform) if not module
        module.ready fn
    return

  NativeClientNotSupported: NativeClientNotSupported
  ready: ready
