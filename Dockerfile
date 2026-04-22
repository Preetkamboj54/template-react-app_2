# ==========================================
# STAGE 1: BUILD
# ==========================================
FROM node:22-alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy rest of the code
COPY . .

# Build Vite React app → produces /dist folder
RUN npm run build

# ==========================================
# STAGE 2: SERVE
# ==========================================
FROM node:22-alpine

WORKDIR /app

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Install serve to host static files
RUN npm install -g serve

# Copy only built files from Stage 1
COPY --from=builder /app/dist ./dist

# Set ownership
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

CMD ["serve", "-s", "dist", "-l", "3000"]