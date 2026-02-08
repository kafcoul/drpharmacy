import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

/// Modèle de préférences de relevés automatiques
class StatementPreference {
  final String frequency;
  final String frequencyLabel;
  final String format;
  final String formatLabel;
  final bool autoSend;
  final String? email;
  final DateTime? nextSendAt;
  final String? nextSendLabel;
  final DateTime? lastSentAt;
  final bool isConfigured;

  StatementPreference({
    required this.frequency,
    required this.frequencyLabel,
    required this.format,
    required this.formatLabel,
    required this.autoSend,
    this.email,
    this.nextSendAt,
    this.nextSendLabel,
    this.lastSentAt,
    required this.isConfigured,
  });

  factory StatementPreference.fromJson(Map<String, dynamic> json) {
    return StatementPreference(
      frequency: json['frequency'] ?? 'monthly',
      frequencyLabel: json['frequency_label'] ?? 'Mensuel',
      format: json['format'] ?? 'pdf',
      formatLabel: json['format_label'] ?? 'PDF',
      autoSend: json['auto_send'] ?? false,
      email: json['email'],
      nextSendAt: json['next_send_at'] != null 
          ? DateTime.tryParse(json['next_send_at']) 
          : null,
      nextSendLabel: json['next_send_label'],
      lastSentAt: json['last_sent_at'] != null 
          ? DateTime.tryParse(json['last_sent_at']) 
          : null,
      isConfigured: json['is_configured'] ?? false,
    );
  }

  /// Valeurs par défaut
  factory StatementPreference.defaults() {
    return StatementPreference(
      frequency: 'monthly',
      frequencyLabel: 'Mensuel',
      format: 'pdf',
      formatLabel: 'PDF',
      autoSend: false,
      isConfigured: false,
    );
  }
}

/// Service pour gérer les préférences de relevés automatiques
class StatementPreferenceService {
  static String get _baseUrl => AppConstants.apiBaseUrl;

  /// Récupérer le token d'authentification
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  /// Récupérer les préférences actuelles
  static Future<StatementPreference> getPreferences() async {
    try {
      final token = await _getToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/pharmacy/statement-preferences'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return StatementPreference.fromJson(data['data']);
        }
      }
      
      return StatementPreference.defaults();
    } catch (e) {
      print('Error fetching statement preferences: $e');
      return StatementPreference.defaults();
    }
  }

  /// Sauvegarder les préférences
  static Future<({bool success, String message, StatementPreference? preference})> savePreferences({
    required String frequency,
    required String format,
    required bool autoSend,
    String? email,
  }) async {
    try {
      final token = await _getToken();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/pharmacy/statement-preferences'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'frequency': frequency,
          'format': format,
          'auto_send': autoSend,
          if (email != null && email.isNotEmpty) 'email': email,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return (
          success: true,
          message: (data['message'] ?? 'Préférences enregistrées') as String,
          preference: StatementPreference.fromJson(data['data']),
        );
      } else {
        return (
          success: false,
          message: (data['message'] ?? 'Erreur lors de l\'enregistrement') as String,
          preference: null,
        );
      }
    } catch (e) {
      return (
        success: false,
        message: 'Erreur de connexion: $e',
        preference: null,
      );
    }
  }

  /// Désactiver les relevés automatiques
  static Future<bool> disableAutoStatements() async {
    try {
      final token = await _getToken();
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/pharmacy/statement-preferences'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('Error disabling auto statements: $e');
      return false;
    }
  }

  /// Convertir la fréquence UI vers la valeur API
  static String frequencyToApi(String uiFrequency) {
    return switch (uiFrequency) {
      'Hebdomadaire' => 'weekly',
      'Mensuel' => 'monthly',
      'Trimestriel' => 'quarterly',
      _ => 'monthly',
    };
  }

  /// Convertir la fréquence API vers l'UI
  static String frequencyToUi(String apiFrequency) {
    return switch (apiFrequency) {
      'weekly' => 'Hebdomadaire',
      'monthly' => 'Mensuel',
      'quarterly' => 'Trimestriel',
      _ => 'Mensuel',
    };
  }

  /// Convertir le format UI vers la valeur API
  static String formatToApi(String uiFormat) {
    return uiFormat.toLowerCase();
  }

  /// Convertir le format API vers l'UI
  static String formatToUi(String apiFormat) {
    return apiFormat.toUpperCase();
  }
}
