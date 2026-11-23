# Linux UAT/production.
# `vite build` writes a Node render server (dist/server) and hashed files (dist/client).
# There is no static index.html, so nginx's default page was what the browser showed.
# Local laptop work still uses `npm run dev`.

FROM node:20-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

ARG VITE_APP_ENV=uat
ARG VITE_API_URL=
ENV VITE_APP_ENV=$VITE_APP_ENV
ENV VITE_API_URL=$VITE_API_URL
ENV DOCKER_STATIC_BUILD=1
ENV NODE_ENV=production

RUN npm run build

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=80
ENV API_PROXY_TARGET=http://backend:8080

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY docker-server.mjs ./docker-server.mjs

EXPOSE 80
CMD ["node", "docker-server.mjs"]
