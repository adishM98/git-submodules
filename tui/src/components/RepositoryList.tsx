/**
 * Repository List component
 */

import React from 'react';
import { Box } from 'ink';
import { Repository, Theme } from '../state/types.js';
import RepositoryItem from './RepositoryItem.js';

interface RepositoryListProps {
  repositories: Repository[];
  selectedIndex: number;
  theme: Theme;
  isBaseRepo: (index: number) => boolean;
}

const RepositoryList: React.FC<RepositoryListProps> = ({
  repositories,
  selectedIndex,
  theme,
  isBaseRepo,
}) => {
  return (
    <Box
      borderStyle={theme.borders.type}
      borderColor={theme.colors.dim}
      paddingX={2}
      paddingY={1}
      flexDirection="column"
    >
      {repositories.map((repo, index) => (
        <RepositoryItem
          key={repo.path}
          repository={repo}
          isSelected={index === selectedIndex}
          isBase={isBaseRepo(index)}
          theme={theme}
        />
      ))}
    </Box>
  );
};

export default RepositoryList;
