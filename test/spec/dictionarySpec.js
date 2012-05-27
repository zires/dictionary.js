describe('Dictionary', function() {

  describe('when use youdao module', function() {
    // This is a fake word should return from server
    var yesterday = '昨天';
    var dict;

    beforeEach(function () {
      // This is a fake youdao server
      this.server = sinon.fakeServer.create();

      this.server.respondWith("GET", 
        "http://fanyi.youdao.com/openapi.do?keyfrom=fackkeyfrom&key=fackkey&type=data&doctype=json&version=1.1&q=yesterday",
        [200, { "Content-Type": "application/json" },'{"translation":["昨天"], "errorCode":0}']);

      this.server.respondWith("GET", 
        "http://fanyi.youdao.com/openapi.do?keyfrom=wrongkeyfrom&key=wrongkey&type=data&doctype=json&version=1.1&q=yesterday",
        [200, { "Content-Type": "application/json" },'{"query":"yesterday","errorCode":50}']);

      dict = new Dictionary('youdao', {keyfrom: 'fackkeyfrom',key: 'fackkey'});

    });

    afterEach(function() {
      this.server.restore();
    });

    it("should have right url", function() {
      dict.translate('yesterday');
      expect( this.server.requests.length ).toBe(1);
      expect( this.server.requests[0].url ).toBe("http://fanyi.youdao.com/openapi.do?keyfrom=fackkeyfrom&key=fackkey&type=data&doctype=json&version=1.1&q=yesterday");
    });

    it("can be able to translate word form english to chinese simply (Synchronous)", function() {
      expect( dict.translate('yesterday') ).toBe(yesterday);
    });

    it("can be able to translate word form english to chinese using success callback", function() {
      var successCallback = sinon.spy();
      dict.translate('yesterday', successCallback);
      this.server.respond();
      var text = this.server.requests[0].responseText
      expect( successCallback.calledWith(text) ).toBeTruthy();
    });

    it("has a alias function t which like translate", function() {
      expect( dict.translate('yesterday') ).toBe( dict.t('yesterday') );
    });

    it("should return null if use wrong keyfrom or key", function() {
      var wrongDict = new Dictionary('youdao', {keyfrom: 'wrongkeyfrom',key: 'wrongkey'});
      expect( wrongDict.translate('yesterday') ).toBe(null);
    });

  });

  describe('when use as Jquery or Zepto plugin', function() {

    beforeEach(function() {
      // Because of chrome cross domain issue.
      // Check test/fixtures/dictionary.html for html version.
      var html = '<div id="demo"><p>yesterday</p></div>';
      html += '<div id="translateSuccessful">';
      html += '<div id="word">foo</div><div id="phonetic">bar</div>';
      html += '<div id="explains"></div>';
      html += '</div>';
      html += '<div id="customSuccessful"><div id="word">foo</div><div id="phonetic">bar</div></div>';
      html += '<div id="beforeTranslation"><span>loading...</span></div>';
      html += '<div id="customLoading"><span>custom loading...</span></div>';
      setFixtures(html);

      // Select element
      selectText = function SelectText(element){
        var doc = document;
        var text = doc.getElementById(element);
        if (doc.body.createTextRange) {
          var range = document.body.createTextRange();
          range.moveToElementText(text);
          range.select();
        } else if (window.getSelection) {
          var selection = window.getSelection();        
          var range = document.createRange();
          range.selectNodeContents(text);
          selection.removeAllRanges();
          selection.addRange(range);
        }
      }

      this.server = sinon.fakeServer.create();

      this.server.respondWith("GET", 
        "http://fanyi.youdao.com/openapi.do?keyfrom=foo&key=123&type=data&doctype=json&version=1.1&q=yesterday",
        [200, { "Content-Type": "application/json" },'{"translation":["昨天"], "errorCode":0}']);

      this.server.respondWith("GET", 
        "http://fanyi.youdao.com/openapi.do?keyfrom=foo&key=1234&type=data&doctype=json&version=1.1&q=yesterday",
        [200, { "Content-Type": "application/json" },'{"translation":["昨天"], "errorCode":0, "basic":{"phonetic":"\'jestədi,-dei", "explains":["n. 昨天；往昔","adv. 昨天"]} }']);

    });

    afterEach(function() {
      this.server.restore();
    });

    it("have a defined function called dict()", function() {
      spyOn($.fn, 'dict').andReturn('bar');
      expect( $('#demo').dict() ).toEqual('bar');
      // spyOn($.fn, "dict");
      // $('#demo').dict();
      // expect( $.fn.dict ).toHaveBeenCalled();
    });

    it("should not see loading container if set loadingContainer is false", function() {
      $('#demo').dict('youdao', {keyfrom: 'foo', key: 123, loadingContainer: false});
      selectText('demo');
      $('#demo p').mousedown().mouseup(); //mock mouse action
      expect( $('body') ).toContain( $('#dictMain') );
      expect( $('#dictMain') ).toBeHidden();
    })

    it("should have a pop window around the mouseup dom without basic translation", function() {
      $('#demo').dict('youdao', {keyfrom: 'foo', key: 123});
      selectText('demo');
      //var stub = sinon.stub($('#demo'), 'mouseup');
      // var e = jQuery.Event('mouseup');
      // e.clientX = 20;
      // var stub = sinon.stub($('#demo'), 'mouseup').withArgs(e);
      $('#demo p').mousedown().mouseup(); //mock mouse action
      expect( $('body') ).toContain( $('#dictMain') );
      expect( $('#dictMain') ).toHaveHtml('<div id="beforeTranslation"><span>loading...</span></div>');
      expect( $('#dictMain') ).toBeVisible();
      expect( $('#dictMain').css('position') ).toBe('absolute');
      this.server.respond();
      expect( $('#dictMain') ).toContain('#translateSuccessful');
      expect( $('#dictMain #translateSuccessful #word').text() ).toBe('yesterday');
      expect( $('#dictMain #translateSuccessful #explains').html() ).toBe('<p>昨天</p>');
      expect( $('#dictMain') ).toBeVisible();
      $('#dictMain #translateSuccessful').mousedown();
      expect( $('#dictMain') ).toBeVisible();
      $('body #demo').mousedown();
      expect( $('#dictMain') ).toBeHidden();
    })

    it("should have a pop window around the mouseup dom with basic translation", function() {
      $('#demo').dict('youdao', {keyfrom: 'foo', key: 1234});
      selectText('demo');
      $('#demo p').mousedown().mouseup(); //mock mouse action
      this.server.respond();
      expect( $('#dictMain') ).toContain('#translateSuccessful');
      expect( $('#dictMain #translateSuccessful #word').text() ).toBe('yesterday');
      expect( $('#dictMain #translateSuccessful #phonetic').text() ).toBe("'jestədi,-dei");
      expect( $('#dictMain #translateSuccessful #explains').html() ).toBe('<p>n. 昨天；往昔</p><p>adv. 昨天</p>');
    })

    it("should correct when using custom propoty", function() {
      $('#demo').dict('youdao', {keyfrom: 'foo', key: 1234, loadingContainer: '#customLoading', successContainer: '#customSuccessful'});
      selectText('demo');
      $('#demo p').mousedown().mouseup(); //mock mouse action
      expect( $('#dictMain') ).toHaveHtml('<div id="customLoading"><span>custom loading...</span></div>');
      this.server.respond();
      expect( $('#dictMain') ).toContain('#customSuccessful');
    })


  });
  

});