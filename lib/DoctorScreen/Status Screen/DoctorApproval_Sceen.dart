import 'package:flutter/material.dart';
import '../../PatientScreen/PatientDatabase.dart';
import '../../PatientScreen/Patient_Model.dart';
import '../../PatientScreen/UpdatePatient_Screen/FullScreen_Image.dart';

class DoctorApprovalScreen extends StatefulWidget {
  final String doctorEmail;

  const DoctorApprovalScreen({required this.doctorEmail, Key? key}) : super(key: key);

  @override
  State<DoctorApprovalScreen> createState() => _DoctorApprovalScreenState();
}

class _DoctorApprovalScreenState extends State<DoctorApprovalScreen> {
  List<Booking> _pendingBookings = [];

  @override
  void initState() {
    super.initState();
    _debugPrintAllBookings();
    _fetchPendingBookings();
  }

  Future<void> _debugPrintAllBookings() async {
    final allBookings = await BookingDatabase.instance.getAllBookings();
    print("=== All Bookings ===");
    for (var b in allBookings) {
      print("ID: ${b.id}, Name: ${b.name}, Status: ${b.status}");
    }
  }

  Future<void> _fetchPendingBookings() async {
    final allPending = await BookingDatabase.instance.getPendingBookings(
        widget.doctorEmail);
    setState(() {
      _pendingBookings = allPending;
    });
  }

  Future<void> _updateStatus(Booking booking, String newStatus) async {
    final updatedBooking = Booking(
      id: booking.id,
      name: booking.name,
      phone: booking.phone,
      email: booking.email,
      age: booking.age,
      reason: booking.reason,
      date: booking.date,
      time: booking.time,
      doctorName: booking.doctorName,
      doctorEmail: booking.doctorEmail,
      status: newStatus,
    );

    await BookingDatabase.instance.updateBooking(updatedBooking);
    _fetchPendingBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pendingBookings.isEmpty
          ? const Center(
        child: Text(
          "No pending bookings",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      )
          : ListView.builder(
        itemCount: _pendingBookings.length,
        itemBuilder: (context, index) {
          final booking = _pendingBookings[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // Center image vertically
                    children: [
                      // Patient image (left side, centered)
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage(
                            'assets/images/patient.png'),
                        // Replace with NetworkImage for dynamic
                        backgroundColor: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 16),

                      // User Info (right side)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _infoRow("Name", booking.name),
                            _infoRow("Phone", booking.phone),
                            _infoRow("Reason", booking.reason),
                            _infoRow("Date ", booking.date),
                            _infoRow("Time", booking.time),
                            _infoRow("Age", booking.age.toString()),
                            _infoRow("Email", booking.email),
                            if (booking.filePath != null)
                              _buildAttachmentView(context, booking.filePath!),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _updateStatus(booking, 'accepted'),
                        icon: const Icon(Icons.check),
                        label: const Text("Approve"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _updateStatus(booking, 'declined'),
                        icon: const Icon(Icons.cancel),
                        label: const Text("Reject"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),


                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentView(BuildContext context, String filePath) {
    final isImage = filePath.toLowerCase().endsWith('.jpg') ||
        filePath.toLowerCase().endsWith('.jpeg') ||
        filePath.toLowerCase().endsWith('.png');
    final isPdf = filePath.toLowerCase().endsWith('.pdf');

    IconData icon;
    Color color;
    String label;

    if (isImage) {
      icon = Icons.photo;
      color = Colors.teal;
      label = "View Attached Photo";
    } else if (isPdf) {
      icon = Icons.picture_as_pdf;
      color = Colors.red;
      label = "PDF Attached";
    } else {
      icon = Icons.insert_drive_file;
      color = Colors.grey;
      label = "File Attached";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: isImage
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenImagePage(imagePath: filePath),
                  ),
                );
              }
                  : null,
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  decoration: isImage ? TextDecoration.underline : TextDecoration.none,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (isImage)
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
