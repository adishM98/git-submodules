/**
 * Help Panel component
 */

import React from 'react';
import { Box, Text } from 'ink';
import { Theme } from '../state/types.js';

interface HelpPanelProps {
  theme: Theme;
}

const HelpPanel: React.FC<HelpPanelProps> = ({ theme }) => {
  return (
    <Box
      marginY={1}
      borderStyle={theme.borders.type}
      borderColor={theme.colors.info}
      paddingX={2}
      paddingY={1}
      flexDirection="column"
    >
      <Text bold color={theme.colors.info}>
        Keyboard Shortcuts:
      </Text>
      <Box marginTop={1} flexDirection="column">
        <Text>  ↑/k - Move selection up</Text>
        <Text>  ↓/j - Move selection down</Text>
        <Text>  r - Refresh data</Text>
        <Text>  t - Cycle themes (dark → light → nord → minimal)</Text>
        <Text>  h/? - Toggle this help</Text>
        <Text>  q/Esc - Quit</Text>
      </Box>
    </Box>
  );
};

export default HelpPanel;
