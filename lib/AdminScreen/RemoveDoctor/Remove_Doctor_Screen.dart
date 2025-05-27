import 'package:flutter/material.dart';
import '../AdminDatabases.dart';
import '../Admin_Model.dart';

class RemoveDoctorWidget extends StatefulWidget {
  const RemoveDoctorWidget({super.key});

  @override
  State<RemoveDoctorWidget> createState() => _RemoveDoctorWidgetState();
}

class _RemoveDoctorWidgetState extends State<RemoveDoctorWidget> {
  final TextEditingController _searchController = TextEditingController();
  Doctor? _doctor;

  Future<void> _searchDoctor() async {
    final dbHelper = DatabaseHelper();
    final id = _searchController.text.trim();
    final doctor = await dbHelper.getDoctorById(id);

    setState(() => _doctor = doctor);

    if (doctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor not found')),
      );
    }
  }

  Future<void> _removeDoctor() async {
    final dbHelper = DatabaseHelper();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Removal'),
        content: const Text('Are you sure you want to remove this doctor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await dbHelper.deleteDoctor(_doctor!.doctorId);
      setState(() {
        _doctor = null;
        _searchController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor removed successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Remove Doctor',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Enter Doctor ID',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: _searchDoctor,
            icon: const Icon(Icons.search,color: Colors.white),
            label: const Text('Search',style: TextStyle(color: Colors.white,fontSize: 20)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(double.infinity, 46),
            ),
          ),
          const SizedBox(height: 24),

          if (_doctor != null) ...[
            Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow("Name", _doctor!.name),
                    _infoRow("Email", _doctor!.email),
                    _infoRow("Specialization", _doctor!.specialization),
                    _infoRow("Experience", _doctor!.experience),
                    _infoRow("Address", _doctor!.address),
                    _infoRow("Phone", _doctor!.phone),
                    _infoRow("Visiting Hours", _doctor!.visitingHours),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever,color: Colors.white,),
              label: const Text('Remove Doctor',style: TextStyle(color: Colors.white,fontSize: 18),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 46),
              ),
              onPressed: _removeDoctor,
            ),
          ]
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
