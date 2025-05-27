import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import '../../AdminScreen/Admin_Model.dart';
import '../PatientDatabase.dart';
import '../Patient_Model.dart'; // Doctor model

class DoctorBookingScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorBookingScreen({super.key, required this.doctor});

  @override
  State<DoctorBookingScreen> createState() => _DoctorBookingScreenState();
}

class _DoctorBookingScreenState extends State<DoctorBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final ageController=TextEditingController();
  final reasonController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  String? selectedFile;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      dateController.text = "${picked.day}-${picked.month}-${picked.year}";
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      timeController.text = picked.format(context);
    }
  }

  Future<void> _pickFile(String type) async {
    var status=await Permission.storage.request();

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission is required")),
      );
      return;
    }

    FilePickerResult? result=await FilePicker.platform.pickFiles();

    if(result!=null){
      File file=File(result.files.single.path!);
      setState(() {
        selectedFile=file.path;
      });
    }else{

    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. ${widget.doctor.name}'),
        backgroundColor: Colors.teal.shade700,
        elevation: 4,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctor.specialization,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.teal),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: nameController,
                    decoration: _inputDecoration('Full Name'),
                    validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: ageController,
                    decoration: _inputDecoration('AGE'),
                    validator: (value) => value!.isEmpty ? 'Enter your age' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: phoneController,
                    decoration: _inputDecoration('Mobile Number'),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.length != 10 ? 'Enter valid number' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: emailController,
                    decoration: _inputDecoration('Email (optional)'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: dateController,
                    decoration: _inputDecoration('Preferred Date'),
                    readOnly: true,
                    onTap: _pickDate,
                    validator: (value) => value!.isEmpty ? 'Select date' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: timeController,
                    decoration: _inputDecoration('Preferred Time'),
                    readOnly: true,
                    onTap: _pickTime,
                    validator: (value) => value!.isEmpty ? 'Select time' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: reasonController,
                    decoration: _inputDecoration('Reason for Appointment'),
                    maxLines: 2,
                    validator: (value) => value!.isEmpty ? 'Please provide a reason' : null,
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: () => _pickFile(""),
                    icon: const Icon(Icons.upload_file),
                    label:Text(
                      selectedFile==null
                                ? "Upload Image / File / PDF"
                                : "File Uploaded",
                      style: TextStyle(color: Colors.teal),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),

                  if (selectedFile != null)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.teal),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected File:',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade700),
                          ),
                          const SizedBox(height: 8),
                          if (selectedFile!.endsWith('.jpg') ||
                              selectedFile!.endsWith('.jpeg') ||
                              selectedFile!.endsWith('.png'))
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(selectedFile!),
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            )
                          else if (selectedFile!.endsWith('.pdf'))
                            const Row(
                              children: [
                                Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                                SizedBox(width: 10),
                                Text('PDF File Selected'),
                              ],
                            )
                          else
                            const Row(
                              children: [
                                Icon(Icons.insert_drive_file, color: Colors.grey, size: 40),
                                SizedBox(width: 10),
                                Text('File Selected'),
                              ],
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {

                            final booking=Booking(
                                name: nameController.text,
                                phone: phoneController.text,
                                email: emailController.text,
                                age: ageController.text,
                                reason: reasonController.text,
                                date: dateController.text,
                                time: timeController.text,
                                filePath: selectedFile,
                                doctorName: widget.doctor.name,
                                doctorEmail: widget.doctor.email,
                                status:'pending'
                            );

                            await BookingDatabase.instance.insertBooking(booking);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Appointment request submitted successfully!'),
                                backgroundColor: Colors.teal,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Request Appointment',
                          style: TextStyle(fontSize: 18,color: Colors.teal),
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
    );
  }
}
