import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../AdminScreen/AdminDatabases.dart';
import '../../AdminScreen/Admin_Model.dart';
import 'DoctorBookingScreen.dart';

class BookingPatientWidget extends StatefulWidget {
  const BookingPatientWidget({super.key});

  @override
  State<BookingPatientWidget> createState() => _BookingPatientWidgetState();
}

class _BookingPatientWidgetState extends State<BookingPatientWidget> {
  final List<Doctor> _doctorList = [];
  List<Doctor> _filteredDoctorList = [];
  final TextEditingController _searchController = TextEditingController();

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
      _doctorList.clear();
      _doctorList.addAll(doctors);
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        _showSnackbar('Could not launch phone dialer');
      }
    } catch (e) {
      _showSnackbar('Error launching dialer: ${e.toString()}');
    }
  }


  Future<void> _sendSMS(String phoneNumber) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        _showSnackbar('No messaging app found');
      }
    } catch (e) {
      _showSnackbar('Error launching messaging app: ${e.toString()}');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.teal;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Patient Directory",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: themeColor,
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(30),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or specialization',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredDoctorList.length,
                itemBuilder: (context, index) {
                  final doctor = _filteredDoctorList[index];
                  return _buildDoctorCard(doctor, themeColor);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor, Color themeColor) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: themeColor.withOpacity(0.1),
                  child: Image.asset(
                    'assets/images/medical-staff.png',
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialization,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            _infoTile(Icons.badge_outlined, "ID", doctor.doctorId),
             _infoTile(Icons.email_sharp, "Email", doctor.email),
            _infoTile(Icons.school_outlined, "Experience", "${doctor.experience} yrs"),
            _infoTile(Icons.access_time_filled, "Hours", doctor.visitingHours),
            _infoTile(Icons.location_on_outlined, "Address", doctor.address),
            _infoTile(Icons.phone_android, "Phone", doctor.phone),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(Icons.call, 'Call', () => _makePhoneCall(doctor.phone), themeColor),
                _actionButton(Icons.message, 'Message', () => _sendSMS(doctor.phone), themeColor),
                _actionButton(Icons.calendar_today, 'Book', () {
                  Navigator.push(
                      context,
                    MaterialPageRoute(
                      builder: (context) => DoctorBookingScreen(doctor: doctor),
                    ),
                  );
                }, themeColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
      IconData icon, String label, VoidCallback onPressed, Color themeColor) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontSize: 13, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: themeColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        elevation: 3,
      ),
    );
  }
}
