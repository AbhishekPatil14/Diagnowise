import 'package:flutter/material.dart';
import '../AdminDatabases.dart';
import '../Admin_Model.dart';

class ViewDoctorWidget extends StatefulWidget {
  const ViewDoctorWidget({super.key});

  @override
  State<ViewDoctorWidget> createState() => _ViewDoctorWidgetState();
}

class _ViewDoctorWidgetState extends State<ViewDoctorWidget> {
  List<Doctor> _doctorList = [];
  List<Doctor> _filteredDoctorList = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    final dbHelper = DatabaseHelper();
    final doctors = await dbHelper.getAllDoctors();
    setState(() {
      _doctorList = doctors;
      _filteredDoctorList = doctors;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDoctorList = _doctorList.where((doctor) {
        return doctor.name.toLowerCase().contains(query) ||
            doctor.specialization.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.teal.shade700;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search doctor by name or specialization',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: themeColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: themeColor, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDoctors,
              child: _filteredDoctorList.isEmpty
                  ? const Center(
                child: Text(
                  'No doctors found.',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _filteredDoctorList.length,
                itemBuilder: (context, index) {
                  final doctor = _filteredDoctorList[index];
                  return Card(
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.blue),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  doctor.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _infoTile(Icons.badge, "ID", doctor.doctorId),
                          _infoTile(Icons.person, "Name", doctor.name),
                          _infoTile(Icons.email, "Email", doctor.email),
                          _infoTile(Icons.medical_services, "Specialization", doctor.specialization),
                          _infoTile(Icons.work_history, "Experience", "${doctor.experience} years"),
                          _infoTile(Icons.access_time, "Visiting Hours", doctor.visitingHours),
                          _infoTile(Icons.location_on, "Address", doctor.address),
                          _infoTile(Icons.phone, "Phone", doctor.phone)
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
