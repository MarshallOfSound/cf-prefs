const { expect } = require('chai');
const { getPreferenceValue, isPreferenceForced } = require('../index');

describe('cf-prefs', () => {
  describe('getPreferenceValue()', () => {
    it('should throw on invalid keys', () => {
      expect(() => {
        getPreferenceValue(123, 'string');
      }).to.throw(/string was expected/);
    });

    it('should throw on invalid types', () => {
      expect(() => {
        getPreferenceValue('Key', 'wizard');
      }).to.throw(/Unsupported preference type/);
    });

    it('should return undefined when no value is present', () => {
      expect(getPreferenceValue('NonsenseKey', 'string')).to.equal(undefined);
    });

    it('should return the provided default value when no value is present', () => {
      expect(getPreferenceValue('NonsenseKey', 'string', 'DefaultValue')).to.equal('DefaultValue');
    });
  });

  describe('isPreferenceForced', () => {
    it('should throw on invalid keys', () => {
      expect(() => {
        isPreferenceForced(123);
      }).to.throw(/string was expected/);
    });

    it('should return a boolean for any valid key', () => {
      expect(isPreferenceForced('TestKey')).to.be.a('boolean');
    });
  });
});
