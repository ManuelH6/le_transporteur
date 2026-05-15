import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';
import 'package:shared_le_transporteur/api/v1/order_api.dart';
import 'package:shared_le_transporteur/api/v1/user_api.dart';
import 'package:shared_le_transporteur/utils/pricing_logic.dart';
import 'package:shared_le_transporteur/models/lieu.dart';
import 'package:shared_le_transporteur/services/address_search_service.dart';
import 'package:shared_le_transporteur/services/notification_service.dart';
import 'package:shared_le_transporteur/services/favorites_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class NewOrderFormPage extends StatefulWidget {
  final String type; // 'livraison' ou 'achat'

  const NewOrderFormPage({super.key, required this.type});

  @override
  State<NewOrderFormPage> createState() => _NewOrderFormPageState();
}

class _NewOrderFormPageState extends State<NewOrderFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  
  // Controllers
  final _descController = TextEditingController();
  final _pickupPhoneController = TextEditingController();
  final _destPhoneController = TextEditingController();
  final _pickupNameController = TextEditingController();
  final _destNameController = TextEditingController();
  final _instructionsController = TextEditingController();
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

  // Form State
  String _deliveryType = 'standard';
  String _transportMode = 'moto';
  String _articleType = 'colis';
  double _weight = 1.0;
  
  // Scheduling
  bool _isScheduled = false;
  DateTime? _scheduledAt;

  // Manual Entry State
  bool _isManualPickup = true;
  bool _isManualDest = true;
  
  final List<String> _beninCities = [
    'Cotonou',
    'Porto-Novo',
    'Bohicon',
    'Natitingou',
    'Abomey',
    'Parakou',
    'Lokossa',
    'Ouidah',
    'Zè',
    'Sèmè-Kraké',
    'Sèmè-Podji',
    'Pahou',
  ];

  final _pickupCityController = TextEditingController(text: 'Cotonou');
  final _pickupStreetController = TextEditingController();
  final _destCityController = TextEditingController(text: 'Cotonou');
  final _destStreetController = TextEditingController();
  
  List<Lieu> _favoriteLieux = [];
  String _currentCountry = 'Bénin';
  bool _showCountrySelector = false;
  String _userAccountCountry = 'Bénin';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadFavorites();
    _detectLocationAndCheckCountry();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = await UserApi().getMe();
      if (mounted && user != null) {
        String originalPhone = user.phoneNumber ?? '';
        String strippedPhone = originalPhone.replaceAll(RegExp(r'^\+229|^\+228|^\+242|^229|^228|^242'), '').trim();
        
        PhoneNumber? detectedNumber;
        try {
          if (originalPhone.startsWith('+')) {
            detectedNumber = await PhoneNumber.getRegionInfoFromPhoneNumber(originalPhone);
          }
        } catch (e) {
          debugPrint("Region detection failed: $e");
        }

        setState(() {
          if (widget.type == 'livraison') {
            _pickupNameController.text = user.name;
            _pickupPhoneController.text = strippedPhone;
            if (detectedNumber != null) _pickupNumber = detectedNumber!;
          } else {
            _destNameController.text = user.name;
            _destPhoneController.text = strippedPhone;
            if (detectedNumber != null) _destNumber = detectedNumber!;
          }
          _userAccountCountry = 'Bénin';
          _currentCountry = _userAccountCountry;
        });
      }
    } catch (e) {
      debugPrint("Error fetching user for default values: $e");
    }
  }

  Future<void> _pickContact(TextEditingController nameCtrl, TextEditingController phoneCtrl, Function(PhoneNumber) onPhoneChanged) async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final contact = await FlutterContacts.openExternalPick();
        if (contact != null) {
          final fullContact = await FlutterContacts.getContact(contact.id);
          if (fullContact != null) {
            String? originalPhone;
            String? strippedPhone;

            if (fullContact.phones.isNotEmpty) {
               originalPhone = fullContact.phones.first.number;
               // Nettoyer le numéro (enlever espaces, tirets, etc.)
               String clean = originalPhone.replaceAll(RegExp(r'[^0-9+]'), '');
               // Retirer l'indicateur (+229, +228, +242 etc.) si présent
               strippedPhone = clean.replaceAll(RegExp(r'^\+229|^\+228|^\+242|^229|^228|^242'), '').trim();
            }

            PhoneNumber? detectedNumber;
            if (originalPhone != null && originalPhone.startsWith('+')) {
              try {
                detectedNumber = await PhoneNumber.getRegionInfoFromPhoneNumber(originalPhone);
              } catch (e) {
                debugPrint("Contact region detection failed: $e");
              }
            }

            setState(() {
              nameCtrl.text = fullContact.displayName;
              if (strippedPhone != null) {
                phoneCtrl.text = strippedPhone;
              }
              if (detectedNumber != null) {
                onPhoneChanged(detectedNumber!);
              }
            });
          }
        }
      } else {
        NotificationService().showError("Permission d'accès aux contacts refusée.");
      }
    } catch (e) {
      debugPrint("Error picking contact: $e");
      NotificationService().showError("Erreur lors de la sélection du contact.");
    }
  }

  Future<void> _detectLocationAndCheckCountry() async {
    try {
      // Import geolocator if not already present
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      
      final country = await _addressService.reverseGeocodeCountry(
        position.latitude, 
        position.longitude
      );

      if (mounted && country != null) {
        debugPrint("Detected country: $country");
        setState(() {
          if (country != _userAccountCountry) {
            _showCountrySelector = true;
          } else {
            _showCountrySelector = false;
          }
          _currentCountry = country;
        });
      }
    } catch (e) {
      debugPrint("Location detection failed: $e. Using account country.");
    }
  }

  void _loadFavorites() {
    setState(() {
      _favoriteLieux = FavoritesService.getFavorites();
    });
  }

  Future<void> _toggleManualFavorite({
    required TextEditingController cityCtrl,
    required TextEditingController streetCtrl,
  }) async {
    final adresse = "${streetCtrl.text}, ${cityCtrl.text}, $_currentCountry";
    if (streetCtrl.text.isEmpty || cityCtrl.text.isEmpty) {
      NotificationService().showError("Veuillez remplir au moins la ville et l'adresse pour ajouter aux favoris.");
      return;
    }
    
    final lieu = Lieu(adresse: adresse, lat: 0, lng: 0, isFavorite: true);
    if (!FavoritesService.isFavorite(adresse)) {
      await FavoritesService.toggleFavorite(lieu);
      _loadFavorites();
      NotificationService().showSuccess("Lieu ajouté aux favoris");
    } else {
      NotificationService().showInfo("Ce lieu est déjà dans vos favoris.");
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pickupCityController.dispose();
    _pickupStreetController.dispose();
    _destCityController.dispose();
    _destStreetController.dispose();
    super.dispose();
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

  void _nextStep() {
    FocusScope.of(context).unfocus(); // Fermer le clavier
    if (_currentStep < 2) {
      // Basic validation for Step 0 (Addresses)
      if (_currentStep == 0) {
        if (!_isManualPickup && _selectedPickup == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Veuillez sélectionner le lieu de retrait dans la liste suggérée ou passer en saisie manuelle.")),
          );
          return;
        }
        if (!_isManualDest && _selectedDest == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Veuillez sélectionner le lieu de livraison dans la liste suggérée ou passer en saisie manuelle.")),
          );
          return;
        }

        // Validation des contacts
        if (_pickupNameController.text.isEmpty || _pickupPhoneController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Veuillez renseigner le nom et le téléphone du contact de retrait.")),
          );
          return;
        }
        if (_destNameController.text.isEmpty || _destPhoneController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Veuillez renseigner le nom et le téléphone du destinataire.")),
          );
          return;
        }

        final hasPickup = _isManualPickup 
            ? (_pickupCityController.text.isNotEmpty && _pickupStreetController.text.isNotEmpty)
            : (_selectedPickup != null);
            
        final hasDest = _isManualDest
            ? (_destCityController.text.isNotEmpty && _destStreetController.text.isNotEmpty)
            : (_selectedDest != null);

        if (!hasPickup || !hasDest) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Veuillez remplir tous les champs d'adresse requis.")),
          );
          return;
        }
      }
      
      // Validation for Step 1 (Package Details)
      if (_currentStep == 1) {
        if (_descController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Veuillez décrire le colis à transporter.")),
          );
          return;
        }
      }
      
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitOrder();
    }
  }

  void _previousStep() {
    FocusScope.of(context).unfocus(); // Fermer le clavier
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final selected = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      
      if (selected.isBefore(now)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Veuillez choisir une heure future.")),
          );
        }
        return;
      }

      setState(() {
        _scheduledAt = selected;
      });
    }
  }

  void _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final pickupLieu = _isManualPickup 
        ? Lieu(adresse: "${_pickupStreetController.text}, ${_pickupCityController.text}, $_currentCountry", lat: 0, lng: 0)
        : (_selectedPickup ?? Lieu(adresse: _pickupAddressController.text, lat: 0, lng: 0));
        
    final destLieu = _isManualDest
        ? Lieu(adresse: "${_destStreetController.text}, ${_destCityController.text}, $_currentCountry", lat: 0, lng: 0)
        : (_selectedDest ?? Lieu(adresse: _destAddressController.text, lat: 0, lng: 0));

    setState(() => _isLoading = true);
    try {
      final orderApi = OrderApi();
      await UserApi().getMe();

      final pickupParts = pickupLieu.adresse.split(',').map((e) => e.trim()).toList();
      final destParts = destLieu.adresse.split(',').map((e) => e.trim()).toList();

      String getPart(List<String> parts, int indexFromEnd, String fallback) {
        if (parts.length > indexFromEnd) return parts[parts.length - 1 - indexFromEnd];
        return fallback;
      }

      final pickupCity = _isManualPickup ? _pickupCityController.text : getPart(pickupParts, 2, 'Cotonou');
      final pickupDistrict = _isManualPickup ? _pickupStreetController.text.split(',').first : getPart(pickupParts, 3, pickupCity);
      final destCity = _isManualDest ? _destCityController.text : getPart(destParts, 2, 'Cotonou');
      final destDistrict = _isManualDest ? _destStreetController.text.split(',').first : getPart(destParts, 3, destCity);
      
      if (_articleType.toLowerCase() != 'colis') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Note : Votre demande sera traitée comme un 'Colis' (seul type supporté actuellement)."),
            backgroundColor: Colors.orange,
          ),
        );
      }

      final payload = {
        'description': _descController.text,
        'weight': _weight,
        'serviceType': 'courrier',
        'deliveryType': _deliveryType,
        'transportMode': _transportMode.toUpperCase(),
        'articleType': 'colis', // Toujours envoyer colis selon le feedback backend
        'zone': 'Cotonou',
        'pickupAddress': {
          'name': _pickupNameController.text,
          'street': pickupLieu.adresse,
          'district': pickupDistrict,
          'city': pickupCity,
          'country': getPart(pickupParts, 0, 'Bénin'),
          'phone': _pickupPhoneController.text,
          'latitude': null,
          'longitude': null,
        },
        'deliveryAddress': {
          'name': _destNameController.text,
          'street': destLieu.adresse,
          'district': destDistrict,
          'city': destCity,
          'country': getPart(destParts, 0, 'Bénin'),
          'phone': _destPhoneController.text,
          'latitude': null,
          'longitude': null,
        },
        'estimatedPrice': null,
        'isScheduled': _isScheduled,
        'scheduledAt': _isScheduled 
            ? (_scheduledAt?.toUtc().toIso8601String() ?? DateTime.now().toUtc().toIso8601String())
            : DateTime.now().toUtc().toIso8601String(),
      };
      
      //debugPrint("DEBUG [NewOrderForm] Creating order with payload: ${jsonEncode(payload)}");
      await orderApi.createOrder(payload);

      // Sauvegarder les adresses dans l'historique
      await _addressService.sauvegarderLieu(pickupLieu);
      await _addressService.sauvegarderLieu(destLieu);

      if (mounted) {
        setState(() => _isLoading = false);
        NotificationService().showSuccessDialog(
          title: "Commande publiée",
          message: "Votre commande a été envoyée avec succès aux livreurs à proximité.",
          onConfirm: () => Navigator.pop(context),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        NotificationService().showError(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: AppColors.text, size: 24.sp),
            onPressed: _isLoading ? null : () => Navigator.pop(context),
          ),
          title: Column(
            children: [
              Text(
                widget.type == 'achat' ? 'Nouvel Achat' : 'Nouvelle Livraison',
                style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.text),
              ),
              Text(
                "Étape ${_currentStep + 1} sur 3",
                style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                _buildProgressBar(),
                Expanded(
                  child: AbsorbPointer(
                    absorbing: _isLoading,
                    child: Form(
                      key: _formKey,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (step) => setState(() => _currentStep = step),
                        children: [
                          _buildStep1(), // Adresses
                          _buildStep2(), // Colis
                          _buildStep3(), // Logistique
                        ],
                      ),
                    ),
                  ),
                ),
                AbsorbPointer(
                  absorbing: _isLoading,
                  child: _buildBottomNavigation(),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 20.h),
                          Text(
                            "Traitement en cours...",
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Veuillez patienter un instant",
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 4.h,
      width: double.infinity,
      color: Colors.grey[200],
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (_currentStep + 1) / 3,
        child: Container(color: AppColors.primary),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Où se trouve le colis ?", "Indiquez les points de retrait et de livraison."),
          SizedBox(height: 24.h),
          _buildCard(
            title: widget.type == 'achat' ? "Où aller acheter ?" : "Point de retrait",
            icon: Icons.trip_origin,
            color: Colors.blue,
            child: Column(
              children: [
                AppTextField(
                  controller: _pickupNameController,
                  labelText: 'Nom du contact',
                  hintText: 'Qui remet le colis ?',
                  prefixIcon: Icons.person_outline,
                  isRequired: true,
                  validator: (val) => val == null || val.isEmpty ? 'Nom requis' : null,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.contact_phone_outlined, color: AppColors.primary),
                    onPressed: () => _pickContact(_pickupNameController, _pickupPhoneController, (p) => _pickupNumber = p),
                  ),
                ),
                SizedBox(height: 12.h),
                _buildPhoneInput(_pickupPhoneController, _pickupNumber, (n) => _pickupNumber = n, validator: (val) => val == null || val.isEmpty ? 'Téléphone requis' : null),
                if (_favoriteLieux.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _buildFavoritesSelector(isPickup: true),
                ],
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Adresse", style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                    TextButton(
                      onPressed: () => setState(() {
                        _isManualPickup = !_isManualPickup;
                        _selectedPickup = null;
                      }),
                      child: Text(_isManualPickup ? "Utiliser la carte (GPS)" : "Saisir manuellement", style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.primary)),
                    ),
                  ],
                ),
                if (!_isManualPickup)
                  _buildAutocompleteField(
                    hintText: widget.type == 'achat' ? 'Où doit-on acheter ?' : 'Adresse exacte de retrait',
                    icon: Icons.map_outlined,
                    controller: _pickupAddressController,
                    onSelected: (lieu) {
                      setState(() {
                        _selectedPickup = lieu;
                        _pickupAddressController.text = lieu.adresse;
                      });
                      _calculatePrice();
                    },
                  )
                else
                  Column(
                    children: [
                      _buildManualAddressFields(
                        cityController: _pickupCityController,
                        streetController: _pickupStreetController,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          _buildCard(
            title: widget.type == 'achat' ? "Où livrer ?" : "Destination",
            icon: Icons.location_on,
            color: Colors.green,
            child: Column(
              children: [
                AppTextField(
                  controller: _destNameController,
                  labelText: 'Nom du destinataire',
                  hintText: 'Qui reçoit le colis ?',
                  prefixIcon: Icons.person_outline,
                  isRequired: true,
                  validator: (val) => val == null || val.isEmpty ? 'Nom requis' : null,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.contact_phone_outlined, color: AppColors.primary),
                    onPressed: () => _pickContact(_destNameController, _destPhoneController, (p) => _destNumber = p),
                  ),
                ),
                SizedBox(height: 12.h),
                _buildPhoneInput(_destPhoneController, _destNumber, (n) => _destNumber = n, validator: (val) => val == null || val.isEmpty ? 'Téléphone requis' : null),
                if (_favoriteLieux.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _buildFavoritesSelector(isPickup: false),
                ],
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Adresse de livraison", style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                    TextButton(
                      onPressed: () => setState(() {
                        _isManualDest = !_isManualDest;
                        _selectedDest = null;
                      }),
                      child: Text(_isManualDest ? "Utiliser la carte (GPS)" : "Saisir manuellement", style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.primary)),
                    ),
                  ],
                ),
                if (!_isManualDest)
                  _buildAutocompleteField(
                    hintText: 'Adresse exacte de livraison',
                    icon: Icons.map_outlined,
                    controller: _destAddressController,
                    onSelected: (lieu) {
                      setState(() {
                        _selectedDest = lieu;
                        _destAddressController.text = lieu.adresse;
                      });
                      _calculatePrice();
                    },
                  )
                else
                  _buildManualAddressFields(
                    cityController: _destCityController,
                    streetController: _destStreetController,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Que transportons-nous ?", "Détails sur l'objet de la course."),
          SizedBox(height: 24.h),
          _buildCard(
            title: "Description du colis",
            icon: Icons.inventory_2_outlined,
            child: Column(
              children: [
                _buildChoiceGroup<String>(
                  label: "Type d'article",
                  value: _articleType,
                  options: [
                    ChoiceOption(value: 'colis', label: 'Colis', icon: Icons.inventory_2_outlined),
                    ChoiceOption(value: 'documents', label: 'Documents', icon: Icons.description_outlined),
                    ChoiceOption(value: 'alimentaire', label: 'Repas', icon: Icons.restaurant),
                    ChoiceOption(value: 'fragile', label: 'Fragile', icon: Icons.wine_bar_outlined),
                  ],
                  onChanged: (val) => setState(() => _articleType = val),
                ),
                SizedBox(height: 16.h),
                AppTextField(
                  controller: _descController,
                  labelText: 'Description du contenu',
                  hintText: 'Ex: Sac de vêtements, Repas chaud...',
                  prefixIcon: Icons.edit_note,
                  isRequired: true,
                  maxLines: 2,
                  validator: (val) => val == null || val.isEmpty 
                      ? 'La description est obligatoire. Il est important que le livreur sache ce qu\'il doit transporter.' 
                      : null,
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          _buildCard(
            title: "Poids estimé",
            icon: Icons.scale_outlined,
            child: _buildWeightSelector(),
          ),
          SizedBox(height: 20.h),
          AppTextField(
            controller: _instructionsController,
            hintText: 'Instructions particulières (Optionnel)',
            prefixIcon: Icons.info_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Logistique & Timing", "Choisissez comment et quand livrer."),
          SizedBox(height: 24.h),
          _buildCard(
            title: "Options de livraison",
            icon: Icons.bolt,
            child: Column(
              children: [
                _buildChoiceGroup<String>(
                  label: "Rapidité",
                  value: _deliveryType,
                  options: [
                    ChoiceOption(value: 'standard', label: 'Standard', icon: Icons.timer_outlined),
                    ChoiceOption(value: 'express', label: 'Express', icon: Icons.bolt),
                  ],
                  onChanged: (val) => setState(() => _deliveryType = val),
                ),
                SizedBox(height: 20.h),
                _buildChoiceGroup<String>(
                  label: "Transport",
                  value: _transportMode,
                  options: [
                    ChoiceOption(value: 'moto', label: 'Moto', icon: Icons.motorcycle),
                    ChoiceOption(value: 'tricycle', label: 'Tricycle', icon: Icons.electric_rickshaw, enabled: false),
                    ChoiceOption(value: 'voiture', label: 'Voiture', icon: Icons.directions_car, enabled: false),
                    ChoiceOption(value: 'camion', label: 'Camion', icon: Icons.local_shipping, enabled: false),
                  ],
                  onChanged: (val) => setState(() => _transportMode = val),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          _buildCard(
            title: "Planification",
            icon: Icons.calendar_month_outlined,
            child: Column(
              children: [
                SwitchListTile(
                  value: _isScheduled,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  title: Text("Programmer à l'avance", style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  onChanged: (val) => setState(() => _isScheduled = val),
                ),
                if (_isScheduled) ...[
                  SizedBox(height: 12.h),
                  InkWell(
                    onTap: _selectTime,
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time, color: AppColors.primary),
                          SizedBox(width: 12.w),
                          Text(
                            _scheduledAt == null 
                                ? "Choisir l'heure" 
                                : "Aujourd'hui à ${DateFormat('HH:mm').format(_scheduledAt!)}",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSelector() {
    final weightOptions = [
      {'label': '< 2kg', 'value': 1.0},
      {'label': '2-5kg', 'value': 4.0},
      {'label': '5-10kg', 'value': 8.0},
      {'label': '> 10kg', 'value': 15.0},
    ];

    return Wrap(
      spacing: 8.w,
      runSpacing: 0,
      children: weightOptions.map((opt) {
        final isSelected = _weight == opt['value'];
        return ChoiceChip(
          label: Text(opt['label'] as String),
          selected: isSelected,
          onSelected: (val) => setState(() => _weight = opt['value'] as double),
          selectedColor: AppColors.primary,
          pressElevation: 0,
          labelPadding: EdgeInsets.symmetric(horizontal: 8.w),
          visualDensity: VisualDensity.compact,
          labelStyle: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.bold)),
        Text(subtitle, style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildCard({required String title, required IconData icon, Color? color, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color ?? AppColors.primary),
              SizedBox(width: 12.w),
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15.sp)),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text("Précédent", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ),
            ),
          if (_currentStep > 0) SizedBox(width: 16.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _currentStep == 2 ? "Confirmer" : "Continuer",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesSelector({required bool isPickup}) {
    final displayedLieux = _favoriteLieux.take(3).toList();
    final hasMore = _favoriteLieux.length > 3;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Lieux suggérés",
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            if (hasMore)
              GestureDetector(
                onTap: () => _showAllFavoritesPicker(isPickup: isPickup),
                child: Text(
                  "Voir tout",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 6.h),
        SizedBox(
          height: 36.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayedLieux.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < displayedLieux.length) {
                final lieu = displayedLieux[index];
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ActionChip(
                    avatar: Icon(Icons.star, size: 12.sp, color: Colors.orange),
                    label: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 120.w),
                      child: Text(
                        lieu.adresse.split(',').first,
                        style: GoogleFonts.poppins(fontSize: 11.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    onPressed: () => _applyLieu(lieu, isPickup: isPickup),
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ActionChip(
                    avatar: Icon(Icons.more_horiz, size: 14.sp, color: AppColors.primary),
                    label: Text("Plus", style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                    onPressed: () => _showAllFavoritesPicker(isPickup: isPickup),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void _showAllFavoritesPicker({required bool isPickup}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tous vos favoris",
              style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _favoriteLieux.length,
                separatorBuilder: (_, __) => Divider(color: Colors.grey[100]),
                itemBuilder: (context, index) {
                  final lieu = _favoriteLieux[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.star, color: Colors.orange, size: 20),
                    ),
                    title: Text(lieu.adresse.split(',').first, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: Text(lieu.adresse, style: GoogleFonts.poppins(fontSize: 12.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      Navigator.pop(context);
                      _applyLieu(lieu, isPickup: isPickup);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApplyFavoriteDialog(Lieu lieu) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Utiliser ce favori",
              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              lieu.adresse,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _applyLieu(lieu, isPickup: true);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text("Comme Retrait", style: GoogleFonts.poppins(color: Colors.white, fontSize: 13.sp)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _applyLieu(lieu, isPickup: false);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text("Comme Livraison", style: GoogleFonts.poppins(color: Colors.white, fontSize: 13.sp)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _applyLieu(Lieu lieu, {required bool isPickup}) {
    // Si lat/lng sont à 0, c'est un lieu saisi manuellement
    bool isManual = (lieu.lat == 0 && lieu.lng == 0);

    setState(() {
      if (isPickup) {
        _isManualPickup = isManual;
        if (isManual) {
          // Extraire la rue de l'adresse combinée (Rue, Ville, Pays)
          final parts = lieu.adresse.split(',');
          _pickupStreetController.text = parts[0].trim();
          if (parts.length > 1) _pickupCityController.text = parts[1].trim();
        } else {
          _selectedPickup = lieu;
          _pickupAddressController.text = lieu.adresse;
        }
      } else {
        _isManualDest = isManual;
        if (isManual) {
          final parts = lieu.adresse.split(',');
          _destStreetController.text = parts[0].trim();
          if (parts.length > 1) _destCityController.text = parts[1].trim();
        } else {
          _selectedDest = lieu;
          _destAddressController.text = lieu.adresse;
        }
      }
    });
    if (!isManual) _calculatePrice();
  }

  // Utilities copied from original version for phone and autocomplete
  Widget _buildPhoneInput(TextEditingController controller, PhoneNumber initial, Function(PhoneNumber) onInputChanged, {String? Function(String?)? validator}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InternationalPhoneNumberInput(
        onInputChanged: onInputChanged,
        textFieldController: controller,
        initialValue: initial,
        selectorConfig: const SelectorConfig(selectorType: PhoneInputSelectorType.BOTTOM_SHEET, showFlags: true),
        ignoreBlank: false,
        autoValidateMode: AutovalidateMode.onUserInteraction,
        selectorTextStyle: GoogleFonts.poppins(color: Colors.black),
        formatInput: true,
        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
        inputDecoration: InputDecoration(
          hintText: 'Téléphone',
          hintStyle: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey),
          border: InputBorder.none,
          isDense: true,
        ),
        validator: validator,
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
      displayStringForOption: (Lieu option) => option.adresse,
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) return const Iterable<Lieu>.empty();
        return await _addressService.rechercherAdresse(textEditingValue.text);
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return AppTextField(
          controller: controller,
          hintText: hintText,
          prefixIcon: icon,
          focusNode: focusNode,
          isRequired: true,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8.0,
            borderRadius: BorderRadius.circular(12.r),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 250.h, maxWidth: MediaQuery.of(context).size.width - 48.w),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final Lieu option = options.elementAt(index);
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                    title: Text(option.adresse, style: GoogleFonts.poppins(fontSize: 13.sp)),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
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
        Text(label, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.grey[700])),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((opt) {
            final isSelected = opt.value == value;
            return InkWell(
              onTap: opt.enabled ? () => onChanged(opt.value) : null,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(opt.icon, size: 14.sp, color: isSelected ? Colors.white : Colors.grey[600]),
                    SizedBox(width: 6.w),
                    Text(
                      opt.label,
                      style: GoogleFonts.poppins(fontSize: 12.sp, color: isSelected ? Colors.white : Colors.grey[800], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    ),
                  ],
                ),
              ),
            );
          }).toList().cast<Widget>(),
        ),
      ],
    );
  }

  Widget _buildManualAddressFields({
    required TextEditingController cityController,
    required TextEditingController streetController,
  }) {
    return Column(
      children: [
        if (_showCountrySelector)
          Column(
            children: [
              AppTextField(
                controller: TextEditingController(text: _currentCountry),
                labelText: 'Pays détecté',
                hintText: 'Pays',
                prefixIcon: Icons.public,
                readOnly: true,
                onTap: () {
                   // Allow changing country if needed
                   _showCountryPicker();
                },
              ),
              SizedBox(height: 12.h),
            ],
          ),
        // Dropdown pour la ville
        DropdownButtonFormField<String>(
          value: _beninCities.contains(cityController.text) ? cityController.text : _beninCities.first,
          items: _beninCities.map((city) => DropdownMenuItem(
            value: city,
            child: Text(city, style: GoogleFonts.poppins(fontSize: 14.sp)),
          )).toList(),
          onChanged: (val) => setState(() => cityController.text = val!),
          decoration: InputDecoration(
            labelText: 'Ville *',
            labelStyle: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[700], fontWeight: FontWeight.w500),
            floatingLabelStyle: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.primary, fontWeight: FontWeight.w600),
            hintText: 'Ville',
            prefixIcon: Icon(Icons.location_city, color: Colors.grey[500], size: 20.sp),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        AppTextField(
          controller: streetController,
          labelText: 'Adresse & Indications',
          hintText: 'Quartier, Rue, Maison ou repère...',
          prefixIcon: Icons.location_on_outlined,
          isRequired: true,
        ),
        SizedBox(height: 12.h),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _toggleManualFavorite(
              cityCtrl: cityController,
              streetCtrl: streetController,
            ),
            icon: const Icon(Icons.star_outline, size: 18, color: AppColors.primary),
            label: Text("Ajouter aux favoris", style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  void _showCountryPicker() {
    final countries = ['Bénin', 'Togo', 'Congo', 'Côte d\'Ivoire', 'Nigeria', 'Ghana'];
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Changer de pays", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            ...countries.map((c) => ListTile(
              title: Text(c, style: GoogleFonts.poppins()),
              trailing: _currentCountry == c ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                setState(() => _currentCountry = c);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}

class ChoiceOption<T> {
  final T value;
  final String label;
  final IconData icon;
  final bool enabled;

  ChoiceOption({required this.value, required this.label, required this.icon, this.enabled = true});
}
