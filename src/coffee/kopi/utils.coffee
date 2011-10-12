kopi.module("kopi.utils")
  .define (exports) ->
    ###
    求和

    @param  {Array}     array     数组
    @param  {Function}  lambda    求和函数
    @return {Object}              求和结果
    ###
    sum = (array, lambda) ->
      s = 0
      for item, i in array
        s += if lambda? then lambda(item, i) else item
      s

    ###
    求平均

    @param  {Array}     array     数组
    @param  {Function}  lambda    求平均函数
    @return {Object}              求平均结果
    ###
    average = (array, lambda) ->
      sum(array, lambda) / array.length

    ###
    Generate an integer Array containing an arithmetic progression. A port of
    [the native Python **range** function]
    (http://docs.python.org/library/functions.html#range).

    @param  {Number}  start        最小值
    @param  {Number}  stop         最大值
    @param  {Number}  step         步阶
    @return {Array}                范围数组
    ###
    range = (start, stop, step) ->
      a = arguments
      solo = a.length <= 1
      i = start = if solo then 0 else a[0]
      stop = if solo then a[0] else a[1]
      step = a[2] or 1
      len = Math.ceil((stop - start) / step)
      return [] if len <= 0
      range = new Array len
      idx = 0
      loop
        return range if (if step > 0 then i - stop else stop - i) >= 0
        range[idx] = i
        idx++
        i+= step

    ###
    用模块查找对象

    @param  {String}  name
    @param  {Object}  scope
    ###
    search = (name, scope=window) ->
      scope = scope[item] for item in name.split '.'
      scope

    ###
    产生唯一 ID

    @param  {String}  prefix  前缀
    ###
    idCounter = 0
    uniqueId = (prefix='') -> prefix + '-' + idCounter++

    ###
    判断对象是否为 Promise 对象

    @param  {Object}  obj
    ###
    isPromise = (obj) ->
      !!(obj.then and obj.done and obj.fail and obj.pipe and
        not obj.reject and not obj.resolve)

    extend = (obj, mixins...) ->
      for mixin in mixins
        for name, method of mixin
          obj[name] = method

    include = (klass, mixins...) ->
      for mixin in mixins
        extend klass.prototype, mixin

    # 把数组转换成循环链表
    # link = (array, circular=true) ->
    #   return array if array.length == 0

    #   len = array.length
    #   first = array[0]
    #   last = array[len - 1]

    #   for node, i in array
    #     node.first = first
    #     node.last = last
    #     node.prev = if i-1 >= 0  then array[i-1] else if circular then last  else null
    #     node.next = if i+1 < len then array[i+1] else if circular then first else null

    $.extend exports,
      sum: sum
      average: average
      range: range
      search: search
      uniqueId: uniqueId
      isPromise: isPromise
      extend: extend
      include: include
      # link: link
