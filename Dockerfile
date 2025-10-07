FROM node:18-alpine

WORKDIR /app
COPY app/package*.json ./
RUN npm ci --only=production
COPY app/ .

# security: non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 3000
CMD ["npm", "start"]

