class Payment {
  final int? id;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String items;
  final double amount;
  final String paymentMethod;
  final DateTime timestamp;

  Payment({
    this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.items,
    required this.amount,
    required this.paymentMethod,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress,
      'items': items,
      'amount': amount,
      'payment_method': paymentMethod,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      customerName: map['customer_name'],
      customerPhone: map['customer_phone'],
      customerAddress: map['customer_address'],
      items: map['items'],
      amount: map['amount'],
      paymentMethod: map['payment_method'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}