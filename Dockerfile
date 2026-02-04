# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source files
COPY . .

# Build the Sanity Studio
RUN npm run build

# Production stage
FROM node:22-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies only
RUN npm ci --production

# Copy built files from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/sanity.config.ts ./
COPY --from=builder /app/sanity.cli.ts ./

# Expose port 3333 (default Sanity Studio port)
EXPOSE 3333

# Start the Sanity Studio
CMD ["npm", "start"]
