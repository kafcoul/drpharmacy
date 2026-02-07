#!/bin/bash

# Script pour lancer l'application pharmacie sur Chrome
# Usage: ./run_pharmacy_web.sh

echo "🚀 Lancement de l'application pharmacie sur Chrome..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$(dirname "$0")"

echo "📂 Répertoire: $(pwd)"
echo ""
echo "🔧 Configuration:"
echo "  - API URL: http://127.0.0.1:8000"
echo "  - Environnement: development"
echo ""
echo "📝 Comptes de test disponibles:"
echo "  Email: kouadio.jean@pharmacie.test"
echo "  Mot de passe: password"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

flutter run -d chrome
