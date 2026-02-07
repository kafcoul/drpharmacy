import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/prescription_model.dart';
import '../providers/prescription_provider.dart';
import 'package:intl/intl.dart';

class PrescriptionDetailsPage extends ConsumerStatefulWidget {
  final PrescriptionModel prescription;

  const PrescriptionDetailsPage({super.key, required this.prescription});

  @override
  ConsumerState<PrescriptionDetailsPage> createState() => _PrescriptionDetailsPageState();
}

class _PrescriptionDetailsPageState extends ConsumerState<PrescriptionDetailsPage> {
  late TextEditingController _notesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.prescription.adminNotes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(prescriptionListProvider.notifier).updateStatus(
        widget.prescription.id,
        status,
        notes: _notesController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Statut mis à jour: $status')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showQuoteDialog() async {
    final amountController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Faire un devis'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Veuillez saisir le montant total du devis pour cette ordonnance.'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Montant (FCFA)',
                border: OutlineInputBorder(),
                prefixText: 'FCFA ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Veuillez entrer un montant valide')),
                 );
                 return;
              }
              Navigator.pop(context);

              setState(() => _isLoading = true);
              try {
                // Determine notes to send. Uses text from the main page controller.
                final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();
                
                await ref.read(prescriptionListProvider.notifier).sendQuote(
                  widget.prescription.id,
                  amount,
                  notes: notes,
                );
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Devis envoyé avec succès')),
                  );
                  Navigator.pop(context); // Go back to list
                }
              } catch (e) {
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Uses centralized base URL
    final baseUrl = AppConstants.storageBaseUrl; 

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails Ordonnance #${widget.prescription.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCustomerInfo(),
            const SizedBox(height: 16),
            _buildImages(baseUrl),
            const SizedBox(height: 16),
            _buildNotes(),
            const SizedBox(height: 24),
            if (widget.prescription.status == 'pending') _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    final customer = widget.prescription.customer;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Client', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Nom: ${customer?['name'] ?? 'Inconnu'}'),
            Text('Email: ${customer?['email'] ?? 'Non spécifié'}'),
            Text('Date: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(widget.prescription.createdAt))}'),
            if (widget.prescription.notes != null) ...[
              const SizedBox(height: 8),
              const Text('Notes du client:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(widget.prescription.notes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImages(String baseUrl) {
    final images = widget.prescription.images;
    if (images == null || images.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Aucune image jointe'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Images', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              // Ensure path format
              var path = images[index];
              if (path.startsWith('public/')) {
                 path = path.replaceFirst('public/', '');
              }
              final url = '$baseUrl$path';
              return Card(
                clipBehavior: Clip.hardEdge,
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, size: 50)),
                  loadingBuilder: (c, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              );
            },
          ),
        ),
        if (images.length > 1)
          Center(child: Text('${images.length} images (Swipe pour voir)')),
      ],
    );
  }

  Widget _buildNotes() {
    return TextField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes Pharmacien / Commentaire Devis',
        border: OutlineInputBorder(),
        hintText: 'Ajouter des détails sur le devis ou instructions...',
      ),
      maxLines: 3,
      enabled: widget.prescription.status == 'pending',
    );
  }

  Widget _buildActionButtons() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Row(
                children: [
                   Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showQuoteDialog,
                      icon: const Icon(Icons.request_quote),
                      label: const Text('Faire un Devis'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus('rejected'),
                      icon: const Icon(Icons.close),
                      label: const Text('Refuser'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Soft red
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus('validated'),
                      icon: const Icon(Icons.check),
                      label: const Text('Valider (Direct)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey, // De-emphasize direct validation
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
  }
}
