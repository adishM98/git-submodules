/**
 * Nord theme for git-submodules TUI
 * Based on the Nord color palette: https://www.nordtheme.com/
 */

import { Theme } from '../state/types.js';

export const nordTheme: Theme = {
  name: 'nord',
  colors: {
    primary: '#88C0D0',      // Nord Frost (bright blue)
    success: '#A3BE8C',      // Nord Aurora (green)
    warning: '#EBCB8B',      // Nord Aurora (yellow)
    error: '#BF616A',        // Nord Aurora (red)
    info: '#81A1C1',         // Nord Frost (cyan)
    dim: '#4C566A',          // Nord Polar Night (gray)
    background: '#2E3440',   // Nord Polar Night (dark)
    text: '#ECEFF4',         // Nord Snow Storm (light)
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
    type: 'round',
  },
};
