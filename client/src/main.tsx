import { createRoot } from "react-dom/client";
// import App from "./App";
import SimpleApp from "./SimpleApp";
import "./index.css";
import { ThemeProvider } from "next-themes";

console.log('🚀 AFL Fantasy Platform: Starting React render');

const rootElement = document.getElementById("root");

if (!rootElement) {
  console.error('❌ Root element not found!');
  document.body.innerHTML = '<div style="color: red; padding: 20px;">ERROR: Root element not found!</div>';
} else {
  try {
    createRoot(rootElement).render(
      <ThemeProvider attribute="class" defaultTheme="light">
        <SimpleApp />
      </ThemeProvider>
    );
    
    console.log('✅ AFL Fantasy Platform: React app rendered successfully');
    
  } catch (error) {
    console.error('💥 React render failed:', error);
    rootElement.innerHTML = `<div style="color: red; padding: 20px; font-family: monospace;">
      <h2>🚨 AFL Fantasy Platform Error</h2>
      <p>React render failed: ${error.message}</p>
      <p>Check the console for more details.</p>
    </div>`;
  }
}
