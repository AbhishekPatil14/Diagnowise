// import 'package:flutter/material.dart';
// import '../../PatientScreen/MedicineBooking/Medicine_Databases.dart';
//
// class MedicineViewScreen extends StatefulWidget {
//   const MedicineViewScreen({Key? key}) : super(key: key);
//
//   @override
//   _MedicineViewScreenState createState() => _MedicineViewScreenState();
// }
//
// class _MedicineViewScreenState extends State<MedicineViewScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Map<String, dynamic>> _medicines = [];
//   List<Map<String, dynamic>> _filteredMedicines = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadMedicines();
//     _searchController.addListener(_filterMedicines);
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadMedicines() async {
//     final medicines = await DatabaseHelper1().getAllMedicines();
//     setState(() {
//       _medicines = medicines;
//       _filteredMedicines = medicines;
//     });
//   }
//
//   void _filterMedicines() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       _filteredMedicines = _medicines.where((medicine) {
//         final name = medicine['name'].toString().toLowerCase();
//         final description = medicine['description'].toString().toLowerCase();
//         return name.contains(query) || description.contains(query);
//       }).toList();
//     });
//   }
//
//   Future<void> _deleteMedicine(int id) async {
//     try {
//       final db = await DatabaseHelper1().database;
//       await db.delete(
//         'medicines',
//         where: 'id = ?',
//         whereArgs: [id],
//       );
//       _loadMedicines(); // Refresh the list
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Medicine deleted successfully!')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }
//
//   Future<void> _showUpdateDialog(Map<String, dynamic> medicine) async {
//     final nameController = TextEditingController(text: medicine['name']);
//     final descController = TextEditingController(text: medicine['description']);
//     final priceController = TextEditingController(text: medicine['price'].toString());
//     final imageController = TextEditingController(text: medicine['imageUrl']);
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Update Medicine'),
//         content: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: const InputDecoration(labelText: 'Name'),
//               ),
//               TextField(
//                 controller: descController,
//                 decoration: const InputDecoration(labelText: 'Description'),
//                 maxLines: 3,
//               ),
//               TextField(
//                 controller: priceController,
//                 decoration: const InputDecoration(labelText: 'Price'),
//                 keyboardType: TextInputType.number,
//               ),
//               TextField(
//                 controller: imageController,
//                 decoration: const InputDecoration(labelText: 'Image URL'),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               try {
//                 final db = await DatabaseHelper1().database;
//                 await db.update(
//                   'medicines',
//                   {
//                     'name': nameController.text,
//                     'description': descController.text,
//                     'price': double.parse(priceController.text),
//                     'imageUrl': imageController.text,
//                   },
//                   where: 'id = ?',
//                   whereArgs: [medicine['id']],
//                 );
//                 _loadMedicines(); // Refresh the list
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Medicine updated!')),
//                 );
//               } catch (e) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Error: $e')),
//                 );
//               }
//             },
//             child: const Text('Update'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Medicine List'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search medicines...',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: _filteredMedicines.isEmpty
//                 ? const Center(child: Text('No medicines found'))
//                 : ListView.builder(
//               itemCount: _filteredMedicines.length,
//               itemBuilder: (context, index) {
//                 final medicine = _filteredMedicines[index];
//                 return MedicineCard(
//                   medicine: medicine,
//
//                   onDelete: () => _deleteMedicine(medicine['id']),
//                   onUpdate: () => _showUpdateDialog(medicine),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class MedicineCard extends StatelessWidget {
//   final Map<String, dynamic> medicine;
//   final VoidCallback onDelete;
//   final VoidCallback onUpdate;
//
//   const MedicineCard({
//     required this.medicine,
//     required this.onDelete,
//     required this.onUpdate,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (medicine['imageUrl'] != null && medicine['imageUrl'].isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.network(
//                     medicine['imageUrl'],
//                     height: 120,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             Text(
//               medicine['name'],
//               style: Theme.of(context).textTheme.headline6,
//             ),
//             const SizedBox(height: 8),
//             if (medicine['description'] != null)
//               Text(
//                 medicine['description'],
//                 style: Theme.of(context).textTheme.bodyText2,
//               ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '\$${medicine['price'].toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: onDelete,
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   label: const Text('Delete'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red[100],
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: onUpdate,
//                   icon: const Icon(Icons.edit, color: Colors.blue),
//                   label: const Text('Update'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue[100],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../../PatientScreen/MedicineBooking/Medicine_Databases.dart';

class MedicineViewScreen extends StatefulWidget {
  const MedicineViewScreen({Key? key}) : super(key: key);

  @override
  _MedicineViewScreenState createState() => _MedicineViewScreenState();
}

class _MedicineViewScreenState extends State<MedicineViewScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _medicines = [];
  List<Map<String, dynamic>> _filteredMedicines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
    _searchController.addListener(_filterMedicines);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicines() async {
    setState(() => _isLoading = true);
    try {
      final medicines = await DatabaseHelper1().getAllMedicines();
      setState(() {
        _medicines = medicines;
        _filteredMedicines = medicines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load medicines: $e');
    }
  }

  void _filterMedicines() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMedicines = _medicines.where((medicine) {
        final name = medicine['name'].toString().toLowerCase();
        final description = medicine['description'].toString().toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteMedicine(int id, String medicineName) async {
    final bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "$medicineName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;

    if (confirmDelete) {
      try {
        final db = await DatabaseHelper1().database;
        await db.delete(
          'medicines',
          where: 'id = ?',
          whereArgs: [id],
        );
        await _loadMedicines(); // Refresh the list
        _showSuccessSnackBar('Medicine deleted successfully');
      } catch (e) {
        _showErrorSnackBar('Error deleting medicine: $e');
      }
    }
  }

  Future<void> _showUpdateDialog(Map<String, dynamic> medicine) async {
    final nameController = TextEditingController(text: medicine['name']);
    final descController = TextEditingController(text: medicine['description']);
    final priceController = TextEditingController(text: medicine['price'].toString());
    final _formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Medicine'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Name cannot be empty' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Price cannot be empty';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  final db = await DatabaseHelper1().database;
                  await db.update(
                    'medicines',
                    {
                      'name': nameController.text,
                      'description': descController.text,
                      'price': double.parse(priceController.text)
                    },
                    where: 'id = ?',
                    whereArgs: [medicine['id']],
                  );
                  await _loadMedicines(); // Refresh the list
                  Navigator.pop(context);
                  _showSuccessSnackBar('Medicine updated successfully');
                } catch (e) {
                  _showErrorSnackBar('Error updating medicine: $e');
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Medicine Inventory",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : _filteredMedicines.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No medicines found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Try a different search term',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadMedicines,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _filteredMedicines.length,
                itemBuilder: (context, index) {
                  final medicine = _filteredMedicines[index];
                  return MedicineCard(
                    medicine: medicine,
                    onDelete: () => _deleteMedicine(
                      medicine['id'],
                      medicine['name'],
                    ),
                    onUpdate: () => _showUpdateDialog(medicine),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MedicineCard extends StatelessWidget {
  final Map<String, dynamic> medicine;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const MedicineCard({
    required this.medicine,
    required this.onDelete,
    required this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/images/tablets.png', // Use your static image path
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\₹${medicine['price'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        medicine['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (medicine['description'] != null &&
                    medicine['description'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      medicine['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onUpdate,
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: BorderSide(color: Colors.blue.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}