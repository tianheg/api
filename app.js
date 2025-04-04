import Fastify from "fastify";
import AutoLoad from "@fastify/autoload";
import Env from "@fastify/env";
import pino from "pino";
import pretty from "pino-pretty";
import { join } from "desm";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

/**
 * Configuration
 */
// Environment schema
const envSchema = {
  type: "object",
  required: ["POSTGRES_URL", "JWT_SECRET"],
  properties: {
    POSTGRES_URL: { type: "string" },
    JWT_SECRET: { type: "string" },
    NODE_ENV: { type: "string", default: "development" },
    PORT: { type: "string", default: "3000" },
  },
};

// Logger configuration
const createLogger = () => {
  const stream = pretty({
    translateTime: "SYS:HH:MM:ss Z",
    messageFormat: "{msg} {req.method} {req.url}",
    include: "time,pid,level",
    hideObject: true,
    colorize: process.env.NODE_ENV === "development",
  });
  return pino({ level: "info" }, stream);
};

/**
 * Authentication middleware
 */
const createAuthenticator = (app) => {
  // Decorate with authenticate method but don't apply globally
  app.decorate("authenticate", async (request, reply) => {
    try {
      await request.jwtVerify();
    } catch (err) {
      reply.code(401);
      return reply.send({ error: "Unauthorized", message: err.message });
    }
  });
};

/**
 * Route registration
 */
const registerRoutes = async (app) => {
  const routesDir = path.join(path.dirname(fileURLToPath(import.meta.url)), "routes");
  
  // Register main routes file
  await app.register(import("./routes/routes.js"));
  
  // Dynamically register all subdirectory route files
  const subdirs = fs.readdirSync(routesDir, { withFileTypes: true })
    .filter(dirent => dirent.isDirectory())
    .map(dirent => dirent.name);
    
  for (const dir of subdirs) {
    const routeFile = `./routes/${dir}/routes.js`;
    try {
      await app.register(import(routeFile));
      app.log.info(`Registered routes from ${routeFile}`);
    } catch (error) {
      app.log.error(`Failed to register routes from ${routeFile}: ${error.message}`);
    }
  }
};

/**
 * Server initialization
 */
const buildApp = async () => {
  // Initialize Fastify with logger
  const loggerInstance = createLogger();
  const app = Fastify({ 
    loggerInstance,
    trustProxy: true
  });

  // Register environment variables
  await app.register(Env, {
    confKey: "secrets",
    schema: envSchema,
    dotenv: true,
  });

  // Setup authentication
  //createAuthenticator(app);

  // Register plugins
  await app.register(AutoLoad, {
    dir: join(import.meta.url, "plugins"),
    dirNameRoutePrefix: false,
    ignorePattern: /.*.no-load\.js/,
    indexPattern: /^no$/i,
  });

  // Register routes
  await registerRoutes(app);

  return app;
};

/**
 * Server startup
 */
const startServer = async (app) => {
  try {
    const port = Number.parseInt(app.secrets.PORT || "3000", 10);
    const isDev = app.secrets.NODE_ENV === "development";
    const host = isDev ? "127.0.0.1" : "0.0.0.0";
    
    await app.listen({ host, port });
    
    app.log.info(`Server running in ${app.secrets.NODE_ENV} mode on http://${host}:${port}`);
  } catch (error) {
    app.log.error(`Error starting server: ${error.message}`);
    process.exit(1);
  }
};

/**
 * Main execution
 */
const main = async () => {
  try {
    const app = await buildApp();
    await startServer(app);
  } catch (error) {
    console.error("Fatal error during startup:", error);
    process.exit(1);
  }
};

main();
