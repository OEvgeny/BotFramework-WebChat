# Setting to a different base image to secure your container supply chain.
ARG REGISTRY=docker.io
ARG BASE_IMAGE=$REGISTRY/node:18-alpine

FROM node:alpine
ENV TARGET_VERSION=0.0.0-0
EXPOSE 80

RUN apk update && \
    apk upgrade && \
    apk add --no-cache rsync bash

ADD . /var/build/

WORKDIR /var/build/
# RUN cp drops/webchat-es5.js /var/build/02.babel-standalone/ && \
#     cp drops/webchat-es5.js /var/build/03.a.renderwebchat-using-es5-bundle/ && \
#     cp drops/webchat.js /var/build/03.b.renderwebchat-using-full-bundle/ && \
#     cp drops/webchat-minimal.js /var/build/03.c.renderwebchat-using-minimal-bundle/ && \
#     cp drops/webchat-es5.js /var/build/04.renderwebchat-with-react/ && \
#     cp drops/webchat-es5.js /var/build/05.renderwebchat-with-directlinespeech/

WORKDIR /var/build/
RUN mkdir -p /var/artifacts/gh-pages && \
    rsync -av . /var/artifacts/gh-pages/ --exclude 08.webpack5 --exclude 07.webpack4 --exclude 01.create-react-app

WORKDIR /var/build/01.create-react-app/
RUN ./install-drops.sh \
    npm run build

WORKDIR /var/build/
RUN mkdir -p /var/artifacts/gh-pages && \
    rsync -av 01.create-react-app/public/ /var/artifacts/gh-pages/01.create-react-app/

WORKDIR /var/build/07.webpack4/
RUN ./install-drops.sh \
    npm run build

WORKDIR /var/build/
RUN mkdir -p /var/artifacts/gh-pages && \
    rsync -av 07.webpack4/public/ /var/artifacts/gh-pages/07.webpack4/

WORKDIR /var/build/08.webpack5/
RUN ./install-drops.sh \
    npm run build

WORKDIR /var/build/
RUN mkdir -p /var/artifacts/gh-pages && \
    rsync -av 08.webpack5/public/ /var/artifacts/gh-pages/08.webpack5/

RUN mv /var/artifacts/gh-pages /var/artifacts/WebChat-release-testing
WORKDIR /var/artifacts/WebChat-release-testing/
RUN npm install -g serve
ENTRYPOINT npx --no-install serve -p 80 ../