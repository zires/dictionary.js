moduleKeywords = ['extended', 'included']

class Module
  @include: (obj) ->
    for key, value of obj when key not in moduleKeywords
      @::[key] = value
    obj.included?.apply(@)
    this

# YouDaoModule
youDaoModule = 
  translate: (word, settings = {}) ->
    url = "http://fanyi.youdao.com/openapi.do?keyfrom=#{@options.keyfrom}&key=#{@options.key}&type=data&doctype=jsonp&callback=?&version=1.1&q=#{word}"
    settings.url   = encodeURI url
    settings.async = true # This must be true
    settings.dataType = settings.dataType ? 'jsonp'
    $.ajax settings
    # $.getJSON url, settings.success

class Dictionary extends Module
  constructor: (@name, @options = {}) ->
    Dictionary.include(youDaoModule) if @name == 'youdao'
  # This method should return a json contain word and coordinate.
  # eq.
  # {word:'yesterday', top: 20, left: 30}
  @getSelectWord: () ->
    word = ''
    if document.selection and document.selection.createRange
      word  = document.selection.createRange().text
    else if window.getSelection
      word  = window.getSelection()
    word.toString()
    # word = ''
    # markerId = "sel_#{new Date().getTime()}_#{Math.random().toString().substr(2)}"
    # if document.selection and document.selection.createRange
    #   word  = document.selection.createRange().text
    #   # Clone the TextRange and collapse
    #   range = document.selection.createRange().duplicate()
    #   range.collapse false
    #   # Create the marker element containing a single invisible character by creating literal HTML and insert it
    #   range.pasteHTML "<span id='#{markerId}' style='position: relative;'>&#xfeff;</span>"
    # else if window.getSelection
    #   word  = window.getSelection()
    #   # TODO: Older WebKit doesn't have getRangeAt
    #   range = word.getRangeAt(0).cloneRange()
    #   range.collapse false
    #   markerEl    = document.createElement("span")
    #   markerEl.id = markerId
    #   markerEl.appendChild( document.createTextNode("\ufeff") )
    #   range.insertNode markerEl
    # marker = document.getElementById markerId
    # top    = marker.offsetTop
    # left   = marker.offsetLeft
    # marker.parentNode.removeChild marker
    # {word: word.toString(), top: top, left: left}

# Jquery or Zepto plugin
$ = window?.jQuery or window?.Zepto or (element) -> element
$.fn.extend dict: (name, options) ->
  # TODO: doubleclick
  # any settings in $.ajax
  # loadingContainer
  # successContainer
  # leftOffset
  # topOffset
  @defaultSettings =
    doubleclick: true
    # loadingContainer: '#beforeTranslation'
    successContainer: '#translateSuccessful'

  settings = $.extend({}, @defaultSettings, options)

  $('body').mousedown ->
    $('.dictMain').hide()

  @each () =>
    dict = new Dictionary(name, settings)
    $(this).mouseup (e) ->
      word = Dictionary.getSelectWord()
      return if word.replace(/\s/g, "") == "" #do nothing if word is empty
      settings.left = e.pageX + 10
      settings.top  = e.pageY - 16
      unless settings.success?
        settings.success = (result) ->
          $container = $(settings.successContainer).addClass('dictMain')
          $container.css('left', settings.left).css('top', settings.top).css('position', 'absolute')
          $("#{settings.successContainer} #word").text result.query
          $("#{settings.successContainer} #phonetic").hide()
          $("#{settings.successContainer} #explains").empty()
          if result.basic?
            phonetic = result.basic.phonetic
            data     = result.basic.explains
          else
            data = result.translation
          $("#{settings.successContainer} #phonetic").text("[#{phonetic}]").show() if phonetic?
          if data?
            $.each data, (index, value) ->
              $("#{settings.successContainer} #explains").append("<p>#{value}</p>")
          $container.show()
      dict.translate word, settings
  @

# Globals
exports = this
exports.Dictionary = Dictionary
