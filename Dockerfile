# Use Node.js LTS (Long Term Support) version
FROM node:22-slim

# Create app directory
WORKDIR /app

# Copy package files
COPY package.json /app

# Install dependencies
RUN npm install

# Copy app source code
COPY . /appc

# Expose the port your Fastify app runs on
EXPOSE 1234

# Start the application
CMD npx pm2 start process.yml && tail -f /dev/null
