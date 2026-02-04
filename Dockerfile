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

# Production stage - Serve static files
FROM node:22-alpine

WORKDIR /app

# Install serve for serving static files
RUN npm install -g serve

# Copy only the built static files from builder
COPY --from=builder /app/dist ./dist

# Expose port 3333 (default Sanity Studio port)
EXPOSE 3333

# Serve the static files with SPA routing support
CMD ["serve", "-s", "dist", "-l", "3333"]
