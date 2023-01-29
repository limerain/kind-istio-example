FROM node:18.13.0-alpine AS build
WORKDIR /app
COPY package*.json ./
COPY yarn.lock ./

RUN npm install yarn
RUN rm package-lock.json
COPY . ./
RUN yarn
RUN yarn build
EXPOSE 3000
CMD [ "node", "build/index.js" ]