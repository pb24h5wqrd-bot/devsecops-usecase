# Use lightweight Node 18 image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY app/package.json app/package-lock.json ./

# Install build tools temporarily and install dependencies
RUN apk add --no-cache python3 make g++ \
    && npm install --only=production \
    && apk del python3 make g++

# Copy app source code
COPY app/ ./

# Use non-root user
USER node

# Expose port and define start command
EXPOSE 3000
CMD ["node", "server.js"]
