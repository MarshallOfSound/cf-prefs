// Type definitions for cf-prefs
// Project: cf-prefs

export type CFPrefValue = boolean | string | number | { [key: string]: CFPrefValue } | Array<CFPrefValue>;
export function getPreferenceValue(key: string): CFPrefValue;

export function isPreferenceForced(key: string): boolean;
