import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';
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

  PhoneNumber _pickupNumber = PhoneNumber(isoCode: 'BJ');
  PhoneNumber _destNumber = PhoneNumber(isoCode: 'BJ');

  final _addressService = AddressSearchService();
  
  Lieu? _selectedPickup;
  Lieu? _selectedDest;
  
  double? _distanceKm;
  List<double>? _prixSuggere;

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
        SnackBar(
          content: Text('Commande publiée avec succès !', style: GoogleFonts.poppins()),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires.', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, top: 24.h),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _buildAutocompleteField({
    required String hintText,
    required IconData icon,
    required Function(Lieu) onSelected,
  }) {
    return Autocomplete<Lieu>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Lieu>.empty();
        }
        return await _addressService.rechercherAdresse(textEditingValue.text);
      },
      displayStringForOption: (Lieu option) => option.adresse,
      onSelected: (Lieu selection) {
        onSelected(selection);
        _addressService.sauvegarderLieu(selection);
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return AppTextField(
          controller: textEditingController,
          focusNode: focusNode,
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
          hintText: hintText,
          prefixIcon: icon,
          validator: (val) => val == null || val.isEmpty ? 'Ce champ est requis' : null,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12.r),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200.h, maxWidth: MediaQuery.of(context).size.width - 32.w),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final Lieu option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20.sp),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              option.adresse,
                              style: GoogleFonts.poppins(fontSize: 14.sp),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAchat = widget.type == 'achat';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.text, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isAchat ? 'Nouvel Achat & Livraison' : 'Nouvelle Livraison',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('1. Informations sur la commande'),
              AppTextField(
                controller: _descController,
                hintText: isAchat ? 'Ex: 2 pains, 1 poulet rôti...' : 'Ex: Sac de vêtements, Documents...',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Description requise' : null,
              ),

              _buildSectionTitle(isAchat ? '2. Lieu d\'achat' : '2. Lieu de récupération'),
              _buildAutocompleteField(
                hintText: isAchat ? 'Où doit-on acheter ?' : 'Où récupérer le colis ?',
                icon: Icons.storefront_outlined,
                onSelected: (lieu) {
                  setState(() => _selectedPickup = lieu);
                  _calculatePrice();
                },
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    _pickupNumber = number;
                  },
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    useEmoji: true,
                  ),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  selectorTextStyle: TextStyle(color: Colors.black, fontSize: 14.sp),
                  initialValue: _pickupNumber,
                  textFieldController: _pickupPhoneController,
                  formatInput: false,
                  textStyle: TextStyle(fontSize: 14.sp, color: Colors.black),
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  inputDecoration: InputDecoration(
                    hintText: 'Numéro de contact sur place',
                    hintStyle: TextStyle(fontSize: 14.sp),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 12.h),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Numéro requis' : null,
                ),
              ),

              _buildSectionTitle('3. Lieu de livraison'),
              _buildAutocompleteField(
                hintText: 'Où livrer ?',
                icon: Icons.location_on_outlined,
                onSelected: (lieu) {
                  setState(() => _selectedDest = lieu);
                  _calculatePrice();
                },
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    _destNumber = number;
                  },
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    useEmoji: true,
                  ),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  selectorTextStyle: TextStyle(color: Colors.black, fontSize: 14.sp),
                  initialValue: _destNumber,
                  textFieldController: _destPhoneController,
                  formatInput: false,
                  textStyle: TextStyle(fontSize: 14.sp, color: Colors.black),
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  inputDecoration: InputDecoration(
                    hintText: 'Numéro du destinataire',
                    hintStyle: TextStyle(fontSize: 14.sp),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 12.h),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Numéro requis' : null,
                ),
              ),

              _buildSectionTitle('4. Options & Prix'),
              AppTextField(
                controller: _instructionsController,
                hintText: 'Instructions spéciales (Optionnel)',
                prefixIcon: Icons.info_outline,
                maxLines: 2,
              ),
              SizedBox(height: 16.h),

              if (_prixSuggere != null) ...[
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Distance estimée',
                            style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[700]),
                          ),
                          Text(
                            '~${_distanceKm?.toStringAsFixed(1)} km',
                            style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Divider(height: 24.h, color: AppColors.primary.withValues(alpha: 0.2)),
                      Text(
                        'Prix suggéré par le système',
                        style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        PricingLogic.formaterIntervalle(_prixSuggere!),
                        style: GoogleFonts.poppins(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              AppTextField(
                controller: _priceProposalController,
                hintText: 'Proposer votre propre prix (Optionnel)',
                prefixIcon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Publier la commande',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
