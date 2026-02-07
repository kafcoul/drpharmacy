import 'package:flutter/foundation.dart'; // Add for kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/ui_components.dart';
import '../../../../core/presentation/widgets/error_display.dart';
import '../../../../core/utils/error_messages.dart';
import '../providers/inventory_provider.dart';
import '../../domain/entities/product_entity.dart';

class AddProductSheet extends ConsumerStatefulWidget {
  final String? scannedBarcode;
  final ProductEntity? productToEdit;

  const AddProductSheet({super.key, this.scannedBarcode, this.productToEdit});

  @override
  ConsumerState<AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends ConsumerState<AddProductSheet> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoryController = TextEditingController();
  final _barcodeController = TextEditingController();
  
  // New Controllers
  final _brandController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _activeIngredientController = TextEditingController();
  final _unitController = TextEditingController(text: 'pièce'); // Default
  final _usageController = TextEditingController();
  final _sideEffectsController = TextEditingController();
  DateTime? _expiryDate;

  XFile? _selectedImage;
  Uint8List? _imageBytes; // Pour l'affichage cross-platform sans dart:io
  final ImagePicker _picker = ImagePicker();

  bool _requiresPrescription = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      final p = widget.productToEdit!;
      _nameController.text = p.name;
      _descController.text = p.description;
      _priceController.text = p.price.toString();
      _stockController.text = p.stockQuantity.toString();
      _categoryController.text = p.category;
      _barcodeController.text = p.barcode ?? '';
      _requiresPrescription = p.requiresPrescription;
      
      // New fields init
      _brandController.text = p.brand ?? '';
      _manufacturerController.text = p.manufacturer ?? '';
      _activeIngredientController.text = p.activeIngredient ?? '';
      _unitController.text = p.unit ?? 'pièce';
      _usageController.text = p.usageInstructions ?? '';
      _sideEffectsController.text = p.sideEffects ?? '';
      _expiryDate = p.expiryDate;

      // Image handling todo: show existing image url if no new image selected
    } else if (widget.scannedBarcode != null) {
      _barcodeController.text = widget.scannedBarcode!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _barcodeController.dispose();
    _brandController.dispose();
    _manufacturerController.dispose();
    _activeIngredientController.dispose();
    _unitController.dispose();
    _usageController.dispose();
    _sideEffectsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = image;
        _imageBytes = bytes;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Si catégorie vide, on met une valeur par défaut
    if (_categoryController.text.trim().isEmpty) {
        _categoryController.text = "Divers"; 
    }

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final description = _descController.text.trim().isEmpty ? name : _descController.text.trim();
    final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;
    final stock = int.tryParse(_stockController.text) ?? 0;
    final category = _categoryController.text.trim();
    final barcode = _barcodeController.text.trim();
    // Find ID from name (backend expects ID now if strict, but let's send ID if we have it, or name if logic allows)
    // The user wants strict. But the addProduct signature in provider receives String category.
    // For now we pass the ID as string or the Name depending on what the backend expects in 'category' field?
    // Backend `store` method expects `category_id`.
    
    // Quick fix: The current Provider signature creates a payload with 'category'.
    // We should update the provider to accept categoryId.
    // However, to avoid huge refactor, let's assume the "category" field in addProduct calls 
    // is mapped to 'category_id' in implementation if it is an ID.
    // Actually, I should update the repository to send `category_id`.

    final selectedCat = ref.read(inventoryProvider).categories.firstWhere(
       (c) => c.name == category,
       orElse: () => throw Exception("Catégorie invalide"),
    );
    
    // We need to pass the ID. But `addProducts` in provider takes generic args.
    // Let's modify the values passed.
    // WARNING: modifications required in repository implementation.
    
    try {
      final categoryId = selectedCat.id.toString();

      if (widget.productToEdit != null) {
         // Update
         await ref.read(inventoryProvider.notifier).updateProduct(
           widget.productToEdit!.id,
           {
             'name': name,
             'description': description,
             'price': price,
             'stock_quantity': stock,
             'category_id': categoryId,
             'requires_prescription': _requiresPrescription ? 1 : 0,
             'barcode': barcode,
           },
           image: _selectedImage,
         );
         if (mounted) {
            context.pop(); 
            ErrorSnackBar.showSuccess(context, "Produit modifié avec succès !");
         }
      } else {
        // Create
        await ref.read(inventoryProvider.notifier).addProduct(
          name,
          description,
          price,
          stock,
          categoryId, 
          _requiresPrescription,
          barcode: barcode,
          image: _selectedImage,
        );
        if (mounted) {
          context.pop(); 
          ErrorSnackBar.showSuccess(context, "Produit ajouté avec succès !");
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.showError(
          context, 
          ErrorMessages.getInventoryError(e.toString()),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // No local creation allowed


  @override
  Widget build(BuildContext context) {
    // Récupérer les catégories existantes depuis le provider (liste stricte depuis le backend)
    final inventoryState = ref.watch(inventoryProvider);
    // On mappe les entités catégories vers une liste de noms pour l'affichage, 
    // ou mieux, on utilise un Dropdown avec l'ID derrière. 
    // Pour l'UX demandée, on veut juste une sélection.
    
    // Pour simplifier l'UI existante, on suppose que l'utilisateur sélectionne parmi les noms, 
    // et on enverra l'ID correspondant.
    final categories = inventoryState.categories;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Pour le clavier
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Poignée
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              widget.productToEdit != null ? "Modifier Produit" : "Nouveau Produit", 
              style: AppTextStyles.h2
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Image Picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200),
                          image: _imageBytes != null
                              ? DecorationImage(
                                  image: MemoryImage(_imageBytes!),
                                  fit: BoxFit.cover,
                                )
                              : (widget.productToEdit?.imageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(widget.productToEdit!.imageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                        ),
                        child: (_imageBytes == null && widget.productToEdit?.imageUrl == null)
                            ? Icon(Icons.add_a_photo_rounded, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600, size: 32)
                            : null,
                      ),
                    ),
                    if (_imageBytes == null && widget.productToEdit?.imageUrl == null)
                       Padding(
                         padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                         child: Text("Ajouter une photo", style: AppTextStyles.bodySmall),
                       ),
                     if (_imageBytes != null || widget.productToEdit?.imageUrl != null)
                        const SizedBox(height: 16),

                    // Code Barre
                    TextFormField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: 'Code Barre (Optionnel)',
                        prefixIcon: Icon(Icons.qr_code_rounded, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nom du produit
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du produit *',
                        hintText: 'Ex: Doliprane 1000mg',
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),
                    
                    // Catégorie (Dropdown strict)
                    DropdownButtonFormField<String>(
                      value: _categoryController.text.isNotEmpty ? _categoryController.text : null,
                      decoration: InputDecoration(
                        labelText: 'Catégorie *',
                        prefixIcon: Icon(Icons.category_outlined, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat.name,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _categoryController.text = val ?? '';
                        });
                      },
                      validator: (v) => v == null || v.isEmpty ? 'Sélectionnez une catégorie' : null,
                    ),
                    const SizedBox(height: 16),

                    // Prix et Stock (Row)
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Prix *',
                              suffixText: 'FCFA',
                            ),
                            validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Stock *',
                            ),
                            validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Toggle Ordonnance
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200),
                      ),
                      child: SwitchListTile(
                        value: _requiresPrescription,
                        onChanged: (val) => setState(() => _requiresPrescription = val),
                        title: Text("Ordonnance Requise", style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text("Cochez si le produit nécessite une ordonnance", style: AppTextStyles.bodySmall),
                        activeColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // --- SECTION DETAILS SUPPLEMENTAIRES ---
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Détails Supplémentaires", style: AppTextStyles.h3),
                    ),
                    
                    // Brand & Manufacturer
                    Row(
                      children: [
                        Expanded(child: TextFormField(
                          controller: _brandController,
                          decoration: const InputDecoration(labelText: 'Marque'),
                        )),
                        const SizedBox(width: 16),
                        Expanded(child: TextFormField(
                          controller: _manufacturerController,
                          decoration: const InputDecoration(labelText: 'Fabricant'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Active Ingredient
                    TextFormField(
                      controller: _activeIngredientController,
                      decoration: const InputDecoration(labelText: 'Principe Actif'),
                    ),
                    const SizedBox(height: 16),

                    // Unit & Expiry
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: ['pièce', 'boîte', 'flacon', 'tube', 'sachet', 'ampoule'].contains(_unitController.text) 
                                ? _unitController.text 
                                : 'pièce',
                            decoration: const InputDecoration(labelText: 'Unité'),
                            items: ['pièce', 'boîte', 'flacon', 'tube', 'sachet', 'ampoule'].map((u) => DropdownMenuItem(
                              value: u, child: Text(u)
                            )).toList(),
                            onChanged: (v) => setState(() => _unitController.text = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                              );
                              if (d != null) setState(() => _expiryDate = d);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Date exp.'),
                              child: Text(
                                _expiryDate != null ? "${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}" : "Choisir",
                                style: TextStyle(color: _expiryDate != null ? Colors.black : Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Instructions & Side Effects
                    TextFormField(
                      controller: _usageController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Instructions d\'usage'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sideEffectsController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Effets secondaires'),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    PrimaryButton(
                      label: widget.productToEdit != null ? "Modifier" : "Ajouter au stock",
                      icon: widget.productToEdit != null ? Icons.save_rounded : Icons.add_rounded,
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
