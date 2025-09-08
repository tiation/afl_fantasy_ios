# Multi-stage build for production optimization
FROM node:18-alpine AS base

# Install system dependencies and setup Python environment
RUN apk add --no-cache \
    python3 \
    py3-pip \
    python3-dev \
    chromium \
    chromium-chromedriver \
    build-base \
    && ln -sf python3 /usr/bin/python \
    && python3 -m venv /opt/venv \
    && . /opt/venv/bin/activate \
    && pip install --no-cache-dir --upgrade pip \
    && rm -rf /var/cache/apk/* /tmp/*

# Activate the virtual environment
ENV PATH="/opt/venv/bin:$PATH"

# Set Chrome path for Selenium
ENV CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/lib/chromium/

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY requirements.txt ./

# Install Node.js dependencies
RUN npm ci --only=production && npm cache clean --force

# Install Python dependencies in layers to cache them
COPY requirements-minimal.txt ./
RUN . /opt/venv/bin/activate \
    && pip install --no-cache-dir -r requirements-minimal.txt \
    && find /opt/venv -name "*.pyc" -delete \
    && find /opt/venv -name "__pycache__" -exec rm -r {} + || true

# Install remaining Python dependencies
COPY requirements.txt ./
RUN . /opt/venv/bin/activate \
    && pip install --no-cache-dir -r requirements.txt \
    && find /opt/venv -name "*.pyc" -delete \
    && find /opt/venv -name "__pycache__" -exec rm -r {} + || true

# Development stage
FROM base AS development
RUN npm ci
COPY . .
EXPOSE 5000
CMD ["npm", "run", "dev"]

# Build stage
FROM base AS build
COPY . .
RUN npm ci && npm run build

# Production stage
FROM node:18-alpine AS production

# Install runtime dependencies and setup Python environment
RUN apk add --no-cache \
    python3 \
    py3-pip \
    python3-dev \
    chromium \
    chromium-chromedriver \
    dumb-init \
    build-base \
    && ln -sf python3 /usr/bin/python \
    && python3 -m venv /opt/venv \
    && . /opt/venv/bin/activate \
    && pip install --no-cache-dir --upgrade pip \
    && rm -rf /var/cache/apk/* /tmp/*

# Activate the virtual environment and add Python build tools
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set Chrome environment
ENV CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/lib/chromium/ \
    NODE_ENV=production \
    PORT=5000

WORKDIR /app

# Copy built application
COPY --from=build --chown=nodejs:nodejs /app/dist ./dist
COPY --from=build --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=build --chown=nodejs:nodejs /app/package*.json ./
COPY --from=build --chown=nodejs:nodejs /app/requirements.txt ./
COPY --from=build --chown=nodejs:nodejs /app/*.py ./
COPY --from=build --chown=nodejs:nodejs /app/*.json ./
COPY --from=build --chown=nodejs:nodejs /app/attached_assets ./attached_assets

# Install Python dependencies
RUN . /opt/venv/bin/activate && pip3 install --no-cache-dir -r requirements.txt

# Create data directories
RUN mkdir -p /app/uploads /app/logs && \
    chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD node -e "require('http').get('http://localhost:5000/api/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]
CMD ["npm", "start"]