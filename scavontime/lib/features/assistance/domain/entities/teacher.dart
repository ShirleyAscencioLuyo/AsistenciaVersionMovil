class Teacher {
  int id;
  DocumentType documentType;
  String documentNumber;
  String name;
  String lastname;
  String cellphone;
  String email;
  String birthdate;
  Ubigeo ubigeo;
  String typeCharge;
  String typeCondition;
  String workday;
  String active;

  Teacher({
    required this.id,
    required this.documentType,
    required this.documentNumber,
    required this.name,
    required this.lastname,
    required this.cellphone,
    required this.email,
    required this.birthdate,
    required this.ubigeo,
    required this.typeCharge,
    required this.typeCondition,
    required this.workday,
    this.active = 'A',
  });

  // Constructor para convertir desde JSON
  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] ?? 0,
      documentType: DocumentType.fromJson(json['documentType']),
      documentNumber: json['documentNumber'] ?? '',
      name: json['name'] ?? '',
      lastname: json['lastname'] ?? '',
      cellphone: json['cellphone'] ?? '',
      email: json['email'] ?? '',
      birthdate: json['birthdate'] ?? '',
      ubigeo: Ubigeo.fromJson(json['ubigeo']),
      typeCharge: json['typeCharge'] ?? '',
      typeCondition: json['typeCondition'] ?? '',
      workday: json['workday'] ?? '',
      active: json['active'] ?? 'A',
    );
  }
}

class DocumentType {
  int id;
  String nameDocument;
  String description;

  DocumentType({
    required this.id,
    required this.nameDocument,
    required this.description,
  });

  factory DocumentType.fromJson(Map<String, dynamic> json) {
    return DocumentType(
      id: json['id'] ?? 0,
      nameDocument: json['nameDocument'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class Ubigeo {
  int id;
  String ubigeoCode;
  String department;
  String province;
  String district;

  Ubigeo({
    required this.id,
    required this.ubigeoCode,
    required this.department,
    required this.province,
    required this.district,
  });

  factory Ubigeo.fromJson(Map<String, dynamic> json) {
    return Ubigeo(
      id: json['id'] ?? 0,
      ubigeoCode: json['ubigeoCode'] ?? '',
      department: json['department'] ?? '',
      province: json['province'] ?? '',
      district: json['district'] ?? '',
    );
  }
}
