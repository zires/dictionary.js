moduleKeywords = ['extended', 'included']

class Module
  @include: (obj) ->
    for key, value of obj when key not in moduleKeywords
      @::[key] = value
    obj.included?.apply(@)
    this

# YouDaoModule
youDaoModule = 
  translate: (word) ->
    url = "http://fanyi.youdao.com/openapi.do?keyfrom=#{@options.keyfrom}&key=#{@options.key}&type=data&doctype=jsonp&callback=?&version=1.1&q=#{word}"
    @options.url      = url
    @options.async    = true # This must be true
    @options.dataType = @options.dataType ? 'json'
    $.ajax @options
    # settings.url   = url
    # settings.async = true # This must be true
    # $.ajax settings

class Dictionary extends Module
  constructor: (@name, @options = {}) ->
    Dictionary.include(youDaoModule) if @name == 'youdao'
  t: (word) ->
    @translate(word)

# Jquery or Zepto plugin
$ = window?.jQuery or window?.Zepto or (element) -> element
$.fn.extend dict: (name, options) ->
  # TODO: doubleclick
  # any settings in $.ajax
  # loadingContainer
  # successContainer
  @defaultSettings =
    doubleclick: true
    loadingContainer: '#beforeTranslation'
    successContainer: '#translateSuccessful'
    

  settings = $.extend({}, @defaultSettings, options)

  # This method should return a json contain word and coordinate.
  # eq.
  # {word:'yesterday', top: 20, left: 30}
  getSelectWord = ()->
    word = ''
    markerId = "sel_#{new Date().getTime()}_#{Math.random().toString().substr(2)}"
    if document.selection and document.selection.createRange
      word  = document.selection.createRange().text
      # Clone the TextRange and collapse
      range = document.selection.createRange().duplicate()
      range.collapse false
      # Create the marker element containing a single invisible character by creating literal HTML and insert it
      range.pasteHTML "<span id='#{markerId}' style='position: relative;'>&#xfeff;</span>"
    else if window.getSelection
      word  = window.getSelection()
      # TODO: Older WebKit doesn't have getRangeAt
      range = word.getRangeAt(0).cloneRange()
      range.collapse false
      markerEl    = document.createElement("span")
      markerEl.id = markerId
      markerEl.appendChild( document.createTextNode("\ufeff") )
      range.insertNode markerEl
    marker = document.getElementById markerId
    {word: word.toString, top: marker.offsetTop, left: marker.offsetLeft}

  $('body').children().not('.dictMain').mousedown ->
    $('.dictMain').hide()

  @each (index, element) =>
    dict = new Dictionary(name, settings)
    $(this).mouseup (e) ->
      word = getSelectWord
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
