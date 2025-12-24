/**
 * Repository Item component
 */

import React from 'react';
import { Box, Text } from 'ink';
import { Repository, Theme } from '../state/types.js';

interface RepositoryItemProps {
  repository: Repository;
  isSelected: boolean;
  isBase: boolean;
  theme: Theme;
}

const RepositoryItem: React.FC<RepositoryItemProps> = ({
  repository,
  isSelected,
  isBase,
  theme,
}) => {
  // Determine status color
  const getStatusColor = () => {
    if (repository.conflicts > 0) return theme.colors.error;
    if (repository.status === 'dirty') return theme.colors.warning;
    return theme.colors.success;
  };

  // Status icon
  const getStatusIcon = () => {
    if (repository.conflicts > 0) return theme.icons.conflict;
    if (repository.status === 'dirty') return theme.icons.dirty;
    return theme.icons.clean;
  };

  // Ahead/behind indicators
  const getTrackingInfo = () => {
    const parts: string[] = [];
    if (repository.ahead > 0) {
      parts.push(`${theme.icons.ahead}${repository.ahead}`);
    }
    if (repository.behind > 0) {
      parts.push(`${theme.icons.behind}${repository.behind}`);
    }
    return parts.join(' ');
  };

  const statusColor = getStatusColor();
  const textColor = isSelected ? theme.colors.primary : theme.colors.text;
  const prefix = isBase ? theme.icons.repo : theme.icons.submodule;

  return (
    <Box>
      {/* Selection indicator */}
      <Text color={isSelected ? theme.colors.primary : theme.colors.dim}>
        {isSelected ? '► ' : '  '}
      </Text>

      {/* Repo icon/prefix */}
      <Text color={textColor}>{prefix} </Text>

      {/* Repo name */}
      <Box width={30}>
        <Text bold={isSelected} color={textColor}>
          {repository.name}
        </Text>
      </Box>

      {/* Branch */}
      <Box width={20} marginLeft={1}>
        <Text color={theme.colors.info}>
          {theme.icons.branch} {repository.branch}
        </Text>
      </Box>

      {/* Status */}
      <Box width={8} marginLeft={1}>
        <Text color={statusColor}>
          {getStatusIcon()}
          {repository.staged + repository.unstaged + repository.untracked > 0 &&
            ` ${repository.staged + repository.unstaged + repository.untracked}`}
        </Text>
      </Box>

      {/* Tracking info */}
      {getTrackingInfo() && (
        <Box marginLeft={1}>
          <Text color={theme.colors.dim}>{getTrackingInfo()}</Text>
        </Box>
      )}
    </Box>
  );
};

export default RepositoryItem;
