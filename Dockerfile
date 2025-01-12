# Use Node.js LTS (Long Term Support) version
FROM node:22-slim

# Create app directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy app source code
COPY . .

# Expose the port your Fastify app runs on
EXPOSE 1234

# Start the application
CMD ["npm", "start"]
