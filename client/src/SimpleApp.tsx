import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

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
      <div style={{ 
        padding: '20px', 
        backgroundColor: '#1f2937', 
        color: 'white', 
        minHeight: '100vh',
        fontFamily: 'system-ui, -apple-system, sans-serif'
      }}>
        <h1 style={{ fontSize: '2rem', marginBottom: '1rem' }}>
          🏈 AFL Fantasy Platform
        </h1>
        <p style={{ marginBottom: '1rem' }}>
          React app is working! The server is running correctly.
        </p>
        <div style={{
          backgroundColor: '#374151',
          padding: '1rem',
          borderRadius: '0.5rem',
          marginBottom: '1rem'
        }}>
          <h2 style={{ fontSize: '1.25rem', marginBottom: '0.5rem' }}>System Status</h2>
          <p>✅ React: OK</p>
          <p>✅ TypeScript: OK</p>
          <p>✅ Vite: OK</p>
          <p>⏳ Full app components: Loading...</p>
        </div>
        <p style={{ color: '#9ca3af' }}>
          Time: {new Date().toLocaleString()}
        </p>
      </div>
    </QueryClientProvider>
  );
}

export default SimpleApp;
