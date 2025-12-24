/**
 * Theme loader and manager
 */

import { Theme, ThemeName } from '../state/types.js';
import { darkTheme } from './dark.js';
import { lightTheme } from './light.js';
import { nordTheme } from './nord.js';
import { minimalTheme } from './minimal.js';

const themes: Record<ThemeName, Theme> = {
  dark: darkTheme,
  light: lightTheme,
  nord: nordTheme,
  minimal: minimalTheme,
};

export function getTheme(name: ThemeName): Theme {
  return themes[name] || themes.dark;
}

export function getAllThemes(): Theme[] {
  return Object.values(themes);
}

export function getNextTheme(current: ThemeName): ThemeName {
  const themeNames: ThemeName[] = ['dark', 'light', 'nord', 'minimal'];
  const currentIndex = themeNames.indexOf(current);
  const nextIndex = (currentIndex + 1) % themeNames.length;
  return themeNames[nextIndex];
}

export { darkTheme, lightTheme, nordTheme, minimalTheme };
