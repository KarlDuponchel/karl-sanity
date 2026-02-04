# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
# Use npm install as fallback if npm ci fails due to lockfile issues
RUN npm ci || npm install

# Copy source files
COPY . .

# Build the Sanity Studio
RUN npm run build

# Production stage
FROM node:22-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (Sanity Studio needs them at runtime)
RUN npm ci || npm install

# Copy built files and source files from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/sanity.config.ts ./
COPY --from=builder /app/sanity.cli.ts ./
COPY --from=builder /app/schemaTypes ./schemaTypes
COPY --from=builder /app/static ./static

# Expose port 3333 (default Sanity Studio port)
EXPOSE 3333

# Start the Sanity Studio
CMD ["npm", "start"]
