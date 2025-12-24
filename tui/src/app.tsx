/**
 * Main App component for git-submodules TUI
 */

import React, { useState } from 'react';
import { Box, Text, useApp, useInput } from 'ink';
import { getTheme, getNextTheme } from './themes/index.js';
import { useGitData } from './hooks/useGitData.js';
import StatusDashboard from './components/StatusDashboard.js';

const App: React.FC = () => {
  const { exit } = useApp();
  const [currentTheme, setCurrentTheme] = useState<'dark' | 'light' | 'nord' | 'minimal'>('dark');
  const [selectedIndex, setSelectedIndex] = useState(0);
  const [isHelpVisible, setIsHelpVisible] = useState(false);

  // Fetch git data with auto-refresh every 2 seconds
  const { data, isLoading, error, refresh } = useGitData(2000);

  const theme = getTheme(currentTheme);

  // Handle keyboard input
  useInput((input: string, key: any) => {
    // Quit
    if (input === 'q' || key.escape) {
      exit();
      return;
    }

    // Cycle themes
    if (input === 't') {
      setCurrentTheme(getNextTheme(currentTheme));
      return;
    }

    // Toggle help
    if (input === 'h' || input === '?') {
      setIsHelpVisible((prev) => !prev);
      return;
    }

    // Manual refresh
    if (input === 'r') {
      refresh();
      return;
    }

    // Navigation (up/down)
    if (key.upArrow || input === 'k') {
      setSelectedIndex((prev) => Math.max(0, prev - 1));
      return;
    }

    if (key.downArrow || input === 'j') {
      const maxIndex = data ? data.submodules.length : 0; // base + submodules
      setSelectedIndex((prev) => Math.min(maxIndex, prev + 1));
      return;
    }
  });

  // Loading state
  if (isLoading && !data) {
    return (
      <Box flexDirection="column" padding={1}>
        <Box borderStyle={theme.borders.type} borderColor={theme.colors.info} paddingX={2}>
          <Text bold color={theme.colors.info}>
            {theme.icons.repo} git-submodules TUI
          </Text>
        </Box>
        <Box marginY={1}>
          <Text color={theme.colors.info}>Loading repository data...</Text>
        </Box>
      </Box>
    );
  }

  // Error state
  if (error || !data) {
    return (
      <Box flexDirection="column" padding={1}>
        <Box borderStyle={theme.borders.type} borderColor={theme.colors.error} paddingX={2}>
          <Text bold color={theme.colors.error}>
            {theme.icons.conflict} Error
          </Text>
        </Box>
        <Box marginY={1} flexDirection="column">
          <Text color={theme.colors.error}>Failed to load git data:</Text>
          <Text color={theme.colors.dim}>{error || 'Unknown error'}</Text>
          <Box marginTop={1}>
            <Text>Press 'r' to retry or 'q' to quit</Text>
          </Box>
        </Box>
      </Box>
    );
  }

  // Main dashboard
  return (
    <StatusDashboard
      data={data}
      selectedIndex={selectedIndex}
      theme={theme}
      isHelpVisible={isHelpVisible}
    />
  );
};

export default App;
