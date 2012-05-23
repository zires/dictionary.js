moduleKeywords = ['extended', 'included']

class Module
  @include: (obj) ->
    for key, value of obj when key not in moduleKeywords
      # Assign properties to the prototype
      # @:: means this.prototype
      @::[key] = value

    obj.included?.apply(@)
    this

# YouDaoModule
youDaoModule = 
  translate: (word, onSuccess, onFailure) ->
    # TODO: may be need some code for ie6
    xhr = new window.XMLHttpRequest()
    url = "http://fanyi.youdao.com/openapi.do?keyfrom=#{@options.keyfrom}&key=#{@options.key}&type=data&doctype=json&version=1.1&q=#{word}"
    xhr.open('GET', url, onSuccess?)
    if onSuccess?
      failureCallback = onFailure ? ->
      xhr.onreadystatechange = ->
        onSuccess(xhr.responseText) if xhr.readyState == 4 and xhr.status == 200
        failureCallback(xhr.responseText) if xhr.readyState == 4 and xhr.status != 200
    xhr.send null
    unless onSuccess?
      if xhr.status == 200
        try
          responseObject = eval("(#{xhr.responseText})")
          if responseObject.errorCode == 0 then responseObject.translation.join() else null
        catch error
          return null
      else
        return xhr.statusText

class Dictionary extends Module
  constructor: (@name, @options = {}) ->
    Dictionary.include(youDaoModule) if @name == 'youdao'
  t: (word, onSuccess, onFailure) ->
    @translate(word, onSuccess, onFailure)

# Jquery or Zepto plugin
$ = window?.jQuery or window?.Zepto
$.fn.extend dict: (name, options) ->
  @defaultSettings =
    doubleclick: true
    loadingContainer: '#beforeTranslation'
    successContainer: '#translateSuccessful'
  settings = $.extend({}, @defaultSettings, options)
  @each (index, element) ->
    dict = new Dictionary(name, settings)
  @


# Globals
exports = this
exports.Dictionary = Dictionary
