#!/usr/bin/env node
/**
 * Simple Documentation Server
 * Serves OpenAPI spec at /docs with Swagger UI
 */

import express from 'express';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.DOCS_PORT || 3001;

// Serve static files
app.use(express.static('public'));

// OpenAPI spec endpoint
app.get('/openapi.yaml', (req, res) => {
  const specPath = path.join(__dirname, 'docs', 'openapi.yaml');
  if (fs.existsSync(specPath)) {
    res.setHeader('Content-Type', 'text/yaml');
    res.sendFile(specPath);
  } else {
    res.status(404).json({ error: 'OpenAPI spec not found' });
  }
});

app.get('/openapi.json', (req, res) => {
  const specPath = path.join(__dirname, 'docs', 'openapi.yaml');
  if (fs.existsSync(specPath)) {
    try {
      // For a simple server, we'll serve YAML as JSON isn't directly available
      // In production, you'd use a proper YAML to JSON converter
      res.setHeader('Content-Type', 'application/json');
      res.json({ 
        message: 'Use /openapi.yaml for the specification',
        spec_url: '/openapi.yaml',
        swagger_ui: '/docs'
      });
    } catch (error) {
      res.status(500).json({ error: 'Failed to process spec' });
    }
  } else {
    res.status(404).json({ error: 'OpenAPI spec not found' });
  }
});

// Simple Swagger UI page
app.get('/docs', (req, res) => {
  const html = `
<!DOCTYPE html>
<html>
<head>
    <title>AFL Fantasy API Documentation</title>
    <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@3.52.5/swagger-ui.css" />
    <style>
        html { box-sizing: border-box; overflow: -moz-scrollbars-vertical; overflow-y: scroll; }
        *, *:before, *:after { box-sizing: inherit; }
        body { margin:0; background: #fafafa; }
    </style>
</head>
<body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist@3.52.5/swagger-ui-bundle.js"></script>
    <script src="https://unpkg.com/swagger-ui-dist@3.52.5/swagger-ui-standalone-preset.js"></script>
    <script>
    window.onload = function() {
        const ui = SwaggerUIBundle({
            url: '/openapi.yaml',
            dom_id: '#swagger-ui',
            deepLinking: true,
            presets: [
                SwaggerUIBundle.presets.apis,
                SwaggerUIStandalonePreset
            ],
            plugins: [
                SwaggerUIBundle.plugins.DownloadUrl
            ],
            layout: "StandaloneLayout"
        });
    }
    </script>
</body>
</html>`;
  res.send(html);
});

// API info endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'AFL Fantasy API Documentation Server',
    version: '1.0.0',
    endpoints: {
      docs: '/docs',
      openapi_yaml: '/openapi.yaml',
      openapi_json: '/openapi.json'
    },
    generated_client: {
      swift: 'ios/Generated/ApiClient/',
      package_swift: 'ios/Generated/ApiClient/Package.swift'
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`📚 AFL Fantasy API Documentation Server running on port ${PORT}`);
  console.log(`🔗 Documentation: http://localhost:${PORT}/docs`);
  console.log(`📄 OpenAPI Spec: http://localhost:${PORT}/openapi.yaml`);
  console.log(`📱 Generated Swift Client: ios/Generated/ApiClient/`);
});

export default app;
