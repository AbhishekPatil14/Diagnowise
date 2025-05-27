class Booking {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String age;
  final String reason;
  final String date;
  final String time;
  final String? filePath;
  final String doctorName;
  final String? doctorEmail;
  final String status;

  Booking({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.age,
    required this.reason,
    required this.date,
    required this.time,
    this.filePath,
    required this.doctorName,
    required this.doctorEmail,
    this.status="pending",
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'age': age,
      'reason': reason,
      'date': date,
      'time': time,
      'filePath': filePath ?? '',
      'doctorName': doctorName,
      'doctorEmail':doctorEmail,
      'status':status
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      age: map['age'],
      reason: map['reason'],
      date: map['date'],
      time: map['time'],
      filePath: map['filePath'],
      doctorName: map['doctorName'],
      doctorEmail: map['doctorEmail'],
      status: map['status'] ?? "pending",
    );
  }

  @override
  String toString(){
    return 'Booking{id: $id, name: $name, phone: $phone, email: $email, age: $age, reason: $reason, date: $date, time: $time, filePath: $filePath, doctorName: $doctorName,doctorEmail:$doctorEmail, status: $status}';
  }
}
