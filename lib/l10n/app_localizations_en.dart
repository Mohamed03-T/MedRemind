// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Medication Reminder';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get account => 'Account';

  @override
  String get userName => 'User Name';

  @override
  String get notSet => 'Not set';

  @override
  String get more => 'More';

  @override
  String get aboutApp => 'About App';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get language => 'Language';

  @override
  String get home => 'Home';

  @override
  String get calendar => 'Calendar';

  @override
  String get medications => 'Medications';

  @override
  String get addMedication => 'Add Medication';

  @override
  String get noMedications => 'No medications added yet';

  @override
  String get viewDetails => 'View Details';

  @override
  String get updateStock => 'Update Stock';

  @override
  String get deleteMedication => 'Delete Medication';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get editName => 'Edit Name';

  @override
  String get enterName => 'Enter your name here';

  @override
  String get total => 'Total';

  @override
  String get taken => 'Taken';

  @override
  String get remaining => 'Remaining';

  @override
  String nextDose(Object name) {
    return 'Next Dose: $name';
  }

  @override
  String atTime(Object time) {
    return 'at $time';
  }

  @override
  String get enterMedName => 'Please enter medication name';

  @override
  String get stepBasicInfo => 'Basic Info & Stock';

  @override
  String get stepSchedule => 'Schedule';

  @override
  String get stepNotification => 'Notifications';

  @override
  String get defaultSound => 'Default Sound';

  @override
  String get softBell => 'Soft Bell';

  @override
  String get loudAlarm => 'Loud Alarm';

  @override
  String get snoozeTitle => '⏰ Snooze: Medication Time';

  @override
  String get snoozeBody => 'Reminder after 10 minutes to take medication';

  @override
  String notificationDescription(Object name) {
    return 'Medication reminder notifications with $name sound';
  }

  @override
  String get testNotificationTitle => 'Instant Notification';

  @override
  String get testNotificationBody =>
      'System is working successfully! Do you hear the alert?';

  @override
  String localeDeleteQuery(Object name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get today => 'Today';

  @override
  String get underDevelopment => 'Under Development';

  @override
  String get appSlogan => 'Your health companion for organizing daily doses';

  @override
  String get feature1Title => 'Smart Alerts';

  @override
  String get feature1Desc =>
      'Never miss a dose with an advanced alert system and precise countdown.';

  @override
  String get feature2Title => 'Follow-up Log';

  @override
  String get feature2Desc =>
      'Track your commitment through a detailed calendar showing taken doses.';

  @override
  String get feature3Title => 'Full Privacy';

  @override
  String get feature3Desc =>
      'Your health data is stored locally on your device for maximum security and privacy.';

  @override
  String get developedWithLove =>
      'Developed with love to help you maintain your health.';

  @override
  String get step1 => 'Step 1';

  @override
  String get medicationBasicInfo => 'Medication Basic Info';

  @override
  String get medicationName => 'Medication Name';

  @override
  String get medicationNameHint => 'e.g., Augmentin 1g';

  @override
  String get medicationForm => 'What is the medication form?';

  @override
  String get pill => 'Pill';

  @override
  String get liquid => 'Liquid';

  @override
  String get injection => 'Injection';

  @override
  String get other => 'Other';

  @override
  String get dosageAndStock => 'Dosage and Available Stock';

  @override
  String get doseAmount => 'Dose Amount';

  @override
  String get pillUnit => 'Pill';

  @override
  String get ml => 'ml';

  @override
  String get previous => 'Previous';

  @override
  String get continueText => 'Continue';

  @override
  String get saveMedication => 'Save Medication';

  @override
  String get unit => 'Unit';

  @override
  String get stockAmount => 'Current Stock Amount';

  @override
  String get lowStockAlert => 'Low Stock Alert';

  @override
  String get lowStockLimit => 'Alert me when stock reaches';

  @override
  String get step2 => 'Step 2';

  @override
  String get medicationSchedule => 'Schedule';

  @override
  String get dailyFrequency => 'How many times a day?';

  @override
  String get times => 'times';

  @override
  String get frequencyOnce => 'Once';

  @override
  String get frequencyTwice => 'Twice';

  @override
  String get frequencyThrice => '3 times';

  @override
  String get frequencyFour => '4 times';

  @override
  String get frequencyFive => '5 times';

  @override
  String selectTimeForDose(Object number) {
    return 'Select time for dose $number';
  }

  @override
  String get step3 => 'Step 3';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notificationSound => 'Notification Sound';

  @override
  String get testSound => 'Test Sound';

  @override
  String get vibration => 'Vibration';

  @override
  String get reorderAlert => 'Stock Alert';

  @override
  String get containerType => 'Container Type';

  @override
  String get box => 'Box';

  @override
  String get bottle => 'Bottle';

  @override
  String get totalBoxes => 'Total Boxes';

  @override
  String get totalBottles => 'Total Bottles';

  @override
  String get unitsPerBox => 'Units per Box';

  @override
  String get unitsPerBottle => 'Liquid per Bottle';

  @override
  String get doseDate => 'Medication Start Date';

  @override
  String get firstDoseTime => 'First Dose Time';

  @override
  String get howManyBoxes => 'How many boxes did you buy?';

  @override
  String get howManyBottles => 'How many bottles did you buy?';

  @override
  String get takenDate => 'Taken Date';

  @override
  String get currentStockLabel => 'Current Stock:';

  @override
  String get addedAmountLabel => 'Added Amount:';

  @override
  String get newStockLabel => 'New Stock:';

  @override
  String get saveUpdate => 'Save Update';

  @override
  String stockUpdateSuccess(num count, String unit) {
    return '✅ Stock updated successfully: $count $unit';
  }

  @override
  String get howManyUnitsPerBox => 'Units per box';

  @override
  String get howManyUnitsPerBottle => 'Liquid per bottle';

  @override
  String get dosingSchedule => 'Dosing Schedule';

  @override
  String get dailyEveryDay => 'Daily (Every day)';

  @override
  String get everyInterval => 'Interval (Every hours)';

  @override
  String get every => 'Every';

  @override
  String get hour => 'Hour';

  @override
  String get hours => 'Hours';

  @override
  String get minute => 'Minute';

  @override
  String get day => 'Day';

  @override
  String get setEndDate => 'Set End Date Manually';

  @override
  String get endDateDesc => 'Alerts will automatically stop on this date';

  @override
  String get stopDate => 'Stop Date';

  @override
  String get lastStep => 'Last Step';

  @override
  String get customizeSound => 'Customize Alert Sound';

  @override
  String get soundSelected => 'Sound selected';

  @override
  String get tapToPreview => 'Tap to preview';

  @override
  String get confirmMedication => 'Confirm Medication Info';

  @override
  String get readyToSave => 'Are you ready to save and activate alerts?';

  @override
  String get readyStep => 'All set!';

  @override
  String get readyStepDesc =>
      'The app will remind you at the specified times. Remember that adhering to your medication schedule is your path to recovery.';

  @override
  String get trackHealth => 'Track your health accurately';

  @override
  String get medicationDetails => 'Medication Details';

  @override
  String get dosage => 'Dosage';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get doseLogged => 'Dose logged successfully';

  @override
  String get logDoseNow => 'Log Dose Now';

  @override
  String get minutes => 'Minutes';

  @override
  String get days => 'Days';

  @override
  String get noTasks => 'No tasks for this day';

  @override
  String get confirm => 'Confirm';

  @override
  String get notTimeYetQuery =>
      'It is not time for this dose yet. Do you want to log it anyway?';

  @override
  String get log => 'Log';

  @override
  String get remainingDosesToday => 'Remaining Doses Today';

  @override
  String get takenDosesToday => 'Taken Doses';

  @override
  String get noDosesToday => 'No scheduled doses for today';
}
