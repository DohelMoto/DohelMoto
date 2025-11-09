# Multi-stage build for React app with Nginx
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

RUN ls -la src/contexts && ls -la src/contexts/AuthContext* || true

# Set environment variables for build
ARG REACT_APP_GOOGLE_CLIENT_ID
ARG REACT_APP_API_URL_PUBLIC=/api
ARG REACT_APP_API_URL=/api
ENV REACT_APP_GOOGLE_CLIENT_ID=$REACT_APP_GOOGLE_CLIENT_ID
ENV REACT_APP_API_URL_PUBLIC=$REACT_APP_API_URL_PUBLIC
ENV REACT_APP_API_URL=$REACT_APP_API_URL


# Build the app
RUN npm run build

# Production stage with Nginx
FROM nginx:1.27-alpine

# Copy custom nginx config
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Copy built app from builder stage
COPY --from=builder /app/build /usr/share/nginx/html

# Set permissions for nginx
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://127.0.0.1/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
