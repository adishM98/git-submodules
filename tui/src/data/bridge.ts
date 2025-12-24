/**
 * Data Bridge - Connects Node.js TUI to zsh plugin functions
 *
 * This module executes zsh functions from the git-submodules plugin
 * and returns parsed JSON data.
 */

import { execSync } from 'child_process';
import { existsSync } from 'fs';
import { join } from 'path';
import { GitStatus, Repository } from '../state/types.js';

export class DataBridge {
  private pluginDir: string;
  private bridgeScript: string;

  constructor() {
    // Get plugin directory from environment or default
    this.pluginDir = process.env.GIT_SUBMODULES_PLUGIN_DIR || process.cwd();

    // Find bridge.zsh location based on installation method
    this.bridgeScript = this.findBridgeScript();
  }

  /**
   * Find bridge.zsh in either npm package or zsh plugin location
   */
  private findBridgeScript(): string {
    // Try npm package location first (bundled copy)
    const npmBridge = join(this.pluginDir, 'lib', 'bridge.zsh');
    if (existsSync(npmBridge)) {
      return npmBridge;
    }

    // Fallback to zsh plugin location
    const zshBridge = join(this.pluginDir, 'lib', 'tui', 'bridge.zsh');
    if (existsSync(zshBridge)) {
      return zshBridge;
    }

    throw new Error(
      'bridge.zsh not found. Ensure git-submodules-tui is properly installed.\n' +
      'Searched:\n' +
      `  - ${npmBridge} (npm install)\n` +
      `  - ${zshBridge} (zsh plugin)`
    );
  }

  /**
   * Fetch full git status (base + all submodules)
   */
  async fetchStatus(): Promise<GitStatus> {
    try {
      const script = `
        source ${this.bridgeScript}
        gsm_tui_status_json
      `;

      const output = execSync(`zsh -c '${script}'`, {
        encoding: 'utf-8',
        cwd: process.cwd(),
        stdio: ['pipe', 'pipe', 'pipe'],
      });

      const data = JSON.parse(output);

      // Transform to our TypeScript types
      return this.transformStatusData(data);
    } catch (error) {
      throw new Error(`Failed to fetch git status: ${(error as Error).message}`);
    }
  }

  /**
   * Fetch status for a single repository
   */
  async fetchRepoStatus(path: string): Promise<Repository> {
    try {
      const script = `
        source ${this.bridgeScript}
        gsm_tui_repo_status "${path}"
      `;

      const output = execSync(`zsh -c '${script}'`, {
        encoding: 'utf-8',
        cwd: process.cwd(),
      });

      return JSON.parse(output) as Repository;
    } catch (error) {
      throw new Error(`Failed to fetch repo status: ${(error as Error).message}`);
    }
  }

  /**
   * Transform raw JSON data to TypeScript types
   */
  private transformStatusData(data: any): GitStatus {
    return {
      timestamp: new Date().toISOString(),
      base: this.transformRepository(data.base || data),
      submodules: (data.submodules || []).map((sub: any) => this.transformRepository(sub)),
    };
  }

  /**
   * Transform repository data
   */
  private transformRepository(repo: any): Repository {
    return {
      name: repo.name || repo.path || 'unknown',
      path: repo.path || process.cwd(),
      branch: repo.branch || repo.current_branch || 'unknown',
      status: (repo.status === 'dirty' ? 'dirty' : 'clean') as 'clean' | 'dirty',
      ahead: parseInt(repo.ahead || '0', 10),
      behind: parseInt(repo.behind || '0', 10),
      staged: parseInt(repo.staged || repo.staged_files || '0', 10),
      unstaged: parseInt(repo.unstaged || repo.modified_files || '0', 10),
      untracked: parseInt(repo.untracked || repo.untracked_files || '0', 10),
      conflicts: parseInt(repo.conflicts || '0', 10),
      stashCount: parseInt(repo.stashCount || repo.stash_count || '0', 10),
      url: repo.url,
      lastCommit: repo.lastCommit
        ? {
            hash: repo.lastCommit.hash || '',
            message: repo.lastCommit.message || '',
            author: repo.lastCommit.author || '',
            date: repo.lastCommit.date || '',
          }
        : undefined,
    };
  }

  /**
   * Execute a git operation (for future interactivity)
   */
  async executeOperation(operation: string, repo: string, args: string[] = []): Promise<boolean> {
    try {
      const argsStr = args.join(' ');
      const script = `
        source ${this.pluginDir}/git-submodules.plugin.zsh
        cd "${repo}"
        ${operation} ${argsStr}
      `;

      execSync(`zsh -c '${script}'`, {
        encoding: 'utf-8',
        cwd: repo,
        stdio: 'inherit',
      });

      return true;
    } catch (error) {
      console.error(`Operation failed: ${(error as Error).message}`);
      return false;
    }
  }
}
