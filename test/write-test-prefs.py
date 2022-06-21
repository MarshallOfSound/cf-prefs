import CoreFoundation

values = {
  'string': 'foo',
  'boolean': True,
  'double': 3.14,
  'integer': 123,
  'dict': {'foo': 1, 'bar': 'baz'},
  'nested-dict': {'foo': {'bar': {'baz': False }}},
  'array': [1,2,3],
  'nested-array': [[['foo']]]
}

for k, v in values.items():
  CoreFoundation.CFPreferencesSetAppValue(k, v, "com.github.cfprefstest")
