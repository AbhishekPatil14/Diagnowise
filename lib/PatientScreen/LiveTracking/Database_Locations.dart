import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../DoctorScreen/Location Entry/Location_Model.dart';


class StorageService {
  static Future<bool> saveDoctor(Doctor1 doctor) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(doctor.id, jsonEncode(doctor.toJson()));
    } catch (e) {
      print('Error saving doctor: $e');
      return false;
    }
  }

  static Future<Doctor1?> getDoctor(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(id);
      return data != null ? Doctor1.fromJson(jsonDecode(data)) : null;
    } catch (e) {
      print('Error retrieving doctor: $e');
      return null;
    }
  }

  static Future<bool> doctorExists(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(id);
  }
}