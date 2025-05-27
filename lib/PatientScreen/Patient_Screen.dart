// import 'package:flutter/material.dart';
//
// import 'Booking/Booking_Screen.dart';
// import 'Chatbot/Chatbot_Screen.dart';
// import 'LiveTracking/LiveTracking_Screen.dart';
// import 'MedicineBooking/UI/MedicineBooking_Screen.dart';
// import 'UpdatePatient_Screen/UpdatePatient_Screen.dart';
//
// class PatientScreen extends StatefulWidget {
//   const PatientScreen({super.key});
//
//   @override
//   State<PatientScreen> createState() => _PatientScreenState();
// }
//
// class _PatientScreenState extends State<PatientScreen> {
//   int _selectedIndex = 0;
//
//   final List<Widget> _pages = [
//     BookingPatientWidget(),
//     BookingListScreen(),
//     MedicineListScreen(),
//     ChatbotPatientWidget(),
//     AmbulanceTrackingScreen(),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() => _selectedIndex = index);
//   }
//
//   final List<BottomNavigationBarItem> _navBarItems = const [
//     BottomNavigationBarItem(
//       icon: Icon(Icons.add_circle_outline),
//       label: 'Booking',
//     ),
//     BottomNavigationBarItem(
//       icon: Icon(Icons.edit_note_outlined),
//       label: 'Update',
//     ),
//     BottomNavigationBarItem(
//       icon: Icon(Icons.edit_note_outlined),
//       label: 'Medicine',
//     ),
//     BottomNavigationBarItem(
//       icon: Icon(Icons.chat_bubble_outline),
//       label: 'Chatbot',
//     ),
//     BottomNavigationBarItem(
//       icon: Icon(Icons.location_on_outlined),
//       label: 'Live Tracking',
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//
//       body: AnimatedSwitcher(
//         duration: const Duration(milliseconds: 300),
//         transitionBuilder: (child, animation) {
//           return FadeTransition(opacity: animation, child: child);
//         },
//         child: _pages[_selectedIndex],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         selectedItemColor: Colors.blueAccent,
//         unselectedItemColor: Colors.grey,
//         type: BottomNavigationBarType.fixed,
//         selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
//         unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
//         items: _navBarItems,
//         backgroundColor: Colors.white,
//         elevation: 10,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import 'LiveTracking/LiveTracking_Screen.dart';
import 'MedicineBooking/UI/MedicineBooking_Screen.dart';
import 'UpdatePatient_Screen/UpdatePatient_Screen.dart';
import 'booking/booking_screen.dart';
import 'chatbot/chatbot_screen.dart';


class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  int _selectedIndex = 0;

  static  List<Widget> _pages = <Widget>[
    BookingPatientWidget(),
    BookingListScreen(),
    MedicineListScreen(),
    ChatbotPatientWidget(),
    PatientSearchScreen(),
  ];

  static const List<BottomNavigationBarItem> _navBarItems = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today_outlined),
      activeIcon: Icon(Icons.calendar_today),
      label: 'Appointments',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.edit_outlined),
      activeIcon: Icon(Icons.edit),
      label: 'Profile',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.medication_outlined),
      activeIcon: Icon(Icons.medication),
      label: 'Medicines',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_outlined),
      activeIcon: Icon(Icons.chat),
      label: 'Assistant',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.location_on_outlined),
      activeIcon: Icon(Icons.location_on),
      label: 'Tracking',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.blue[800],
      unselectedItemColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      items: _navBarItems,
      backgroundColor: Colors.white,
      elevation: 8,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }
}
