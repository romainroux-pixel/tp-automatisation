# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Copier les fichiers de configuration et les dépendances
COPY package*.json ./
COPY jest.config.js ./

# Installer les dépendances
RUN npm ci --only=production

# Copier le reste de l'application
COPY . .

# Construire l'application (si nécessaire)
RUN npm run build --if-present

# Stage 2: Runtime
FROM node:20-alpine

WORKDIR /app

# Créer un utilisateur non-root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Copier les artefacts du stage de build
COPY --from=builder /app .

# Exposer le port 3000
EXPOSE 3000

# Définir un HEALTHCHECK
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:3000/api/tasks || exit 1

# Commande pour démarrer l'application
CMD ["npm", "start"]
