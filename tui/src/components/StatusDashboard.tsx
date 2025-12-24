/**
 * Status Dashboard - Main TUI view
 */

import React from 'react';
import { Box, Text } from 'ink';
import { GitStatus, Theme } from '../state/types.js';
import Header from './Header.js';
import RepositoryList from './RepositoryList.js';
import HelpPanel from './HelpPanel.js';

interface StatusDashboardProps {
  data: GitStatus;
  selectedIndex: number;
  theme: Theme;
  isHelpVisible: boolean;
}

const StatusDashboard: React.FC<StatusDashboardProps> = ({
  data,
  selectedIndex,
  theme,
  isHelpVisible,
}) => {
  // Combine base and submodules for display
  const allRepos = [data.base, ...data.submodules];

  return (
    <Box flexDirection="column" padding={1}>
      <Header theme={theme} currentRepo={data.base.name} />

      <Box marginY={1}>
        <RepositoryList
          repositories={allRepos}
          selectedIndex={selectedIndex}
          theme={theme}
          isBaseRepo={(index) => index === 0}
        />
      </Box>

      {isHelpVisible && <HelpPanel theme={theme} />}

      <Box marginTop={1} borderStyle="single" borderColor={theme.colors.dim} paddingX={2}>
        <Box>
          {/* Operations shortcuts */}
          <Box marginRight={2}>
            <Text color={theme.colors.dim}>[r]efresh</Text>
          </Box>
          <Box marginRight={2}>
            <Text color={theme.colors.dim}>[t]heme</Text>
          </Box>
          <Box marginRight={2}>
            <Text color={theme.colors.dim}>[h]elp</Text>
          </Box>
          <Box>
            <Text color={theme.colors.dim}>[q]uit</Text>
          </Box>
        </Box>
      </Box>
    </Box>
  );
};

export default StatusDashboard;
