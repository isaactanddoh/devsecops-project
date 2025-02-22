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

# Install dumb-init for proper process handling
RUN apk add --no-cache dumb-init && \
    addgroup -S nodejs && \
    adduser -S nodejsuser -G nodejs

# Set working directory
WORKDIR /usr/src/app

# Copy from builder stage
COPY --from=builder --chown=nodejsuser:nodejs /usr/src/app/node_modules ./node_modules
COPY --from=builder --chown=nodejsuser:nodejs /usr/src/app/src ./src
COPY --from=builder --chown=nodejsuser:nodejs /usr/src/app/public ./public
COPY --from=builder --chown=nodejsuser:nodejs /usr/src/app/package.json ./

# Set environment variables
ENV NODE_ENV=production \
    PORT=3000

# Security hardening
RUN chmod -R 555 /usr/src/app && \
    chown -R nodejsuser:nodejs /usr/src/app

# Switch to non-root user
USER nodejsuser

# Expose port
EXPOSE 3000

# Use dumb-init as entrypoint
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["node", "src/app.js"]