describe('Dictionary', function() {

  describe('when use youdao module', function() {

    it("should be able to translate word form english to chinese", function() {
      var expectTranslation = {"phonetic":"'jestədi,-dei","explains":["n. 昨天；往昔","adv. 昨天"]};
      expect( Dictionary.translate('yesterday') ).toBe(expectTranslation);
    });

  });

});