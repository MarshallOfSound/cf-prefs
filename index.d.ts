// Type definitions for cf-prefs
// Project: cf-prefs

export type CFPrefValue = boolean | number | string | Array<CFPrefValue> | Record<string, CFPrefValue> | undefined;
export function getPreferenceValue(key: string): CFPrefValue;

export function isPreferenceForced(key: string): boolean;
