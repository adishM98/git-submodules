#!/usr/bin/env node

/**
 * Main entry point for git-submodules TUI
 */

import React from 'react';
import { render } from 'ink';
import App from './app.js';

// Render the app
const { waitUntilExit } = render(<App />);

// Wait for app to exit
waitUntilExit().catch((error: Error) => {
  console.error('TUI crashed:', error);
  process.exit(1);
});
