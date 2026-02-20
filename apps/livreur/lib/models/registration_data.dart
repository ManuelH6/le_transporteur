class RegistrationData {
  String? nomComplet;
  String? email;
  String? telephone;
  String? password;
  String? countryCode;
  String? zone;
  String? vehiculeType;
  String? photoProfilePath;
  String? pieceIdentiteType;
  String? pieceIdentiteRectoPath;
  String? pieceIdentiteVersoPath;
  String? carteGrisePath;
  String? plaqueImmatriculation;
  String? numeroChassis;
  String? numeroCarteGrise;
  String? marqueVehicule;
  String? modeleVehicule;

  RegistrationData({
    this.nomComplet,
    this.email,
    this.telephone,
    this.password,
    this.countryCode,
    this.zone,
    this.vehiculeType,
    this.photoProfilePath,
    this.pieceIdentiteType,
    this.pieceIdentiteRectoPath,
    this.pieceIdentiteVersoPath,
    this.carteGrisePath,
    this.plaqueImmatriculation,
    this.numeroChassis,
    this.numeroCarteGrise,
    this.marqueVehicule,
    this.modeleVehicule,
  });

  @override
  String toString() {
    return 'RegistrationData(nom: $nomComplet, email: $email, phone: $telephone, zone: $zone, vehicle: $vehiculeType)';
  }
}
