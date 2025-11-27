import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import AutoLoad from "@fastify/autoload";
import Env from "@fastify/env";
import { join } from "desm";
import Fastify from "fastify";
import pino from "pino";
import pretty from "pino-pretty";

// ============================================================================
// CONFIGURATION
// ============================================================================

/**
 * Defines required and optional environment variables
 */
const envSchema = {
  type: "object",
  required: ["POSTGRES_URL", "JWT_SECRET"],
  properties: {
    POSTGRES_URL: { type: "string" },
    NODE_ENV: { type: "string", default: "development" },
    PORT: { type: "string", default: "3000" },
  },
};

/**
 * Creates a configured logger instance with pretty formatting for development
 * and compact formatting for production
 */
function createLogger() {
  const stream = pretty({
    translateTime: "SYS:HH:MM:ss Z",
    messageFormat: "{msg} {req.method} {req.url}",
    include: "time,pid,level",
    hideObject: true,
    colorize: process.env.NODE_ENV === "development",
  });
  return pino({ level: "info" }, stream);
}

// ============================================================================
// PLUGIN REGISTRATION
// ============================================================================

/**
 * Registers the main routes file and all route subdirectories dynamically.
 * This allows adding new route modules without modifying the app.js file.
 *
 * @param {FastifyInstance} app - The Fastify application instance
 * @throws {Error} If a route file fails to load
 */
async function registerRoutes(app) {
  const routesDir = path.join(
    path.dirname(fileURLToPath(import.meta.url)),
    "routes",
  );

  // Register the main routes file first
  await app.register(import("./routes/routes.js"));

  // Discover and register all subdirectory route files
  const subdirectories = fs
    .readdirSync(routesDir, { withFileTypes: true })
    .filter((dirent) => dirent.isDirectory())
    .map((dirent) => dirent.name);

  for (const directory of subdirectories) {
    const routeFilePath = `./routes/${directory}/routes.js`;
    try {
      await app.register(import(routeFilePath));
      app.log.info(`✓ Loaded routes from ${routeFilePath}`);
    } catch (error) {
      app.log.error(
        `✗ Failed to load routes from ${routeFilePath}: ${error.message}`,
      );
      throw error; // Fail fast on critical route loading errors
    }
  }
}

// ============================================================================
// APPLICATION INITIALIZATION
// ============================================================================

/**
 * Builds and configures the Fastify application instance.
 * Sets up all plugins, middleware, and routes.
 *
 * @returns {Promise<FastifyInstance>} Configured Fastify application
 */
async function buildApp() {
  // Initialize Fastify with configured logger
  const logger = createLogger();
  const app = Fastify({
    loggerInstance: logger,
    trustProxy: true,
  });

  // Register environment variables with validation
  await app.register(Env, {
    confKey: "secrets",
    schema: envSchema,
    dotenv: true,
  });

  // Register all plugins from the plugins directory
  // Plugins handle middleware like compression, CORS, security headers, etc.
  await app.register(AutoLoad, {
    dir: join(import.meta.url, "plugins"),
    dirNameRoutePrefix: false,
    ignorePattern: /.*.no-load\.js/,
    indexPattern: /^no$/i,
  });

  // Register all application routes
  await registerRoutes(app);

  return app;
}

// ============================================================================
// SERVER STARTUP
// ============================================================================

/**
 * Starts the Fastify server on the configured port and host.
 * Logs connection information and handles startup errors.
 *
 * @param {FastifyInstance} app - The configured Fastify application
 * @throws {Error} If server fails to start
 */
async function startServer(app) {
  try {
    const port = app.secrets.PORT || "3000";
    const nodeEnv = app.secrets.NODE_ENV;
    const isDevelopment = nodeEnv === "development";
    const host = isDevelopment ? "127.0.0.1" : "0.0.0.0";

    await app.listen({ host, port });

    app.log.info(
      `🚀 Server running in ${nodeEnv} mode\n   URL: http://${host}:${port}`,
    );
  } catch (error) {
    app.log.error(`💥 Failed to start server: ${error.message}`);
    process.exit(1);
  }
}

// ============================================================================
// APPLICATION ENTRY POINT
// ============================================================================

/**
 * Main entry point that initializes and starts the server.
 * Handles any fatal errors during startup.
 */
async function main() {
  try {
    const app = await buildApp();
    await startServer(app);
  } catch (error) {
    console.error("💥 Fatal error during startup:", error);
    process.exit(1);
  }
}

// Start the application
main();
