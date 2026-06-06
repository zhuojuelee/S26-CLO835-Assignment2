FROM node:26-alpine

WORKDIR /app

COPY apps/nodejs/package.json .
COPY apps/nodejs/server.js .

RUN npm run build

EXPOSE 8080

CMD ["node", "server.js"]
