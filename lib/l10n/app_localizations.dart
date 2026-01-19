import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'تذكير الدواء'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get darkMode;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات'**
  String get notifications;

  /// No description provided for @enableNotifications.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل التنبيهات'**
  String get enableNotifications;

  /// No description provided for @soundEffects.
  ///
  /// In ar, this message translates to:
  /// **'المؤثرات الصوتية'**
  String get soundEffects;

  /// No description provided for @account.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get account;

  /// No description provided for @userName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get userName;

  /// No description provided for @notSet.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم التحديد'**
  String get notSet;

  /// No description provided for @more.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get more;

  /// No description provided for @aboutApp.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In ar, this message translates to:
  /// **'إصدار 1.0.0'**
  String get version;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @calendar.
  ///
  /// In ar, this message translates to:
  /// **'التقويم'**
  String get calendar;

  /// No description provided for @medications.
  ///
  /// In ar, this message translates to:
  /// **'الأدوية'**
  String get medications;

  /// No description provided for @addMedication.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دواء'**
  String get addMedication;

  /// No description provided for @noMedications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أدوية مضافة حالياً'**
  String get noMedications;

  /// No description provided for @viewDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get viewDetails;

  /// No description provided for @updateStock.
  ///
  /// In ar, this message translates to:
  /// **'تحديث المخزون'**
  String get updateStock;

  /// No description provided for @deleteMedication.
  ///
  /// In ar, this message translates to:
  /// **'حذف الدواء'**
  String get deleteMedication;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @editName.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الاسم'**
  String get editName;

  /// No description provided for @enterName.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك هنا'**
  String get enterName;

  /// No description provided for @total.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get total;

  /// No description provided for @taken.
  ///
  /// In ar, this message translates to:
  /// **'أخذت'**
  String get taken;

  /// No description provided for @remaining.
  ///
  /// In ar, this message translates to:
  /// **'متبقية'**
  String get remaining;

  /// No description provided for @nextDose.
  ///
  /// In ar, this message translates to:
  /// **'الجرعة القادمة: {name}'**
  String nextDose(Object name);

  /// No description provided for @atTime.
  ///
  /// In ar, this message translates to:
  /// **'في تمام الساعة {time}'**
  String atTime(Object time);

  /// No description provided for @enterMedName.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال اسم الدواء'**
  String get enterMedName;

  /// No description provided for @stepBasicInfo.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الأساسية والمخزون'**
  String get stepBasicInfo;

  /// No description provided for @stepSchedule.
  ///
  /// In ar, this message translates to:
  /// **'الجدول الزمني'**
  String get stepSchedule;

  /// No description provided for @stepNotification.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات'**
  String get stepNotification;

  /// No description provided for @defaultSound.
  ///
  /// In ar, this message translates to:
  /// **'النغمة الافتراضية'**
  String get defaultSound;

  /// No description provided for @softBell.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه هادئ'**
  String get softBell;

  /// No description provided for @loudAlarm.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه قوي'**
  String get loudAlarm;

  /// No description provided for @glassPing.
  ///
  /// In ar, this message translates to:
  /// **'رنين زجاجي'**
  String get glassPing;

  /// No description provided for @echoChime.
  ///
  /// In ar, this message translates to:
  /// **'صدى الجرس'**
  String get echoChime;

  /// No description provided for @crystalBell.
  ///
  /// In ar, this message translates to:
  /// **'جرس كريستال'**
  String get crystalBell;

  /// No description provided for @snoozeTitle.
  ///
  /// In ar, this message translates to:
  /// **'⏰ غفوة: موعد دواء'**
  String get snoozeTitle;

  /// No description provided for @snoozeBody.
  ///
  /// In ar, this message translates to:
  /// **'تذكير بعد 10 دقائق لتناول الدواء'**
  String get snoozeBody;

  /// No description provided for @notificationDescription.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات تذكير الدواء بنغمة {name}'**
  String notificationDescription(Object name);

  /// No description provided for @testNotificationTitle.
  ///
  /// In ar, this message translates to:
  /// **'إشعار فوري'**
  String get testNotificationTitle;

  /// No description provided for @testNotificationBody.
  ///
  /// In ar, this message translates to:
  /// **'النظام يعمل بنجاح! هل تسمع التنبيه؟'**
  String get testNotificationBody;

  /// No description provided for @localeDeleteQuery.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف {name}؟'**
  String localeDeleteQuery(Object name);

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @underDevelopment.
  ///
  /// In ar, this message translates to:
  /// **'قيد التطوير'**
  String get underDevelopment;

  /// No description provided for @appSlogan.
  ///
  /// In ar, this message translates to:
  /// **'رفيقك الصحي لتنظيم جرعاتك اليومية'**
  String get appSlogan;

  /// No description provided for @feature1Title.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات ذكية'**
  String get feature1Title;

  /// No description provided for @feature1Desc.
  ///
  /// In ar, this message translates to:
  /// **'لا تنسى جرعتك أبداً مع نظام التنبيهات المتقدم والعد التنازلي الدقيق.'**
  String get feature1Desc;

  /// No description provided for @feature2Title.
  ///
  /// In ar, this message translates to:
  /// **'سجل المتابعة'**
  String get feature2Title;

  /// No description provided for @feature2Desc.
  ///
  /// In ar, this message translates to:
  /// **'تتبع مدى التزامك من خلال تقويم تفصيلي يعرض الجرعات التي تم أخذها.'**
  String get feature2Desc;

  /// No description provided for @feature3Title.
  ///
  /// In ar, this message translates to:
  /// **'خصوصية تامة'**
  String get feature3Title;

  /// No description provided for @feature3Desc.
  ///
  /// In ar, this message translates to:
  /// **'بياناتك الصحية مخزنة محلياً على جهازك لضمان أعلى مستويات الأمان والخصوصية.'**
  String get feature3Desc;

  /// No description provided for @developedWithLove.
  ///
  /// In ar, this message translates to:
  /// **'تم التطوير بكل حب لمساعدتكم في الحفاظ على صحتكم.'**
  String get developedWithLove;

  /// No description provided for @step1.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة الأولى'**
  String get step1;

  /// No description provided for @medicationBasicInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الدواء الأساسية'**
  String get medicationBasicInfo;

  /// No description provided for @medicationName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الدواء'**
  String get medicationName;

  /// No description provided for @medicationNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً: أوغمنتين 1جم'**
  String get medicationNameHint;

  /// No description provided for @medicationForm.
  ///
  /// In ar, this message translates to:
  /// **'ما هو شكل الدواء؟'**
  String get medicationForm;

  /// No description provided for @pill.
  ///
  /// In ar, this message translates to:
  /// **'حبوب'**
  String get pill;

  /// No description provided for @liquid.
  ///
  /// In ar, this message translates to:
  /// **'سائل'**
  String get liquid;

  /// No description provided for @injection.
  ///
  /// In ar, this message translates to:
  /// **'حقنة'**
  String get injection;

  /// No description provided for @other.
  ///
  /// In ar, this message translates to:
  /// **'آخر'**
  String get other;

  /// No description provided for @dosageAndStock.
  ///
  /// In ar, this message translates to:
  /// **'الجرعة والمخزون المتاح'**
  String get dosageAndStock;

  /// No description provided for @doseAmount.
  ///
  /// In ar, this message translates to:
  /// **'كمية الجرعة الواحدة'**
  String get doseAmount;

  /// No description provided for @pillUnit.
  ///
  /// In ar, this message translates to:
  /// **'حبة'**
  String get pillUnit;

  /// No description provided for @ml.
  ///
  /// In ar, this message translates to:
  /// **'مل'**
  String get ml;

  /// No description provided for @previous.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previous;

  /// No description provided for @continueText.
  ///
  /// In ar, this message translates to:
  /// **'المتابعة'**
  String get continueText;

  /// No description provided for @saveMedication.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الدواء'**
  String get saveMedication;

  /// No description provided for @unit.
  ///
  /// In ar, this message translates to:
  /// **'وحدة'**
  String get unit;

  /// No description provided for @stockAmount.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المتاحة في المخزون'**
  String get stockAmount;

  /// No description provided for @lowStockAlert.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه عند انخفاض المخزون'**
  String get lowStockAlert;

  /// No description provided for @lowStockLimit.
  ///
  /// In ar, this message translates to:
  /// **'نبهني عندما تتبقى كمية'**
  String get lowStockLimit;

  /// No description provided for @step2.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة الثانية'**
  String get step2;

  /// No description provided for @medicationSchedule.
  ///
  /// In ar, this message translates to:
  /// **'الجدول الزمني'**
  String get medicationSchedule;

  /// No description provided for @dailyFrequency.
  ///
  /// In ar, this message translates to:
  /// **'كم مرة في اليوم؟'**
  String get dailyFrequency;

  /// No description provided for @times.
  ///
  /// In ar, this message translates to:
  /// **'مرات'**
  String get times;

  /// No description provided for @frequencyOnce.
  ///
  /// In ar, this message translates to:
  /// **'مرة واحدة'**
  String get frequencyOnce;

  /// No description provided for @frequencyTwice.
  ///
  /// In ar, this message translates to:
  /// **'مرتين'**
  String get frequencyTwice;

  /// No description provided for @frequencyThrice.
  ///
  /// In ar, this message translates to:
  /// **'3 مرات'**
  String get frequencyThrice;

  /// No description provided for @frequencyFour.
  ///
  /// In ar, this message translates to:
  /// **'4 مرات'**
  String get frequencyFour;

  /// No description provided for @frequencyFive.
  ///
  /// In ar, this message translates to:
  /// **'5 مرات'**
  String get frequencyFive;

  /// No description provided for @selectTimeForDose.
  ///
  /// In ar, this message translates to:
  /// **'حدد وقت الجرعة {number}'**
  String selectTimeForDose(Object number);

  /// No description provided for @step3.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة الثالثة'**
  String get step3;

  /// No description provided for @notificationSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات التنبيهات'**
  String get notificationSettings;

  /// No description provided for @notificationSound.
  ///
  /// In ar, this message translates to:
  /// **'نغمة التنبيه'**
  String get notificationSound;

  /// No description provided for @testSound.
  ///
  /// In ar, this message translates to:
  /// **'تجربة الصوت'**
  String get testSound;

  /// No description provided for @vibration.
  ///
  /// In ar, this message translates to:
  /// **'الاهتزاز'**
  String get vibration;

  /// No description provided for @reorderAlert.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه المخزون'**
  String get reorderAlert;

  /// No description provided for @containerType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الحاوية'**
  String get containerType;

  /// No description provided for @box.
  ///
  /// In ar, this message translates to:
  /// **'علبة'**
  String get box;

  /// No description provided for @bottle.
  ///
  /// In ar, this message translates to:
  /// **'قارورة'**
  String get bottle;

  /// No description provided for @totalBoxes.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي العلب'**
  String get totalBoxes;

  /// No description provided for @totalBottles.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي القوارير'**
  String get totalBottles;

  /// No description provided for @unitsPerBox.
  ///
  /// In ar, this message translates to:
  /// **'عدد الحبوب في كل علبة'**
  String get unitsPerBox;

  /// No description provided for @unitsPerBottle.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي السائل في القارورة'**
  String get unitsPerBottle;

  /// No description provided for @doseDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ بدء الدواء'**
  String get doseDate;

  /// No description provided for @firstDoseTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت أول جرعة في اليوم'**
  String get firstDoseTime;

  /// No description provided for @howManyBoxes.
  ///
  /// In ar, this message translates to:
  /// **'كم علبة اشتريت؟'**
  String get howManyBoxes;

  /// No description provided for @howManyBottles.
  ///
  /// In ar, this message translates to:
  /// **'كم قارورة اشتريت؟'**
  String get howManyBottles;

  /// No description provided for @takenDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الجرعة'**
  String get takenDate;

  /// No description provided for @currentStockLabel.
  ///
  /// In ar, this message translates to:
  /// **'المخزون الحالي:'**
  String get currentStockLabel;

  /// No description provided for @addedAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المضافة:'**
  String get addedAmountLabel;

  /// No description provided for @newStockLabel.
  ///
  /// In ar, this message translates to:
  /// **'المخزون الجديد:'**
  String get newStockLabel;

  /// No description provided for @saveUpdate.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التحديث'**
  String get saveUpdate;

  /// No description provided for @stockUpdateSuccess.
  ///
  /// In ar, this message translates to:
  /// **'✅ تم تحديث المخزون بنجاح: {count} {unit}'**
  String stockUpdateSuccess(num count, String unit);

  /// No description provided for @howManyUnitsPerBox.
  ///
  /// In ar, this message translates to:
  /// **'عدد الحبوب في العلبة'**
  String get howManyUnitsPerBox;

  /// No description provided for @howManyUnitsPerBottle.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي السائل في القارورة'**
  String get howManyUnitsPerBottle;

  /// No description provided for @dosingSchedule.
  ///
  /// In ar, this message translates to:
  /// **'نظام تكرار الجرعات'**
  String get dosingSchedule;

  /// No description provided for @dailyEveryDay.
  ///
  /// In ar, this message translates to:
  /// **'يومي (كل يوم)'**
  String get dailyEveryDay;

  /// No description provided for @everyInterval.
  ///
  /// In ar, this message translates to:
  /// **'كل وقت معين'**
  String get everyInterval;

  /// No description provided for @every.
  ///
  /// In ar, this message translates to:
  /// **'كل'**
  String get every;

  /// No description provided for @hour.
  ///
  /// In ar, this message translates to:
  /// **'ساعة'**
  String get hour;

  /// No description provided for @hours.
  ///
  /// In ar, this message translates to:
  /// **'ساعات'**
  String get hours;

  /// No description provided for @minute.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة'**
  String get minute;

  /// No description provided for @day.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get day;

  /// No description provided for @setEndDate.
  ///
  /// In ar, this message translates to:
  /// **'تحديد تاريخ انتهاء يدوياً'**
  String get setEndDate;

  /// No description provided for @endDateDesc.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إيقاف التنبيهات تلقائياً في هذا التاريخ'**
  String get endDateDesc;

  /// No description provided for @stopDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ التوقف'**
  String get stopDate;

  /// No description provided for @lastStep.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة الأخيرة'**
  String get lastStep;

  /// No description provided for @customizeSound.
  ///
  /// In ar, this message translates to:
  /// **'تخصيص صوت التنبيه'**
  String get customizeSound;

  /// No description provided for @soundSelected.
  ///
  /// In ar, this message translates to:
  /// **'تم اختيار النغمة'**
  String get soundSelected;

  /// No description provided for @tapToPreview.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للمعاينة'**
  String get tapToPreview;

  /// No description provided for @confirmMedication.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد معلومات الدواء'**
  String get confirmMedication;

  /// No description provided for @readyToSave.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت مستعد لحفظ الدواء وتفعيل التنبيهات؟'**
  String get readyToSave;

  /// No description provided for @readyStep.
  ///
  /// In ar, this message translates to:
  /// **'جاهز تماماً!'**
  String get readyStep;

  /// No description provided for @readyStepDesc.
  ///
  /// In ar, this message translates to:
  /// **'سيقوم التطبيق بتنبيهك في الأوقات المحددة بدقة. تذكر دائماً أن الالتزام بموعد الدواء هو طريقك للشفاء.'**
  String get readyStepDesc;

  /// No description provided for @trackHealth.
  ///
  /// In ar, this message translates to:
  /// **'تتبع صحتك بدقة'**
  String get trackHealth;

  /// No description provided for @medicationDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الدواء'**
  String get medicationDetails;

  /// No description provided for @dosage.
  ///
  /// In ar, this message translates to:
  /// **'الجرعة'**
  String get dosage;

  /// No description provided for @daily.
  ///
  /// In ar, this message translates to:
  /// **'يومياً'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعياً'**
  String get weekly;

  /// No description provided for @doseLogged.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل أخذ الجرعة بنجاح'**
  String get doseLogged;

  /// No description provided for @logDoseNow.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل أخذ الجرعة الآن'**
  String get logDoseNow;

  /// No description provided for @minutes.
  ///
  /// In ar, this message translates to:
  /// **'دقائق'**
  String get minutes;

  /// No description provided for @days.
  ///
  /// In ar, this message translates to:
  /// **'أيام'**
  String get days;

  /// No description provided for @noTasks.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مهام لهذا اليوم'**
  String get noTasks;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @notTimeYetQuery.
  ///
  /// In ar, this message translates to:
  /// **'لم يحن وقت هذه الجرعة بعد. هل تريد شطبها على أي حال؟'**
  String get notTimeYetQuery;

  /// No description provided for @log.
  ///
  /// In ar, this message translates to:
  /// **'شطب'**
  String get log;

  /// No description provided for @remainingDosesToday.
  ///
  /// In ar, this message translates to:
  /// **'الجرعات المتبقية لليوم'**
  String get remainingDosesToday;

  /// No description provided for @takenDosesToday.
  ///
  /// In ar, this message translates to:
  /// **'الجرعات التي تم أخذها'**
  String get takenDosesToday;

  /// No description provided for @noDosesToday.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد جرعات مجدولة لليوم'**
  String get noDosesToday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
