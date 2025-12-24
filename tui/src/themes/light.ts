/**
 * Light theme for git-submodules TUI
 */

import { Theme } from '../state/types.js';

export const lightTheme: Theme = {
  name: 'light',
  colors: {
    primary: '#0184BC',      // Bright blue for selected items
    success: '#50A14F',      // Dark green for clean repos
    warning: '#C18401',      // Dark yellow for dirty repos
    error: '#E45649',        // Red for conflicts/errors
    info: '#0997B3',         // Cyan for info
    dim: '#A0A1A7',          // Gray for inactive items
    background: '#FAFAFA',   // Light background
    text: '#383A42',         // Dark gray text
  },
  icons: {
    dirty: '●',
    clean: '✓',
    ahead: '▲',
    behind: '▼',
    conflict: '✗',
    branch: '',
    staged: '+',
    unstaged: 'M',
    untracked: '?',
    repo: '📦',
    submodule: '├─',
  },
  borders: {
    type: 'single',
  },
};
