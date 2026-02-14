#!/usr/bin/env bash
set -euo pipefail

# Builds the module and starts Docker environment if available.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> Building javascript-console-repo..."
cd "$SCRIPT_DIR"
mvn clean install -DskipTests

if [ $? -ne 0 ]; then
  echo "Build failed!"
  exit 1
fi

echo "==> Build successful: $(ls -lh target/*.jar | tail -1 | awk '{print $9}')"

if command -v docker >/dev/null 2>&1 && [ -f "$ROOT_DIR/docker-compose.yml" ]; then
  echo ""
  echo "==> Lancement de l'environnement Docker Alfresco..."
  cd "$ROOT_DIR"
  docker compose up -d
  
  echo ""
  echo "Alfresco disponible sur:"
  echo "  - Repository: http://localhost:8080/alfresco"
  echo "  - Share: http://localhost:8180/share"
  echo ""
  echo "Pour arrêter: docker compose down"
  echo "Pour voir les logs: docker compose logs -f"
else
  echo ""
  echo "Docker non disponible ou docker-compose.yml manquant."
  echo "Les JARs sont disponibles dans target/ pour déploiement manuel."
fi
