# backend/Dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package.json and lock file
COPY package.json yarn.lock ./
# Or if using npm:
# COPY package.json package-lock.json ./

# Install dependencies (only production if you build separately, otherwise all)
RUN yarn install --frozen-lockfile --production # For smaller image if no build step in Dockerfile
# If you have devDependencies needed for a build step within Docker (e.g. TypeScript compilation):
# RUN yarn install --frozen-lockfile

# Copy the rest of the application code
COPY . .

# If you are using TypeScript and compiling to a 'dist' folder:
# RUN yarn build # or npm run build (this script should compile TS to JS in dist/)
# Then your CMD would be something like: CMD ["node", "dist/server.js"]

# Expose the port the app runs on
EXPOSE 3001 # Ensure this matches your app's listening port (process.env.PORT)

# Define environment variables that might be passed during `docker run` or by ECS
# These are defaults if not overridden.
ENV NODE_ENV=production
ENV PORT=3001
# Other ENVs like DB_HOST, DB_USER will be injected by ECS or docker-compose

# Command to run the application
CMD ["node", "src/server.js"]
