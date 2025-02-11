# Use Node.js LTS (Long Term Support) version
FROM node:22-slim

# Create app directory
WORKDIR /app

# Copy package files
COPY package.json /app

# Install dependencies
RUN npm install

# Copy app source code
COPY . /app

# Expose the port your Fastify app runs on
EXPOSE 3000

# Start the application
CMD ["node", "app.js"]
