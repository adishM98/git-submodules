/**
 * TypeScript type definitions for git-submodules TUI
 */

export interface GitStatus {
  timestamp: string;
  base: Repository;
  submodules: Repository[];
}

export interface Repository {
  name: string;
  path: string;
  branch: string;
  status: 'clean' | 'dirty';
  ahead: number;
  behind: number;
  staged: number;
  unstaged: number;
  untracked: number;
  conflicts: number;
  stashCount: number;
  url?: string;
  lastCommit?: Commit;
}

export interface Commit {
  hash: string;
  message: string;
  author: string;
  date: string;
}

export interface FileChange {
  path: string;
  status: 'added' | 'modified' | 'deleted' | 'untracked';
}

export type ThemeName = 'dark' | 'light' | 'nord' | 'minimal';

export interface Theme {
  name: ThemeName;
  colors: {
    primary: string;
    success: string;
    warning: string;
    error: string;
    info: string;
    dim: string;
    background: string;
    text: string;
  };
  icons: {
    dirty: string;
    clean: string;
    ahead: string;
    behind: string;
    conflict: string;
    branch: string;
    staged: string;
    unstaged: string;
    untracked: string;
    repo: string;
    submodule: string;
  };
  borders: {
    type: 'single' | 'double' | 'round' | 'bold';
  };
}

export interface AppConfig {
  theme: ThemeName;
  refreshInterval: number; // milliseconds
  keyBindings?: Record<string, string>;
}

export interface AppState {
  gitData: GitStatus | null;
  selectedIndex: number;
  currentTheme: ThemeName;
  isHelpVisible: boolean;
  isLoading: boolean;
  error: string | null;
  lastRefresh: Date | null;
}
