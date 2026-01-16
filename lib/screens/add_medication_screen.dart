import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:medremind/l10n/app_localizations.dart';
import '../models/medication.dart';
import '../providers/medication_provider.dart';
import '../providers/settings_provider.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Step 1: Basic Info & Stock
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseAmountController = TextEditingController(text: '1.0');
  final TextEditingController _containerCountController = TextEditingController(text: '1');
  final TextEditingController _unitsPerContainerController = TextEditingController(text: '30');
  
  String _medType = 'pill'; 
  String _containerType = 'box';

  // Step 2: Schedule
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  String _frequencyType = 'daily'; 
  int _intervalValue = 1;
  String _intervalUnit = 'hours'; 
  bool _hasEndDate = false;
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));

  // Step 3: Notification
  String _selectedSound = 'default';
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Map<String, String>> _getAvailableSounds(AppLocalizations l10n) => [
    {'name': l10n.defaultSound, 'id': 'default', 'icon': '🎵'},
    {'name': l10n.softBell, 'id': 'soft_bell', 'icon': '🔔'},
    {'name': l10n.loudAlarm, 'id': 'loud_alarm', 'icon': '📢'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    _nameController.dispose();
    _doseAmountController.dispose();
    _containerCountController.dispose();
    _unitsPerContainerController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final l10n = AppLocalizations.of(context)!;
    if (_currentStep == 0) {
      if (_nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.enterMedName)),
        );
        return;
      }
    }
    
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveForm();
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _playPreview(String soundId) async {
    if (soundId == 'default') return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$soundId.mp3'));
    } catch (e) {
      debugPrint('Error playing preview: $e');
    }
  }
  void _updateNumericValue(TextEditingController controller, double delta, {bool isInt = false}) {
    double current = double.tryParse(controller.text) ?? 0.0;
    double newValue = current + delta;
    if (newValue < 0) newValue = 0;
    
    setState(() {
      controller.text = isInt ? newValue.toInt().toString() : newValue.toStringAsFixed(1);
    });
  }

  Widget _buildNumericControl(TextEditingController controller, String label, Color color, {bool isInt = false, double step = 1.0}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label, 
            style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStepButton(Icons.remove, () => _updateNumericValue(controller, -step, isInt: isInt), Colors.red),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  decoration: const InputDecoration(
                    border: InputBorder.none, 
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              _buildStepButton(Icons.add, () => _updateNumericValue(controller, step, isInt: isInt), Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton(IconData icon, VoidCallback onPressed, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      ),
    );
  }
  void _saveForm() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text;
    final doseAmount = double.tryParse(_doseAmountController.text) ?? 1.0;
    final containerCount = int.tryParse(_containerCountController.text) ?? 1;
    final unitsPerContainer = int.tryParse(_unitsPerContainerController.text) ?? 0;

    final startDT = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    String finalDosage = '$doseAmount ${_medType == 'pill' ? l10n.pillUnit : (_medType == 'liquid' ? l10n.ml : l10n.unit)}';
    String freqLabel = _frequencyType == 'daily' ? l10n.dailyEveryDay : '${l10n.every} $_intervalValue ${_intervalUnit == 'hours' ? l10n.hours : (_intervalUnit == 'minutes' ? l10n.minute : l10n.day)}';

    int totalUnits = containerCount * unitsPerContainer;
    String? calculatedEndDateStr;

    if (totalUnits > 0 && doseAmount > 0) {
      double dosesAvailable = totalUnits / doseAmount;
      double dosesPerDay = 1.0;
      if (_frequencyType == 'interval') {
        if (_intervalUnit == 'hours') dosesPerDay = 24.0 / _intervalValue;
        else if (_intervalUnit == 'minutes') dosesPerDay = (24.0 * 60) / _intervalValue;
        else if (_intervalUnit == 'days') dosesPerDay = 1.0 / _intervalValue;
      }
      
      int daysUntilDepletion = (dosesAvailable / dosesPerDay).ceil();
      final depDate = startDT.add(Duration(days: daysUntilDepletion > 0 ? daysUntilDepletion - 1 : 0));
      calculatedEndDateStr = DateFormat('yyyy-MM-dd').format(depDate);
    } else if (_hasEndDate) {
      calculatedEndDateStr = DateFormat('yyyy-MM-dd').format(_endDate);
    }

    final locale = Localizations.localeOf(context).toString();
    final newMed = Medication(
      name: name,
      dosage: finalDosage,
      timeText: "${DateFormat.yMd(locale).format(startDT)} ${DateFormat.jm(locale).format(startDT)}",
      frequency: freqLabel,
      interval: _frequencyType == 'interval' ? _intervalValue : null,
      intervalUnit: _frequencyType == 'interval' ? _intervalUnit : 'daily',
      hour: _startTime.hour,
      minute: _startTime.minute,
      year: _startDate.year,
      month: _startDate.month,
      day: _startDate.day,
      sound: _selectedSound == 'default' ? null : _selectedSound,
      totalPills: totalUnits > 0 ? totalUnits : null,
      endDate: calculatedEndDateStr,
    );

    await Provider.of<MedicationProvider>(context, listen: false).addMedication(newMed);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withValues(alpha: 0.05),
              theme.scaffoldBackgroundColor,
              Colors.purple.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (int index) {
                    setState(() => _currentStep = index);
                  },
                  children: [
                    _buildStep1Page(),
                    _buildStep2Page(),
                    _buildStep3Page(),
                  ],
                ),
              ),
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Icon(Icons.close, color: theme.colorScheme.primary),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Column(
            children: [
              Text(
                l10n.addMedication,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                l10n.trackHealth,
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
            ],
          ),
          const SizedBox(width: 48), // Spacer for balance
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (index) {
          bool isActive = index <= _currentStep;
          bool isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isCurrent ? 45 : 35,
                  height: isCurrent ? 45 : 35,
                  decoration: BoxDecoration(
                    color: isActive ? theme.primaryColor : theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: isActive ? [
                      BoxShadow(
                        color: theme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ] : [],
                    border: Border.all(
                      color: isActive ? Colors.transparent : theme.hintColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isActive && !isCurrent
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : theme.hintColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
                if (index < 2)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: index < _currentStep 
                          ? theme.primaryColor 
                          : theme.hintColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark ? theme.primaryColor.withValues(alpha: 0.1) : theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: TextButton(
                onPressed: _previousPage,
                child: Text(l10n.previous, style: TextStyle(color: theme.colorScheme.primary.withValues(alpha: 0.6), fontWeight: FontWeight.bold)),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                shadowColor: theme.primaryColor.withValues(alpha: 0.3),
              ),
              onPressed: _nextPage,
              child: Text(
                _currentStep < 2 ? l10n.continueText : l10n.saveMedication,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Page() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.step1,
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.medicationBasicInfo,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 30),
          
          TextField(
            controller: _nameController,
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              labelText: l10n.medicationName,
              hintText: l10n.medicationNameHint,
              prefixIcon: Icon(Icons.medication, color: theme.primaryColor),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.brightness == Brightness.dark ? Colors.white : Colors.black.withValues(alpha: 0.1),
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
            ),
          ),
          const SizedBox(height: 30),
          
          Text(l10n.medicationForm, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildTypeCard('pill', l10n.pill, Icons.adjust, constraints.maxWidth),
                  _buildTypeCard('liquid', l10n.liquid, Icons.water_drop, constraints.maxWidth),
                  _buildTypeCard('injection', l10n.injection, Icons.vaccines, constraints.maxWidth),
                  _buildTypeCard('other', l10n.other, Icons.more_horiz, constraints.maxWidth),
                ],
              );
            },
          ),
          
          const SizedBox(height: 40),
          Text(l10n.dosageAndStock, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Dosage Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.brightness == Brightness.dark ? Colors.white : Colors.black.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.doseAmount, 
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _medType == 'pill' ? l10n.pillUnit : (_medType == 'liquid' ? l10n.ml : l10n.unit),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStepButton(Icons.remove, () => _updateNumericValue(_doseAmountController, -0.5), Colors.red),
                    Expanded(
                      child: TextField(
                        controller: _doseAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        decoration: const InputDecoration(
                          border: InputBorder.none, 
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                    _buildStepButton(Icons.add, () => _updateNumericValue(_doseAmountController, 0.5), Colors.green),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Container Toggle Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.brightness == Brightness.dark ? Colors.white : Colors.black.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.containerType,
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildToggleOption('box', l10n.box, Colors.orange),
                    const SizedBox(width: 8),
                    _buildToggleOption('bottle', l10n.bottle, Colors.orange),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Container Count Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.brightness == Brightness.dark ? Colors.white : Colors.black.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            child: _buildNumericControl(
              _containerCountController, 
              _containerType == 'box' ? l10n.totalBoxes : l10n.totalBottles, 
              Colors.orange,
              isInt: true,
            ),
          ),
          const SizedBox(height: 16),
          // Units Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.brightness == Brightness.dark ? Colors.white : Colors.black.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            child: _buildNumericControl(
              _unitsPerContainerController, 
              _containerType == 'box' ? l10n.unitsPerBox : l10n.unitsPerBottle, 
              Colors.blue,
              isInt: true,
              step: 1.0,
            ),
          ),
          const SizedBox(height: 40),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTypeCard(String type, String label, IconData icon, double maxWidth) {
    final theme = Theme.of(context);
    bool isSelected = _medType == type;
    double cardWidth = (maxWidth - 36) / 4;
    
    return GestureDetector(
      onTap: () => setState(() => _medType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: cardWidth,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? theme.primaryColor.withValues(alpha: 0.4)
                : (theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : theme.shadowColor.withValues(alpha: 0.1)),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected 
              ? (theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor) 
              : (theme.brightness == Brightness.dark ? Colors.white : Colors.black.withValues(alpha: 0.1)),
            width: isSelected ? 3 : 2.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon, 
              color: isSelected ? Colors.white : theme.hintColor,
              size: 28,
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label, 
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : theme.hintColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption(String value, String label, Color color) {
    bool isSelected = _containerType == value;
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _containerType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : (theme.brightness == Brightness.dark ? Colors.white24 : color.withValues(alpha: 0.2)),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep2Page() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.step2,
              style: const TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.medicationSchedule,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 30),
          
          _buildInfoTile(l10n.doseDate, DateFormat.yMMMMd(l10n.localeName).format(_startDate), Icons.calendar_today, Colors.blue, () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _startDate,
              firstDate: DateTime.now().subtract(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) setState(() => _startDate = picked);
          }),
          const SizedBox(height: 16),
          _buildInfoTile(l10n.firstDoseTime, _startTime.format(context), Icons.access_time, Colors.orange, () async {
            final picked = await showTimePicker(context: context, initialTime: _startTime);
            if (picked != null) setState(() => _startTime = picked);
          }),
          
          const SizedBox(height: 40),
          Text(l10n.dosingSchedule, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildFrequencyChip(l10n.dailyEveryDay, 'daily', Icons.today)),
              const SizedBox(width: 12),
              Expanded(child: _buildFrequencyChip(l10n.everyInterval, 'interval', Icons.update)),
            ],
          ),
          
          if (_frequencyType == 'interval') ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor.withValues(alpha: 0.2),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.brightness == Brightness.dark ? theme.primaryColor.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.repeat, color: theme.primaryColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Text(l10n.every, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        _buildStepButton(Icons.remove, () {
                          if (_intervalValue > 1) setState(() => _intervalValue--);
                        }, theme.primaryColor),
                        const SizedBox(width: 6),
                        Text('$_intervalValue', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        _buildStepButton(Icons.add, () {
                          setState(() => _intervalValue++);
                        }, theme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _intervalUnit,
                            isExpanded: true,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                            items: [
                              DropdownMenuItem(value: 'minutes', child: Text(l10n.minute, style: const TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'hours', child: Text(l10n.hour, style: const TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'days', child: Text(l10n.day, style: const TextStyle(fontSize: 12))),
                            ],
                            onChanged: (v) => setState(() => _intervalUnit = v!),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              color: _hasEndDate ? Colors.red.withValues(alpha: 0.1) : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hasEndDate 
                  ? Colors.red 
                  : (theme.brightness == Brightness.dark ? Colors.white : Colors.black.withValues(alpha: 0.1)),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.brightness == Brightness.dark && !_hasEndDate ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                SwitchListTile(
                  activeColor: Colors.red,
                  title: Text(l10n.setEndDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(l10n.endDateDesc),
                  value: _hasEndDate,
                  onChanged: (v) => setState(() => _hasEndDate = v),
                ),
                if (_hasEndDate)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: _buildInfoTile(l10n.stopDate, DateFormat.yMMMMd(l10n.localeName).format(_endDate), Icons.event_busy, Colors.red, () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
                        firstDate: _startDate,
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (picked != null) setState(() => _endDate = picked);
                    }),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFrequencyChip(String label, String type, IconData icon) {
    final theme = Theme.of(context);
    bool isSelected = _frequencyType == type;
    return GestureDetector(
      onTap: () => setState(() => _frequencyType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? (theme.brightness == Brightness.dark ? Colors.white : Colors.transparent) : (theme.brightness == Brightness.dark ? Colors.white : Colors.black.withValues(alpha: 0.1)),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? theme.primaryColor.withValues(alpha: 0.4) 
                : (theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : theme.shadowColor.withValues(alpha: 0.05)),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : theme.hintColor, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3Page() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.lastStep,
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.customizeSound,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 30),
          
          ..._getAvailableSounds(l10n).map((sound) {
            final soundId = sound['id'] ?? 'default';
            final soundName = sound['name'] ?? '';
            final soundIcon = sound['icon'] ?? '🎵';
            bool isSelected = _selectedSound == soundId;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: theme.colorScheme.surface,
                border: Border.all(
                  color: isSelected 
                    ? (theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor) 
                    : (theme.brightness == Brightness.dark ? Colors.white : Colors.black.withValues(alpha: 0.1)),
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                      ? theme.primaryColor.withValues(alpha: 0.2) 
                      : (theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : theme.shadowColor.withValues(alpha: 0.05)),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.primaryColor.withValues(alpha: 0.1) : theme.hintColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(soundIcon, style: const TextStyle(fontSize: 24)),
                ),
                title: Text(
                  soundName, 
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(isSelected ? l10n.soundSelected : l10n.tapToPreview),
                trailing: isSelected 
                  ? Icon(Icons.check_circle, color: theme.primaryColor) 
                  : Icon(Icons.play_circle_outline, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                onTap: () {
                  setState(() => _selectedSound = soundId);
                  _playPreview(soundId);
                },
              ),
            );
          }),
          
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor.withValues(alpha: 0.1), theme.colorScheme.surface],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.brightness == Brightness.dark ? theme.primaryColor.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.02),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.notifications_active, size: 80, color: theme.primaryColor.withValues(alpha: 0.3)),
                const SizedBox(height: 20),
                Text(
                  l10n.readyStep,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.readyStepDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.brightness == Brightness.dark ? Colors.white : Colors.black.withValues(alpha: 0.1),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark ? theme.primaryColor.withValues(alpha: 0.1) : theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.edit_calendar, color: theme.colorScheme.primary.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }
}


