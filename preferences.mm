#include <napi.h>

#import <Foundation/Foundation.h>

// CF Converters

struct PropertyObjectContext {
  Napi::Env *env;
  Napi::Object *obj;
};
typedef struct PropertyObjectContext PropertyObjectContext;
struct PropertyArrayContext {
  Napi::Env *env;
  Napi::Array *array;
  int i;
};
typedef struct PropertyArrayContext PropertyArrayContext;

// Forward decl
Napi::Value PropertyToValue(Napi::Env env, CFPropertyListRef property);

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

// Callback function for CFDictionaryApplyFunction. |key| and |value| are an
// entry of the CFDictionary that should be converted into an equivalent entry
// in the DictionaryValue in |context|.
void DictionaryEntryToValue(const void *key, const void *value, void *context) {
  if (CFGetTypeID(key) == CFStringGetTypeID()) {
    CFStringRef cf_key = reinterpret_cast<CFStringRef>(key);
    PropertyObjectContext *property_ctx =
        static_cast<PropertyObjectContext *>(context);
    Napi::Value converted = PropertyToValue(
        *property_ctx->env, static_cast<CFPropertyListRef>(value));
    if (converted) {
      const std::string string = CFStringToStdString(cf_key);
      property_ctx->obj->Set(string, std::move(converted));
    }
  }
}

// Callback function for CFArrayApplyFunction. |value| is an entry of the
// CFArray that should be converted into an equivalent entry in the ListValue
// in |context|.
void ArrayEntryToValue(const void *value, void *context) {
  PropertyArrayContext *array_ctx =
      static_cast<PropertyArrayContext *>(context);
  Napi::Value converted =
      PropertyToValue(*array_ctx->env, static_cast<CFPropertyListRef>(value));
  if (converted) {
    (*array_ctx->array)[array_ctx->i++] = converted;
  }
}

Napi::Value PropertyToValue(Napi::Env env, CFPropertyListRef property) {
  CFTypeID prop_type_id = CFGetTypeID(property);

  if (prop_type_id == CFNullGetTypeID())
    return Napi::Value();

  if (prop_type_id == CFBooleanGetTypeID()) {
    CFBooleanRef boolean = reinterpret_cast<CFBooleanRef>(property);
    return Napi::Value::From(env,
                             static_cast<bool>(CFBooleanGetValue(boolean)));
  }

  if (prop_type_id == CFNumberGetTypeID()) {
    CFNumberRef number = reinterpret_cast<CFNumberRef>(property);
    // CFNumberGetValue() converts values implicitly when the conversion is not
    // lossy. Check the type before trying to convert.
    if (CFNumberIsFloatType(number)) {
      double double_value = 0.0;
      if (CFNumberGetValue(number, kCFNumberDoubleType, &double_value)) {
        return Napi::Value::From(env, double_value);
      }
    } else {
      int int_value = 0;
      if (CFNumberGetValue(number, kCFNumberIntType, &int_value)) {
        return Napi::Value::From(env, int_value);
      }
    }
  }

  if (prop_type_id == CFStringGetTypeID()) {
    CFStringRef string = reinterpret_cast<CFStringRef>(property);
    return Napi::Value::From(env, CFStringToStdString(string));
  }

  if (prop_type_id == CFDictionaryGetTypeID()) {
    CFDictionaryRef dict = reinterpret_cast<CFDictionaryRef>(property);
    Napi::Object obj = Napi::Object::New(env);
    PropertyObjectContext ctx;
    ctx.env = &env;
    ctx.obj = &obj;
    CFDictionaryApplyFunction(dict, DictionaryEntryToValue, &ctx);
    return obj;
  }

  if (prop_type_id == CFArrayGetTypeID()) {
    CFArrayRef cf_array = reinterpret_cast<CFArrayRef>(property);
    int array_size = CFArrayGetCount(cf_array);
    Napi::Array array = Napi::Array::New(env, array_size);
    PropertyArrayContext ctx;
    ctx.env = &env;
    ctx.array = &array;
    ctx.i = 0;
    CFArrayApplyFunction(cf_array, CFRangeMake(0, array_size),
                         ArrayEntryToValue, &ctx);
    return array;
  }

  return Napi::Value();
}

// Preference getters

CFStringRef GetCFKeyFromArgs(const Napi::CallbackInfo &info) {
  if (info.Length() < 1) {
    throw Napi::Error::New(info.Env(), "Missing 'key' argument to GetValue()");
  }

  if (!info[0].IsString()) {
    throw Napi::Error::New(
        info.Env(),
        "Invalid argument 'key' to GetValue(), string was expected");
  }

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

CFStringRef GetCFApplicationIDFromArgs(const Napi::CallbackInfo &info) {
#ifdef ALLOW_APPLICATION_ID
  if (info.Length() < 2) {
    return kCFPreferencesCurrentApplication;
  }

  Napi::String app_id(info.Env(), info[1]);
  CFStringRef app_id_str = CFStringCreateWithCString(
      NULL, app_id.Utf8Value().c_str(), kCFStringEncodingUTF8);

  return app_id_str == NULL ? kCFPreferencesCurrentApplication : app_id_str;
#else
  return kCFPreferencesCurrentApplication;
#endif
}

Napi::Value GetValue(const Napi::CallbackInfo &info) {
  CFStringRef key = GetCFKeyFromArgs(info);
  CFStringRef app_id = GetCFApplicationIDFromArgs(info);
  CFPropertyListRef property_list = CFPreferencesCopyAppValue(key, app_id);
  CFRelease(key);

  if (!property_list) {
    return Napi::Value();
  }

  Napi::Value value = PropertyToValue(info.Env(), property_list);
  CFRelease(property_list);

  return value;
}

Napi::Value IsPreferenceForced(const Napi::CallbackInfo &info) {
  if (info.Length() < 1) {
    throw Napi::Error::New(info.Env(),
                           "Missing 'key' argument to IsPreferenceForced()");
  }

  CFStringRef key = GetCFKeyFromArgs(info);
  CFStringRef app_id = GetCFApplicationIDFromArgs(info);
  Boolean is_forced = CFPreferencesAppValueIsForced(key, app_id);
  CFRelease(key);

  return Napi::Value::From(info.Env(), CFBooleanToBool(is_forced));
}

// Module bindings

Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "getValue"),
              Napi::Function::New(env, GetValue));

  exports.Set(Napi::String::New(env, "isPreferenceForced"),
              Napi::Function::New(env, IsPreferenceForced));

  return exports;
}

NODE_API_MODULE(cfprefs, Init)