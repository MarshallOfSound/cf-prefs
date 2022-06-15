[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)
 [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com) [![Actions Status](https://github.com/MarshallOfSound/cf-prefs/workflows/Test/badge.svg)](https://github.com/MarshallOfSound/cf-prefs/actions)

# cf-prefs

```js
$ yarn add cf-prefs
```

This native Node.js module allows you to read managed app preferences on macOS.  It maps to the underlying `CFPreferencesCopyAppValue` family of APIs.  This module only truly works in apps with valid bundle IDs (i.e. Electron apps).

## API

## `prefs.getPreferenceValue(key, applicationId)`

* `key` String - The preference key to fetch the value of, has to be a valid UTF-8 string.
* `applicationId` String (Optional) - The identifier of the application whose preferences to search. If no value is provided, the current application's identifier is used.

Returns `String` | `Integer` | `Boolean` | `Object` | `Array` | `undefined`

**Notes:**
* If the preference is not available you will receive `undefined`.

Example:
```js
console.log('My Preference Value:', prefs.getPreferenceValue('MyAppsCoolPreference'))
console.log('Other Preference Value:', prefs.getPreferenceValue('OtherAppsCoolPreference', 'com.domain.otherapp'))
```

## `permissions.isPreferenceForced(key, applicationId)`

* `key` String - The preference key to determine if the value is forced, has to be a valid UTF-8 string.
* `applicationId` String (Optional) - The identifier of the application whose preferences to search. If no value is provided, the current application's identifier is used.

Returns `Boolean` - Whether the preference key is "forced", if this method returns true you should not allow users to override this preference in your application as a system administrator has indicated this preference key is "forced".  For more information [check out the apple API docs](https://developer.apple.com/documentation/corefoundation/1515521-cfpreferencesappvalueisforced?language=objc).
