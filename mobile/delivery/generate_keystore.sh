#!/bin/bash

# =============================================================================
# DR-PHARMA Courier - Script de Génération de Keystore
# =============================================================================
# Ce script génère un keystore pour signer l'APK de release
# 
# IMPORTANT: 
# - Gardez le keystore et les mots de passe en lieu sûr
# - Ne les commitez JAMAIS dans git
# - Sauvegardez-les, ils sont nécessaires pour les mises à jour
# =============================================================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     DR-PHARMA Courier - Génération de Keystore            ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Configuration
KEYSTORE_DIR="android/keystore"
KEYSTORE_FILE="$KEYSTORE_DIR/drpharma-courier.jks"
KEY_ALIAS="drpharma-courier"
KEY_PROPERTIES_FILE="android/key.properties"

# Vérifier si le keystore existe déjà
if [ -f "$KEYSTORE_FILE" ]; then
    echo -e "${YELLOW}⚠️  Un keystore existe déjà: $KEYSTORE_FILE${NC}"
    read -p "Voulez-vous le remplacer? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Opération annulée.${NC}"
        exit 0
    fi
fi

# Créer le répertoire si nécessaire
mkdir -p "$KEYSTORE_DIR"

# Demander les informations
echo -e "${BLUE}Entrez les informations pour le certificat:${NC}"
echo ""

read -p "Mot de passe du keystore (min 6 caractères): " -s STORE_PASSWORD
echo ""
read -p "Confirmez le mot de passe: " -s STORE_PASSWORD_CONFIRM
echo ""

if [ "$STORE_PASSWORD" != "$STORE_PASSWORD_CONFIRM" ]; then
    echo -e "${RED}❌ Les mots de passe ne correspondent pas${NC}"
    exit 1
fi

if [ ${#STORE_PASSWORD} -lt 6 ]; then
    echo -e "${RED}❌ Le mot de passe doit contenir au moins 6 caractères${NC}"
    exit 1
fi

echo ""
read -p "Prénom et Nom (ex: Jean Dupont): " CN
read -p "Organisation (ex: DR-PHARMA): " O
read -p "Ville (ex: Abidjan): " L
read -p "Pays (code 2 lettres, ex: CI): " C

# Générer le keystore
echo ""
echo -e "${BLUE}🔐 Génération du keystore...${NC}"

keytool -genkeypair \
    -v \
    -keystore "$KEYSTORE_FILE" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias "$KEY_ALIAS" \
    -storepass "$STORE_PASSWORD" \
    -keypass "$STORE_PASSWORD" \
    -dname "CN=$CN, O=$O, L=$L, C=$C"

echo ""
echo -e "${GREEN}✅ Keystore généré: $KEYSTORE_FILE${NC}"

# Créer le fichier key.properties
echo -e "${BLUE}📝 Création du fichier key.properties...${NC}"

cat > "$KEY_PROPERTIES_FILE" << EOF
# DR-PHARMA Courier - Keystore Configuration
# GÉNÉRÉ AUTOMATIQUEMENT - NE PAS COMMITER DANS GIT !
# Date: $(date)

storePassword=$STORE_PASSWORD
keyPassword=$STORE_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=keystore/drpharma-courier.jks
EOF

echo -e "${GREEN}✅ Fichier créé: $KEY_PROPERTIES_FILE${NC}"

# Ajouter au .gitignore si pas déjà présent
GITIGNORE_FILE="android/.gitignore"
if [ -f "$GITIGNORE_FILE" ]; then
    if ! grep -q "key.properties" "$GITIGNORE_FILE"; then
        echo "key.properties" >> "$GITIGNORE_FILE"
        echo "keystore/" >> "$GITIGNORE_FILE"
        echo -e "${GREEN}✅ Ajouté au .gitignore${NC}"
    fi
fi

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          Keystore généré avec succès ! 🎉                 ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT - À FAIRE MAINTENANT:${NC}"
echo -e "   1. Sauvegardez ${BLUE}$KEYSTORE_FILE${NC} en lieu sûr"
echo -e "   2. Notez le mot de passe: ${RED}[CONFIDENTIEL]${NC}"
echo -e "   3. Ne commitez JAMAIS ces fichiers dans git"
echo ""
echo -e "${BLUE}Pour générer l'APK release:${NC}"
echo -e "   ./build_release.sh"
echo ""
