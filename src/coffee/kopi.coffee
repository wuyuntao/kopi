isFunction = (fn) ->
  !!(fn and fn.constructor and fn.call and fn.apply)

###
Module

TODO 加入子模块和父模块的引用，从而实现递归导入
TODO 如果遇到循环依赖，需要报错
###
class Module

  # @type {RegExp}          模块名称的正则表达式
  reModuleName = /^([\w_]+\.)*[\w_]+$/

  # @type {Hash}            模块名对应的 js 文件地址
  scripts = {
    # 'kopi': '/js/kopi.js'
    # 'kopi.utils': '/js/kopi/utils.js'
    # 'kopi.utils.i18n': '/js/kopi/utils/i18n.js'
    # ...
    # 一个 Minified JS 可以包括所有的 JS
    # 'kopi': '/js/kopi.all.js'
    # 'kopi.utils': '/js/kopi.all.js'
    # 'kopi.utils.i18n': '/js/kopi.all.js'
    # ...
  }

  ###
  加载脚本

  @param  {String}  src         脚本地址
  @param  {Boolean} async       是否为异步加载
  ###
  # loadScript = (src, async=true) ->
  #   throw new Error("Not implemented yet")

  ###
  生成模块对象

  @param  {String}  name        模块名称
  @param  {Boolean} autoCreate  是否自动创建模块
  @param  {Boolean} autoLoad    是否自动加载模块
  @param  {Boolean} moduleOnly  是否只允许加载模块
  @return {Object}              模块
  ###
  this.build = (name, autoCreate=true, autoLoad=false, moduleOnly=true) ->
    module = window
    for item in name.split('.')
      if item of module
        if moduleOnly and not module[item] instanceof this
          throw new Error("#{item} is not a module: #{name}")
        module = module[item]
      else if autoCreate
        module = module[item] = new this(name)
      else if autoLoad
        throw new Error("Module #{item} does not exist: #{name}")
      else
        throw new Error("Module #{item} does not exist: #{name}")
    module

  ###
  @param  {String}  name    模块名称
  ###
  constructor: (name) ->
    throw new Error("#{name} is not a valid module name") unless reModuleName.test(name)
    # @type   {String}      模块名称
    this.name = name
    # @type {Array}         依赖关系
    this.requires = []
    # @type {Hash}          模块方法
    this.exports = {}

  ###
  TODO 对于没有模块的脚本，可以直接 load
  ###
  # load: (script) ->
  #   this

  ###
  声明引入的模块

  TODO 动态加载依赖对象的脚本？
  TODO Accept multiple names as arguments

  @param  {String}  name        需要引入的模块名称
  @param  {Boolean} assignment  该模块是否需要被赋值
  @param  {Boolean} chain
  @return {Module}              模块对象
  ###
  require: (name, assignment=true, chain=true) ->
    throw new Error("#{name} is not a valid module name") unless reModuleName.test(name)
    require = this.constructor.build(name, false)
    this.requires.push(require) if assignment
    if chain then this else require.exports

  ###
  模块定义

  @param  {Function}  fn     模块定义的回调方法
  @return {null}
  ###
  define: (fn) ->
    self = this
    delete self.require
    delete self.define
    if isFunction(fn)
      requireFn = (name) -> self.require(name, false, false)
      fn(self.exports, self.requires..., requireFn)
    else
      # Extend module
      for name of fn
        self.exports[name] = fn[name]
    return

###
声明模块

@param  {String}  name    模块名称
@return {Module}          模块
###
module = (name) -> Module.build(name)

###
Define module `kopi`
###
module("kopi").define module: module

###
Provide an AMD-compatible define() method for external modules

@param {String} name            The module name.
@param {Array<string>} requires The module dependencies.
@param {Function} factory       The module factory function.
###
define = (name, requires, fn) ->
  argsLen = arguments.length

  if argsLen < 2
    throw new Error("ArgumentError: define() requires at least 2 arguments")

  # define(name, fn)
  else if argsLen == 2
    fn = requires
    requires = undefined

  mod = module(name)
  if requires
    for require in requires
      mod.require(require)
  if fn
    mod.define(fn)
  mod

window.define = define
