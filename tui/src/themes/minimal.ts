/**
 * Minimal theme for git-submodules TUI
 * ASCII-only icons and monochrome colors
 */

import { Theme } from '../state/types.js';

export const minimalTheme: Theme = {
  name: 'minimal',
  colors: {
    primary: '#FFFFFF',      // White for selected items
    success: '#FFFFFF',      // White for clean repos
    warning: '#FFFFFF',      // White for dirty repos
    error: '#FFFFFF',        // White for conflicts/errors
    info: '#FFFFFF',         // White for info
    dim: '#808080',          // Gray for inactive items
    background: '#000000',   // Black background
    text: '#FFFFFF',         // White text
  },
  icons: {
    dirty: '*',
    clean: 'OK',
    ahead: '^',
    behind: 'v',
    conflict: 'X',
    branch: '>',
    staged: '+',
    unstaged: 'M',
    untracked: '?',
    repo: '#',
    submodule: '|-',
  },
  borders: {
    type: 'single',
  },
};
