class RegistrationData {
  String? nomComplet;
  String? email;
  String? telephone;
  String? password;
  String? zone;
  String? vehiculeType;
  String? photoProfilePath;
  String? pieceIdentiteRectoPath;
  String? pieceIdentiteVersoPath;
  String? carteGrisePath;
  String? assurancePath;

  RegistrationData({
    this.nomComplet,
    this.email,
    this.telephone,
    this.password,
    this.zone,
    this.vehiculeType,
    this.photoProfilePath,
    this.pieceIdentiteRectoPath,
    this.pieceIdentiteVersoPath,
    this.carteGrisePath,
    this.assurancePath,
  });

  @override
  String toString() {
    return 'RegistrationData(nom: $nomComplet, email: $email, phone: $telephone, zone: $zone, vehicle: $vehiculeType)';
  }
}
