import 'package:flutter/material.dart';
import '../AdminDatabases.dart';
import '../Admin_Model.dart';

class AddDoctorWidget extends StatefulWidget {
  const AddDoctorWidget({super.key});

  @override
  State<AddDoctorWidget> createState() => _AddDoctorWidgetState();
}

class _AddDoctorWidgetState extends State<AddDoctorWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _doctorIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _visitingHoursController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedSpecialization;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _selectedDate;

  final List<String> _specializations = [
    'Cardiologist', 'Dermatologist', 'Neurologist', 'Orthopedic',
    'Pediatrician', 'Psychiatrist', 'Radiologist', 'General Physician', 'Heart'
  ];

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return TimeOfDay.fromDateTime(dt).format(context);
  }

  String _formatDate(DateTime date) {
    return "${date.day} ${_monthName(date.month)}";
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  Future<void> _selectVisitingHours() async {
    _selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (_selectedDate != null) {
      _startTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
      );
      if (_startTime != null) {
        _endTime = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 18, minute: 0),
        );

        if (_endTime != null) {
          setState(() {
            _visitingHoursController.text =
            "${_formatTime(_startTime!)} to ${_formatTime(_endTime!)} - ${_formatDate(_selectedDate!)}";
          });
        }
      }
    }
  }

  void _addDoctor() async {
    if (_formKey.currentState!.validate()) {
      Doctor doctor = Doctor(
        doctorId: _doctorIdController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        specialization: _selectedSpecialization!,
        experience: _experienceController.text.trim(),
        address: _addressController.text.trim(),
        visitingHours: _visitingHoursController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      final dbHelper = DatabaseHelper();
      await dbHelper.insertDoctor(doctor);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor added successfully!')),
      );

      _doctorIdController.clear();
      _nameController.clear();
      _emailController.clear();
      _visitingHoursController.clear();
      _experienceController.clear();
      _addressController.clear();
      _phoneController.clear();

      setState(() {
        _selectedSpecialization = null;
      });
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Card(
            color: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Doctor Information",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _doctorIdController,
                    decoration: _inputDecoration('Doctor ID', Icons.badge),
                    validator: (value) => value!.isEmpty ? 'Enter doctor ID' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Doctor Name', Icons.person),
                    validator: (value) => value!.isEmpty ? 'Enter doctor name' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration('Email', Icons.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter email';
                      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedSpecialization,
                    decoration: _inputDecoration('Specialization', Icons.medical_services),
                    items: _specializations.map((speciality) {
                      return DropdownMenuItem<String>(
                        value: speciality,
                        child: Text(speciality),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSpecialization = value;
                      });
                    },
                    validator: (value) => value == null ? 'Select specialization' : null,
                  ),
                  const SizedBox(height: 24),

                  const Text("Professional Details",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _experienceController,
                    decoration: _inputDecoration('Experience (years)', Icons.timeline),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter experience' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _addressController,
                    decoration: _inputDecoration('Clinic Address', Icons.location_on),
                    validator: (value) => value!.isEmpty ? 'Enter clinic address' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _visitingHoursController,
                    readOnly: true,
                    onTap: _selectVisitingHours,
                    decoration: _inputDecoration('Visiting Hours', Icons.access_time),
                    validator: (value) => value!.isEmpty ? 'Select visiting hours' : null,
                  ),
                  const SizedBox(height: 24),

                  const Text("Contact Info",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneController,
                    decoration: _inputDecoration('Phone Number', Icons.phone),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter phone number';
                      } else if (value.length != 10) {
                        return 'Enter valid 10-digit phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addDoctor,
                      icon: const Icon(Icons.add,color: Colors.white,),
                      label: const Text(
                        'Add Doctor',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
