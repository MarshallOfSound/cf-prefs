const util = require('util');
const exec = util.promisify(require('child_process').exec);
const path = require('path');
const { expect } = require('chai');
const { getPreferenceValue, isPreferenceForced } = require('../index');

describe('cf-prefs', () => {
  const TEST_BUNDLE_ID = 'com.github.cfprefstest';

  before(async () => {
    const { stderr } = await exec(`python ${path.join(__dirname, 'write-test-prefs.py')}`);
    if (stderr.length > 0) {
      throw new Error(stderr);
    }
  });

  describe('getPreferenceValue()', () => {
    it('should throw on invalid keys', () => {
      expect(() => {
        getPreferenceValue(123);
      }).to.throw(/string was expected/);
    });

    it('should return undefined when no value is present', () => {
      expect(getPreferenceValue('NonsenseKey')).to.equal(undefined);
    });

    it('should convert a string', () => {
      expect(getPreferenceValue('string', TEST_BUNDLE_ID)).to.equal('foo');
    });

    it('should convert a boolean', () => {
      expect(getPreferenceValue('boolean', TEST_BUNDLE_ID)).to.equal(true);
    });

    it('should convert a double', () => {
      expect(getPreferenceValue('double', TEST_BUNDLE_ID)).to.equal(3.14);
    });

    it('should convert an integer', () => {
      expect(getPreferenceValue('integer', TEST_BUNDLE_ID)).to.equal(123);
    });

    it('should convert a dict', () => {
      expect(getPreferenceValue('dict', TEST_BUNDLE_ID)).to.deep.equal({ foo: 1, bar: 'baz' });
    });

    it('should convert a nested dict', () => {
      expect(getPreferenceValue('nested-dict', TEST_BUNDLE_ID)).to.deep.equal({ foo: { bar: { baz: false } } });
    });

    it('should convert an array', () => {
      expect(getPreferenceValue('array', TEST_BUNDLE_ID)).to.deep.equal([1, 2, 3]);
    });

    it('should convert a nested array', () => {
      expect(getPreferenceValue('nested-array', TEST_BUNDLE_ID)).to.deep.equal([[['foo']]]);
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
