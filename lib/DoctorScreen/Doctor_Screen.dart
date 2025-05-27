import 'package:flutter/material.dart';
import 'Location Entry/LocationEntry.dart';
import 'Status Screen/DoctorApproval_Sceen.dart';
import 'PieChart Screen/Booking_Status_PieChat_Screen.dart';
import 'Approval Screen/ViewDoctorWidget1.dart';
import '../../PatientScreen/PatientDatabase.dart';
import '../../PatientScreen/Patient_Model.dart';

class DoctorScreen extends StatefulWidget {
  final String doctorEmail;

  const DoctorScreen({super.key, required this.doctorEmail});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  int selectedIndex = 0;
  late List<Widget> pages;
  late Future<List<Booking>> bookingListFuture;

  @override
  void initState() {
    super.initState();
    bookingListFuture = _fetchBookings();

    pages = [
      DoctorApprovalScreen(doctorEmail: widget.doctorEmail),
      BookingStatusPieChart(doctorEmail: widget.doctorEmail),
      DoctorRegistrationScreen(),
      DoctorAppointmentsScreen(doctorEmail: widget.doctorEmail),
    ];
  }

  Future<List<Booking>> _fetchBookings() async {
    final db = BookingDatabase.instance;
    final allBookings = await db.getPendingBookings(widget.doctorEmail);

    return allBookings
        .where((booking) => booking.doctorName.toLowerCase() == widget.doctorEmail.toLowerCase())
        .toList();
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final navBarItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.person_add_alt_1),
      label: 'Requests',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.edit_note),
      label: 'Graph',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.map),
      label: 'Map',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.list_alt),
      label: 'View All',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.teal;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Doctor Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: themeColor,
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: pages[selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        selectedItemColor: themeColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: navBarItems,
        backgroundColor: Colors.white,
        elevation: 15,
        showUnselectedLabels: true,
      ),
    );
  }
}
