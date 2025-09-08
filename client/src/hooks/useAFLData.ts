import { useQuery } from "@tanstack/react-query";

const BASE_URL = 'http://localhost:5173/api';

interface UseAFLDataOptions {
  enabled?: boolean;
  refetchInterval?: number | false;
  onSuccess?: (data: any) => void;
  onError?: (error: Error) => void;
}

export const useAFLData = (endpoint: string, options: UseAFLDataOptions = {}) => {
  const { enabled = true, refetchInterval = false, onSuccess, onError } = options;

  return useQuery({
    queryKey: [endpoint],
    queryFn: async () => {
      const response = await fetch(`${BASE_URL}${endpoint}`);
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.json();
    },
    enabled,
    refetchInterval,
    onSuccess,
    onError,
  });
};
