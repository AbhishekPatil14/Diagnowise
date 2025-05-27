import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../PatientScreen/PatientDatabase.dart';
import '../../PatientScreen/Patient_Model.dart';
import '../../PatientScreen/UpdatePatient_Screen/FullScreen_Image.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  final String doctorEmail;

  const DoctorAppointmentsScreen({required this.doctorEmail, Key? key}) : super(key: key);

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> with SingleTickerProviderStateMixin {
  List<Booking> _pendingBookings = [];
  List<Booking> _acceptedBookings = [];
  List<Booking> _declinedBookings = [];
  bool _isLoading = true;
  Map<String, int> _statusCounts = {'pending': 0, 'accepted': 0, 'declined': 0};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get status counts
      _statusCounts = await BookingDatabase.instance.getStatusCounts(widget.doctorEmail);

      // Fetch bookings by status
      final pendingBookings = await BookingDatabase.instance.getPendingBookings(widget.doctorEmail);

      // Fetch accepted and declined bookings for the doctor
      final db = await BookingDatabase.instance.database;
      final acceptedResult = await db.query(
        'bookings',
        where: 'LOWER(status) = ? AND LOWER(doctorEmail) = ?',
        whereArgs: ['accepted', widget.doctorEmail.toLowerCase()],
      );

      final declinedResult = await db.query(
        'bookings',
        where: 'LOWER(status) = ? AND LOWER(doctorEmail) = ?',
        whereArgs: ['declined', widget.doctorEmail.toLowerCase()],
      );

      setState(() {
        _pendingBookings = pendingBookings;
        _acceptedBookings = acceptedResult.map((map) => Booking.fromMap(map)).toList();
        _declinedBookings = declinedResult.map((map) => Booking.fromMap(map)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching bookings: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load appointments: $e')),
      );
    }
  }

  Future<void> _updateStatus(Booking booking, String newStatus) async {
    try {
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
        filePath: booking.filePath,
      );

      await BookingDatabase.instance.updateBooking(updatedBooking);

      // Show confirmation to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment ${newStatus.toUpperCase()}'),
          backgroundColor: newStatus == 'accepted' ? Colors.green : Colors.red,
        ),
      );

      // Refresh the bookings
      _fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update appointment: $e')),
      );
    }
  }

  String _formatDate(String dateStr) {
    try {
      // Parse the date string into a DateTime object
      final date = DateFormat('yyyy-MM-dd').parse(dateStr);
      // Format it in a more readable format
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      // If parsing fails, return the original string
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,  // Remove default AppBar height space
        titleSpacing: 0,   // Remove title spacing
        title: const SizedBox.shrink(),  // Remove default title area
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(78),  // Set exact TabBar height
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.teal,  // Optional: set your preferred color
            labelPadding: EdgeInsets.zero,  // Remove internal tab padding
            tabs: [
              Tab(
                text: 'Pending (${_statusCounts['pending']})',
                icon: const Icon(Icons.schedule,color: Colors.teal,),
              ),
              Tab(
                text: 'Accepted (${_statusCounts['accepted']})',
                icon: const Icon(Icons.check_circle,color: Colors.teal),
              ),
              Tab(
                text: 'Declined (${_statusCounts['declined']})',
                icon: const Icon(Icons.cancel,color: Colors.teal),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          // Pending Tab
          _buildBookingsList(_pendingBookings, showActions: true),

          // Accepted Tab
          _buildBookingsList(_acceptedBookings),

          // Declined Tab
          _buildBookingsList(_declinedBookings),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _fetchBookings,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings, {bool showActions = false}) {
    if (bookings.isEmpty) {
      return const Center(
        child: Text(
          "No appointments found",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Appointment Header with Date
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(booking.date),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      Text(
                        booking.time,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Patient Details Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient image
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: const AssetImage('assets/images/patient.png'),
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 16),

                    // Patient Information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(booking.phone),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.email, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(child: Text(booking.email, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text("${booking.age} years"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24),

                // Appointment Reason
                Text(
                  "Reason for Visit:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.reason,
                  style: const TextStyle(fontSize: 15),
                ),

                // Attachments Section (if available)
                if (booking.filePath != null) ...[
                  const SizedBox(height: 16),
                  _buildAttachmentView(context, booking.filePath!),
                ],

                // Actions Section (only for pending appointments)
                if (showActions) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateStatus(booking, 'accepted'),
                          icon: const Icon(Icons.check),
                          label: const Text("Approve"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateStatus(booking, 'declined'),
                          icon: const Icon(Icons.cancel),
                          label: const Text("Decline"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
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