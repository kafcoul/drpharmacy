import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/address_entity.dart';

/// Données de formulaire pour les adresses (labels et infos pré-remplies)
class AddressFormData {
  final List<String> labels;
  final String? defaultPhone;
  final String? userName;

  AddressFormData({
    required this.labels,
    this.defaultPhone,
    this.userName,
  });
}

/// Repository abstrait pour la gestion des adresses
abstract class AddressRepository {
  /// Obtenir toutes les adresses du client
  Future<Either<Failure, List<AddressEntity>>> getAddresses();

  /// Obtenir une adresse par son ID
  Future<Either<Failure, AddressEntity>> getAddress(int id);

  /// Obtenir l'adresse par défaut
  Future<Either<Failure, AddressEntity>> getDefaultAddress();

  /// Créer une nouvelle adresse
  Future<Either<Failure, AddressEntity>> createAddress({
    required String label,
    required String address,
    String? city,
    String? district,
    String? phone,
    String? instructions,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  });

  /// Mettre à jour une adresse
  Future<Either<Failure, AddressEntity>> updateAddress({
    required int id,
    String? label,
    String? address,
    String? city,
    String? district,
    String? phone,
    String? instructions,
    double? latitude,
    double? longitude,
    bool? isDefault,
  });

  /// Supprimer une adresse
  Future<Either<Failure, void>> deleteAddress(int id);

  /// Définir une adresse comme adresse par défaut
  Future<Either<Failure, AddressEntity>> setDefaultAddress(int id);

  /// Obtenir les labels disponibles avec données de pré-remplissage
  Future<Either<Failure, AddressFormData>> getLabels();
}
