FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Create directories
RUN mkdir -p /app/logs /app/data

# Expose port
EXPOSE 5000

# Start the application
CMD ["node", "server/index.js"]
