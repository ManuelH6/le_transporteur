class RegistrationData {
  String? nomComplet;
  String? email;
  String? telephone;
  String? password;
  String? countryCode;
  String? genderrole;
  String? zone;
  String? vehiculeType;
  String? photoProfilePath;
  String? pieceIdentiteType;
  String? pieceIdentiteNumero;
  String? pieceIdentiteRectoPath;
  String? pieceIdentiteVersoPath;
  String? carteGrisePath;
  String? plaqueImmatriculation;
  String? numeroChassis;
  String? numeroCarteGrise;
  String? marqueVehicule;
  String? modeleVehicule;
  String? vehiculeCouleur;
  String? dateExpirationPiece;
  String? dateExpirationCarteGrise;
  String? ifuNumber;


  RegistrationData({
    this.nomComplet,
    this.email,
    this.telephone,
    this.password,
    this.countryCode,
    this.genderrole,
    this.zone,
    this.vehiculeType,
    this.photoProfilePath,
    this.pieceIdentiteType,
    this.pieceIdentiteNumero,
    this.pieceIdentiteRectoPath,
    this.pieceIdentiteVersoPath,
    this.carteGrisePath,
    this.plaqueImmatriculation,
    this.numeroChassis,
    this.numeroCarteGrise,
    this.marqueVehicule,
    this.modeleVehicule,
    this.vehiculeCouleur,
    this.dateExpirationPiece,
    this.dateExpirationCarteGrise,
    this.ifuNumber,
  });


  Map<String, dynamic> toJson() => {
        'nomComplet': nomComplet,
        'email': email,
        'telephone': telephone,
        'password': password,
        'countryCode': countryCode,
        'genderrole': genderrole,
        'zone': zone,
        'vehiculeType': vehiculeType,
        'photoProfilePath': photoProfilePath,
        'pieceIdentiteType': pieceIdentiteType,
        'pieceIdentiteNumero': pieceIdentiteNumero,
        'pieceIdentiteRectoPath': pieceIdentiteRectoPath,
        'pieceIdentiteVersoPath': pieceIdentiteVersoPath,
        'carteGrisePath': carteGrisePath,
        'plaqueImmatriculation': plaqueImmatriculation,
        'numeroChassis': numeroChassis,
        'numeroCarteGrise': numeroCarteGrise,
        'marqueVehicule': marqueVehicule,
        'modeleVehicule': modeleVehicule,
        'vehiculeCouleur': vehiculeCouleur,
        'dateExpirationPiece': dateExpirationPiece,
        'dateExpirationCarteGrise': dateExpirationCarteGrise,
        'ifuNumber': ifuNumber,
      };


  factory RegistrationData.fromJson(Map<String, dynamic> json) => RegistrationData(
        nomComplet: json['nomComplet'],
        email: json['email'],
        telephone: json['telephone'],
        password: json['password'],
        countryCode: json['countryCode'],
        genderrole: json['genderrole'],
        zone: json['zone'],
        vehiculeType: json['vehiculeType'],
        photoProfilePath: json['photoProfilePath'],
        pieceIdentiteType: json['pieceIdentiteType'],
        pieceIdentiteNumero: json['pieceIdentiteNumero'],
        pieceIdentiteRectoPath: json['pieceIdentiteRectoPath'],
        pieceIdentiteVersoPath: json['pieceIdentiteVersoPath'],
        carteGrisePath: json['carteGrisePath'],
        plaqueImmatriculation: json['plaqueImmatriculation'],
        numeroChassis: json['numeroChassis'],
        numeroCarteGrise: json['numeroCarteGrise'],
        marqueVehicule: json['marqueVehicule'],
        modeleVehicule: json['modeleVehicule'],
        vehiculeCouleur: json['vehiculeCouleur'],
        dateExpirationPiece: json['dateExpirationPiece'],
        dateExpirationCarteGrise: json['dateExpirationCarteGrise'],
        ifuNumber: json['ifuNumber'],
      );


  @override
  String toString() {
    return 'RegistrationData(nom: $nomComplet, email: $email, phone: $telephone, zone: $zone, vehicle: $vehiculeType)';
  }
}
