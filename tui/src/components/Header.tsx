/**
 * Header component
 */

import React from 'react';
import { Box, Text } from 'ink';
import { Theme } from '../state/types.js';

interface HeaderProps {
  theme: Theme;
  currentRepo: string;
}

const Header: React.FC<HeaderProps> = ({ theme, currentRepo }) => {
  return (
    <Box
      borderStyle={theme.borders.type}
      borderColor={theme.colors.primary}
      paddingX={2}
      justifyContent="space-between"
    >
      <Box>
        <Text bold color={theme.colors.primary}>
          {theme.icons.repo} git-submodules TUI
        </Text>
        <Text dimColor> │ </Text>
        <Text color={theme.colors.text}>{currentRepo}</Text>
      </Box>
      <Text color={theme.colors.dim}>[Theme: {theme.name}]</Text>
    </Box>
  );
};

export default Header;
