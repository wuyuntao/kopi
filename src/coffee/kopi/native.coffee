kopi.module("kopi.native")
  .require("kopi.exceptions")
  .require("kopi.settings")
  .require("kopi.native.android")
  .require("kopi.native.chromium")
  .require("kopi.native.ios")
  .define (exports, exceptions, settings, android, chromium, ios) ->

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

    exports.NativeClientNotSupported = NativeClientNotSupported
    exports.ready = ready
