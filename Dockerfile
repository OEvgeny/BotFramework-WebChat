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
    rsync -av . /var/artifacts/gh-pages/ --exclude 08.webpack5 --exclude 07.webpack4 --exclude 01.create-react-app

# Build create-react-app
WORKDIR /var/build/01.create-react-app/
RUN ./install-drops.sh && \
    npm run build

# Copy create-react-app build
WORKDIR /var/build/
RUN mkdir -p /var/artifacts/gh-pages/01.create-react-app && \
    rsync -av 01.create-react-app/public/ /var/artifacts/gh-pages/01.create-react-app/

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
FROM $BASE_IMAGE

EXPOSE 80

# Install serve globally in the runtime image
RUN npm install -g serve

# Copy only the built artifacts from the builder stage
COPY --from=builder /var/artifacts /var/artifacts

# Set working directory and command
WORKDIR /var/artifacts/WebChat-release-testing/
ENTRYPOINT ["npx", "--no-install", "serve", "-p", "80", "../"]