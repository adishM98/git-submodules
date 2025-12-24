#!/usr/bin/env node

/**
 * git-submodules TUI launcher
 *
 * This is the entry point for the TUI. It sets up the environment
 * and launches the main Ink application.
 */

import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { spawn } from 'child_process';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Detect installation context
const isNpmGlobal = !process.env.GIT_SUBMODULES_PLUGIN_DIR;
const isDev = process.env.NODE_ENV === 'development';

// Set plugin directory based on installation method
if (isNpmGlobal) {
  // Running from npm global install
  // Point to npm package directory (parent of bin/)
  process.env.GIT_SUBMODULES_PLUGIN_DIR = join(__dirname, '..');
} else {
  // Running from zsh plugin
  // GIT_SUBMODULES_PLUGIN_DIR is already set by launcher.zsh
  // Keep existing value
}

const entryPoint = isDev
  ? join(__dirname, '..', 'src', 'index.tsx')
  : join(__dirname, '..', 'dist', 'index.js');

// In development, use tsx to run TypeScript directly
if (isDev) {
  const tsx = spawn('npx', ['tsx', entryPoint], {
    stdio: 'inherit',
    env: process.env
  });

  tsx.on('exit', (code) => {
    process.exit(code || 0);
  });
} else {
  // In production, import and run the compiled JavaScript
  import(entryPoint).catch((err) => {
    console.error('Failed to start TUI:', err.message);
    process.exit(1);
  });
}
