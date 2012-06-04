define "kopi/utils/date", (require, exports, module) ->

  isDate = (date) -> !!(date and date.getFullYear)

  # ES5 15.9.4.4
  # https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Date/now
  now = Date.now or= -> +new Date()

  ###
  Several helper method to calculate time duration
  ###
  seconds = (count=1) -> count

  minutes = (count=1) -> seconds(60) * count

  hours = (count=1) -> minutes(60) * count

  day = (count=1) -> hours(24) * count

  today = ->
    now = new Date()
    new Date(now.getFullYear(), now.getMonth(), now.getDate())

  dayBefore = (count=1) ->
    new Date(today - days(count))

  dayAfter = (count=1) ->
    new Date(today + days(count))

  yesterday = -> dayBefore(1)

  tomorrow = -> dayAfter(1)

  isDate: isDate
  now: now
  seconds: seconds
  minutes: minutes
  hours: hours
  day: day
  today: today
  dayBefore: dayBefore
  dayAfter: dayAfter
  yesterday: yesterday
  tomorrow: tomorrow
