#include <napi.h>

#include "preferences.h"

// Module bindings

Napi::Object InitCFPrefs(Napi::Env env, Napi::Object exports) {
  return exports;
}

NODE_API_MODULE(cfprefs, InitCFPrefs)
