# Use Node.js LTS (Long Term Support) version
FROM node:20-slim

# Install PostgreSQL client
RUN apt-get update && apt-get install -y postgresql-client

# Create app directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy app source code
COPY . .

# Expose the port your Fastify app runs on
EXPOSE 3000

# Start the application
CMD ["npm", "start"]