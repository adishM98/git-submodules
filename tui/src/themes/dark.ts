/**
 * Dark theme for git-submodules TUI
 */

import { Theme } from '../state/types.js';

export const darkTheme: Theme = {
  name: 'dark',
  colors: {
    primary: '#61AFEF',      // Bright blue for selected items
    success: '#98C379',      // Green for clean repos
    warning: '#E5C07B',      // Yellow for dirty repos
    error: '#E06C75',        // Red for conflicts/errors
    info: '#56B6C2',         // Cyan for info
    dim: '#5C6370',          // Gray for inactive items
    background: '#282C34',   // Dark background
    text: '#ABB2BF',         // Light gray text
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
