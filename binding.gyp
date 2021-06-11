{
  "targets": [{
    "target_name": "cf-prefs",
    "sources": [ ],
    "conditions": [
      ['OS=="mac"', {
        "sources": [
          "preferences.mm"
        ],
      }]
    ],
    'include_dirs': [
      "<!@(node -p \"require('node-addon-api').include\")"
    ],
    'libraries': [],
    'dependencies': [
      "<!(node -p \"require('node-addon-api').gyp\")"
    ],
    'defines': [],
    "xcode_settings": {
      "MACOSX_DEPLOYMENT_TARGET": "10.10",
      "OTHER_CPLUSPLUSFLAGS": ["-std=c++14", "-stdlib=libc++"],
      "OTHER_LDFLAGS": ["-framework CoreFoundation"],
      "GCC_ENABLE_CPP_EXCEPTIONS": 'YES'
    }
  }]
}