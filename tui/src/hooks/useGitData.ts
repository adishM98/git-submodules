/**
 * Custom hook for fetching git data
 */

import { useState, useEffect, useCallback } from 'react';
import { GitStatus } from '../state/types.js';
import { DataBridge } from '../data/bridge.js';

interface UseGitDataResult {
  data: GitStatus | null;
  isLoading: boolean;
  error: string | null;
  refresh: () => Promise<void>;
}

export function useGitData(refreshInterval: number = 2000): UseGitDataResult {
  const [data, setData] = useState<GitStatus | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  const bridge = new DataBridge();

  const refresh = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);
      const status = await bridge.fetchStatus();
      setData(status);
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Initial load
  useEffect(() => {
    refresh();
  }, [refresh]);

  // Auto-refresh
  useEffect(() => {
    if (refreshInterval <= 0) return;

    const interval = setInterval(refresh, refreshInterval);
    return () => clearInterval(interval);
  }, [refresh, refreshInterval]);

  return { data, isLoading, error, refresh };
}
