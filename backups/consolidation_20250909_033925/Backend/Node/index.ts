import express, { type Request, Response, NextFunction } from "express";
import { registerRoutes } from "./routes";
import { setupVite, serveStatic, log } from "./vite";
import { metricsMiddleware, healthCheck, metricsEndpoint } from "./middleware/metrics.js";
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

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// Enterprise monitoring middleware
app.use(metricsMiddleware);

// Health and metrics endpoints
app.get('/api/health', healthCheck);
app.get('/metrics', metricsEndpoint);

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

(async () => {
  const server = await registerRoutes(app);

  app.use((err: any, _req: Request, res: Response, _next: NextFunction) => {
    const status = err.status || err.statusCode || 500;
    const message = err.message || "Internal Server Error";

    log(`Error occurred: ${message}`);
    res.status(status).json({ message });
  });

  if (app.get("env") === "development") {
    await setupVite(app, server);
  } else {
    serveStatic(app);
  }

  const port = process.env.PORT ? parseInt(process.env.PORT) : 5000;
  
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
