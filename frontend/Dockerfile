# frontend/Dockerfile

# Stage 1: Build the React application
FROM node:18-alpine AS builder
WORKDIR /app

# Copy package.json and lock file
COPY package.json yarn.lock ./
# Or if using npm:
# COPY package.json package-lock.json ./

# Install dependencies
RUN yarn install --frozen-lockfile
# Or if using npm:
# RUN npm ci

# Copy the rest of the application code
COPY . .

# Set build-time environment variables if needed
# ARG REACT_APP_API_URL
# ENV REACT_APP_API_URL=$REACT_APP_API_URL

# Build the application
RUN yarn build
# Or if using npm:
# RUN npm run build

# Stage 2: Serve the static files with Nginx
FROM nginx:stable-alpine

# Copy built assets from the builder stage
COPY --from=builder /app/build /usr/share/nginx/html

# Copy custom Nginx configuration if you have one
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
