kopi.module("kopi.utils.date")
  .require("kopi.utils.object")
  .define (exports, object) ->

    isDate = (date) -> !!(date and date.getFullYear)

    exports.isDate = isDate
