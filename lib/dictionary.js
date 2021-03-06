// Generated by CoffeeScript 1.3.3
(function() {
  var $, Dictionary, Module, exports, moduleKeywords, youDaoModule,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  moduleKeywords = ['extended', 'included'];

  Module = (function() {

    function Module() {}

    Module.include = function(obj) {
      var key, value, _ref;
      for (key in obj) {
        value = obj[key];
        if (__indexOf.call(moduleKeywords, key) < 0) {
          this.prototype[key] = value;
        }
      }
      if ((_ref = obj.included) != null) {
        _ref.apply(this);
      }
      return this;
    };

    return Module;

  })();

  youDaoModule = {
    translate: function(word, settings) {
      var url, _ref;
      if (settings == null) {
        settings = {};
      }
      url = "http://fanyi.youdao.com/openapi.do?keyfrom=" + this.options.keyfrom + "&key=" + this.options.key + "&type=data&doctype=jsonp&callback=?&version=1.1&q=" + word;
      settings.url = encodeURI(url);
      settings.async = true;
      settings.dataType = (_ref = settings.dataType) != null ? _ref : 'jsonp';
      return $.ajax(settings);
    }
  };

  Dictionary = (function(_super) {

    __extends(Dictionary, _super);

    function Dictionary(name, options) {
      this.name = name;
      this.options = options != null ? options : {};
      if (this.name === 'youdao') {
        Dictionary.include(youDaoModule);
      }
    }

    Dictionary.getSelectWord = function() {
      var word;
      word = '';
      if (document.selection && document.selection.createRange) {
        word = document.selection.createRange().text;
      } else if (window.getSelection) {
        word = window.getSelection();
      }
      return word.toString();
    };

    return Dictionary;

  })(Module);

  $ = (typeof window !== "undefined" && window !== null ? window.jQuery : void 0) || (typeof window !== "undefined" && window !== null ? window.Zepto : void 0) || function(element) {
    return element;
  };

  $.fn.extend({
    dict: function(name, options) {
      var settings,
        _this = this;
      this.defaultSettings = {
        doubleclick: true,
        successContainer: '#translateSuccessful'
      };
      settings = $.extend({}, this.defaultSettings, options);
      $('body').mousedown(function() {
        return $('.dictMain').hide();
      });
      this.each(function() {
        var dict;
        dict = new Dictionary(name, settings);
        return $(_this).mouseup(function(e) {
          var word;
          word = Dictionary.getSelectWord();
          if (word.replace(/\s/g, "") === "") {
            return;
          }
          settings.left = e.pageX + 10;
          settings.top = e.pageY - 16;
          if (settings.success == null) {
            settings.success = function(result) {
              var $container, data, phonetic;
              $container = $(settings.successContainer).addClass('dictMain');
              $container.css('left', settings.left).css('top', settings.top).css('position', 'absolute');
              $("" + settings.successContainer + " #word").text(result.query);
              $("" + settings.successContainer + " #phonetic").hide();
              $("" + settings.successContainer + " #explains").empty();
              if (result.basic != null) {
                phonetic = result.basic.phonetic;
                data = result.basic.explains;
              } else {
                data = result.translation;
              }
              if (phonetic != null) {
                $("" + settings.successContainer + " #phonetic").text("[" + phonetic + "]").show();
              }
              if (data != null) {
                $.each(data, function(index, value) {
                  return $("" + settings.successContainer + " #explains").append("<p>" + value + "</p>");
                });
              }
              return $container.show();
            };
          }
          return dict.translate(word, settings);
        });
      });
      return this;
    }
  });

  exports = this;

  exports.Dictionary = Dictionary;

}).call(this);
