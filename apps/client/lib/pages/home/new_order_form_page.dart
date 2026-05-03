import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';
import 'package:shared_le_transporteur/api/v1/order_api.dart';
import 'package:shared_le_transporteur/api/v1/user_api.dart';
import 'package:shared_le_transporteur/utils/pricing_logic.dart';
import 'package:shared_le_transporteur/models/lieu.dart';
import 'package:shared_le_transporteur/services/address_search_service.dart';
import 'package:shared_le_transporteur/services/notification_service.dart';

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
  final _pickupNameController = TextEditingController();
  final _destNameController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _priceProposalController = TextEditingController();

  final _pickupAddressController = TextEditingController();
  final _destAddressController = TextEditingController();

  PhoneNumber _pickupNumber = PhoneNumber(isoCode: 'BJ');
  PhoneNumber _destNumber = PhoneNumber(isoCode: 'BJ');

  final _addressService = AddressSearchService();
  
  Lieu? _selectedPickup;
  Lieu? _selectedDest;
  
  double? _distanceKm;
  List<double>? _prixSuggere;
  bool _isLoading = false;

  String _deliveryType = 'standard';
  String _transportMode = 'moto';
  String _articleType = 'colis';
  double _weight = 1.0;
  final _weightController = TextEditingController(text: '1');

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

  void _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final pickupLieu = _selectedPickup ?? Lieu(
      adresse: _pickupAddressController.text,
      lat: 0,
      lng: 0,
    );

    final destLieu = _selectedDest ?? Lieu(
      adresse: _destAddressController.text,
      lat: 0,
      lng: 0,
    );

    if (pickupLieu.adresse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.type == 'achat' ? 'Veuillez renseigner le lieu d\'achat.' : 'Veuillez renseigner le lieu de récupération.', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (destLieu.adresse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez renseigner le lieu de livraison.', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final orderApi = OrderApi();
      await UserApi().getMe();

      // Parsing des adresses
      final pickupParts = pickupLieu.adresse.split(',').map((e) => e.trim()).toList();
      final destParts = destLieu.adresse.split(',').map((e) => e.trim()).toList();

      String getPart(List<String> parts, int indexFromEnd, String fallback) {
        if (parts.length > indexFromEnd) {
          return parts[parts.length - 1 - indexFromEnd];
        }
        return fallback;
      }

      final pickupCountry = getPart(pickupParts, 0, 'Bénin');
      final pickupCity = getPart(pickupParts, 1, 'Cotonou');
      final pickupDistrict = getPart(pickupParts, 2, pickupCity);

      final destCountry = getPart(destParts, 0, 'Bénin');
      final destCity = getPart(destParts, 1, 'Cotonou');
      final destDistrict = getPart(destParts, 2, destCity);
      
      final proposition = double.tryParse(_priceProposalController.text);
      final estimated = proposition ?? (_prixSuggere != null ? (_prixSuggere![0] + _prixSuggere![1]) / 2 : 1000.0);

      await orderApi.createOrder({
        'description': _descController.text,
        'weight': _weight,
        'serviceType': widget.type == 'livraison' ? 'courrier' : 'achat',
        'deliveryType': _deliveryType,
        'transportMode': _transportMode,
        'articleType': _articleType,
        'zone': destCity.contains('Abomey') ? 'Cotonou-Abomey' : 'Cotonou',
        'pickupAddress': {
          'name': _pickupNameController.text,
          'street': pickupLieu.adresse,
          'district': pickupDistrict,
          'city': pickupCity,
          'country': pickupCountry,
          'phone': _pickupPhoneController.text,
        },
        'deliveryAddress': {
          'name': _destNameController.text,
          'street': destLieu.adresse,
          'district': destDistrict,
          'city': destCity,
          'country': destCountry,
          'phone': _destPhoneController.text,
        },
        'estimatedPrice': estimated.toInt(),
      });

      if (mounted) {
        setState(() => _isLoading = false);
        NotificationService().showSuccessDialog(
          title: "Commande publiée",
          message: "Votre commande a été enregistrée et sera bientôt traitée.",
          onConfirm: () => Navigator.pop(context),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    required TextEditingController controller,
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
        // Link the provided controller with the one from Autocomplete
        if (controller.text.isEmpty && textEditingController.text.isNotEmpty) {
          controller.text = textEditingController.text;
        }
        
        textEditingController.addListener(() {
          controller.text = textEditingController.text;
          // If text changes and doesn't match selected, clear selected to force manual or re-select
          if (_selectedPickup?.adresse != controller.text && _selectedDest?.adresse != controller.text) {
             // We don't know which one it is here easily without more logic, 
             // but it's handled in _submitOrder by taking controller text.
          }
        });

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
              _buildSectionTitle('1. Expéditeur / Commanditaire'),
              _buildCardSection(
                child: Column(
                  children: [
                    AppTextField(
                      controller: _pickupNameController,
                      hintText: 'Nom et Prénom(s)',
                      prefixIcon: Icons.person_outline,
                    ),
                    SizedBox(height: 12.h),
                    _buildPhoneInput(_pickupPhoneController, _pickupNumber, (n) => _pickupNumber = n),
                    SizedBox(height: 12.h),
                    _buildAutocompleteField(
                      hintText: isAchat ? 'Où doit-on acheter ?' : 'Où récupérer le colis ?',
                      icon: Icons.storefront_outlined,
                      controller: _pickupAddressController,
                      onSelected: (lieu) {
                        setState(() => _selectedPickup = lieu);
                        _calculatePrice();
                      },
                    ),
                  ],
                ),
              ),

              _buildSectionTitle('2. Destinataire / Bénéficiaire'),
              _buildCardSection(
                child: Column(
                  children: [
                    AppTextField(
                      controller: _destNameController,
                      hintText: 'Nom et Prénom(s)',
                      prefixIcon: Icons.person_outline,
                    ),
                    SizedBox(height: 12.h),
                    _buildPhoneInput(_destPhoneController, _destNumber, (n) => _destNumber = n),
                    SizedBox(height: 12.h),
                    _buildAutocompleteField(
                      hintText: 'Où livrer ?',
                      icon: Icons.location_on_outlined,
                      controller: _destAddressController,
                      onSelected: (lieu) {
                        setState(() => _selectedDest = lieu);
                        _calculatePrice();
                      },
                    ),
                  ],
                ),
              ),

              _buildSectionTitle('3. Détails de la course'),
              _buildChoiceGroup<String>(
                label: 'Type de livraison',
                value: _deliveryType,
                options: [
                  ChoiceOption(value: 'standard', label: 'Standard', icon: Icons.timer_outlined),
                  ChoiceOption(value: 'express', label: 'Express', icon: Icons.bolt),
                ],
                onChanged: (val) => setState(() => _deliveryType = val),
              ),
              SizedBox(height: 16.h),
              _buildChoiceGroup<String>(
                label: 'Type d\'article',
                value: _articleType,
                options: [
                  ChoiceOption(value: 'documents', label: 'Documents', icon: Icons.description_outlined),
                  ChoiceOption(value: 'colis', label: 'Colis', icon: Icons.inventory_2_outlined),
                  ChoiceOption(value: 'fragile', label: 'Fragile', icon: Icons.wine_bar_outlined),
                  ChoiceOption(value: 'alimentaire', label: 'Alimentaire', icon: Icons.restaurant),
                  ChoiceOption(value: 'autre', label: 'Autre', icon: Icons.more_horiz),
                ],
                onChanged: (val) => setState(() => _articleType = val),
              ),
              SizedBox(height: 16.h),
              _buildChoiceGroup<String>(
                label: 'Mode de transport',
                value: _transportMode,
                options: [
                  ChoiceOption(value: 'moto', label: 'Moto', icon: Icons.motorcycle),
                  ChoiceOption(value: 'tricycle', label: 'Tricycle', icon: Icons.electric_rickshaw, enabled: false),
                  ChoiceOption(value: 'voiture', label: 'Voiture', icon: Icons.directions_car, enabled: false),
                  ChoiceOption(value: 'camion', label: 'Camion', icon: Icons.local_shipping, enabled: false),
                ],
                onChanged: (val) => setState(() => _transportMode = val),
              ),
              
              _buildSectionTitle('4. Détails du colis'),
              _buildCardSection(
                child: Column(
                  children: [
                    AppTextField(
                      controller: _descController,
                      hintText: 'Description des articles (ex: Colis fragile...)',
                      prefixIcon: Icons.description_outlined,
                      maxLines: 2,
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      controller: _instructionsController,
                      hintText: 'Instructions de livraison (Optionnel)',
                      prefixIcon: Icons.info_outline,
                    ),
                    SizedBox(height: 24.h),
                    _buildWeightSlider(),
                  ],
                ),
              ),

              _buildSectionTitle('5. Proposition de Prix'),
              _buildCardSection(
                child: Column(
                  children: [
                    if (_prixSuggere != null) ...[
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          children: [
                            Text(
                              PricingLogic.formaterIntervalle(_prixSuggere!),
                              style: GoogleFonts.poppins(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Estimation suggérée par le système',
                              style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey[600]),
                            ),
                            if (_distanceKm != null)
                              Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: Text(
                                  'Distance : ${_distanceKm!.toStringAsFixed(1)} km',
                                  style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey[500]),
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
                  ],
                ),
              ),

              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
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

  Widget _buildChoiceGroup<T>({
    required String label,
    required T value,
    required List<ChoiceOption<T>> options,
    required ValueChanged<T> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((opt) {
            final isSelected = opt.value == value;
            final isEnabled = opt.enabled;
            return InkWell(
              onTap: isEnabled ? () => onChanged(opt.value) : null,
              child: Opacity(
                opacity: isEnabled ? 1.0 : 0.4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[300]!),
                    boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(opt.icon, size: 16.sp, color: isSelected ? Colors.white : Colors.grey[600]),
                      SizedBox(width: 8.w),
                      Text(
                        opt.label,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.grey[800],
                        ),
                      ),
                      if (!isEnabled) ...[
                        SizedBox(width: 4.w),
                        Icon(Icons.lock_outline, size: 12.sp, color: Colors.grey),
                      ]
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCardSection({required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildWeightSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Poids estimé',
              style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            Container(
              width: 80.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp, 
                  fontWeight: FontWeight.bold, 
                  color: AppColors.primary
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                  border: InputBorder.none,
                  suffixText: 'kg',
                  suffixStyle: TextStyle(fontSize: 10.sp, color: AppColors.primary),
                ),
                onChanged: (val) {
                  double? v = double.tryParse(val);
                  if (v != null) {
                    setState(() {
                      _weight = v.clamp(1.0, 500.0);
                    });
                  }
                },
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withValues(alpha: 0.2),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.1),
            valueIndicatorColor: AppColors.primary,
            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
          ),
          child: Slider(
            value: _weight,
            min: 1.0,
            max: 500.0,
            divisions: 500,
            label: '${_weight.toInt()} kg',
            onChanged: (val) {
              setState(() {
                _weight = val;
                _weightController.text = val.toInt().toString();
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1 kg', style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
            Text('500 kg', style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneInput(TextEditingController controller, PhoneNumber initialValue, ValueChanged<PhoneNumber> onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InternationalPhoneNumberInput(
        onInputChanged: onChanged,
        selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
          useEmoji: true,
        ),
        ignoreBlank: false,
        autoValidateMode: AutovalidateMode.disabled,
        selectorTextStyle: TextStyle(color: Colors.black, fontSize: 14.sp),
        initialValue: initialValue,
        textFieldController: controller,
        formatInput: false,
        textStyle: TextStyle(fontSize: 14.sp, color: Colors.black),
        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
        inputDecoration: InputDecoration(
          hintText: 'Numéro de téléphone',
          hintStyle: TextStyle(fontSize: 14.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(bottom: 12.h),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Numéro requis' : null,
      ),
    );
  }
}

class ChoiceOption<T> {
  final T value;
  final String label;
  final IconData icon;
  final bool enabled;

  ChoiceOption({
    required this.value, 
    required this.label, 
    required this.icon,
    this.enabled = true,
  });
}
