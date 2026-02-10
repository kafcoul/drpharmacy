import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _vehicleRegistrationController = TextEditingController();

  String _selectedVehicleType = 'motorcycle';
  
  // Documents recto/verso
  File? _idCardFrontImage;      // CNI Recto
  File? _idCardBackImage;       // CNI Verso
  File? _selfieImage;
  File? _drivingLicenseFrontImage;  // Permis Recto
  File? _drivingLicenseBackImage;   // Permis Verso
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 0;

  // Erreurs par champ
  Map<String, String?> _fieldErrors = {};
  String? _generalError;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licenseNumberController.dispose();
    _vehicleRegistrationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, String type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          switch (type) {
            case 'id_card_front':
              _idCardFrontImage = File(image.path);
              break;
            case 'id_card_back':
              _idCardBackImage = File(image.path);
              break;
            case 'selfie':
              _selfieImage = File(image.path);
              break;
            case 'driving_license_front':
              _drivingLicenseFrontImage = File(image.path);
              break;
            case 'driving_license_back':
              _drivingLicenseBackImage = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      _showError('Erreur lors de la sélection de l\'image');
    }
  }

  void _showImagePickerDialog(String type, String title) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ImagePickerOption(
                    icon: Icons.camera_alt,
                    label: 'Caméra',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera, type);
                    },
                  ),
                  _ImagePickerOption(
                    icon: Icons.photo_library,
                    label: 'Galerie',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery, type);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Réinitialiser les erreurs
    setState(() {
      _fieldErrors = {};
      _generalError = null;
    });
    
    // Vérifier les documents obligatoires (recto ET verso)
    if (_idCardFrontImage == null) {
      setState(() => _fieldErrors['id_card_front'] = 'Veuillez télécharger le RECTO de votre pièce d\'identité');
      return;
    }
    if (_idCardBackImage == null) {
      setState(() => _fieldErrors['id_card_back'] = 'Veuillez télécharger le VERSO de votre pièce d\'identité');
      return;
    }
    if (_selfieImage == null) {
      setState(() => _fieldErrors['selfie'] = 'Veuillez prendre un selfie de vérification');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).registerCourier(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        vehicleType: _selectedVehicleType,
        vehicleRegistration: _vehicleRegistrationController.text.trim(),
        licenseNumber: _licenseNumberController.text.trim(),
        idCardFrontImage: _idCardFrontImage,
        idCardBackImage: _idCardBackImage,
        selfieImage: _selfieImage,
        drivingLicenseFrontImage: _drivingLicenseFrontImage,
        drivingLicenseBackImage: _drivingLicenseBackImage,
      );

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _parseAndShowErrors(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _parseAndShowErrors(String error) {
    final errorMessage = error.replaceAll('Exception:', '').trim();
    final errorLower = errorMessage.toLowerCase();
    
    setState(() {
      // Parser les erreurs et les associer aux champs
      if (errorLower.contains('email') && (errorLower.contains('existe') || errorLower.contains('taken') || errorLower.contains('already'))) {
        _fieldErrors['email'] = 'Cet email est déjà utilisé';
        _currentStep = 0; // Retourner à l'étape des infos personnelles
      } else if (errorLower.contains('email') && errorLower.contains('invalid')) {
        _fieldErrors['email'] = 'Format d\'email invalide';
        _currentStep = 0;
      } else if (errorLower.contains('phone') || errorLower.contains('téléphone')) {
        if (errorLower.contains('existe') || errorLower.contains('taken') || errorLower.contains('already')) {
          _fieldErrors['phone'] = 'Ce numéro est déjà utilisé';
        } else {
          _fieldErrors['phone'] = 'Numéro de téléphone invalide';
        }
        _currentStep = 0;
      } else if (errorLower.contains('password') || errorLower.contains('mot de passe')) {
        _fieldErrors['password'] = errorMessage;
        _currentStep = 0;
      } else if (errorLower.contains('name') || errorLower.contains('nom')) {
        _fieldErrors['name'] = errorMessage;
        _currentStep = 0;
      } else if (errorLower.contains('vehicle') || errorLower.contains('véhicule') || errorLower.contains('immatriculation')) {
        _fieldErrors['vehicle'] = errorMessage;
        _currentStep = 1;
      } else if (errorLower.contains('license') || errorLower.contains('permis')) {
        _fieldErrors['license'] = errorMessage;
        _currentStep = 1;
      } else if (errorLower.contains('document') || errorLower.contains('image') || errorLower.contains('photo')) {
        _fieldErrors['documents'] = errorMessage;
        _currentStep = 2;
      } else if (errorMessage.contains('DioException') || errorMessage.contains('SocketException')) {
        _generalError = 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
      } else {
        _generalError = errorMessage;
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'Inscription réussie !',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Votre compte est en attente de validation par notre équipe. Vous recevrez une notification une fois approuvé.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Retour à la connexion'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Devenir Livreur'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _register();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ? null : details.onStepContinue,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading && _currentStep == 2
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(_currentStep == 2 ? 'S\'inscrire' : 'Continuer'),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Retour'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Informations personnelles'),
              subtitle: const Text('Nom, email, téléphone'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildPersonalInfoStep(),
            ),
            Step(
              title: const Text('Véhicule'),
              subtitle: const Text('Type et immatriculation'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildVehicleStep(),
            ),
            Step(
              title: const Text('Documents KYC'),
              subtitle: const Text('Pièce d\'identité et selfie'),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: _buildKYCStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      children: [
        // Erreur générale
        if (_generalError != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _generalError!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        _buildTextField(
          controller: _nameController,
          label: 'Nom complet',
          icon: Icons.person_outline,
          fieldKey: 'name',
          validator: (value) => value!.isEmpty ? 'Entrez votre nom' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          fieldKey: 'email',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value!.isEmpty) return 'Entrez votre email';
            if (!value.contains('@')) return 'Email invalide';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Téléphone',
          icon: Icons.phone_outlined,
          fieldKey: 'phone',
          keyboardType: TextInputType.phone,
          validator: (value) => value!.isEmpty ? 'Entrez votre téléphone' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: 'Mot de passe',
          icon: Icons.lock_outline,
          fieldKey: 'password',
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: (value) {
            if (value!.isEmpty) return 'Entrez un mot de passe';
            if (value.length < 8) return 'Minimum 8 caractères';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Confirmer mot de passe',
          icon: Icons.lock_outline,
          fieldKey: 'confirm_password',
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
          validator: (value) {
            if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildVehicleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Erreur sur le véhicule
        if (_fieldErrors['vehicle'] != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _fieldErrors['vehicle']!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        const Text(
          'Type de véhicule',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _VehicleTypeCard(
              icon: Icons.pedal_bike,
              label: 'Vélo',
              isSelected: _selectedVehicleType == 'bicycle',
              onTap: () => setState(() => _selectedVehicleType = 'bicycle'),
            ),
            const SizedBox(width: 12),
            _VehicleTypeCard(
              icon: Icons.two_wheeler,
              label: 'Moto',
              isSelected: _selectedVehicleType == 'motorcycle',
              onTap: () => setState(() => _selectedVehicleType = 'motorcycle'),
            ),
            const SizedBox(width: 12),
            _VehicleTypeCard(
              icon: Icons.directions_car,
              label: 'Voiture',
              isSelected: _selectedVehicleType == 'car',
              onTap: () => setState(() => _selectedVehicleType = 'car'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _vehicleRegistrationController,
          label: 'Immatriculation du véhicule',
          icon: Icons.badge_outlined,
          fieldKey: 'vehicle_registration',
          validator: (value) => value!.isEmpty ? 'Entrez l\'immatriculation' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _licenseNumberController,
          label: 'Numéro de permis (optionnel pour vélo)',
          icon: Icons.credit_card_outlined,
          fieldKey: 'license',
        ),
      ],
    );
  }

  Widget _buildKYCStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Erreur sur les documents
        if (_fieldErrors['documents'] != null || _fieldErrors['id_card_front'] != null || 
            _fieldErrors['id_card_back'] != null || _fieldErrors['selfie'] != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _fieldErrors['documents'] ?? 
                    _fieldErrors['id_card_front'] ?? 
                    _fieldErrors['id_card_back'] ?? 
                    _fieldErrors['selfie'] ?? '',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        const Text(
          'Pour vérifier votre identité, nous avons besoin des documents suivants :',
          style: TextStyle(color: Colors.grey, height: 1.5),
        ),
        const SizedBox(height: 24),
        
        // Pièce d'identité - Recto
        _DocumentUploadCard(
          title: 'Pièce d\'identité (Recto) *',
          subtitle: 'Face avant de votre CNI',
          icon: Icons.badge,
          image: _idCardFrontImage,
          onTap: () {
            if (_fieldErrors['id_card_front'] != null) {
              setState(() => _fieldErrors.remove('id_card_front'));
            }
            _showImagePickerDialog('id_card_front', 'CNI (Recto)');
          },
          isRequired: true,
          hasError: _fieldErrors['id_card_front'] != null,
        ),
        const SizedBox(height: 16),
        
        // Pièce d'identité - Verso
        _DocumentUploadCard(
          title: 'Pièce d\'identité (Verso) *',
          subtitle: 'Face arrière de votre CNI',
          icon: Icons.badge_outlined,
          image: _idCardBackImage,
          onTap: () {
            if (_fieldErrors['id_card_back'] != null) {
              setState(() => _fieldErrors.remove('id_card_back'));
            }
            _showImagePickerDialog('id_card_back', 'CNI (Verso)');
          },
          isRequired: true,
          hasError: _fieldErrors['id_card_back'] != null,
        ),
        const SizedBox(height: 16),
        
        // Selfie de vérification
        _DocumentUploadCard(
          title: 'Selfie de vérification *',
          subtitle: 'Prenez une photo de vous tenant votre pièce d\'identité',
          icon: Icons.camera_front,
          image: _selfieImage,
          onTap: () {
            if (_fieldErrors['selfie'] != null) {
              setState(() => _fieldErrors.remove('selfie'));
            }
            _showImagePickerDialog('selfie', 'Selfie de vérification');
          },
          isRequired: true,
          hasError: _fieldErrors['selfie'] != null,
        ),
        const SizedBox(height: 16),
        
        // Permis de conduire (si moto/voiture)
        if (_selectedVehicleType != 'bicycle') ...[
          _DocumentUploadCard(
            title: 'Permis de conduire (Recto)',
            subtitle: 'Face avant de votre permis',
            icon: Icons.drive_eta,
            image: _drivingLicenseFrontImage,
            onTap: () => _showImagePickerDialog('driving_license_front', 'Permis (Recto)'),
            isRequired: _selectedVehicleType != 'bicycle',
          ),
          const SizedBox(height: 16),
          _DocumentUploadCard(
            title: 'Permis de conduire (Verso)',
            subtitle: 'Face arrière de votre permis',
            icon: Icons.drive_eta_outlined,
            image: _drivingLicenseBackImage,
            onTap: () => _showImagePickerDialog('driving_license_back', 'Permis (Verso)'),
            isRequired: false,
          ),
        ],
        
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Vos documents seront vérifiés par notre équipe sous 24-48h.',
                  style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? fieldKey,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final hasError = fieldKey != null && _fieldErrors[fieldKey] != null;
    final errorText = fieldKey != null ? _fieldErrors[fieldKey] : null;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: (_) {
        if (fieldKey != null && _fieldErrors[fieldKey] != null) {
          setState(() => _fieldErrors.remove(fieldKey));
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: hasError ? Colors.red : null),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: hasError ? Colors.red.shade50 : Colors.white,
        errorText: errorText,
        errorStyle: TextStyle(color: Colors.red.shade700, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: hasError ? Colors.red.shade300 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: hasError ? Colors.red : Colors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}

// --- Helper Widgets ---

class _VehicleTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleTypeCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.blue : Colors.grey.shade600,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final File? image;
  final VoidCallback onTap;
  final bool isRequired;
  final bool hasError;

  const _DocumentUploadCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.image,
    required this.onTap,
    this.isRequired = false,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = image != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasError 
              ? Colors.red.shade50 
              : (hasImage ? Colors.green.shade50 : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasError 
                ? Colors.red.shade300 
                : (hasImage ? Colors.green : Colors.grey.shade300),
            width: hasError ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: hasError 
                    ? Colors.red.shade100 
                    : (hasImage ? Colors.green.shade100 : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(image!, fit: BoxFit.cover),
                    )
                  : Icon(
                      icon, 
                      color: hasError ? Colors.red.shade400 : Colors.grey.shade500, 
                      size: 28,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: hasError ? Colors.red.shade700 : null,
                          ),
                        ),
                      ),
                      if (hasImage)
                        const Icon(Icons.check_circle, color: Colors.green, size: 20)
                      else if (hasError)
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasError ? 'Ce document est requis' : subtitle,
                    style: TextStyle(
                      color: hasError ? Colors.red.shade600 : Colors.grey.shade600, 
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hasImage ? Icons.edit : Icons.add_a_photo,
              color: hasError ? Colors.red : (hasImage ? Colors.green : Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImagePickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
