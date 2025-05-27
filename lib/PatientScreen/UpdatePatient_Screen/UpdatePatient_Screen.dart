import 'package:flutter/material.dart';
import '../PatientDatabase.dart';
import '../Patient_Model.dart';
import 'FullScreen_Image.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  late Future<List<Booking>> bookings;

  @override
  void initState() {
    super.initState();
    bookings = BookingDatabase.instance.getAllBookings();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.teal;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "My Bookings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: themeColor,
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: FutureBuilder<List<Booking>>(
        future: bookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading bookings.'));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final booking = data[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.teal.withOpacity(0.1),
                              child: Image.asset(
                                'assets/images/medical-team.png',
                                width: 36,
                                height: 36,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Dr. ${booking.doctorName}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Patient Information",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _infoRow("Name", booking.name),
                      _infoRow("Age", booking.age),
                      _infoRow("Phone", booking.phone),
                      _infoRow("Date", booking.date),
                      _infoRow("Time", booking.time),
                      _infoRow("Reason", booking.reason),
                       Row(
                         children: [
                           const Text(
                             "Status:",
                             style: TextStyle(
                               fontWeight: FontWeight.w600,
                               color: Colors.black87,
                             ),
                           ),
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                             decoration: BoxDecoration(
                               color: _getStatusColor(booking.status),
                               borderRadius: BorderRadius.circular(20),
                             ),
                             child: Text(
                               booking.status,
                               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                             ),
                           )
                         ],
                       ),
                      const SizedBox(height: 12),
                      if (booking.filePath != null)
                        _attachmentView(context, booking.filePath!),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }


  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _attachmentView(BuildContext context, String filePath) {
    final isImage = filePath.endsWith('.jpg') || filePath.endsWith('.jpeg') || filePath.endsWith('.png');
    final isPdf = filePath.endsWith('.pdf');

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

    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 8),
        GestureDetector(
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
      ],
    );
  }
}
