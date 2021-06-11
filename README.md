[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)
 [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com) [![Actions Status](https://github.com/MarshallOfSound/cf-prefs/workflows/Test/badge.svg)](https://github.com/MarshallOfSound/cf-prefs/actions)

# cf-prefs

```js
$ yarn add cf-prefs
```

This native Node.js module allows you to read managed app preferences on macOS.  It maps to the underlying `CFPreferencesCopyAppValue` family of APIs.  This module only truly works in apps with valid bundle IDs (i.e. Electron apps).

## API

## `prefs.getPreferenceValue(key, type)`

* `key` String - The preference key to fetch the value of, has to be a valid UTF-8 string.
* `type` String - The data-type of the preference you are fetching. Can be one of `string`, `integer` or `boolean`.
* `defaultValue` String | Integer | Boolean (Optional) - If no value is present this value will be returned instead, if no default value is provided this method may return `undefined`.

Returns `String` | `Integer` | `Boolean` | `undefined` - Depending on the requested type, see [the type definitions](./index.d.ts) for a more accurate mapping.

**Notes:**
* If the preference is available but in a different type you will not receive an error, you will receive `undefined`.
* If the preference is not available you will receive `undefined`.

Example:
```js
console.log('Preference Value:', prefs.getPreferenceValue('MyAppsCoolPreference', 'string', 'this-is-the-default'))
```

## `permissions.isPreferenceForced(key)`

* `key` String - The preference key to determine if the value is forced, has to be a valid UTF-8 string.

Returns `Boolean` - Whether the preference key is "forced", if this method returns true you should not allow users to override this preference in your application as a system administrator has indicated this preference key is "forced".  For more information [check out the apple API docs](https://developer.apple.com/documentation/corefoundation/1515521-cfpreferencesappvalueisforced?language=objc).
