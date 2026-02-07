# 🔐 Certificate Pinning - Guide de Configuration

## Vue d'ensemble

Le Certificate Pinning protège l'application contre les attaques Man-in-the-Middle (MITM) en vérifiant que le certificat du serveur correspond à un hash connu.

## Configuration

### Fichier de configuration
`lib/core/security/certificate_pinning.dart`

### Environnements

| Environnement | Pinning Activé | Notes |
|---------------|----------------|-------|
| development   | ❌ Non         | Facilite le développement local |
| staging       | ✅ Oui (release build) | Test de la configuration |
| production    | ✅ Oui (release build) | Sécurité maximale |

## Génération des Hashes

### Méthode 1: Script automatique

```bash
chmod +x scripts/generate_cert_hashes.sh
./scripts/generate_cert_hashes.sh api.drpharma.com
```

### Méthode 2: Manuelle avec OpenSSL

```bash
# 1. Récupérer le certificat
openssl s_client -servername api.drpharma.com -connect api.drpharma.com:443 < /dev/null 2>/dev/null | \
  openssl x509 -outform DER > cert.der

# 2. Générer le hash SHA-256 en Base64
openssl dgst -sha256 -binary cert.der | openssl base64

# 3. Nettoyer
rm cert.der
```

### Méthode 3: SSL Labs

Utiliser [SSL Labs](https://www.ssllabs.com/ssltest/) pour analyser le domaine et obtenir les informations du certificat.

## Mise à jour des Certificats

### Procédure de Rotation

1. **30 jours avant expiration:**
   - Générer le nouveau certificat sur le serveur
   - Récupérer le hash du nouveau certificat
   - Ajouter le nouveau hash à `pinnedCertificateHashes` (garder l'ancien)
   - Déployer l'application mise à jour

2. **Rotation du certificat serveur:**
   - Installer le nouveau certificat sur le serveur
   - L'application acceptera les deux certificats

3. **30 jours après rotation:**
   - Supprimer l'ancien hash de `pinnedCertificateHashes`
   - Déployer la mise à jour

### Exemple de configuration

```dart
static List<String> get pinnedCertificateHashes {
  return const [
    // Certificat actuel (expire: 2027-01-15)
    'sha256/abc123...=',
    
    // Nouveau certificat (pour rotation, expire: 2028-01-15)  
    'sha256/def456...=',
    
    // CA Intermédiaire (Let's Encrypt R3)
    'sha256/xyz789...=',
  ];
}
```

## Bonnes Pratiques

### ✅ À faire

- Toujours garder au moins 2 hashes (actuel + backup)
- Inclure le hash du CA intermédiaire pour plus de flexibilité
- Documenter les dates d'expiration
- Tester sur staging avant production
- Surveiller les dates d'expiration

### ❌ À éviter

- Ne jamais déployer avec un seul hash (risque de blocage)
- Ne pas oublier de mettre à jour avant expiration
- Ne pas désactiver en production

## Dépannage

### L'application refuse de se connecter

1. Vérifier que les hashes sont corrects
2. Vérifier que le domaine est dans `pinnedDomains`
3. Vérifier les logs: `[CertPinning]`

### Générer le hash d'un certificat en runtime

```dart
// Pour debug uniquement
import 'dart:io';
import 'package:drpharma_client/core/security/certificate_pinning.dart';

// Dans un callback badCertificateCallback:
final hash = CertificatePinningService.generateCertificateHash(certificate);
print('Certificate hash: $hash');
```

## Tests

### Test unitaire

```dart
test('should have valid pinning configuration', () {
  expect(CertificatePinningConfig.pinnedCertificateHashes.length, greaterThanOrEqualTo(2));
  expect(CertificatePinningConfig.pinnedDomains, contains('api.drpharma.com'));
});
```

### Test d'intégration

```bash
# Tester avec un proxy MITM (doit échouer en production)
flutter run --release
# Configurer Charles/mitmproxy et vérifier que les requêtes échouent
```

## Monitoring

Ajouter une alerte pour:
- Certificats expirant dans 30 jours
- Échecs de validation SSL dans les logs
- Taux d'erreurs SSL anormal

## Références

- [OWASP Certificate Pinning](https://owasp.org/www-community/controls/Certificate_and_Public_Key_Pinning)
- [Dio Certificate Pinning](https://pub.dev/packages/dio)
- [Let's Encrypt Certificate Chain](https://letsencrypt.org/certificates/)
