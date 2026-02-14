#!/usr/bin/env bash
set -euo pipefail

# Builds the module and starts Docker environment if available.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> Building javascript-console-share..."
cd "$SCRIPT_DIR"
mvn clean install -DskipTests

if [ $? -ne 0 ]; then
  echo "Build failed!"
  exit 1
fi

echo "==> Build successful: $(ls -lh target/*.jar | tail -1 | awk '{print $9}')"

if command -v docker >/dev/null 2>&1 && [ -f "$ROOT_DIR/docker-compose-share.yml" ]; then
  echo ""
  
  # Vérifier que le réseau alfresco-network existe (créé par docker-compose-alfresco.yml)
  if ! docker network inspect alfresco-network >/dev/null 2>&1; then
    echo "ATTENTION: Le réseau 'alfresco-network' n'existe pas."
    echo "Lancez d'abord le repository avec: cd ../javascript-console-repo && bash run.sh"
    exit 1
  fi
  
  echo "==> Lancement de l'environnement Docker Share..."
  cd "$ROOT_DIR"
  docker compose -f docker-compose-share.yml up -d
  
  echo ""
  echo "Alfresco Share disponible sur: http://localhost:8180/share"
  echo "Identifiants: admin / admin"
  echo ""
  echo "Pour arrêter: docker compose -f docker-compose-share.yml down"
  echo "Pour voir les logs: docker compose -f docker-compose-share.yml logs -f share"
else
  echo ""
  echo "Docker non disponible ou docker-compose-share.yml manquant."
  echo "Les JARs sont disponibles dans target/ pour déploiement manuel."
fi
