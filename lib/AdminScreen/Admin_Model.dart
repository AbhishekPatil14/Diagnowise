class Doctor {
  final String doctorId;
  final String name;
  final String email;
  final String specialization;
  final String experience;
  final String address;
  final String visitingHours;
  final String phone;

  Doctor({
    required this.doctorId,
    required this.name,
    required this.email,
    required this.specialization,
    required this.experience,
    required this.address,
    required this.visitingHours,
    required this.phone
  });

  // fromMap method to convert a map to a Doctor object
  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      doctorId: map['doctorId'],
      name: map['name'],
      email: map['email'],
      specialization: map['specialization'],
      experience: map['experience'],
      address: map['address'],
      visitingHours: map['visitingHours'],
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'name': name,
      'email':email,
      'specialization': specialization,
      'experience': experience,
      'address': address,
      'visitingHours': visitingHours,
      'phone':phone
    };
  }
}
