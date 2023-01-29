FROM node:18.13.0-alpine
WORKDIR /usr/src/app
COPY package*.json ./
COPY yarn.lock ./

RUN npm install yarn
RUN rm package-lock.json
RUN yarn
COPY . .
EXPOSE 3002
CMD [ "node", "index.js" ]