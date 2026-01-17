# MedRemind - متتبع الأدوية الذكي
**بواسطة: Mohamed03-T**

[English version below](#english-version)

---

تطبيق Flutter متطور مصمم لمساعدتك على تنظيم مواعيد أدويتك بذكاء وأناقة. يتميز التطبيق بتصميم واجهة عصري يدعم الثيم الداكن (الأسود النقي) والثيم الفاتح المريح للعين، مع دعم كامل للغتين العربية والإنجليزية.

---

## 📱 أقسام وشاشات التطبيق

### 1. الصفحة الرئيسية (Home Screen)
تعتبر لوحة التحكم الرئيسية للمستخدم، وتحتوي على:
*   **شريط الإحصائيات:** يعرض ملخصاً يومياً للجرعات (الإجمالي، المأخوذة، المتبقية) بألوان تفاعلية.
*   **بطاقة الجرعة القادمة:** تظهر بشكل بارز في الأعلى مع مؤقت عد تنازلي حي (بالثواني) واسم الدواء وموعده.
*   **قائمة الجرعات اليومية:** مقسمة إلى جرعات متبقية (Pending) وجرعات تم أخذها (Taken). 
*   **نظام الألوان:** يتغير لون حالة الجرعة (أخضر/برتقالي/أحمر) بناءً على مدى قرب الموعد أو تأخره.

### 2. تفاصيل الدواء (Medication Details)
شاشة مفصلة تعرض كل ما يتعلق بدواء معين:
*   **نظام الجرعة المستحقة:** يظهر زر "تسجيل أخذ الجرعة" فقط عندما يحين الموعد أو يقترب (خلال ساعة)، ويختفي تلقائياً فور التسجيل.
*   **المعلومات الأساسية:** الاسم، الجرعة، وتاريخ البدء.
*   **الجدول الزمني:** عرض تكرار الدواء (يومي، أسبوعي، أو فترات محددة).
*   **المخزون والتنبيهات:** عرض كمية الحبوب المتبقية ونوع صوت التنبيه المختار.

### 3. التقويم والسجل (Calendar Screen)
شاشة تفاعلية لمتابعة الالتزام التاريخي:
*   **عرض شهري:** مربعات مصممة بأناقة تعرض نسبة الإنجاز لكل يوم عبر تدرجات لونية.
*   **مؤشرات الأداء:** أسهم ملونة ترمز للجرعات المأخوذة (↑) والجرعات الفائتة (↓).
*   **تفاصيل اليوم:** عند الضغط على أي يوم، تفتح شاشة جانبية تعرض سجل الجرعات التفصيلي لذلك اليوم.

### 4. إضافة دواء جديد (Add Medication)
عملية منظمة عبر خطوات (Stepper) لتسهيل الإضافة:
*   **الخطوة 1:** المعلومات الأساسية (الاسم والجرعة).
*   **الخطوة 2:** ضبط الجدول الزمني (الوقت، التكرار، تاريخ النهاية).
*   **الخطوة 3:** التخصيص (اختيار صوت التنبيه، تفعيل تتبع المخزون).

### 5. الإعدادات (Settings Screen)
واجهة تحكم حديثة تشمل:
*   **مبدل اللغة:** زر عصري ومنزلق للتحويل بين العربية والإنجليزية.
*   **الوضع الداكن:** خيار التحويل للثيم الأسود النقي (Pure Black) مع حواف متوهجة.
*   **المؤثرات الصوتية:** التحكم في أصوات التطبيق والتنبيهات.
*   **أزرار تفاعلية:** مفاتيح (Switches) مخصصة بتصميم أنيق وحركات انسيابية.

---

## 🎨 الهوية البصرية

*   **الثيم الداكن (Dark Mode):** خلفية سوداء نقية (#000000) مع حاويات ذات حدود بيضاء رفيعة وتوهج بسيط لإعطاء مظهر مستقبلي.
*   **الثيم الفاتح (Light Mode):** ألوان هادئة تعتمد على درجات Indigo و Slate لتقليل إجهاد العين، مع مراعاة ظهور شريط الحالة (Status Bar) بشكل واضح.

---

## 🛠 التقنيات المستخدمة

*   **State Management:** Provider (لتزامن البيانات عبر التطبيق).
*   **Database:** Sqflite (لتخزين الأدوية والسجلات محلياً).
*   **Notifications:** Flutter Local Notifications (للتنبيهات الدقيقة والمجدولة).
*   **Localization:** Flutter Localization (دعم AR/EN).
*   **Storage:** Shared Preferences (لحفظ إعدادات المستخدم).

---

<div id="english-version"></div>

# MedRemind - Smart Medication Tracker
**By: Mohamed03-T**

A sophisticated Flutter application designed to help you organize your medication schedules with intelligence and elegance. The app features a modern UI that supports both a "Pure Black" dark theme and a retina-friendly light theme, with full support for Arabic and English languages.

---

## 📱 App Features & Screens

### 1. Home Screen
The main dashboard for the user, featuring:
*   **Statistics Bar:** Displays a daily summary of doses (Total, Taken, Remaining) with interactive colors.
*   **Next Dose Card:** Prominently displays the upcoming dose with a live countdown timer (including seconds), medication name, and scheduled time.
*   **Daily Dose List:** Organized into "Pending" and "Taken" doses.
*   **Color System:** Dose status colors (Green/Orange/Red) adapt based on how close or overdue the dose is.

### 2. Medication Details
A detailed view for a specific medication:
*   **Due Dose System:** The "Log Dose Now" button appears only when a dose is due or approaching (within 1 hour) and disappears automatically after logging.
*   **Essential Info:** Name, dosage, and start date.
*   **Schedule:** Displays dosing frequency (Daily, Weekly, or specific intervals).
*   **Inventory & Alerts:** Displays remaining pill stock and the selected notification sound.

### 3. Calendar & History
An interactive screen for tracking historical adherence:
*   **Monthly View:** Elegantly designed tiles showing completion percentage for each day via color gradients.
*   **Performance Indicators:** Colored arrows symbolizing Taken doses (↑) and Missed doses (↓).
*   **Day Details:** Tapping any day opens a side panel viewing the detailed dose history for that specific date.

### 4. Add Medication
A structured process via a Stepper to simplify adding entries:
*   **Step 1:** Basic Info (Name and Dosage).
*   **Step 2:** Scheduling (Time, Frequency, End Date).
*   **Step 3:** Customization (Notification sound selection, enabling inventory tracking).

### 5. Settings Screen
A modern control interface including:
*   **Language Switcher:** A stylish custom toggle for switching between Arabic and English.
*   **Dark Mode:** Option to switch to the "Pure Black" theme with glowing borders.
*   **Sound Effects:** Control over app UI sounds and notifications.
*   **Interactive Controls:** Custom-designed modern switches with smooth animations.

---

## 🎨 Visual Identity

*   **Dark Mode:** Pure Black background (#000000) with thin white-bordered containers and subtle glowing effects for a futuristic look.
*   **Light Mode:** Soft colors based on Indigo and Slate to reduce eye strain, ensuring the system status bar remains visible.

---

## 🛠 Tech Stack

*   **State Management:** Provider.
*   **Database:** Sqflite (Local storage).
*   **Notifications:** Flutter Local Notifications.
*   **Localization:** Flutter Localization (AR/EN support).
*   **Storage:** Shared Preferences (User preferences).

---

## 🚀 Getting Started

1. Ensure Flutter SDK is installed.
2. Run `flutter pub get` to fetch dependencies.
3. Use `flutter run` to launch the app on an emulator or physical device.



