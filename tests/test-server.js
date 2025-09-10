import express from 'express';
import path from 'path';

const app = express();
const PORT = 5003;

// Simple test endpoint
app.get('/test', (req, res) => {
  res.json({ status: 'Server is working!', time: new Date().toISOString() });
});

// Serve static HTML for testing
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
        <title>AFL Fantasy Platform - Test</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
    </head>
    <body style="font-family: sans-serif; padding: 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; min-height: 100vh; margin: 0;">
        <div style="max-width: 800px; margin: 0 auto; text-align: center;">
            <h1>🏆 AFL Fantasy Platform</h1>
            <h2>✅ Server is Running!</h2>
            <p>This is a test page to verify the server setup.</p>
            <p>Time: ${new Date().toLocaleString()}</p>
            <div style="background: rgba(255,255,255,0.1); padding: 20px; border-radius: 10px; margin: 20px 0;">
                <h3>Next Steps:</h3>
                <p>• Verify React app compilation</p>
                <p>• Check Vite middleware setup</p>
                <p>• Test API endpoints</p>
            </div>
            <a href="/test" style="display: inline-block; background: rgba(255,255,255,0.2); padding: 10px 20px; border-radius: 5px; color: white; text-decoration: none; margin: 10px;">Test API</a>
        </div>
    </body>
    </html>
  `);
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Test server running at http://localhost:${PORT}`);
  console.log(`📡 Test API at http://localhost:${PORT}/test`);
});
