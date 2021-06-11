const preferences = require('bindings')('cf-prefs.node');

function maybeWithDefault(value, defaultValue) {
  if (value === undefined && defaultValue !== undefined) {
    return defaultValue;
  }
  return value;
}

function getPreferenceValue(key, type, defaultValue) {
  switch (type) {
    case 'string':
      return maybeWithDefault(preferences.getString(key), defaultValue);
    case 'integer':
      return maybeWithDefault(preferences.getInteger(key), defaultValue);
    case 'boolean':
      return maybeWithDefault(preferences.getBoolean(key), defaultValue);
    default:
      throw new Error(`Unsupported preference type "${type}"`);
  }
}

module.exports = {
  getPreferenceValue,
  isPreferenceForced: preferences.isPreferenceForced,
};
