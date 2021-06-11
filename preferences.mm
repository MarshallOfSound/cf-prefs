#include <napi.h>

#import <Foundation/Foundation.h>

// CF Converters

/**
 * Converts a CFString to a std::string
 *
 * This either uses CFStringGetCStringPtr or (if that fails)
 * CFStringGetCString, trying to be as efficient as possible.
 */
const std::string CFStringToStdString(CFStringRef cfstring) {
  const char *cstr = CFStringGetCStringPtr(cfstring, kCFStringEncodingUTF8);

  if (cstr != NULL) {
    return std::string(cstr);
  }

  CFIndex length = CFStringGetLength(cfstring);
  // Worst case: 2 bytes per character + NUL
  CFIndex cstrPtrLen = length * 2 + 1;
  char *cstrPtr = static_cast<char *>(malloc(cstrPtrLen));

  Boolean result =
      CFStringGetCString(cfstring, cstrPtr, cstrPtrLen, kCFStringEncodingUTF8);

  std::string stdstring;
  if (result) {
    stdstring = std::string(cstrPtr);
  }

  free(cstrPtr);

  return stdstring;
}

/**
 * Converts a Boolean to a bool
 *
 * A "Boolean" type is actually an int of 0 or 1
 * so this just casts 0 === false, everything else === true
 */
bool CFBooleanToBool(Boolean value) { return value != 0; }

// Preference getters

CFStringRef GetCFKeyFromArgs(const Napi::CallbackInfo &info) {
  Napi::String key(info.Env(), info[0]);
  CFStringRef key_str = CFStringCreateWithCString(NULL, key.Utf8Value().c_str(),
                                                  kCFStringEncodingUTF8);

  if (key_str == NULL) {
    throw Napi::Error::New(
        info.Env(),
        "Failed to convert 'key' argument to CFString in GetInteger()");
  }

  return key_str;
}

Napi::Value GetString(const Napi::CallbackInfo &info) {
  if (info.Length() < 1) {
    throw Napi::Error::New(info.Env(), "Missing 'key' argument to GetString()");
  }

  CFStringRef key = GetCFKeyFromArgs(info);
  CFStringRef value_str = (CFStringRef)CFPreferencesCopyAppValue(
      key, kCFPreferencesCurrentApplication);
  CFRelease(key);

  if (!value_str) {
    return Napi::Value();
  }

  Napi::Value value =
      Napi::Value::From(info.Env(), CFStringToStdString(value_str));
  CFRelease(value_str);
  return value;
}

Napi::Value GetInteger(const Napi::CallbackInfo &info) {
  if (info.Length() < 1) {
    throw Napi::Error::New(info.Env(),
                           "Missing 'key' argument to GetInteger()");
  }

  CFStringRef key = GetCFKeyFromArgs(info);
  Boolean value_existed = false;
  CFIndex value_int = CFPreferencesGetAppIntegerValue(
      key, kCFPreferencesCurrentApplication, &value_existed);
  CFRelease(key);

  if (!value_existed) {
    return Napi::Value();
  }

  return Napi::Value::From(info.Env(), value_int);
}

Napi::Value GetBoolean(const Napi::CallbackInfo &info) {
  if (info.Length() < 1) {
    throw Napi::Error::New(info.Env(),
                           "Missing 'key' argument to GetBoolean()");
  }

  CFStringRef key = GetCFKeyFromArgs(info);
  Boolean value_existed = false;
  Boolean value_bool = CFPreferencesGetAppBooleanValue(
      key, kCFPreferencesCurrentApplication, &value_existed);
  CFRelease(key);

  if (!value_existed) {
    return Napi::Value();
  }

  return Napi::Value::From(info.Env(), CFBooleanToBool(value_bool));
}

Napi::Value IsPreferenceForced(const Napi::CallbackInfo &info) {
  if (info.Length() < 1) {
    throw Napi::Error::New(info.Env(),
                           "Missing 'key' argument to IsPreferenceForced()");
  }

  CFStringRef key = GetCFKeyFromArgs(info);
  Boolean is_forced =
      CFPreferencesAppValueIsForced(key, kCFPreferencesCurrentApplication);
  CFRelease(key);

  return Napi::Value::From(info.Env(), CFBooleanToBool(is_forced));
}

// Module bindings

Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "getString"),
              Napi::Function::New(env, GetString));
  exports.Set(Napi::String::New(env, "getInteger"),
              Napi::Function::New(env, GetInteger));
  exports.Set(Napi::String::New(env, "getBoolean"),
              Napi::Function::New(env, GetBoolean));

  exports.Set(Napi::String::New(env, "isPreferenceForced"),
              Napi::Function::New(env, IsPreferenceForced));

  return exports;
}

NODE_API_MODULE(cfprefs, Init)