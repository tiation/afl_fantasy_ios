import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import AFLFantasyDashboardImproved from "./components/AFLFantasyDashboard_improved";

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
      <AFLFantasyDashboardImproved />
    </QueryClientProvider>
  );
}

export default SimpleApp;
