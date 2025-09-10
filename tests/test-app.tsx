import { createRoot } from "react-dom/client";

function TestApp() {
  return (
    <div style={{ padding: '20px', backgroundColor: '#1f2937', color: 'white', minHeight: '100vh' }}>
      <h1>🏈 AFL Fantasy Test App</h1>
      <p>If you can see this, React is working!</p>
      <p>Current time: {new Date().toLocaleString()}</p>
    </div>
  );
}

const rootElement = document.getElementById("root");
if (rootElement) {
  createRoot(rootElement).render(<TestApp />);
} else {
  console.error("Root element not found!");
}
