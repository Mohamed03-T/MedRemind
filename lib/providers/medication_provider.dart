import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class MedicationProvider with ChangeNotifier {
  List<Medication> _medications = [];
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  MedicationProvider() {
    // Refresh medication list when completions/stock change via notifications
    NotificationService().addDataChangedListener(() {
      loadMedications();
    });
  }

  List<Medication> get medications => _medications;

  Future<void> loadMedications() async {
    _medications = await _dbService.getMedications();
    notifyListeners();
  }

  Future<void> addMedication(Medication medication) async {
    try {
      final id = await _dbService.insertMedication(medication);
      debugPrint('Medication inserted with ID: $id');
      final newMed = medication.copyWith(id: id);
      _medications.add(newMed);
      
      try {
        await _notificationService.scheduleNotification(newMed);
      } catch (e) {
        debugPrint('Error scheduling notification: $e');
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding medication: $e');
    }
  }

  Future<void> deleteMedication(int id) async {
    await _dbService.deleteMedication(id);
    _medications.removeWhere((med) => med.id == id);
    await _notificationService.cancelNotification(id);
    try {
      await _dbService.deleteCompletionsForMed(id);
    } catch (e) {
      debugPrint('Error deleting completions for med $id: $e');
    }
    notifyListeners();
  }

  Future<void> toggleStatus(Medication medication) async {
    final updatedMed = medication.copyWith(isTaken: !medication.isTaken);
    await _dbService.updateMedication(updatedMed);
    final index = _medications.indexWhere((m) => m.id == medication.id);
    if (index != -1) {
      _medications[index] = updatedMed;
      notifyListeners();
    }
  }

  Future<void> decrementPillCount(int medicationId) async {
    final remaining = await _dbService.decrementPills(medicationId);
    final index = _medications.indexWhere((m) => m.id == medicationId);
    if (index != -1 && remaining != null) {
      _medications[index] = _medications[index].copyWith(totalPills: remaining);
      notifyListeners();
    }
  }

  Future<void> updatePillCount(int medicationId, int newCount) async {
    final medIndex = _medications.indexWhere((m) => m.id == medicationId);
    if (medIndex != -1) {
      final updatedMed = _medications[medIndex].copyWith(totalPills: newCount);
      await _dbService.updateMedication(updatedMed);
      _medications[medIndex] = updatedMed;
      notifyListeners();
    }
  }
}
