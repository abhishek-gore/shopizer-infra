# Build stage
FROM node:16 AS builder
WORKDIR /build
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build && \
    echo 'window._env_ = { APP_PRODUCTION: "false", APP_BASE_URL: "http://backend.local", APP_API_VERSION: "/api/v1/", APP_MERCHANT: "DEFAULT", APP_PRODUCT_GRID_LIMIT: "15", APP_MAP_API_KEY: "", APP_NUVEI_TERMINAL_ID: "", APP_NUVEI_SECRET: "", APP_PAYMENT_TYPE: "STRIPE", APP_STRIPE_KEY: "pk_test_TYooMQauvdEDq54NiTphI7jx", APP_THEME_COLOR: "#D1D1D1" }' > /build/build/env-config.js

# Runtime stage
FROM nginx:alpine
COPY --from=builder /build/build /usr/share/nginx/html
RUN echo 'server { listen 80; root /usr/share/nginx/html; index index.html; location / { try_files $uri $uri/ /index.html; } }' > /etc/nginx/conf.d/default.conf
EXPOSE 80
