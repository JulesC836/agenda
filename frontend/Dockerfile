FROM node:25-alpine

WORKDIR /usr/src/app

COPY ./ /usr/src/app/

RUN npm install -g pnpm

RUN pnpm add --save-dev @types/node && pnpm install

CMD ["npm", "start"]

EXPOSE 4200