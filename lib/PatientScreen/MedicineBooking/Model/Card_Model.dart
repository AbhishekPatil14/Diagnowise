class CartItem {
  final int id;
  final int medicineId;
  final String medicineName;
  final double medicinePrice;
  final double price;
  final int quantity;
  final DateTime addedDate;
  bool isSelected;

  CartItem({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.medicinePrice,
    required this.price,
    required this.quantity,
    required this.addedDate,
    required this.isSelected
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      medicineId: map['medicineId'],
      medicineName: map['name'],
      medicinePrice: map['price'],
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'],
      addedDate: DateTime.parse(map['addedDate']),
      isSelected: map['isSelected'] ?? false,
    );
  }

  double get totalPrice => medicinePrice * quantity;
}