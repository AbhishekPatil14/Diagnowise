class Medicine {
  final int id;
  final String name;
  final String description;
  final double price;

  Medicine({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
    );
  }
}