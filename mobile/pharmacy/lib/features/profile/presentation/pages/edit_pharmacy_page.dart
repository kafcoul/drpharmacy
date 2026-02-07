import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../auth/domain/entities/pharmacy_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/duty_zones_provider.dart';
import '../../../auth/data/models/duty_zone_model.dart';
import '../providers/profile_provider.dart';


class EditPharmacyPage extends ConsumerStatefulWidget {
  final PharmacyEntity pharmacy;

  const EditPharmacyPage({super.key, required this.pharmacy});

  @override
  ConsumerState<EditPharmacyPage> createState() => _EditPharmacyPageState();
}

class _EditPharmacyPageState extends ConsumerState<EditPharmacyPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _emailController;
  late TextEditingController _licenseNumberController;
  int? _selectedDutyZoneId;

  final ImagePicker _picker = ImagePicker();
  XFile? _licenseFile;
  XFile? _idCardFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pharmacy.name);
    _phoneController = TextEditingController(text: widget.pharmacy.phone);
    _addressController = TextEditingController(text: widget.pharmacy.address);
    _cityController = TextEditingController(text: widget.pharmacy.city);
    _emailController = TextEditingController(text: widget.pharmacy.email);
    _licenseNumberController = TextEditingController(text: widget.pharmacy.licenseNumber);
    _selectedDutyZoneId = widget.pharmacy.dutyZoneId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(bool isLicense) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isLicense) {
          _licenseFile = image;
        } else {
          _idCardFile = image;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      dynamic data;
      
      // Check if we need FormData (if files are present)
      if (_licenseFile != null || _idCardFile != null) {
        final formData = FormData.fromMap({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'license_number': _licenseNumberController.text,
          if (_selectedDutyZoneId != null) 'duty_zone_id': _selectedDutyZoneId,
          if (_emailController.text.isNotEmpty) 'email': _emailController.text,
        });

        if (_licenseFile != null) {
          final bytes = await _licenseFile!.readAsBytes();
          formData.files.add(MapEntry(
            'license_document',
            MultipartFile.fromBytes(bytes, filename: _licenseFile!.name),
          ));
        }

        if (_idCardFile != null) {
          final bytes = await _idCardFile!.readAsBytes();
          formData.files.add(MapEntry(
            'id_card_document',
            MultipartFile.fromBytes(bytes, filename: _idCardFile!.name),
          ));
        }
        
        data = formData;
      } else {
        // Simple JSON update
        data = {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'license_number': _licenseNumberController.text,
          'duty_zone_id': _selectedDutyZoneId,
          'email': _emailController.text.isNotEmpty ? _emailController.text : null,
        };
      }

      await ref.read(profileProvider.notifier).updatePharmacy(widget.pharmacy.id, data);
      
      final state = ref.read(profileProvider);
      if (state.hasError) {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${state.error}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pharmacie mise à jour avec succès'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final isLoading = state.isLoading;
    final dutyZonesValue = ref.watch(dutyZonesProvider);

    // Get the latest pharmacy data from auth provider
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final PharmacyEntity currentPharmacy = user?.pharmacies.firstWhere(
      (p) => p.id == widget.pharmacy.id,
      orElse: () => widget.pharmacy,
    ) ?? widget.pharmacy;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Gérer ma Pharmacie'),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informations Générales'),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Nom de la Pharmacie',
                        icon: Icons.store_mall_directory_outlined,
                        validator: (v) => v!.isEmpty ? 'Le nom est requis' : null,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Localisation'),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _cityController,
                        label: 'Ville / Quartier',
                        icon: Icons.location_city_outlined,
                        validator: (v) => v!.isEmpty ? 'La ville est requise' : null,
                      ),
                      const SizedBox(height: 16),
                      // Zone de Garde Dropdown
                      dutyZonesValue.when(
                        data: (zones) => DropdownButtonFormField<int>(
                          value: _selectedDutyZoneId,
                          decoration: InputDecoration(
                            labelText: 'Zone de Garde',
                            prefixIcon: const Icon(Icons.share_location_outlined, color: Colors.grey),
                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: zones.map((zone) => DropdownMenuItem(
                            value: zone.id,
                            child: Text(zone.name),
                          )).toList(),
                          onChanged: (val) {
                             setState(() => _selectedDutyZoneId = val);
                          },
                          validator: (val) => val == null ? 'Veuillez sélectionner une zone' : null,
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (err, stack) => Text('Erreur chargement zones: $err', style: const TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Adresse exacte (ex: En face de la mairie)',
                        icon: Icons.map_outlined,
                        maxLines: 2,
                        validator: (v) => v!.isEmpty ? 'L\'adresse est requise' : null,
                      ),
                    ],
                  ),
                ),
              ),

              _buildSectionTitle('Documents & Vérification'),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _licenseNumberController,
                        label: 'Numéro de Licence',
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildFilePicker(
                        title: 'Document de Licence',
                        file: _licenseFile,
                        onTap: () => _pickFile(true),
                        isUploaded: currentPharmacy.licenseDocument != null && currentPharmacy.licenseDocument!.isNotEmpty,
                      ),
                      const SizedBox(height: 16),
                      _buildFilePicker(
                        title: 'CNI / Pièce d\'Identité',
                        file: _idCardFile,
                        onTap: () => _pickFile(false),
                        isUploaded: currentPharmacy.idCardDocument != null && currentPharmacy.idCardDocument!.isNotEmpty,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Contact'),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Téléphone',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'Le téléphone est requis' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email professionnel (Optionnel)',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Enregistrer les modifications',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildFilePicker({
    required String title,
    required XFile? file,
    required VoidCallback onTap,
    bool isUploaded = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(
              file != null ? Icons.check_circle : (isUploaded ? Icons.verified : Icons.upload_file),
              color: file != null ? Colors.green : (isUploaded ? Colors.blue : Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    file != null ? file.name : (isUploaded ? "Document reçu (Cliquez pour modifier)" : "Aucun fichier sélectionné"),
                    style: TextStyle(
                      color: file != null ? Colors.green : Colors.grey[600],
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
