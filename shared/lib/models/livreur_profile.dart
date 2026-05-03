// shared/lib/models/livreur_profile.dart

class LivreurProfile {
  final String id; // _id
  final String userId;
  final String? vehicleType; // New field
  final String? motoPlateNumber;
  final String? motoChassisNumber;
  final String? motoCarteGriseNumber; // New field
  final String? motoBrand;
  final String? motoModel;
  final String? motoCouleur; // New field
  final String? ifuNumber;
  final String? idType;
  final String? idNumber;
  final String? verificationStatus; // none, pending, approved, rejected
  final String? verificationNote;
  final DateTime? verifiedAt;

  LivreurProfile({
    required this.id,
    required this.userId,
    this.vehicleType,
    this.motoPlateNumber,
    this.motoChassisNumber,
    this.motoCarteGriseNumber,
    this.motoBrand,
    this.motoModel,
    this.motoCouleur,
    this.ifuNumber,
    this.idType,
    this.idNumber,
    this.verificationStatus,
    this.verificationNote,
    this.verifiedAt,
  });

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': userId,
        'vehicleType': vehicleType,
        'motoPlateNumber': motoPlateNumber,
        'motoChassisNumber': motoChassisNumber,
        'motoCarteGriseNumber': motoCarteGriseNumber,
        'motoBrand': motoBrand,
        'motoModel': motoModel,
        'motoCouleur': motoCouleur,
        'ifuNumber': ifuNumber,
        'idType': idType,
        'idNumber': idNumber,
        'verificationStatus': verificationStatus,
        'verificationNote': verificationNote,
        'verifiedAt': verifiedAt?.toIso8601String(),
      };

  factory LivreurProfile.fromJson(Map<String, dynamic> json) => LivreurProfile(
        id: json['_id'] as String,
        userId: json['userId'] as String,
        vehicleType: json['vehicleType'] as String?,
        motoPlateNumber: json['motoPlateNumber'] as String?,
        motoChassisNumber: json['motoChassisNumber'] as String?,
        motoCarteGriseNumber: json['motoCarteGriseNumber'] as String?,
        motoBrand: json['motoBrand'] as String?,
        motoModel: json['motoModel'] as String?,
        motoCouleur: json['motoCouleur'] as String?,
        ifuNumber: json['ifuNumber'] as String?,
        idType: json['idType'] as String?,
        idNumber: json['idNumber'] as String?,
        verificationStatus: json['verificationStatus'] as String?,
        verificationNote: json['verificationNote'] as String?,
        verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt'] as String) : null,
      );
}
