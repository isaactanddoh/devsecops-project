# Build stage
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY src/ ./src/
COPY public/ ./public/

# Production stage
FROM node:20-alpine

# Install dumb-init and setup user
RUN apk add --no-cache dumb-init && \
    addgroup -S nodejs && \
    adduser -S nodejsuser -G nodejs

# Set working directory
WORKDIR /usr/src/app

# Copy from builder stage with specific permissions
COPY --from=builder --chown=nodejsuser:nodejs /usr/src/app/node_modules ./node_modules
COPY --from=builder --chown=nodejsuser:nodejs /usr/src/app/src ./src
COPY --from=builder --chown=nodejsuser:nodejs /usr/src/app/public ./public
COPY --from=builder --chown=nodejsuser:nodejs /usr/src/app/package.json ./

# Set environment variables
ENV NODE_ENV=production \
    PORT=3000

# Security hardening: Set strict permissions
RUN chmod -R 555 /usr/src/app && \
    chmod -R 444 /usr/src/app/node_modules && \
    chmod -R 444 /usr/src/app/src && \
    chmod -R 444 /usr/src/app/public && \
    chmod 444 /usr/src/app/package.json && \
    # Create a directory for runtime files if needed
    mkdir -p /usr/src/app/tmp && \
    chown -R nodejsuser:nodejs /usr/src/app/tmp && \
    chmod 755 /usr/src/app/tmp

# Switch to non-root user
USER nodejsuser

# Expose port
EXPOSE 3000

# Use dumb-init as entrypoint
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["node", "src/app.js"]