import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/core/app_dimensions.dart';
import 'package:shared_le_transporteur/core/app_theme.dart';
import 'package:shared_le_transporteur/models/commande.dart';
import 'package:shared_le_transporteur/models/lieu.dart';
import 'package:shared_le_transporteur/services/address_search_service.dart';
import 'package:shared_le_transporteur/services/mock_database.dart';
import 'package:shared_le_transporteur/utils/pricing_logic.dart';

class NewOrderFormPage extends StatefulWidget {
  final String type; // 'livraison' ou 'achat'

  const NewOrderFormPage({super.key, required this.type});

  @override
  State<NewOrderFormPage> createState() => _NewOrderFormPageState();
}

class _NewOrderFormPageState extends State<NewOrderFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _pickupPhoneController = TextEditingController();
  final _destPhoneController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _priceProposalController = TextEditingController();

  final _addressService = AddressSearchService();
  
  Lieu? _selectedPickup;
  Lieu? _selectedDest;
  
  double? _distanceKm;
  List<double>? _prixSuggere;

  // Simulate an async address search bottom sheet / modal for V1
  Future<Lieu?> _showAddressSearch(String title) async {
    // In a real app, we open a full-screen search or bottom sheet.
    // For this mock, we just present a simple dialog with dummy text logic
    // But we integrate the AddressSearchService behind the scenes.
    String query = '';
    return await showDialog<Lieu>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title, style: TextStyle(fontSize: AppDimensions.fontLg)),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Rechercher un lieu...'),
            onChanged: (val) => query = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (query.isNotEmpty) {
                  // Fallback Mock Logic
                  final res = Lieu(adresse: query, lat: 6.36, lng: 2.42);
                  await _addressService.sauvegarderLieu(res);
                  if (mounted) Navigator.pop(ctx, res);
                }
              },
              child: const Text('Valider'),
            ),
          ],
        );
      }
    );
  }

  void _calculatePrice() async {
    if (_selectedPickup != null && _selectedDest != null) {
      double dist = await _addressService.calculerDistance(_selectedPickup!, _selectedDest!);
      bool isFerie = PricingLogic.estJourFerie(DateTime.now());
      
      setState(() {
        _distanceKm = dist;
        _prixSuggere = PricingLogic.calculerIntervallePrix(dist, isFerie);
      });
    }
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate() && _selectedPickup != null && _selectedDest != null) {
      final proposition = double.tryParse(_priceProposalController.text);
      
      final commande = Commande(
        id: 'CMD-\${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        type: widget.type,
        description: _descController.text,
        pickup: _selectedPickup!,
        pickupPhone: _pickupPhoneController.text,
        livraison: _selectedDest!,
        livraisonPhone: _destPhoneController.text,
        instructions: _instructionsController.text.isNotEmpty ? _instructionsController.text : null,
        prixSuggere: _prixSuggere ?? [1000.0, 2000.0],
        propositionClient: proposition,
        statut: 'Disponible',
        dateCreation: DateTime.now(),
      );

      MockDatabase().ajouterCommande(commande);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande publiée avec succès !'), backgroundColor: AppTheme.successColor),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires.'), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == 'achat' ? 'Nouvel Achat' : 'Nouvelle Livraison', style: TextStyle(fontSize: AppDimensions.fontLg)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.paddingMd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '1. Informations',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: AppDimensions.paddingMd),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (Obligatoire)',
                  hintText: 'Ex: Sac de riz, Téléphone...',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Description requise' : null,
              ),
              SizedBox(height: AppDimensions.paddingXl),

              Text(
                '2. Prise en charge',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: AppDimensions.paddingMd),
              InkWell(
                onTap: () async {
                  final lieu = await _showAddressSearch('Lieu de prise en charge');
                  if (lieu != null) {
                    setState(() => _selectedPickup = lieu);
                    _calculatePrice();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(AppDimensions.paddingMd),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.trip_origin, color: AppTheme.primaryColor),
                      SizedBox(width: AppDimensions.paddingMd),
                      Expanded(
                        child: Text(
                          _selectedPickup?.adresse ?? 'Choisir le lieu de récupération',
                          style: TextStyle(
                            color: _selectedPickup == null ? Colors.grey : AppTheme.textPrimary,
                            fontSize: AppDimensions.fontMd
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.paddingMd),
              TextFormField(
                controller: _pickupPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact au lieu de retrait',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Numéro de contact requis' : null,
              ),
              SizedBox(height: AppDimensions.paddingXl),

              Text(
                '3. Livraison',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: AppDimensions.paddingMd),
              InkWell(
                onTap: () async {
                  final lieu = await _showAddressSearch('Lieu de livraison');
                  if (lieu != null) {
                    setState(() => _selectedDest = lieu);
                    _calculatePrice();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(AppDimensions.paddingMd),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: AppTheme.secondaryColor),
                      SizedBox(width: AppDimensions.paddingMd),
                      Expanded(
                        child: Text(
                          _selectedDest?.adresse ?? 'Choisir le lieu de livraison',
                          style: TextStyle(
                            color: _selectedDest == null ? Colors.grey : AppTheme.textPrimary,
                            fontSize: AppDimensions.fontMd
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.paddingMd),
              TextFormField(
                controller: _destPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact à la livraison',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Numéro de contact requis' : null,
              ),
              SizedBox(height: AppDimensions.paddingXl),

              Text(
                '4. Options & Prix',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: AppDimensions.paddingMd),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions spéciales (Optionnel)',
                  hintText: 'Ex: Appeler avant, Urgent...',
                ),
              ),
              SizedBox(height: AppDimensions.paddingLg),

              if (_prixSuggere != null) ...[
                Container(
                  padding: EdgeInsets.all(AppDimensions.paddingMd),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Distance estimée : ~${_distanceKm?.toStringAsFixed(1)} km',
                        style: TextStyle(fontSize: AppDimensions.fontSm, color: AppTheme.textSecondary),
                      ),
                      SizedBox(height: AppDimensions.paddingSm),
                      Text(
                        'Prix suggéré',
                        style: TextStyle(fontSize: AppDimensions.fontMd, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\${_prixSuggere![0].toInt()} - \${_prixSuggere![1].toInt()} FCFA',
                        style: TextStyle(fontSize: AppDimensions.fontXl, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDimensions.paddingMd),
              ],

              TextFormField(
                controller: _priceProposalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Proposer votre propre prix (FCFA)',
                  hintText: 'Optionnel',
                  prefixIcon: Icon(Icons.money),
                ),
              ),

              SizedBox(height: AppDimensions.paddingXl * 1.5),

              ElevatedButton(
                onPressed: _submitOrder,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, AppDimensions.buttonHeight),
                ),
                child: Text(
                  'Publier la commande',
                  style: TextStyle(fontSize: AppDimensions.fontLg, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: AppDimensions.paddingXl),
            ],
          ),
        ),
      ),
    );
  }
}
