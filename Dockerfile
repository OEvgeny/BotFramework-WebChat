# First stage: Build
ARG REGISTRY=docker.io
ARG BASE_IMAGE=$REGISTRY/node:18-alpine

FROM node:alpine AS builder
ENV TARGET_VERSION=0.0.0-0

RUN apk update && \
    apk upgrade && \
    apk add --no-cache rsync bash

WORKDIR /var/build/
ADD . .

# Initial rsync excluding specific directories
RUN mkdir -p /var/artifacts/gh-pages && \
    rsync -av . /var/artifacts/gh-pages/ --exclude 08.webpack5 --exclude 07.webpack4 --exclude 06.esbuild --exclude 01.create-react-app

# Build create-react-app
WORKDIR /var/build/01.create-react-app/
RUN ./install-drops.sh && \
    npm run build

# Copy create-react-app build
WORKDIR /var/build/
RUN mkdir -p /var/artifacts/gh-pages/01.create-react-app && \
    rsync -av 01.create-react-app/build/ /var/artifacts/gh-pages/01.create-react-app/

# Build esbuild
WORKDIR /var/build/07.esbuild/
RUN ./install-drops.sh && \
    npm run build

# Copy esbuild build
WORKDIR /var/build/
RUN mkdir -p /var/artifacts/gh-pages/06.esbuild && \
    rsync -av 06.esbuild/public/ /var/artifacts/gh-pages/06.esbuild/

# Build webpack4
WORKDIR /var/build/07.webpack4/
RUN ./install-drops.sh && \
    npm run build

# Copy webpack4 build
WORKDIR /var/build/
RUN mkdir -p /var/artifacts/gh-pages/07.webpack4 && \
    rsync -av 07.webpack4/public/ /var/artifacts/gh-pages/07.webpack4/

# Build webpack5
WORKDIR /var/build/08.webpack5/
RUN ./install-drops.sh && \
    npm run build

# Copy webpack5 build
WORKDIR /var/build/
RUN mkdir -p /var/artifacts/gh-pages/08.webpack5 && \
    rsync -av 08.webpack5/public/ /var/artifacts/gh-pages/08.webpack5/

# Rename final directory
RUN mv /var/artifacts/gh-pages /var/artifacts/WebChat-release-testing

# Second stage: Runtime
FROM nginx:alpine

# Copy nginx configuration
COPY <<'EOF' /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name localhost;
    
    root /var/artifacts;
    autoindex on;

    # Redirect root to /WebChat-release-testing/
    location = / {
        return 301 /WebChat-release-testing/;
    }
    
    # Handle WebChat-release-testing paths
    location /WebChat-release-testing/ {
        # Preserve index.html files
        location ~ /WebChat-release-testing/.*/index\.html$ {
            try_files $uri =404;
        }
        
        # For all other requests
        try_files $uri $uri/index.html $uri/ =404;
    }
    
    # Add security headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";
}
EOF

EXPOSE 80

# Copy artifacts from builder stage
COPY --from=builder /var/artifacts /var/artifacts