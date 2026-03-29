FROM node:20-alpine AS build
WORKDIR /app
# Copy the package.json and lockfile if available
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production Environment
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
# Expose port (Nginx default)
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
