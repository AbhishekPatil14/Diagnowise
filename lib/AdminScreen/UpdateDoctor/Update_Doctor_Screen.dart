import 'package:flutter/material.dart';
import '../AdminDatabases.dart';
import '../Admin_Model.dart';

class UpdateDoctorWidget extends StatefulWidget {
  const UpdateDoctorWidget({super.key});

  @override
  State<UpdateDoctorWidget> createState() => _UpdateDoctorWidgetState();
}

class _UpdateDoctorWidgetState extends State<UpdateDoctorWidget> {
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _experienceController = TextEditingController();
  final _addressController = TextEditingController();
  final _visitingHoursController = TextEditingController();
  final _phoneController = TextEditingController();

  Doctor? _doctor;
  final _formKey = GlobalKey<FormState>();

  final List<String> _specializations = [
    'Cardiologist', 'Dermatologist', 'Neurologist', 'Orthopedic',
    'Pediatrician', 'Psychiatrist', 'Radiologist', 'General Physician', 'Heart'
  ];
  String? _selectedSpecialization;

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _experienceController.dispose();
    _addressController.dispose();
    _visitingHoursController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _searchDoctor() async {
    final dbHelper = DatabaseHelper();
    final doctor = await dbHelper.getDoctorById(_searchController.text.trim());

    if (doctor != null) {
      setState(() {
        _doctor = doctor;
        _nameController.text = doctor.name;
        _emailController.text = doctor.email;
        _selectedSpecialization = doctor.specialization;
        _experienceController.text = doctor.experience;
        _addressController.text = doctor.address;
        _visitingHoursController.text = doctor.visitingHours;
        _phoneController.text = doctor.phone;
      });
    } else {
      setState(() => _doctor = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor not found')),
      );
    }
  }

  Future<void> _updateDoctor() async {
    if (_formKey.currentState!.validate() && _doctor != null) {
      final updatedDoctor = Doctor(
        doctorId: _doctor!.doctorId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        specialization: _selectedSpecialization ?? '',
        experience: _experienceController.text.trim(),
        address: _addressController.text.trim(),
        visitingHours: _visitingHoursController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      final dbHelper = DatabaseHelper();
      await dbHelper.updateDoctor(updatedDoctor);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor updated successfully')),
      );

      setState(() {
        _doctor = null;
        _searchController.clear();
        _nameController.clear();
        _emailController.clear();
        _selectedSpecialization = null;
        _experienceController.clear();
        _addressController.clear();
        _visitingHoursController.clear();
        _phoneController.clear();
      });
    }
  }

  Future<void> _selectSchedule() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      TimeOfDay? start = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
      );
      if (start != null) {
        TimeOfDay? end = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 17, minute: 0),
        );
        if (end != null) {
          setState(() {
            _visitingHoursController.text =
            "${_formatTime(start)} to ${_formatTime(end)} - ${_formatDate(date)}";
          });
        }
      }
    }
  }

  String _formatTime(TimeOfDay time) =>
      time.format(context);

  String _formatDate(DateTime date) =>
      "${date.day} ${_monthName(date.month)}";

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Search Doctor by ID',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Doctor ID',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.search,color: Colors.white,),
                        label: const Text('Search',style: TextStyle(fontSize: 14,color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _searchDoctor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_doctor != null)
                Form(
                  key: _formKey,
                  child: Card(
                    color: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Doctor Details',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _buildTextField(_nameController, 'Name', Icons.person),
                          _buildTextField(_emailController, 'Email', Icons.email),
                          _buildDropdownSpecialization(),
                          _buildTextField(_experienceController, 'Experience (years)', Icons.timeline, isNumber: true),
                          _buildTextField(_addressController, 'Address', Icons.location_city),
                          _buildTextField(_phoneController, 'Phone', Icons.phone, isNumber: true),
                          _buildScheduleField(),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.update),
                              label: const Text('Update Doctor'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _updateDoctor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDropdownSpecialization() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: DropdownButtonFormField<String>(
        value: _selectedSpecialization,
        decoration: InputDecoration(
          labelText: 'Specialization',
          prefixIcon: const Icon(Icons.medical_services),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: _specializations.map((specialty) {
          return DropdownMenuItem<String>(
            value: specialty,
            child: Text(specialty),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedSpecialization = value),
        validator: (value) =>
        value == null || value.isEmpty ? 'Please select a specialization' : null,
      ),
    );
  }

  Widget _buildScheduleField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: TextFormField(
        controller: _visitingHoursController,
        readOnly: true,
        onTap: _selectSchedule,
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: 'Visiting Hours',
          prefixIcon: const Icon(Icons.schedule),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
