// Type definitions for cf-prefs
// Project: cf-prefs

export function getPreferenceValue(key: string, type: 'string'): string | undefined;
export function getPreferenceValue(key: string, type: 'string', defaultValue: string): string;
export function getPreferenceValue(key: string, type: 'integer'): number | undefined;
export function getPreferenceValue(key: string, type: 'integer', defaultValue: number): number;
export function getPreferenceValue(key: string, type: 'boolean'): boolean | undefined;
export function getPreferenceValue(key: string, type: 'boolean', defaultValue: boolean): boolean;

export function isPreferenceForced(key: string): boolean;
