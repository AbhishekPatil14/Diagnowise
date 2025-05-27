import 'package:flutter/material.dart';
import '../../PatientScreen/LiveTracking/Database_Locations.dart';
import 'Location_Model.dart';

class DoctorRegistrationScreen extends StatefulWidget {
  @override
  _DoctorRegistrationScreenState createState() => _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final doctor = Doctor1(
      name: _nameController.text.trim(),
      id: _idController.text.trim(),
      mobile: _mobileController.text.trim(),
      address: _addressController.text.trim(),
    );

    final exists = await StorageService.doctorExists(doctor.id);
    if (exists) {
      _showMessage('Doctor ID already exists!', isError: true);
      setState(() => _isSaving = false);
      return;
    }

    final success = await StorageService.saveDoctor(doctor);

    if (success) {
      _clearForm();
      _showMessage('Doctor registered successfully!');
    } else {
      _showMessage('Failed to save doctor!', isError: true);
    }

    setState(() => _isSaving = false);
  }

  void _clearForm() {
    _nameController.clear();
    _idController.clear();
    _mobileController.clear();
    _addressController.clear();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Doctor Name',
                      icon: Icons.person,
                      validator: (value) => value!.trim().isEmpty ? 'Required field' : null,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _idController,
                      label: 'Doctor ID',
                      icon: Icons.badge,
                      validator: (value) => value!.trim().isEmpty ? 'Required field' : null,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _mobileController,
                      label: 'Mobile Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.trim().isEmpty) return 'Required field';
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return 'Invalid number';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.home,
                      maxLines: 3,
                      validator: (value) => value!.trim().isEmpty ? 'Required field' : null,
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveDoctor,
                        icon: Icon(Icons.save),
                        label: _isSaving
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Register Doctor'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}
