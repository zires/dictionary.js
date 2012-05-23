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
    

    
  });
  



});