define "kopi/utils/date", (require, exports, module) ->

  isDate = (date) -> !!(date and date.getFullYear)

  # ES5 15.9.4.4
  # https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Date/now
  now = Date.now or= -> +new Date()

  isDate: isDate
  now: now
