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
      html += '<div id="explains"><span id="explains1">hello</span><span id="explains2">world</span></div>';
      html += '</div>';
      html += '<div id="customSuccessful"><div id="word">foo</div><div id="phonetic">bar</div></div>';
      html += '<div id="beforeTranslation"><span>loading...</span></div>';
      html += '<div id="customLoading"><span>custom loading...</span></div>';
      setFixtures(html);
    });

    it("have a defined function called dict()", function() {
      spyOn($.fn, 'dict').andReturn('bar');
      expect( $('#demo').dict() ).toEqual('bar');
      // spyOn($.fn, "dict");
      // $('#demo').dict();
      // expect( $.fn.dict ).toHaveBeenCalled();
    });

    it("should have a pop windows above selected dom", function() {
      $('#demo').dict();
    })

    it("should have a pop windows above double click dom", function() {
      $('#demo').dict();
    })


  });
  



});