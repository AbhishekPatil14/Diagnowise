import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../DoctorScreen/Location Entry/Location_Model.dart';
import 'Database_Locations.dart';

class PatientSearchScreen extends StatefulWidget {
  @override
  _PatientSearchScreenState createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends State<PatientSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Doctor1? _doctor;
  String _message = '';
  bool _isSearching = false;

  Future<void> _searchDoctor() async {
    final id = _searchController.text.trim();
    if (id.isEmpty) {
      setState(() => _message = 'Please enter Doctor ID');
      return;
    }

    setState(() {
      _isSearching = true;
      _message = '';
      _doctor = null;
    });

    try {
      final doctor = await StorageService.getDoctor(id);
      setState(() {
        _doctor = doctor;
        _message = doctor == null ? 'Doctor not found' : '';
      });
    } catch (e) {
      setState(() => _message = 'Error searching doctor');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _openMap() async {
    if (_doctor?.address == null) return;
    final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(_doctor!.address)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      setState(() => _message = 'Could not launch maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Find Doctor',
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter Doctor ID',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: _isSearching
                      ? const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                      : Icon(Icons.search),
                  onPressed: _isSearching ? null : _searchDoctor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_message.isNotEmpty)
              Text(
                _message,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
              ),
            if (_doctor != null) ...[
              const SizedBox(height: 16),
              _DoctorInfoCard(doctor: _doctor!),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.map, color: Colors.black), // Black icon
                  label: const Text(
                    'View on Map',
                    style: TextStyle(color: Colors.black), // Black text
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // White background
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.black), // Optional: add black border
                    ),
                    elevation: 2,
                  ),
                  onPressed: _openMap,
                ),
              ),

            ],
          ],
        ),
      ),
    );
  }
}

class _DoctorInfoCard extends StatelessWidget {
  final Doctor1 doctor;

  const _DoctorInfoCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Doctor Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(thickness: 1.2),
            const SizedBox(height: 8),
            _buildInfoRow('Name', doctor.name),
            _buildInfoRow('ID', doctor.id),
            _buildInfoRow('Mobile', doctor.mobile),
            _buildInfoRow('Address', doctor.address),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
