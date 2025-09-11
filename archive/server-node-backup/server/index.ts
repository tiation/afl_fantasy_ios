import express, { type Request, Response, NextFunction } from "express";
import { registerRoutes } from "./routes";
import { setupVite, serveStatic, log } from "./vite";
import { metricsMiddleware, healthCheck, metricsEndpoint } from "./middleware/metrics.js";
import { registerDockerControlRoutes } from './docker-control';
import path from "path";
import { fileURLToPath } from "url";
import dotenv from "dotenv";

// Load environment variables
dotenv.config();

// ✅ Fix __dirname for ES module scope
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

// ✅ Serve your CSV file
app.use('/data', express.static(path.join(__dirname, '../data')));

// ✅ Serve guernsey images
app.use('/guernseys', express.static(path.join(__dirname, '../public/guernseys')));

// ✅ Serve dashboard assets statically
app.use('/dashboards/assets', express.static(path.join(__dirname, '../dashboards/assets'), {
  maxAge: '1d',
  etag: true
}));

// ✅ Serve other dashboard files
app.use('/dashboards', express.static(path.join(__dirname, '../dashboards'), {
  index: false,
  dotfiles: 'deny'
}));

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// Enterprise monitoring middleware
app.use(metricsMiddleware);

// Health and metrics endpoints
app.get('/api/health', healthCheck);
app.get('/metrics', metricsEndpoint);

// Serve new consolidated dashboard
app.get('/dashboard', (req, res) => {
  res.sendFile(path.join(__dirname, '../dashboards/index.html'));
});

// Static routes disabled in development - Vite will handle these
// app.get('/', (req, res) => {
//   const clientIndex = app.get("env") === "development"
//     ? path.join(__dirname, '../client/index.html')
//     : path.join(__dirname, '../dist/public/index.html');
//   res.sendFile(clientIndex);
// });

// app.get(/^(?!\/(api|metrics|dashboards|data|guernseys)\b).*/, (req, res) => {
//   const clientIndex = app.get("env") === "development"
//     ? path.join(__dirname, '../client/index.html')
//     : path.join(__dirname, '../dist/public/index.html');
//   res.sendFile(clientIndex);
// });

// Legacy dashboard redirects with deprecation notice
app.get('/status', (req, res) => {
  res.redirect(301, '/dashboard');
});

app.get('/debug-status', (req, res) => {
  res.redirect(301, '/dashboard#debug');
});

app.get('/simple-status', (req, res) => {
  res.redirect(301, '/dashboard');
});

// Legacy file access (for backwards compatibility)
app.get('/legacy-debug', (req, res) => {
  res.sendFile(path.join(__dirname, '../debug-status.html'));
});

app.get('/legacy-simple', (req, res) => {
  res.sendFile(path.join(__dirname, '../simple-status.html'));
});

app.use((req, res, next) => {
  const start = Date.now();
  const path = req.path;
  let capturedJsonResponse: Record<string, any> | undefined = undefined;

  const originalResJson = res.json;
  res.json = function (bodyJson, ...args) {
    capturedJsonResponse = bodyJson;
    return originalResJson.apply(res, [bodyJson, ...args]);
  };

  res.on("finish", () => {
    const duration = Date.now() - start;
    if (path.startsWith("/api")) {
      let logLine = `${req.method} ${path} ${res.statusCode} in ${duration}ms`;
      if (capturedJsonResponse) {
        logLine += ` :: ${JSON.stringify(capturedJsonResponse)}`;
      }

      if (logLine.length > 80) {
        logLine = logLine.slice(0, 79) + "…";
      }

      log(logLine);
    }
  });

  next();
});

// Register all routes
(async () => {
  // Register Docker control API first
  registerDockerControlRoutes(app);
  // These routes need to be registered BEFORE Vite middleware
  // to prevent Vite from intercepting them
  
  const server = await registerRoutes(app);

  app.use((err: any, _req: Request, res: Response, _next: NextFunction) => {
    const status = err.status || err.statusCode || 500;
    const message = err.message || "Internal Server Error";

    log(`Error occurred: ${message}`);
    res.status(status).json({ message });
  });

  if (app.get("env") === "development") {
    try {
      await setupVite(app, server);
      log('Vite middleware configured successfully');
    } catch (error) {
      log(`Vite setup failed: ${error.message}`);
      // Fallback to simple HTML if Vite fails
      app.get('*', (req, res) => {
        if (!req.path.startsWith('/api') && !req.path.startsWith('/metrics') && !req.path.startsWith('/dashboard')) {
          res.send(`
            <!DOCTYPE html>
            <html>
            <head><title>AFL Fantasy Platform - Fallback</title></head>
            <body style="font-family: sans-serif; padding: 40px; text-align: center;">
              <h1>🏆 AFL Fantasy Platform</h1>
              <h2>⚠️ Vite Error - Running in Fallback Mode</h2>
              <p>Error: ${error.message}</p>
              <p>Server is running but React app compilation failed.</p>
            </body>
            </html>
          `);
        }
      });
    }
  } else {
    serveStatic(app);
  }

// Use environment PORT or fallback to 5002
const port = process.env.PORT ? parseInt(process.env.PORT) : 5002;
  
  server.listen(port, "0.0.0.0", () => {
    log(`serving on port ${port}`);
  }).on('error', (e: any) => {
    if (e.code === 'EADDRINUSE') {
      log(`Port ${port} is in use, please try a different port`);
      process.exit(1);
    } else {
      log(`Failed to start server: ${e.message}`);
      process.exit(1);
    }
  });
})();
