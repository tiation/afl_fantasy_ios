import React from 'react';
import { AlertOctagon } from 'lucide-react';

export const ErrorFallback = ({ error, resetErrorBoundary }: { error: Error, resetErrorBoundary: () => void }) => {
  return (
    <div className="min-h-[200px] flex flex-col items-center justify-center text-center p-6 space-y-4 bg-red-50 dark:bg-red-900/20 rounded-xl border border-red-200 dark:border-red-800">
      <AlertOctagon className="h-8 w-8 text-red-500" />
      <div>
        <h3 className="text-lg font-semibold text-red-700 dark:text-red-400 mb-2">
          Something went wrong
        </h3>
        <p className="text-sm text-red-600 dark:text-red-300 mb-4">
          {error.message}
        </p>
        <button
          onClick={resetErrorBoundary}
          className="px-4 py-2 bg-red-100 dark:bg-red-900 text-red-700 dark:text-red-300 rounded-lg hover:bg-red-200 dark:hover:bg-red-800 transition-colors"
        >
          Try again
        </button>
      </div>
    </div>
  );
};
