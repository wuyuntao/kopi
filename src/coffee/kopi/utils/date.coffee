kopi.module("kopi.utils.date")
  .define (exports) ->

    isDate = (date) -> !!(date and date.getFullYear)

    exports.isDate = isDate
