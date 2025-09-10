import { Loader2 } from "lucide-react";

export const LoadingSpinner = () => (
  <div className="flex flex-col items-center justify-center min-h-[200px]">
    <Loader2 className="h-8 w-8 animate-spin text-primary mb-4" />
    <p className="text-gray-600 dark:text-gray-400">
      Loading data...
    </p>
  </div>
);
