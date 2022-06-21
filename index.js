const preferences = require('bindings')('cf-prefs.node');

module.exports = {
  getPreferenceValue: preferences.getValue,
  isPreferenceForced: preferences.isPreferenceForced,
};
