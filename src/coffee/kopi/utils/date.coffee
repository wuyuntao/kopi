kopi.module("kopi.utils.date")
  .define (exports) ->

    isDate = (date) -> !!(date and date.getFullYear)

    # ES5 15.9.4.4
    # https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Date/now
    now = Date.now or= -> +new Date()

    exports.isDate = isDate
    exports.now = now
