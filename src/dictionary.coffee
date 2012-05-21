moduleKeywords = ['extended', 'included']

class Module
  @include: (obj) ->
    for key, value of obj when key not in moduleKeywords
      # Assign properties to the prototype
      @::[key] = value

    obj.included?.apply(@)
    this

# YouDaoModule
youDaoModule = 
  translate: (word) ->
    # TODO: may be need some code for ie6
    xhr = new window.XMLHttpRequest()
    url = "http://fanyi.youdao.com/openapi.do?keyfrom=#{@options.keyfrom}&key=#{@options.key}&type=data&doctype=json&version=1.1&q=#{word}"
    xhr.open('GET', url, true)
    xhr.send null
    xhr

class Dictionary extends Module
  constructor: (@name, @options) ->
    if @name == 'youdao'
      Dictionary.include(youDaoModule)

# Globals
exports = this
exports.Dictionary = Dictionary
