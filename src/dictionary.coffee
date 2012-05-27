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
$ = window?.jQuery or window?.Zepto or (element) -> element
$.fn.extend dict: (name, options) ->
  # TODO: doubleclick
  # onSuccess
  # OnFailure
  # beforeTranslation
  # loadingContainer
  # successContainer
  @defaultSettings =
    doubleclick: true
    loadingContainer: '#beforeTranslation'
    successContainer: '#translateSuccessful'
    onFailure: ->

  settings = $.extend({}, @defaultSettings, options)

  getSelectWord = (doc)->
    word = ''
    word = window.getSelection() if window.getSelection
    word = doc.getSelection() if doc.getSelection
    word = doc.selection.createRange().text if doc.selection
    word.toString()

  $('body').children().not('#dictMain').mousedown ->
    $('#dictMain').hide()

  @each (index, element) =>
    dict = new Dictionary(name, settings)
    $(this).mouseup (e) ->
      word = getSelectWord document
      return if word == '' #do nothing if word is empty
      status = true
      status = settings.beforeTranslation.call this if typeof(settings.beforeTranslation) == 'function'
      if status
        offset = window.pageYOffset or document.documentElement.scrollTop or document.body.scrollTop or 0
        left   = e.clientX
        left   += settings.left if settings.left?
        top    = (e.clientY - 40 < 0) ? e.clientY + offset + 10 : e.clientY + offset - 30
        top    += settings.top if settings.top?
        $container = if $('#dictMain').length > 0 then $('#dictMain') else $('<div id="dictMain"></div>').appendTo('body')
        $container.empty()
        $container.css('left', left).css('top', top).css('position', 'absolute')
        $container.append( $(settings.loadingContainer) ).show() if settings.loadingContainer
        onSuccess = settings.onSuccess ? (result) ->
          $successContainer = $(settings.successContainer)
          $successContainer.children('#word').text word
          result = $.parseJSON result
          console.log result
          if result.basic?
            $successContainer.children('#phonetic').text result.basic.phonetic
            $.each result.basic.explains, (index, value) ->
              $successContainer.children("#explains").append("<p>#{value}</p>")
          else
            $successContainer.children('#phonetic').hide()
            $.each result.translation, (index, value) ->
              $successContainer.children("#explains").append("<p>#{value}</p>")
          $container.empty().append($successContainer).show()
        dict.translate word, onSuccess, settings.onFailure
  @

# Globals
exports = this
exports.Dictionary = Dictionary
