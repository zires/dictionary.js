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
    url = "http://fanyi.youdao.com/openapi.do?keyfrom=#{@options.keyfrom}&key=#{@options.key}&type=data&doctype=jsonp&callback=?&version=1.1&q=#{word}"
    $.getJSON(url, onSuccess)
    # if window.XMLHttpRequest
    #   xhr = new window.XMLHttpRequest()
    # else if window.ActiveXObject
    #   xhr = new ActiveXObject("Microsoft.XMLHTTP")
    # url = "http://fanyi.youdao.com/openapi.do?keyfrom=#{@options.keyfrom}&key=#{@options.key}&type=data&doctype=json&version=1.1&q=#{word}"
    # xhr.open('GET', url, onSuccess?)
    # if onSuccess?
    #   failureCallback = onFailure ? ->
    #   xhr.onreadystatechange = ->
    #     onSuccess(xhr.responseText) if xhr.readyState == 4 and xhr.status == 200
    #     failureCallback(xhr.responseText) if xhr.readyState == 4 and xhr.status != 200
    # xhr.send null
    # unless onSuccess?
    #   if xhr.status == 200
    #     try
    #       responseObject = eval("(#{xhr.responseText})")
    #       if responseObject.errorCode == 0 then responseObject.translation.join() else null
    #     catch error
    #       return null
    #   else
    #     return xhr.statusText

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

  $('body').children().not('.dictMain').mousedown ->
    $('.dictMain').hide()

  @each (index, element) =>
    dict = new Dictionary(name, settings)
    $(this).mouseup (e) ->
      word = getSelectWord document
      return if word.replace(/\s/g, "") == "" #do nothing if word is empty
      status = true
      status = settings.beforeTranslation.call this if typeof(settings.beforeTranslation) == 'function'
      if status
        offset = window.pageYOffset or document.documentElement.scrollTop or document.body.scrollTop or 0
        left   = e.pageX
        left   += settings.left if settings.left?
        top    = if e.pageY - 40 < 0 then e.pageY + offset + 10 else e.pageY + offset + 20
        top    += settings.top if settings.top?
        if settings.loadingContainer
          $container = $(settings.loadingContainer).addClass('dictMain')
          $container.css('left', left).css('top', top).css('position', 'absolute')
          $container.show()
        # $container = if $('#dictMain').length > 0 then $('#dictMain') else $('<div id="dictMain"></div>').appendTo('body')
        # $container.empty()
        # $container.css('left', left).css('top', top).css('position', 'absolute')
        # $container.append( $(settings.loadingContainer).clone() ).show() if settings.loadingContainer
        onSuccess = settings.onSuccess ? (result) ->
          #$successContainer = $(settings.successContainer).clone()
          $container = $(settings.successContainer).addClass('dictMain')
          $container.css('left', left).css('top', top).css('position', 'absolute')
          $("#{settings.successContainer} #word").text word
          if result.basic?
            phonetic = result.basic.phonetic
            data     = result.basic.explains
          else
            data = result.translation

          if phonetic?
            $("#{settings.successContainer} #phonetic").text phonetic
          else
            $("#{settings.successContainer} #phonetic").hide()

          if data?
            $("#{settings.successContainer} #explains").empty()
            $.each data, (index, value) ->
              $("#{settings.successContainer} #explains").append("<p>#{value}</p>")
          else
            $("#{settings.successContainer} #explains").empty().hide()

          $('.dictMain').hide()
          $container.show()
          # phonetic = result.basic.phonetic if result.basic?
          # data = if result.basic? then 
          #phonetic = if result.basic? then result.basic.phonetic
          # if result.basic?
          #   $successContainer.children('#phonetic').text result.basic.phonetic
          #   $.each result.basic.explains, (index, value) ->
          #     $successContainer.children("#explains").append("<p>#{value}</p>")
          # else
          #   $successContainer.children('#phonetic').hide()
          #   $.each result.translation, (index, value) ->
          #     $successContainer.children("#explains").append("<p>#{value}</p>")
          # $container.empty().append($successContainer.show()).show()
        dict.translate word, onSuccess, settings.onFailure
  @

# Globals
exports = this
exports.Dictionary = Dictionary
