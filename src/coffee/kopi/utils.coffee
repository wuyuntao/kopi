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
    取范围值

    @param  {Number}  value       数值
    @param  {Number}  min         范围的最小值
    @param  {Number}  max         范围的最大值
    @return {Number}              在范围内的数值
    ###
    range = (value, min, max) ->
      Math.max(Math.min(value, max), min)

    ###
    用模块查找对象

    @param  {String}  name
    @param  {Object}  scope
    ###
    search = (name, scope=window) ->
      scope = scope[item] for item in name.split '.'
      scope

    ###
    格式化字符串

    @param  {String}  string      待格式化的字符串
    @param  {Hash}    params      格式化字符串的参数
    ###
    format = (string, params) ->
      return string unless params
      for name, value of params
        string = string.replace(new RegExp("\{#{name}\}", 'gi'), value)
      string

    $.extend exports,
      sum: sum
      average: average
      range: range
      search: search
      format: format
