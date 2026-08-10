FROM node:22-alpine

WORKDIR /repo

# Shared (repo-root) dependencies: prisma CLI, @prisma/adapter-pg, pg, dotenv
COPY package*.json prisma.config.ts ./
RUN npm install

# Prisma schema + generated client are shared at the repo root
COPY prisma ./prisma
RUN npx prisma generate

# Backend app
COPY backend ./backend
WORKDIR /repo/backend
RUN npm install

ENV DATABASE_URL="postgresql://postgres:postgres@company-db:5432/postgres?schema=public"

EXPOSE 3000

CMD ["sh", "-c", "cd /repo && npx prisma migrate deploy && cd /repo/backend && npm start"]
