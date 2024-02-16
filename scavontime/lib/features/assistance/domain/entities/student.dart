class Student {
  final int studentId;
  final String name;
  final String lastname;
  final String email;
  final String documentType;
  final String documentNumber;
  final String active;

  Student({
    required this.studentId,
    required this.name,
    required this.lastname,
    required this.email,
    required this.documentType,
    required this.documentNumber,
    required this.active,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'] ?? 0,
      name: json['name'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      documentType: json['documentType'] ?? '',
      documentNumber: json['documentNumber'] ?? '',
      active: json['active'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'name': name,
      'lastname': lastname,
      'email': email,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'active': active,
    };
  }
}
