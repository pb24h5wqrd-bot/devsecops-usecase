FROM node:18-alpine AS builder

WORKDIR /app

COPY app/ .
RUN npm install --production

# Runtime stage with non-root user
FROM node:18-alpine AS runtime

RUN addgroup -g 1001 -S nodejs && \
    adduser -S devsecops -u 1001

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/server.js .

USER devsecops

EXPOSE 3000

CMD ["node", "server.js"]
