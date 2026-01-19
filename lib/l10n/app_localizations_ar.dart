// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تذكير الدواء';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get notifications => 'التنبيهات';

  @override
  String get enableNotifications => 'تشغيل التنبيهات';

  @override
  String get soundEffects => 'المؤثرات الصوتية';

  @override
  String get account => 'الحساب';

  @override
  String get userName => 'اسم المستخدم';

  @override
  String get notSet => 'لم يتم التحديد';

  @override
  String get more => 'المزيد';

  @override
  String get aboutApp => 'عن التطبيق';

  @override
  String get version => 'إصدار 1.0.0';

  @override
  String get language => 'اللغة';

  @override
  String get home => 'الرئيسية';

  @override
  String get calendar => 'التقويم';

  @override
  String get medications => 'الأدوية';

  @override
  String get addMedication => 'إضافة دواء';

  @override
  String get noMedications => 'لا توجد أدوية مضافة حالياً';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get updateStock => 'تحديث المخزون';

  @override
  String get deleteMedication => 'حذف الدواء';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get editName => 'تعديل الاسم';

  @override
  String get enterName => 'أدخل اسمك هنا';

  @override
  String get total => 'الإجمالي';

  @override
  String get taken => 'أخذت';

  @override
  String get remaining => 'متبقية';

  @override
  String nextDose(Object name) {
    return 'الجرعة القادمة: $name';
  }

  @override
  String atTime(Object time) {
    return 'في تمام الساعة $time';
  }

  @override
  String get enterMedName => 'يرجى إدخال اسم الدواء';

  @override
  String get stepBasicInfo => 'المعلومات الأساسية والمخزون';

  @override
  String get stepSchedule => 'الجدول الزمني';

  @override
  String get stepNotification => 'التنبيهات';

  @override
  String get defaultSound => 'النغمة الافتراضية';

  @override
  String get softBell => 'تنبيه هادئ';

  @override
  String get loudAlarm => 'تنبيه قوي';

  @override
  String get glassPing => 'رنين زجاجي';

  @override
  String get echoChime => 'صدى الجرس';

  @override
  String get crystalBell => 'جرس كريستال';

  @override
  String get snoozeTitle => '⏰ غفوة: موعد دواء';

  @override
  String get snoozeBody => 'تذكير بعد 10 دقائق لتناول الدواء';

  @override
  String notificationDescription(Object name) {
    return 'إشعارات تذكير الدواء بنغمة $name';
  }

  @override
  String get testNotificationTitle => 'إشعار فوري';

  @override
  String get testNotificationBody => 'النظام يعمل بنجاح! هل تسمع التنبيه؟';

  @override
  String localeDeleteQuery(Object name) {
    return 'هل أنت متأكد من حذف $name؟';
  }

  @override
  String get today => 'اليوم';

  @override
  String get underDevelopment => 'قيد التطوير';

  @override
  String get appSlogan => 'رفيقك الصحي لتنظيم جرعاتك اليومية';

  @override
  String get feature1Title => 'تنبيهات ذكية';

  @override
  String get feature1Desc =>
      'لا تنسى جرعتك أبداً مع نظام التنبيهات المتقدم والعد التنازلي الدقيق.';

  @override
  String get feature2Title => 'سجل المتابعة';

  @override
  String get feature2Desc =>
      'تتبع مدى التزامك من خلال تقويم تفصيلي يعرض الجرعات التي تم أخذها.';

  @override
  String get feature3Title => 'خصوصية تامة';

  @override
  String get feature3Desc =>
      'بياناتك الصحية مخزنة محلياً على جهازك لضمان أعلى مستويات الأمان والخصوصية.';

  @override
  String get developedWithLove =>
      'تم التطوير بكل حب لمساعدتكم في الحفاظ على صحتكم.';

  @override
  String get step1 => 'المرحلة الأولى';

  @override
  String get medicationBasicInfo => 'معلومات الدواء الأساسية';

  @override
  String get medicationName => 'اسم الدواء';

  @override
  String get medicationNameHint => 'مثلاً: أوغمنتين 1جم';

  @override
  String get medicationForm => 'ما هو شكل الدواء؟';

  @override
  String get pill => 'حبوب';

  @override
  String get liquid => 'سائل';

  @override
  String get injection => 'حقنة';

  @override
  String get other => 'آخر';

  @override
  String get dosageAndStock => 'الجرعة والمخزون المتاح';

  @override
  String get doseAmount => 'كمية الجرعة الواحدة';

  @override
  String get pillUnit => 'حبة';

  @override
  String get ml => 'مل';

  @override
  String get previous => 'السابق';

  @override
  String get continueText => 'المتابعة';

  @override
  String get saveMedication => 'حفظ الدواء';

  @override
  String get unit => 'وحدة';

  @override
  String get stockAmount => 'الكمية المتاحة في المخزون';

  @override
  String get lowStockAlert => 'تنبيه عند انخفاض المخزون';

  @override
  String get lowStockLimit => 'نبهني عندما تتبقى كمية';

  @override
  String get step2 => 'المرحلة الثانية';

  @override
  String get medicationSchedule => 'الجدول الزمني';

  @override
  String get dailyFrequency => 'كم مرة في اليوم؟';

  @override
  String get times => 'مرات';

  @override
  String get frequencyOnce => 'مرة واحدة';

  @override
  String get frequencyTwice => 'مرتين';

  @override
  String get frequencyThrice => '3 مرات';

  @override
  String get frequencyFour => '4 مرات';

  @override
  String get frequencyFive => '5 مرات';

  @override
  String selectTimeForDose(Object number) {
    return 'حدد وقت الجرعة $number';
  }

  @override
  String get step3 => 'المرحلة الثالثة';

  @override
  String get notificationSettings => 'إعدادات التنبيهات';

  @override
  String get notificationSound => 'نغمة التنبيه';

  @override
  String get testSound => 'تجربة الصوت';

  @override
  String get vibration => 'الاهتزاز';

  @override
  String get reorderAlert => 'تنبيه المخزون';

  @override
  String get containerType => 'نوع الحاوية';

  @override
  String get box => 'علبة';

  @override
  String get bottle => 'قارورة';

  @override
  String get totalBoxes => 'إجمالي العلب';

  @override
  String get totalBottles => 'إجمالي القوارير';

  @override
  String get unitsPerBox => 'عدد الحبوب في كل علبة';

  @override
  String get unitsPerBottle => 'إجمالي السائل في القارورة';

  @override
  String get doseDate => 'تاريخ بدء الدواء';

  @override
  String get firstDoseTime => 'وقت أول جرعة في اليوم';

  @override
  String get howManyBoxes => 'كم علبة اشتريت؟';

  @override
  String get howManyBottles => 'كم قارورة اشتريت؟';

  @override
  String get takenDate => 'تاريخ الجرعة';

  @override
  String get currentStockLabel => 'المخزون الحالي:';

  @override
  String get addedAmountLabel => 'الكمية المضافة:';

  @override
  String get newStockLabel => 'المخزون الجديد:';

  @override
  String get saveUpdate => 'حفظ التحديث';

  @override
  String stockUpdateSuccess(num count, String unit) {
    return '✅ تم تحديث المخزون بنجاح: $count $unit';
  }

  @override
  String get howManyUnitsPerBox => 'عدد الحبوب في العلبة';

  @override
  String get howManyUnitsPerBottle => 'إجمالي السائل في القارورة';

  @override
  String get dosingSchedule => 'نظام تكرار الجرعات';

  @override
  String get dailyEveryDay => 'يومي (كل يوم)';

  @override
  String get everyInterval => 'كل وقت معين';

  @override
  String get every => 'كل';

  @override
  String get hour => 'ساعة';

  @override
  String get hours => 'ساعات';

  @override
  String get minute => 'دقيقة';

  @override
  String get day => 'يوم';

  @override
  String get setEndDate => 'تحديد تاريخ انتهاء يدوياً';

  @override
  String get endDateDesc => 'سيتم إيقاف التنبيهات تلقائياً في هذا التاريخ';

  @override
  String get stopDate => 'تاريخ التوقف';

  @override
  String get lastStep => 'المرحلة الأخيرة';

  @override
  String get customizeSound => 'تخصيص صوت التنبيه';

  @override
  String get soundSelected => 'تم اختيار النغمة';

  @override
  String get tapToPreview => 'اضغط للمعاينة';

  @override
  String get confirmMedication => 'تأكيد معلومات الدواء';

  @override
  String get readyToSave => 'هل أنت مستعد لحفظ الدواء وتفعيل التنبيهات؟';

  @override
  String get readyStep => 'جاهز تماماً!';

  @override
  String get readyStepDesc =>
      'سيقوم التطبيق بتنبيهك في الأوقات المحددة بدقة. تذكر دائماً أن الالتزام بموعد الدواء هو طريقك للشفاء.';

  @override
  String get trackHealth => 'تتبع صحتك بدقة';

  @override
  String get medicationDetails => 'تفاصيل الدواء';

  @override
  String get dosage => 'الجرعة';

  @override
  String get daily => 'يومياً';

  @override
  String get weekly => 'أسبوعياً';

  @override
  String get doseLogged => 'تم تسجيل أخذ الجرعة بنجاح';

  @override
  String get logDoseNow => 'تسجيل أخذ الجرعة الآن';

  @override
  String get minutes => 'دقائق';

  @override
  String get days => 'أيام';

  @override
  String get noTasks => 'لا يوجد مهام لهذا اليوم';

  @override
  String get confirm => 'تأكيد';

  @override
  String get notTimeYetQuery =>
      'لم يحن وقت هذه الجرعة بعد. هل تريد شطبها على أي حال؟';

  @override
  String get log => 'شطب';

  @override
  String get remainingDosesToday => 'الجرعات المتبقية لليوم';

  @override
  String get takenDosesToday => 'الجرعات التي تم أخذها';

  @override
  String get noDosesToday => 'لا توجد جرعات مجدولة لليوم';
}
