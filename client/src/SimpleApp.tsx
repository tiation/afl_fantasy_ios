import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import WorkingDashboard from "./components/WorkingDashboard";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: false,
    },
  },
});

function SimpleApp() {
  return (
    <QueryClientProvider client={queryClient}>
      <WorkingDashboard />
    </QueryClientProvider>
  );
}

export default SimpleApp;
