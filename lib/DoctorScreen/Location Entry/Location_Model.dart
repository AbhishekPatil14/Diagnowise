class Doctor1 {
  final String name;
  final String id;
  final String mobile;
  final String address;

  Doctor1({
    required this.name,
    required this.id,
    required this.mobile,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'id': id,
    'mobile': mobile,
    'address': address,
  };

  factory Doctor1.fromJson(Map<String, dynamic> json) => Doctor1(
    name: json['name'],
    id: json['id'],
    mobile: json['mobile'],
    address: json['address'],
  );
}