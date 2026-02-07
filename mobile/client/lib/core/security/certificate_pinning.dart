/// Service de Certificate Pinning pour sécuriser les connexions HTTPS
/// Protège contre les attaques MITM (Man-in-the-Middle)
library;

import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../services/app_logger.dart';
import '../config/env_config.dart';

/// Configuration du Certificate Pinning
/// 
/// Pour générer les hashes des certificats:
/// 1. Obtenir le certificat: `openssl s_client -servername api.drpharma.com -connect api.drpharma.com:443 < /dev/null 2>/dev/null | openssl x509 -outform DER > cert.der`
/// 2. Générer le hash: `openssl dgst -sha256 -binary cert.der | openssl base64`
/// 
/// Ou utiliser: https://www.ssllabs.com/ssltest/
class CertificatePinningConfig {
  /// SHA-256 hashes des certificats autorisés (format base64)
  /// Inclure le certificat actuel ET le backup pour permettre la rotation
  /// 
  /// IMPORTANT: Mettre à jour ces hashes 30 jours AVANT l'expiration du certificat
  /// Date d'expiration à documenter dans le README
  static List<String> get pinnedCertificateHashes {
    final env = EnvConfig.environment;
    
    switch (env) {
      case 'production':
        return const [
          // ========================================
          // CERTIFICATS PRODUCTION DR-PHARMA API
          // ========================================
          // 
          // Certificat principal (Let's Encrypt / DigiCert)
          // Expiration: À documenter lors de la mise en production
          // Généré avec: openssl s_client -connect api.drpharma.com:443
          'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
          
          // Certificat intermédiaire (CA)
          // Permet la validation même si le certificat leaf change
          'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
          
          // Certificat de backup (pour rotation sans interruption)
          // Générer un nouveau certificat et ajouter son hash ici AVANT rotation
          'sha256/CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=',
        ];
        
      case 'staging':
        return const [
          // Certificats staging (peut être self-signed)
          'sha256/STAGING_CERT_HASH_HERE=====================',
        ];
        
      default:
        // Development: pas de pinning, certificats locaux acceptés
        return const [];
    }
  }

  /// Domaines autorisés pour le pinning
  static List<String> get pinnedDomains {
    final env = EnvConfig.environment;
    
    switch (env) {
      case 'production':
        return const [
          'api.drpharma.com',
          'drpharma.com',
          'www.drpharma.com',
        ];
        
      case 'staging':
        return const [
          'staging-api.drpharma.com',
          'staging.drpharma.com',
        ];
        
      default:
        return const []; // Pas de pinning en dev
    }
  }

  /// Active/désactive le pinning selon l'environnement
  static bool get isEnabled {
    final env = EnvConfig.environment;
    
    // Toujours désactivé en development
    if (env == 'development' || env == 'local') {
      AppLogger.debug('[CertPinning] Disabled in $env environment');
      return false;
    }
    
    // Désactivé en debug build même en staging/prod
    bool isDebugMode = false;
    assert(() {
      isDebugMode = true;
      return true;
    }());
    
    if (isDebugMode) {
      AppLogger.warning('[CertPinning] Disabled in debug mode');
      return false;
    }
    
    // Activé en release build pour staging et production
    return true;
  }
  
  /// Retourne les informations de configuration pour le debugging
  static Map<String, dynamic> get debugInfo => {
    'enabled': isEnabled,
    'environment': EnvConfig.environment,
    'pinnedDomains': pinnedDomains,
    'hashCount': pinnedCertificateHashes.length,
  };
}

/// Service de Certificate Pinning
class CertificatePinningService {
  CertificatePinningService._();

  /// Configure le certificate pinning sur un client Dio
  static void configureDio(Dio dio) {
    if (!CertificatePinningConfig.isEnabled) {
      AppLogger.info('[CertPinning] Skipping certificate pinning (debug mode)');
      return;
    }

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        
        // Configurer la validation du certificat
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          // Vérifier si le domaine est dans la liste des domaines pinnés
          final isPinnedDomain = CertificatePinningConfig.pinnedDomains.any(
            (domain) => host.endsWith(domain),
          );

          if (!isPinnedDomain) {
            // Domaine non pinné, accepter le certificat standard
            AppLogger.debug('[CertPinning] Non-pinned domain: $host');
            return false; // Laisser la validation standard
          }

          // Vérifier le hash du certificat
          final certHash = _computeCertificateHash(cert);
          final isValid = CertificatePinningConfig.pinnedCertificateHashes.contains(certHash);

          if (!isValid) {
            AppLogger.error(
              '[CertPinning] Certificate validation FAILED for $host',
              error: 'Hash mismatch. Expected one of: ${CertificatePinningConfig.pinnedCertificateHashes}, got: $certHash',
            );
          } else {
            AppLogger.debug('[CertPinning] Certificate validated for $host');
          }

          return !isValid; // Retourner true pour rejeter le mauvais certificat
        };

        return client;
      },
    );

    AppLogger.info('[CertPinning] Certificate pinning configured');
  }

  /// Calcule le hash SHA-256 du certificat en base64
  static String _computeCertificateHash(X509Certificate certificate) {
    final derBytes = certificate.der;
    final hash = sha256.convert(derBytes);
    return base64.encode(hash.bytes);
  }

  /// Vérifie manuellement un certificat
  static bool verifyCertificate(X509Certificate certificate) {
    final hash = _computeCertificateHash(certificate);
    return CertificatePinningConfig.pinnedCertificateHashes.contains(hash);
  }

  /// Génère le hash d'un certificat pour l'ajouter à la configuration
  /// Utile pour obtenir le hash lors de la configuration initiale
  static String generateCertificateHash(X509Certificate certificate) {
    return _computeCertificateHash(certificate);
  }
}

/// Extension pour faciliter l'ajout du pinning à Dio
extension DioSecurityExtension on Dio {
  /// Active le certificate pinning sur cette instance Dio
  void enableCertificatePinning() {
    CertificatePinningService.configureDio(this);
  }
}

/// Intercepteur Dio pour logging des erreurs de certificat
class CertificatePinningInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.badCertificate) {
      AppLogger.error(
        '[CertPinning] SSL/TLS Error',
        error: err.message,
      );
      // Transformer en erreur plus explicite
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          type: DioExceptionType.badCertificate,
          error: 'Connexion sécurisée impossible. Vérifiez votre réseau.',
          message: 'Certificate pinning validation failed',
        ),
      );
      return;
    }
    handler.next(err);
  }
}
