# Linux UAT/production: production Vite build + nginx (hashed bundles, not /src/*.tsx).
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

RUN npm run build \
  && mkdir -p /out \
  && if [ -d dist/client ]; then cp -a dist/client/. /out/; \
     elif [ -d .output/public ]; then cp -a .output/public/. /out/; \
     elif [ -f dist/index.html ]; then cp -a dist/. /out/; \
     else echo "No client build output found" && find . -maxdepth 3 -type d && exit 1; \
     fi

FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /out /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
