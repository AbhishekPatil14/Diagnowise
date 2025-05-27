import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Added for currency formatting
import '../Medicine_Databases.dart';
import '../Model/Medicine_Model.dart';
import 'CardScreen.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});
  @override
  _MedicineListScreenState createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  late DatabaseHelper1 _dbHelper;
  late Future<List<Medicine>> _medicinesFuture;
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹');  // Added rupee format

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper1();
    _medicinesFuture = _loadMedicines();
  }

  Future<List<Medicine>> _loadMedicines() async {
    final medicines = await _dbHelper.getAllMedicines();
    return medicines.map((map) => Medicine.fromMap(map)).toList();
  }

  Future<void> _addToCart(int medicineId, String medicineName) async {
    await _dbHelper.addToCart(medicineId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$medicineName added to cart'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Select Medicine',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Medicine>>(
        future: _medicinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading medicines'));
          }

          final medicines = snapshot.data ?? [];

          if (medicines.isEmpty) {
            return const Center(child: Text('No medicines found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final medicine = medicines[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),

                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Static medicine image
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/tablets.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicine.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              medicine.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currencyFormat.format(medicine.price),
                              style: const TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart, color: Colors.teal),
                        onPressed: () => _addToCart(medicine.id, medicine.name),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}