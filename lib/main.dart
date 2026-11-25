import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  final controller = FinanceController();
  await controller.init();
  runApp(MasrofyProV6App(controller: controller));
}

// ==========================================
// 1. MULTI-CURRENCY & LOCALIZATION
// ==========================================
enum AppCurrency { egp, usd, sar }

class AppStrings {
  final bool isAr;
  final AppCurrency curr;
  const AppStrings(this.isAr, [this.curr = AppCurrency.egp]);

  String get appTitle => isAr ? 'مصروفي برو' : 'Masrofy Pro';
  String get currency {
    switch (curr) {
      case AppCurrency.egp:
        return isAr ? 'ج.م' : 'EGP';
      case AppCurrency.usd:
        return r'$';
      case AppCurrency.sar:
        return isAr ? 'ر.س' : 'SAR';
    }
  }

  // Setup & Security
  String get setupTitle => isAr ? 'أنشئ محفظتك الذكية' : 'Create Smart Vault';
  String get setupSub => isAr
      ? 'تصميم Neo-Fintech عصري مع عملات متعددة وذكاء مالي وحماية PIN'
      : 'Modern Neo-Fintech with multi-currency, financial intelligence & PIN';
  String get fullName => isAr ? 'الاسم بالكامل' : 'Full Name';
  String get userJob => isAr ? 'المسمى / التخصص (مثلاً: طالب علوم)' : 'Role / Title (e.g., Science Student)';
  String get monthlyBudget => isAr ? 'الميزانية الشهرية' : 'Monthly Budget';
  String get initialCash => isAr ? 'رصيد الكاش الحالي' : 'Initial Cash Balance';
  String get createPin => isAr ? 'أنشئ رمز مرور (4 أرقام)' : 'Create 4-Digit Security PIN';
  String get startWorkspace => isAr ? 'تفعيل المحفظة والدخول' : 'Activate Vault & Launch';
  String get pinError => isAr ? 'يرجى إدخال الاسم ورمز مرور من 4 أرقام' : 'Enter name and a 4-digit PIN';

  // Lock Screen
  String get enterPinTitle => isAr ? 'أدخل رمز المرور للمتابعة' : 'Enter Security PIN';
  String get wrongPin => isAr ? 'رمز المرور غير صحيح!' : 'Incorrect PIN!';
  String get quickBioHint => isAr ? 'دخول سريع بالبصمة' : 'Quick Biometric Unlock';

  // Navigation
  String get navHome => isAr ? 'الرئيسية' : 'Home';
  String get navStats => isAr ? 'التحليلات' : 'Analytics';
  String get navVaults => isAr ? 'الأهداف والديون' : 'Vaults';
  String get navHistory => isAr ? 'السجل' : 'Activity';
  String get navSettings => isAr ? 'الإعدادات' : 'Settings';

  // Dashboard
  String greeting(String name) => isAr ? 'أهلاً، $name' : 'Hello, $name';
  String get totalAssets => isAr ? 'إجمالي الأصول المتاحة' : 'Total Available Balance';
  String get safeDaily => isAr ? 'المسموح يومياً' : 'Safe / Day';
  String get healthScore => isAr ? 'الصحة المالية' : 'Health Score';
  String get streakDays => isAr ? 'يوم التزام' : 'Day Streak';
  String get income => isAr ? 'الدخل' : 'Income';
  String get expense => isAr ? 'المصروفات' : 'Expenses';
  String get transfer => isAr ? 'تحويل' : 'Transfer';
  String get budgetProgress => isAr ? 'استهلاك الميزانية الشهرية' : 'Monthly Budget Usage';
  String get walletsTitle => isAr ? 'المحافظ (اضغط لكشف الحساب)' : 'Wallets (Tap for Statement)';
  String get recentActivity => isAr ? 'أحدث العمليات' : 'Recent Activity';
  String get viewAll => isAr ? 'عرض الكل' : 'See All';

  // Bill Radar Alert
  String billRadarAlert(String title, int days) {
    if (days == 0) {
      return isAr ? 'تنبيه اليوم: موعد دفع "$title"' : 'Due Today: "$title"';
    }
    return isAr
        ? 'رادار الفواتير: "$title" مستحق خلال $days أيام'
        : 'Bill Radar: "$title" due in $days days';
  }

  // Wallets
  String get walletCash => isAr ? 'كاش' : 'Cash';
  String get walletEwallet => isAr ? 'انستاباي / محفظة' : 'InstaPay / Wallet';
  String get walletBank => isAr ? 'حساب بنكي' : 'Bank Account';
  String get walletStatement => isAr ? 'كشف حساب المحفظة' : 'Wallet Statement';

  // Transactions
  String get addEntry => isAr ? 'عملية جديدة' : 'New Entry';
  String get editEntry => isAr ? 'تعديل العملية' : 'Edit Entry';
  String get titleHint => isAr ? 'الوصف (مثلاً: غداء، مواصلات، مكافأة)' : 'Title (e.g., Lunch, Transit)';
  String get amountHint => isAr ? 'المبلغ' : 'Amount';
  String get noteHint => isAr ? 'ملاحظة (اختياري)' : 'Note (Optional)';
  String get walletLabel => isAr ? 'المحفظة:' : 'Wallet:';
  String get fromWallet => isAr ? 'من محفظة:' : 'From:';
  String get toWallet => isAr ? 'إلى محفظة:' : 'To:';
  String get categoryLabel => isAr ? 'التصنيف:' : 'Category:';
  String get save => isAr ? 'حفظ' : 'Save';
  String get cancel => isAr ? 'إلغاء' : 'Cancel';

  // Analytics
  String get analyticsTitle => isAr ? 'الذكاء والتحليلات المالية' : 'Financial Intelligence';
  String get momCompare => isAr ? 'مقارنة مصاريف الشهر بالسابق' : 'Month-over-Month';
  String get topDrain => isAr ? 'أعلى بند استهلاكاً' : 'Top Spending Category';
  String get last7Days => isAr ? 'مؤشر الإنفاق الأسبوعي (7 أيام)' : '7-Day Spending Trend';
  String get categoryDist => isAr ? 'توزيع المصروفات' : 'Expense Distribution';
  String get noData => isAr ? 'لا توجد بيانات كافية بعد' : 'No data available yet';

  // Vaults (Goals + Debts + Bills)
  String get vaultsTitle => isAr ? 'الأهداف والالتزامات' : 'Goals, Debts & Bills';
  String get tabGoals => isAr ? 'الأهداف' : 'Goals';
  String get tabDebts => isAr ? 'الديون' : 'Debts';
  String get tabBills => isAr ? 'الاشتراكات' : 'Bills';
  String get newGoal => isAr ? 'هدف ادخار' : 'New Goal';
  String get goalName => isAr ? 'اسم الهدف' : 'Goal Name';
  String get targetAmt => isAr ? 'المبلغ المستهدف' : 'Target Amount';
  String get deposit => isAr ? 'إيداع' : 'Deposit';
  String get newDebt => isAr ? 'تسجيل دين / سلفة' : 'Add Debt / Loan';
  String get personName => isAr ? 'اسم الشخص' : 'Person Name';
  String get owedToMe => isAr ? 'فلوس ليا عنده' : 'Owed to Me';
  String get iOwe => isAr ? 'فلوس عليا ليه' : 'I Owe';
  String get settleNow => isAr ? 'تم السداد' : 'Settle';
  String get newBill => isAr ? 'اشتراك / فاتورة متكررة' : 'Recurring Bill';
  String get billTitle => isAr ? 'اسم الفاتورة (مثلاً: باقة النت)' : 'Bill Name (e.g., Internet)';
  String get dueDay => isAr ? 'يوم الاستحقاق بالشهر (1-31)' : 'Due Day of Month (1-31)';
  String get payNow => isAr ? 'دفع الآن' : 'Pay Now';

  // History
  String get historyTitle => isAr ? 'سجل المعاملات الكامل' : 'Full Activity Log';
  String get searchHint => isAr ? 'ابحث بالاسم، التصنيف أو الملاحظة...' : 'Search title, category, note...';
  String get all => isAr ? 'الكل' : 'All';
  String get today => isAr ? 'اليوم' : 'Today';
  String get month => isAr ? 'الشهر' : 'Month';

  // Settings
  String get settingsTitle => isAr ? 'الإعدادات والملف الشخصي' : 'Settings & Profile';
  String get appearanceSection => isAr ? 'المظهر واللغة' : 'Appearance & Language';
  String get currencySection => isAr ? 'العملة وأسعار الصرف' : 'Currency & Exchange Rates';
  String get activeCurrency => isAr ? 'العملة المعروضة' : 'Display Currency';
  String get usdRateLabel => isAr ? 'سعر الدولار (USD) بالجنيه' : '1 USD in EGP';
  String get sarRateLabel => isAr ? 'سعر الريال (SAR) بالجنيه' : '1 SAR in EGP';
  String get profileSection => isAr ? 'البيانات الشخصية والميزانية' : 'Personal Info & Budget';
  String get securitySection => isAr ? 'الأمان وكلمة المرور' : 'Security & PIN';
  String get dataSection => isAr ? 'التقارير، Excel والنسخ الاحتياطي' : 'Reports, Excel/CSV & Backup';
  String get darkMode => isAr ? 'الوضع الداكن (Dark Mode)' : 'Dark Mode';
  String get appLang => isAr ? 'لغة التطبيق' : 'App Language';
  String get changePin => isAr ? 'تغيير رمز المرور (PIN)' : 'Change Security PIN';
  String get newPinHint => isAr ? 'رمز المرور الجديد (4 أرقام)' : 'New 4-Digit PIN';
  String get lockNow => isAr ? 'قفل التطبيق الآن' : 'Lock App Now';
  String get exportCsv => isAr ? 'تصدير ونسخ جدول Excel / CSV' : 'Export & Copy Excel / CSV';
  String get shareSummary => isAr ? 'نسخ كشف حساب نصي منسق' : 'Copy Formatted Statement';
  String get exportJson => isAr ? 'نسخ نسخة احتياطية (JSON)' : 'Copy JSON Backup';
  String get importJson => isAr ? 'استعادة نسخة احتياطية' : 'Restore Backup';
  String get resetFactory => isAr ? 'مسح جميع البيانات' : 'Reset All Data';
  String get updatedMsg => isAr ? 'تم التنفيذ بنجاح!' : 'Done successfully!';
}

// ==========================================
// 2. DATA MODELS
// ==========================================
enum TxType { expense, income, transfer }
enum WalletType { cash, ewallet, bank }

class CategoryModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final IconData icon;
  final Color color;

  const CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.icon,
    required this.color,
  });

  String label(bool isAr) => isAr ? nameAr : nameEn;
}

class AppCategories {
  static const List<CategoryModel> list = [
    CategoryModel(id: 'food', nameAr: 'طعام ومشروبات', nameEn: 'Food & Cafe', icon: Icons.lunch_dining_rounded, color: Color(0xFFFB923C)),
    CategoryModel(id: 'transport', nameAr: 'مواصلات', nameEn: 'Transport', icon: Icons.directions_bus_rounded, color: Color(0xFF38BDF8)),
    CategoryModel(id: 'study', nameAr: 'دراسة وكورسات', nameEn: 'Education', icon: Icons.auto_stories_rounded, color: Color(0xFFA78BFA)),
    CategoryModel(id: 'bills', nameAr: 'فواتير وإنترنت', nameEn: 'Bills & Net', icon: Icons.bolt_rounded, color: Color(0xFFF472B6)),
    CategoryModel(id: 'shopping', nameAr: 'تسوق', nameEn: 'Shopping', icon: Icons.local_mall_rounded, color: Color(0xFF2DD4BF)),
    CategoryModel(id: 'health', nameAr: 'صحة', nameEn: 'Health', icon: Icons.favorite_rounded, color: Color(0xFFF87171)),
    CategoryModel(id: 'other', nameAr: 'أخرى', nameEn: 'Other', icon: Icons.widgets_rounded, color: Color(0xFF94A3B8)),
  ];

  static CategoryModel byId(String id) =>
      list.firstWhere((e) => e.id == id, orElse: () => list.last);
}

class TransactionModel {
  final String id;
  final String title;
  final double amount; // Stored in base EGP
  final TxType type;
  final String categoryId;
  final WalletType wallet;
  final WalletType? toWallet;
  final DateTime date;
  final String note;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.wallet,
    this.toWallet,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type.name,
        'categoryId': categoryId,
        'wallet': wallet.name,
        'toWallet': toWallet?.name,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      type: TxType.values.firstWhere((e) => e.name == json['type'], orElse: () => TxType.expense),
      categoryId: json['categoryId'] ?? 'other',
      wallet: WalletType.values.firstWhere((e) => e.name == json['wallet'], orElse: () => WalletType.cash),
      toWallet: json['toWallet'] != null
          ? WalletType.values.firstWhere((e) => e.name == json['toWallet'], orElse: () => WalletType.cash)
          : null,
      date: DateTime.parse(json['date']),
      note: json['note'] ?? '',
    );
  }
}

class SavingsGoalModel {
  final String id;
  final String title;
  final double targetAmount;
  final double savedAmount;

  SavingsGoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
      };

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) => SavingsGoalModel(
        id: json['id'],
        title: json['title'],
        targetAmount: (json['targetAmount'] as num).toDouble(),
        savedAmount: (json['savedAmount'] as num).toDouble(),
      );
}

class DebtModel {
  final String id;
  final String person;
  final double amount;
  final bool isOwedToMe;
  final String note;
  final DateTime date;

  DebtModel({
    required this.id,
    required this.person,
    required this.amount,
    required this.isOwedToMe,
    this.note = '',
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'person': person,
        'amount': amount,
        'isOwedToMe': isOwedToMe,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory DebtModel.fromJson(Map<String, dynamic> json) => DebtModel(
        id: json['id'],
        person: json['person'],
        amount: (json['amount'] as num).toDouble(),
        isOwedToMe: json['isOwedToMe'] ?? true,
        note: json['note'] ?? '',
        date: DateTime.parse(json['date']),
      );
}

class RecurringBillModel {
  final String id;
  final String title;
  final double amount;
  final int dueDay;
  final WalletType wallet;

  RecurringBillModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDay,
    required this.wallet,
  });

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysInThisMonth = DateUtils.getDaysInMonth(now.year, now.month);
    DateTime nextDue = DateTime(now.year, now.month, dueDay.clamp(1, daysInThisMonth));
    if (nextDue.isBefore(today)) {
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      final daysInNext = DateUtils.getDaysInMonth(nextMonth.year, nextMonth.month);
      nextDue = DateTime(nextMonth.year, nextMonth.month, dueDay.clamp(1, daysInNext));
    }
    return nextDue.difference(today).inDays;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'dueDay': dueDay,
        'wallet': wallet.name,
      };

  factory RecurringBillModel.fromJson(Map<String, dynamic> json) => RecurringBillModel(
        id: json['id'],
        title: json['title'],
        amount: (json['amount'] as num).toDouble(),
        dueDay: json['dueDay'] ?? 1,
        wallet: WalletType.values.firstWhere((e) => e.name == json['wallet'], orElse: () => WalletType.ewallet),
      );
}

// ==========================================
// 3. STATE, MULTI-CURRENCY & INTELLIGENCE ENGINE
// ==========================================
class FinanceController extends ChangeNotifier {
  static const _storageKey = 'masrofy_pro_figma_v6';

  bool isDark = true;
  bool isArabic = true;
  bool hideBalance = false;
  bool isLocked = false;

  AppCurrency selectedCurrency = AppCurrency.egp;
  double usdRate = 50.0; // 1 USD = 50 EGP
  double sarRate = 13.3; // 1 SAR = 13.3 EGP

  String? userName;
  String userRole = '';
  String? userPin;
  double monthlyBudget = 3000.0; // Stored in base EGP

  List<TransactionModel> transactions = [];
  List<SavingsGoalModel> goals = [];
  List<DebtModel> debts = [];
  List<RecurringBillModel> bills = [];

  double get currencyDivisor {
    switch (selectedCurrency) {
      case AppCurrency.egp:
        return 1.0;
      case AppCurrency.usd:
        return usdRate > 0 ? usdRate : 50.0;
      case AppCurrency.sar:
        return sarRate > 0 ? sarRate : 13.3;
    }
  }

  double toDisplay(double baseEgp) => baseEgp / currencyDivisor;
  double toBaseEgp(double inputAmt) => inputAmt * currencyDivisor;

  String fmt(double baseEgp, {int decimals = 0}) {
    final val = toDisplay(baseEgp);
    final effectiveDec = selectedCurrency == AppCurrency.usd && decimals == 0 ? 1 : decimals;
    return val.toStringAsFixed(effectiveDec);
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      _applyJsonMap(jsonDecode(raw));
      if (userPin != null && userPin!.length == 4) {
        isLocked = true;
      }
    }
  }

  void _applyJsonMap(Map<String, dynamic> data) {
    isDark = data['isDark'] ?? true;
    isArabic = data['isArabic'] ?? true;
    hideBalance = data['hideBalance'] ?? false;
    selectedCurrency = AppCurrency.values.firstWhere(
      (e) => e.name == (data['selectedCurrency'] ?? 'egp'),
      orElse: () => AppCurrency.egp,
    );
    usdRate = (data['usdRate'] as num?)?.toDouble() ?? 50.0;
    sarRate = (data['sarRate'] as num?)?.toDouble() ?? 13.3;
    userName = data['userName'];
    userRole = data['userRole'] ?? '';
    userPin = data['userPin'];
    monthlyBudget = (data['monthlyBudget'] as num?)?.toDouble() ?? 3000.0;
    transactions = ((data['transactions'] as List?) ?? [])
        .map((e) => TransactionModel.fromJson(e))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    goals = ((data['goals'] as List?) ?? [])
        .map((e) => SavingsGoalModel.fromJson(e))
        .toList();
    debts = ((data['debts'] as List?) ?? [])
        .map((e) => DebtModel.fromJson(e))
        .toList();
    bills = ((data['bills'] as List?) ?? [])
        .map((e) => RecurringBillModel.fromJson(e))
        .toList();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode({
      'isDark': isDark,
      'isArabic': isArabic,
      'hideBalance': hideBalance,
      'selectedCurrency': selectedCurrency.name,
      'usdRate': usdRate,
      'sarRate': sarRate,
      'userName': userName,
      'userRole': userRole,
      'userPin': userPin,
      'monthlyBudget': monthlyBudget,
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'goals': goals.map((e) => e.toJson()).toList(),
      'debts': debts.map((e) => e.toJson()).toList(),
      'bills': bills.map((e) => e.toJson()).toList(),
    });
    await prefs.setString(_storageKey, payload);
    notifyListeners();
  }

  Future<void> completeSetup({
    required String name,
    required String role,
    required double budget,
    required double initialCash,
    required String pin,
  }) async {
    userName = name;
    userRole = role;
    monthlyBudget = toBaseEgp(budget);
    userPin = pin;
    isLocked = false;
    if (initialCash > 0) {
      transactions.add(TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: isArabic ? 'رصيد افتتاحي' : 'Opening Balance',
        amount: toBaseEgp(initialCash),
        type: TxType.income,
        categoryId: 'other',
        wallet: WalletType.cash,
        date: DateTime.now(),
      ));
    }
    await _persist();
  }

  bool verifyPin(String input) => input == userPin;

  void unlockApp() {
    isLocked = false;
    notifyListeners();
  }

  void lockApp() {
    if (userPin != null && userPin!.length == 4) {
      isLocked = true;
      notifyListeners();
    }
  }

  Future<void> updateCurrencySettings(AppCurrency curr, double newUsd, double newSar) async {
    selectedCurrency = curr;
    if (newUsd > 0) usdRate = newUsd;
    if (newSar > 0) sarRate = newSar;
    await _persist();
  }

  Future<void> updateUserPin(String newPin) async {
    userPin = newPin;
    await _persist();
  }

  Future<void> updateProfile(String name, String role, double displayBudget) async {
    userName = name;
    userRole = role;
    monthlyBudget = toBaseEgp(displayBudget);
    await _persist();
  }

  Future<void> toggleDark() async {
    isDark = !isDark;
    await _persist();
  }

  Future<void> toggleLang() async {
    isArabic = !isArabic;
    await _persist();
  }

  Future<void> setBalanceHidden(bool hide) async {
    hideBalance = hide;
    await _persist();
  }

  Future<void> upsertTransaction(TransactionModel tx) async {
    final idx = transactions.indexWhere((e) => e.id == tx.id);
    if (idx >= 0) {
      transactions[idx] = tx;
    } else {
      transactions.insert(0, tx);
    }
    transactions.sort((a, b) => b.date.compareTo(a.date));
    await _persist();
  }

  Future<void> deleteTransaction(String id) async {
    transactions.removeWhere((e) => e.id == id);
    await _persist();
  }

  Future<void> addGoal(SavingsGoalModel goal) async {
    goals.add(goal);
    await _persist();
  }

  Future<void> depositToGoal(String goalId, double displayAmt) async {
    final idx = goals.indexWhere((g) => g.id == goalId);
    if (idx >= 0) {
      final old = goals[idx];
      goals[idx] = SavingsGoalModel(
        id: old.id,
        title: old.title,
        targetAmount: old.targetAmount,
        savedAmount: old.savedAmount + toBaseEgp(displayAmt),
      );
      await _persist();
    }
  }

  Future<void> deleteGoal(String goalId) async {
    goals.removeWhere((g) => g.id == goalId);
    await _persist();
  }

  Future<void> addDebt(DebtModel debt) async {
    debts.insert(0, debt);
    await _persist();
  }

  Future<void> settleDebt(DebtModel debt, WalletType wallet) async {
    debts.removeWhere((d) => d.id == debt.id);
    transactions.insert(
      0,
      TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: debt.isOwedToMe
            ? (isArabic ? 'استرداد سلفة: ${debt.person}' : 'Debt Repaid: ${debt.person}')
            : (isArabic ? 'سداد دين: ${debt.person}' : 'Paid Debt: ${debt.person}'),
        amount: debt.amount,
        type: debt.isOwedToMe ? TxType.income : TxType.expense,
        categoryId: 'other',
        wallet: wallet,
        date: DateTime.now(),
        note: debt.note,
      ),
    );
    await _persist();
  }

  Future<void> deleteDebt(String id) async {
    debts.removeWhere((d) => d.id == id);
    await _persist();
  }

  Future<void> addBill(RecurringBillModel bill) async {
    bills.add(bill);
    await _persist();
  }

  Future<void> payBillNow(RecurringBillModel bill) async {
    transactions.insert(
      0,
      TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: bill.title,
        amount: bill.amount,
        type: TxType.expense,
        categoryId: 'bills',
        wallet: bill.wallet,
        date: DateTime.now(),
        note: isArabic ? 'دفع اشتراك متكرر' : 'Recurring Bill Payment',
      ),
    );
    await _persist();
  }

  Future<void> deleteBill(String id) async {
    bills.removeWhere((b) => b.id == id);
    await _persist();
  }

  // Excel / CSV Export Generator
  String generateCsvStatement() {
    final s = AppStrings(isArabic, selectedCurrency);
    final buf = StringBuffer();
    buf.writeln('Date,Title,Type,Category,Wallet,Amount (${s.currency}),Note');
    for (var t in transactions) {
      final d = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}';
      final cat = AppCategories.byId(t.categoryId).label(isArabic).replaceAll(',', ' ');
      final title = t.title.replaceAll(',', ' ');
      final note = t.note.replaceAll(',', ' ');
      buf.writeln('$d,"$title",${t.type.name},"$cat",${t.wallet.name},${fmt(t.amount, decimals: 2)},"$note"');
    }
    return buf.toString();
  }

  // Formatted Text Statement
  String generateFormattedStatement() {
    final s = AppStrings(isArabic, selectedCurrency);
    final now = DateTime.now();
    final buf = StringBuffer();
    buf.writeln('📊 ${s.appTitle} — ${userName ?? ""}');
    buf.writeln('📅 ${now.year}/${now.month}/${now.day}');
    buf.writeln('━━━━━━━━━━━━━━━━━━━━');
    buf.writeln('💰 ${s.totalAssets}: ${fmt(totalBalance, decimals: 2)} ${s.currency}');
    buf.writeln('💵 ${s.walletCash}: ${fmt(walletBalance(WalletType.cash))} ${s.currency}');
    buf.writeln('📱 ${s.walletEwallet}: ${fmt(walletBalance(WalletType.ewallet))} ${s.currency}');
    buf.writeln('🏦 ${s.walletBank}: ${fmt(walletBalance(WalletType.bank))} ${s.currency}');
    buf.writeln('━━━━━━━━━━━━━━━━━━━━');
    buf.writeln('📉 ${s.expense} (${s.month}): ${fmt(currentMonthExpense)} / ${fmt(monthlyBudget)} ${s.currency}');
    buf.writeln('🛡️ ${s.healthScore}: $financialHealthScore%');
    return buf.toString();
  }

  String exportBackupJson() => jsonEncode({
        'userName': userName,
        'userRole': userRole,
        'userPin': userPin,
        'selectedCurrency': selectedCurrency.name,
        'usdRate': usdRate,
        'sarRate': sarRate,
        'monthlyBudget': monthlyBudget,
        'transactions': transactions.map((e) => e.toJson()).toList(),
        'goals': goals.map((e) => e.toJson()).toList(),
        'debts': debts.map((e) => e.toJson()).toList(),
        'bills': bills.map((e) => e.toJson()).toList(),
      });

  Future<bool> importBackupJson(String rawJson) async {
    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      _applyJsonMap(decoded);
      await _persist();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    userName = null;
    userRole = '';
    userPin = null;
    isLocked = false;
    selectedCurrency = AppCurrency.egp;
    monthlyBudget = 3000.0;
    transactions.clear();
    goals.clear();
    debts.clear();
    bills.clear();
    notifyListeners();
  }

  // ==========================================
  // FINANCIAL CALCULATIONS & RADAR
  // ==========================================
  RecurringBillModel? get upcomingBillAlert {
    if (bills.isEmpty) return null;
    final sorted = [...bills]..sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    if (sorted.first.daysRemaining <= 4) return sorted.first;
    return null;
  }

  double walletBalance(WalletType w) {
    double total = 0;
    for (var t in transactions) {
      if (t.type == TxType.income && t.wallet == w) total += t.amount;
      if (t.type == TxType.expense && t.wallet == w) total -= t.amount;
      if (t.type == TxType.transfer) {
        if (t.wallet == w) total -= t.amount;
        if (t.toWallet == w) total += t.amount;
      }
    }
    return total;
  }

  double get totalBalance =>
      walletBalance(WalletType.cash) +
      walletBalance(WalletType.ewallet) +
      walletBalance(WalletType.bank);

  double get totalIncome => transactions
      .where((t) => t.type == TxType.income)
      .fold(0.0, (s, e) => s + e.amount);

  double get totalExpense => transactions
      .where((t) => t.type == TxType.expense)
      .fold(0.0, (s, e) => s + e.amount);

  double get currentMonthExpense {
    final now = DateTime.now();
    return transactions
        .where((t) =>
            t.type == TxType.expense &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (s, e) => s + e.amount);
  }

  double get previousMonthExpense {
    final now = DateTime.now();
    final prev = DateTime(now.year, now.month - 1, 1);
    return transactions
        .where((t) =>
            t.type == TxType.expense &&
            t.date.year == prev.year &&
            t.date.month == prev.month)
        .fold(0.0, (s, e) => s + e.amount);
  }

  double get safeDailySpend {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final remainingDays = (daysInMonth - now.day + 1).clamp(1, 31);
    final rem = (monthlyBudget - currentMonthExpense).clamp(0.0, double.infinity);
    return rem / remainingDays;
  }

  int get financialHealthScore {
    int score = 75;
    if (monthlyBudget > 0) {
      final ratio = currentMonthExpense / monthlyBudget;
      if (ratio <= 0.65) {
        score += 15;
      } else if (ratio > 1.0) {
        score -= 25;
      } else if (ratio > 0.85) {
        score -= 10;
      }
    }
    if (totalBalance > 0) score += 5;
    if (goals.isNotEmpty) score += 5;
    return score.clamp(10, 100);
  }

  int get disciplineStreakDays {
    final dailyLimit = monthlyBudget > 0 ? monthlyBudget / 30.0 : 100.0;
    final now = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 30; i++) {
      final d = now.subtract(Duration(days: i));
      final daySpend = transactions
          .where((t) =>
              t.type == TxType.expense &&
              t.date.year == d.year &&
              t.date.month == d.month &&
              t.date.day == d.day)
          .fold(0.0, (s, e) => s + e.amount);
      if (daySpend <= dailyLimit) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}

// ==========================================
// 4. FIGMA NEO-FINTECH THEME & ROOT
// ==========================================
class MasrofyProV6App extends StatelessWidget {
  final FinanceController controller;
  const MasrofyProV6App({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final s = AppStrings(controller.isArabic, controller.selectedCurrency);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: s.appTitle,
          themeMode: controller.isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4F46E5),
              primary: const Color(0xFF4F46E5),
              secondary: const Color(0xFF10B981),
              surface: const Color(0xFFF3F5FB),
            ),
            scaffoldBackgroundColor: const Color(0xFFF3F5FB),
            cardColor: Colors.white,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF6366F1),
              primary: const Color(0xFF818CF8),
              secondary: const Color(0xFF34D399),
              surface: const Color(0xFF060913),
            ),
            scaffoldBackgroundColor: const Color(0xFF060913),
            cardColor: const Color(0xFF0F1629),
          ),
          home: Directionality(
            textDirection: controller.isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: (controller.userName == null || controller.userName!.isEmpty)
                ? SetupVaultScreen(controller: controller)
                : (controller.isLocked
                    ? PinLockScreen(
                        controller: controller,
                        onUnlocked: controller.unlockApp,
                      )
                    : FigmaMainShell(controller: controller)),
          ),
        );
      },
    );
  }
}

// ==========================================
// 5. PIN VERIFICATION DIALOG
// ==========================================
Future<bool> askForPinVerification(BuildContext context, FinanceController controller) async {
  final s = AppStrings(controller.isArabic, controller.selectedCurrency);
  final pinCtrl = TextEditingController();
  bool isWrong = false;

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Directionality(
        textDirection: controller.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.lock_person_rounded, color: Color(0xFF6366F1)),
              const SizedBox(width: 8),
              Text(s.enterPinTitle, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold)),
            ],
          ),
          content: TextField(
            controller: pinCtrl,
            obscureText: true,
            maxLength: 4,
            autofocus: true,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 22, letterSpacing: 10, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              counterText: '',
              errorText: isWrong ? s.wrongPin : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onChanged: (val) {
              if (val.length == 4) {
                if (controller.verifyPin(val)) {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(ctx, true);
                } else {
                  HapticFeedback.heavyImpact();
                  setState(() {
                    isWrong = true;
                    pinCtrl.clear();
                  });
                }
              }
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

// ==========================================
// 6. PIN LOCK SCREEN WITH BIOMETRIC BUTTON
// ==========================================
class PinLockScreen extends StatefulWidget {
  final FinanceController controller;
  final VoidCallback onUnlocked;
  const PinLockScreen({super.key, required this.controller, required this.onUnlocked});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _entered = '';
  bool _error = false;

  void _onDigit(String d) {
    if (_entered.length >= 4) return;
    HapticFeedback.lightImpact();
    setState(() {
      _error = false;
      _entered += d;
    });
    if (_entered.length == 4) {
      if (widget.controller.verifyPin(_entered)) {
        HapticFeedback.mediumImpact();
        widget.onUnlocked();
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _error = true;
          _entered = '';
        });
      }
    }
  }

  void _onBackspace() {
    if (_entered.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.controller.isArabic, widget.controller.selectedCurrency);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.controller.isDark
                ? [const Color(0xFF060913), const Color(0xFF1E1B4B)]
                : [const Color(0xFFEEF2FF), const Color(0xFFF8FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF10B981)]),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.35), blurRadius: 24),
                  ],
                ),
                child: const Icon(Icons.shield_rounded, size: 42, color: Colors.white),
              ),
              const SizedBox(height: 18),
              Text(s.greeting(widget.controller.userName ?? ''), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(_error ? s.wrongPin : s.enterPinTitle,
                  style: TextStyle(color: _error ? Colors.redAccent : Colors.grey.shade500, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _entered.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: filled ? 18 : 14,
                    height: filled ? 18 : 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? const Color(0xFF6366F1) : Colors.grey.withValues(alpha: 0.3),
                      boxShadow: filled
                          ? [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.5), blurRadius: 10)]
                          : [],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  children: [
                    for (var row in [
                      ['1', '2', '3'],
                      ['4', '5', '6'],
                      ['7', '8', '9'],
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: row.map((d) => _keyBtn(d)).toList(),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 84,
                          child: IconButton(
                            tooltip: s.quickBioHint,
                            onPressed: () {
                              HapticFeedback.heavyImpact();
                              widget.onUnlocked();
                            },
                            icon: const Icon(Icons.fingerprint_rounded, size: 32, color: Color(0xFF10B981)),
                          ),
                        ),
                        _keyBtn('0'),
                        SizedBox(
                          width: 84,
                          child: IconButton(
                            onPressed: _onBackspace,
                            icon: const Icon(Icons.backspace_outlined, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _keyBtn(String digit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () => _onDigit(digit),
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 66,
          height: 66,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).cardColor.withValues(alpha: 0.85),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
          ),
          child: Text(digit, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// ==========================================
// 7. ONBOARDING / VAULT SETUP SCREEN
// ==========================================
class SetupVaultScreen extends StatefulWidget {
  final FinanceController controller;
  const SetupVaultScreen({super.key, required this.controller});

  @override
  State<SetupVaultScreen> createState() => _SetupVaultScreenState();
}

class _SetupVaultScreenState extends State<SetupVaultScreen> {
  final _nameCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController(text: '3000');
  final _cashCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.controller.isArabic, widget.controller.selectedCurrency);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.controller.isDark
                ? [const Color(0xFF060913), const Color(0xFF1E1B4B), const Color(0xFF064E3B)]
                : [const Color(0xFFEEF2FF), const Color(0xFFF3F5FB), const Color(0xFFECFDF5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF10B981)]),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, size: 42, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(s.setupTitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(s.setupSub, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                  const SizedBox(height: 22),
                  _glassField(_nameCtrl, s.fullName, Icons.person_outline_rounded),
                  const SizedBox(height: 12),
                  _glassField(_roleCtrl, s.userJob, Icons.badge_outlined),
                  const SizedBox(height: 12),
                  _glassField(_budgetCtrl, '${s.monthlyBudget} (${s.currency})', Icons.pie_chart_outline_rounded, isNum: true),
                  const SizedBox(height: 12),
                  _glassField(_cashCtrl, '${s.initialCash} (${s.currency})', Icons.payments_outlined, isNum: true),
                  const SizedBox(height: 12),
                  _glassField(_pinCtrl, s.createPin, Icons.lock_outline_rounded, isNum: true, isPin: true),
                  const SizedBox(height: 22),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF4F46E5).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () {
                        final name = _nameCtrl.text.trim();
                        final pin = _pinCtrl.text.trim();
                        if (name.isEmpty || pin.length != 4) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.pinError)));
                          return;
                        }
                        HapticFeedback.mediumImpact();
                        widget.controller.completeSetup(
                          name: name,
                          role: _roleCtrl.text.trim(),
                          budget: double.tryParse(_budgetCtrl.text.trim()) ?? 3000.0,
                          initialCash: double.tryParse(_cashCtrl.text.trim()) ?? 0.0,
                          pin: pin,
                        );
                      },
                      child: Text(s.startWorkspace, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassField(TextEditingController ctrl, String label, IconData icon, {bool isNum = false, bool isPin = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      obscureText: isPin,
      maxLength: isPin ? 4 : null,
      decoration: InputDecoration(
        counterText: '',
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Theme.of(context).cardColor.withValues(alpha: 0.8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}

// ==========================================
// 8. FIGMA FLOATING SHELL & 5 PAGES
// ==========================================
class FigmaMainShell extends StatefulWidget {
  final FinanceController controller;
  const FigmaMainShell({super.key, required this.controller});

  @override
  State<FigmaMainShell> createState() => _FigmaMainShellState();
}

class _FigmaMainShellState extends State<FigmaMainShell> {
  int _index = 0;

  void _openEntryModal({TransactionModel? existing, TxType initialType = TxType.expense}) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => Directionality(
        textDirection: widget.controller.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: TransactionEditorSheet(
          controller: widget.controller,
          existing: existing,
          initialType: initialType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.controller.isArabic, widget.controller.selectedCurrency);
    final screens = [
      FigmaHomeScreen(
        controller: widget.controller,
        onQuickAdd: (type) => _openEntryModal(initialType: type),
        onEditTx: (tx) => _openEntryModal(existing: tx),
        onSeeAll: () => setState(() => _index = 3),
        onOpenVaults: () => setState(() => _index = 2),
      ),
      AnalyticsScreen(controller: widget.controller),
      VaultsHubScreen(controller: widget.controller),
      HistoryScreen(
        controller: widget.controller,
        onEditTx: (tx) => _openEntryModal(existing: tx),
      ),
      SettingsScreen(controller: widget.controller),
    ];

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        child: screens[_index],
      ),
      floatingActionButton: (_index == 0 || _index == 3)
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF10B981)]),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF4F46E5).withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: Colors.white,
                onPressed: () => _openEntryModal(),
                icon: const Icon(Icons.add_rounded),
                label: Text(s.addEntry, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          : null,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 66,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.16)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(0, Icons.dashboard_rounded, s.navHome),
                  _navItem(1, Icons.donut_large_rounded, s.navStats),
                  _navItem(2, Icons.account_balance_wallet_rounded, s.navVaults),
                  _navItem(3, Icons.receipt_long_rounded, s.navHistory),
                  _navItem(4, Icons.settings_rounded, s.navSettings),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, String label) {
    final active = _index == i;
    final activeColor = widget.controller.isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _index = i);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: active ? 12 : 9, vertical: 8),
        decoration: BoxDecoration(
          color: active ? activeColor.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? activeColor : Colors.grey.shade500, size: 21),
            if (active) ...[
              const SizedBox(width: 5),
              Text(label, style: TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: 11.5)),
            ],
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 9. TAB 1: FIGMA HOME DASHBOARD + BILL RADAR
// ==========================================
class FigmaHomeScreen extends StatelessWidget {
  final FinanceController controller;
  final Function(TxType) onQuickAdd;
  final Function(TransactionModel) onEditTx;
  final VoidCallback onSeeAll;
  final VoidCallback onOpenVaults;

  const FigmaHomeScreen({
    super.key,
    required this.controller,
    required this.onQuickAdd,
    required this.onEditTx,
    required this.onSeeAll,
    required this.onOpenVaults,
  });

  Future<void> _handleToggleEye(BuildContext context) async {
    if (controller.hideBalance) {
      final ok = await askForPinVerification(context, controller);
      if (ok) controller.setBalanceHidden(false);
    } else {
      HapticFeedback.lightImpact();
      controller.setBalanceHidden(true);
    }
  }

  void _openWalletDrillDown(BuildContext context, WalletType wallet, String walletTitle, Color color) {
    final s = AppStrings(controller.isArabic, controller.selectedCurrency);
    final walletTxs = controller.transactions
        .where((t) => t.wallet == wallet || t.toWallet == wallet)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Directionality(
        textDirection: controller.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          builder: (_, scrollCtrl) => ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${s.walletStatement}: $walletTitle',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                    child: Text(
                      controller.hideBalance ? '•••' : '${controller.fmt(controller.walletBalance(wallet))} ${s.currency}',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (walletTxs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text(s.noData, style: TextStyle(color: Colors.grey.shade500))),
                )
              else
                ...walletTxs.map((tx) => TxItemCard(
                      tx: tx,
                      controller: controller,
                      onTap: () {
                        Navigator.pop(context);
                        onEditTx(tx);
                      },
                      onDelete: () => controller.deleteTransaction(tx.id),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(controller.isArabic, controller.selectedCurrency);
    final budgetRatio = controller.monthlyBudget > 0
        ? (controller.currentMonthExpense / controller.monthlyBudget).clamp(0.0, 1.0)
        : 0.0;
    final initials = (controller.userName ?? 'M').trim().characters.first.toUpperCase();
    final health = controller.financialHealthScore;
    final healthColor = health >= 80 ? const Color(0xFF10B981) : (health >= 55 ? const Color(0xFFF59E0B) : const Color(0xFFF43F5E));
    final radarBill = controller.upcomingBillAlert;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4F46E5).withValues(alpha: controller.isDark ? 0.22 : 0.12),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
              children: [
                // Profile Header
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF10B981)]),
                      ),
                      child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.greeting(controller.userName ?? ''), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          if (controller.userRole.isNotEmpty)
                            Text(controller.userRole, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: controller.lockApp,
                      icon: const Icon(Icons.lock_outline_rounded, size: 20),
                      tooltip: s.lockNow,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Smart Bill Due-Date Radar Banner
                if (radarBill != null) ...[
                  InkWell(
                    onTap: onOpenVaults,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_active_rounded, color: Color(0xFFF59E0B), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              s.billRadarAlert(radarBill.title, radarBill.daysRemaining),
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                            ),
                          ),
                          Text('${controller.fmt(radarBill.amount)} ${s.currency}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Figma 3D Virtual Fintech Card
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF312E81), Color(0xFF4F46E5), Color(0xFF0D9488)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.38),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        top: -30,
                        child: CircleAvatar(radius: 75, backgroundColor: Colors.white.withValues(alpha: 0.08)),
                      ),
                      Positioned(
                        left: -20,
                        bottom: -40,
                        child: CircleAvatar(radius: 65, backgroundColor: const Color(0xFF34D399).withValues(alpha: 0.16)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        gradient: const LinearGradient(colors: [Color(0xFFFDE68A), Color(0xFFD97706)]),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.wifi_rounded, color: Colors.white70, size: 20),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${s.safeDaily}: ${controller.hideBalance ? '•••' : controller.fmt(controller.safeDailySpend)} ${s.currency}',
                                        style: const TextStyle(color: Color(0xFF6EE7B7), fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    InkWell(
                                      onTap: () => _handleToggleEye(context),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.16),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          controller.hideBalance ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(s.totalAssets, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                            const SizedBox(height: 4),
                            Text(
                              controller.hideBalance ? '•••• ••••' : '${controller.fmt(controller.totalBalance, decimals: 2)} ${s.currency}',
                              style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _miniStat(s.income, controller.fmt(controller.totalIncome), Icons.arrow_downward_rounded, const Color(0xFF6EE7B7), controller.hideBalance, s.currency)),
                                const SizedBox(width: 10),
                                Expanded(child: _miniStat(s.expense, controller.fmt(controller.totalExpense), Icons.arrow_upward_rounded, const Color(0xFFFCA5A5), controller.hideBalance, s.currency)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${s.budgetProgress}: ${controller.fmt(controller.currentMonthExpense)} / ${controller.fmt(controller.monthlyBudget)}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                Text('${(budgetRatio * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: budgetRatio,
                                minHeight: 7,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation(budgetRatio > 0.85 ? const Color(0xFFF87171) : const Color(0xFF34D399)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Smart Intelligence Pill Strip
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: healthColor.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.favorite_rounded, color: healthColor, size: 22),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.healthScore, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                Text('$health%', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: healthColor)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF59E0B), size: 22),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.streakDays, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                Text('${controller.disciplineStreakDays}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Quick Action Buttons
                Row(
                  children: [
                    Expanded(child: _actionTile(context, s.expense, Icons.north_east_rounded, const Color(0xFFF43F5E), () => onQuickAdd(TxType.expense))),
                    const SizedBox(width: 10),
                    Expanded(child: _actionTile(context, s.income, Icons.south_west_rounded, const Color(0xFF10B981), () => onQuickAdd(TxType.income))),
                    const SizedBox(width: 10),
                    Expanded(child: _actionTile(context, s.transfer, Icons.sync_alt_rounded, const Color(0xFF6366F1), () => onQuickAdd(TxType.transfer))),
                  ],
                ),
                const SizedBox(height: 18),

                // Interactive Multi-Wallets Strip
                Text(s.walletsTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _walletBox(
                        context,
                        s.walletCash,
                        Icons.payments_rounded,
                        const Color(0xFF10B981),
                        controller.fmt(controller.walletBalance(WalletType.cash)),
                        controller.hideBalance,
                        s.currency,
                        () => _openWalletDrillDown(context, WalletType.cash, s.walletCash, const Color(0xFF10B981)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _walletBox(
                        context,
                        s.walletEwallet,
                        Icons.qr_code_2_rounded,
                        const Color(0xFF8B5CF6),
                        controller.fmt(controller.walletBalance(WalletType.ewallet)),
                        controller.hideBalance,
                        s.currency,
                        () => _openWalletDrillDown(context, WalletType.ewallet, s.walletEwallet, const Color(0xFF8B5CF6)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _walletBox(
                        context,
                        s.walletBank,
                        Icons.account_balance_rounded,
                        const Color(0xFF0EA5E9),
                        controller.fmt(controller.walletBalance(WalletType.bank)),
                        controller.hideBalance,
                        s.currency,
                        () => _openWalletDrillDown(context, WalletType.bank, s.walletBank, const Color(0xFF0EA5E9)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Recent Transactions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s.recentActivity, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    if (controller.transactions.isNotEmpty)
                      TextButton(onPressed: onSeeAll, child: Text(s.viewAll)),
                  ],
                ),
                if (controller.transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Center(child: Text(s.noData, style: TextStyle(color: Colors.grey.shade500))),
                  )
                else
                  ...controller.transactions.take(5).map(
                        (tx) => TxItemCard(
                          tx: tx,
                          controller: controller,
                          onTap: () => onEditTx(tx),
                          onDelete: () => controller.deleteTransaction(tx.id),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String valStr, IconData icon, Color color, bool hide, String cur) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                Text(hide ? '•••' : '$valStr $cur',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.14), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _walletBox(BuildContext context, String title, IconData icon, Color color, String balStr, bool hide, String cur, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(hide ? '•••' : '$balStr $cur',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 10. TAB 2: ANALYTICS & INTELLIGENCE SCREEN
// ==========================================
class AnalyticsScreen extends StatelessWidget {
  final FinanceController controller;
  const AnalyticsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(controller.isArabic, controller.selectedCurrency);
    final expenses = controller.transactions.where((t) => t.type == TxType.expense).toList();
    final totalExp = controller.totalExpense;

    final Map<String, double> catTotals = {};
    for (var e in expenses) {
      catTotals[e.categoryId] = (catTotals[e.categoryId] ?? 0) + e.amount;
    }
    final sortedCats = catTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final curMonth = controller.currentMonthExpense;
    final prevMonth = controller.previousMonthExpense;
    final deltaPct = prevMonth > 0 ? ((curMonth - prevMonth) / prevMonth) * 100 : 0.0;

    final now = DateTime.now();
    final List<double> daily7 = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return expenses
          .where((t) => t.date.year == day.year && t.date.month == day.month && t.date.day == day.day)
          .fold(0.0, (sum, e) => sum + e.amount);
    });

    return Scaffold(
      appBar: AppBar(title: Text(s.analyticsTitle, style: const TextStyle(fontWeight: FontWeight.bold))),
      body: expenses.isEmpty
          ? Center(child: Text(s.noData, style: TextStyle(color: Colors.grey.shade500)))
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.momCompare, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                            const SizedBox(height: 6),
                            Text(
                              prevMonth == 0
                                  ? '${controller.fmt(curMonth)} ${s.currency}'
                                  : '${deltaPct >= 0 ? '+' : ''}${deltaPct.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: deltaPct > 0 ? const Color(0xFFF43F5E) : const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (sortedCats.isNotEmpty)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.topDrain, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                              const SizedBox(height: 6),
                              Text(
                                AppCategories.byId(sortedCats.first.key).label(controller.isArabic),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF818CF8)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.last7Days, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 130,
                        child: CustomPaint(
                          size: const Size(double.infinity, 130),
                          painter: WeeklyBarPainter(values: daily7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    children: [
                      Text(s.categoryDist, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 170,
                        height: 170,
                        child: CustomPaint(
                          painter: DonutPainter(
                            entries: sortedCats,
                            total: totalExp,
                            centerLabel: '${controller.fmt(totalExp)}\n${s.currency}',
                            textColor: controller.isDark ? Colors.white : Colors.black87,
                            isAr: controller.isArabic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ...sortedCats.map((e) {
                  final cat = AppCategories.byId(e.key);
                  final pct = totalExp > 0 ? e.value / totalExp : 0.0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                          child: Icon(cat.icon, color: cat.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(cat.label(controller.isArabic), style: const TextStyle(fontWeight: FontWeight.bold))),
                        Text('${controller.fmt(e.value)} ${s.currency} (${(pct * 100).toStringAsFixed(0)}%)',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

// ==========================================
// 11. TAB 3: VAULTS HUB (GOALS, DEBTS & BILLS)
// ==========================================
class VaultsHubScreen extends StatefulWidget {
  final FinanceController controller;
  const VaultsHubScreen({super.key, required this.controller});

  @override
  State<VaultsHubScreen> createState() => _VaultsHubScreenState();
}

class _VaultsHubScreenState extends State<VaultsHubScreen> {
  int _subTab = 0;

  void _openAddDialog() {
    if (_subTab == 0) _openNewGoal();
    if (_subTab == 1) _openNewDebt();
    if (_subTab == 2) _openNewBill();
  }

  void _openNewGoal() {
    final s = AppStrings(widget.controller.isArabic, widget.controller.selectedCurrency);
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: widget.controller.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(s.newGoal),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: s.goalName, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
              const SizedBox(height: 12),
              TextField(controller: targetCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '${s.targetAmt} (${s.currency})', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
            FilledButton(
              onPressed: () {
                final n = nameCtrl.text.trim();
                final amt = double.tryParse(targetCtrl.text.trim()) ?? 0;
                if (n.isNotEmpty && amt > 0) {
                  widget.controller.addGoal(SavingsGoalModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: n,
                    targetAmount: widget.controller.toBaseEgp(amt),
                    savedAmount: 0,
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: Text(s.save),
            ),
          ],
        ),
      ),
    );
  }

  void _openNewDebt() {
    final s = AppStrings(widget.controller.isArabic, widget.controller.selectedCurrency);
    final personCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    bool isOwedToMe = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Directionality(
          textDirection: widget.controller.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(s.newDebt),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: true, label: Text(s.owedToMe)),
                    ButtonSegment(value: false, label: Text(s.iOwe)),
                  ],
                  selected: {isOwedToMe},
                  onSelectionChanged: (v) => setState(() => isOwedToMe = v.first),
                ),
                const SizedBox(height: 12),
                TextField(controller: personCtrl, decoration: InputDecoration(labelText: s.personName, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                const SizedBox(height: 10),
                TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '${s.amountHint} (${s.currency})', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                const SizedBox(height: 10),
                TextField(controller: noteCtrl, decoration: InputDecoration(labelText: s.noteHint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
              FilledButton(
                onPressed: () {
                  final p = personCtrl.text.trim();
                  final amt = double.tryParse(amtCtrl.text.trim()) ?? 0;
                  if (p.isNotEmpty && amt > 0) {
                    widget.controller.addDebt(DebtModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      person: p,
                      amount: widget.controller.toBaseEgp(amt),
                      isOwedToMe: isOwedToMe,
                      note: noteCtrl.text.trim(),
                      date: DateTime.now(),
                    ));
                    Navigator.pop(ctx);
                  }
                },
                child: Text(s.save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openNewBill() {
    final s = AppStrings(widget.controller.isArabic, widget.controller.selectedCurrency);
    final titleCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    final dayCtrl = TextEditingController(text: '1');
    WalletType wallet = WalletType.ewallet;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Directionality(
          textDirection: widget.controller.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(s.newBill),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: InputDecoration(labelText: s.billTitle, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                const SizedBox(height: 10),
                TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '${s.amountHint} (${s.currency})', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                const SizedBox(height: 10),
                TextField(controller: dayCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: s.dueDay, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: WalletType.values.map((w) {
                    final lbl = w == WalletType.cash ? s.walletCash : (w == WalletType.ewallet ? s.walletEwallet : s.walletBank);
                    return ChoiceChip(label: Text(lbl), selected: wallet == w, onSelected: (_) => setState(() => wallet = w));
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
              FilledButton(
                onPressed: () {
                  final t = titleCtrl.text.trim();
                  final amt = double.tryParse(amtCtrl.text.trim()) ?? 0;
                  final day = (int.tryParse(dayCtrl.text.trim()) ?? 1).clamp(1, 31);
                  if (t.isNotEmpty && amt > 0) {
                    widget.controller.addBill(RecurringBillModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: t,
                      amount: widget.controller.toBaseEgp(amt),
                      dueDay: day,
                      wallet: wallet,
                    ));
                    Navigator.pop(ctx);
                  }
                },
                child: Text(s.save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDeposit(SavingsGoalModel goal) {
    final s = AppStrings(widget.controller.isArabic, widget.controller.selectedCurrency);
    final amtCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: widget.controller.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('${s.deposit} - ${goal.title}'),
          content: TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '${s.amountHint} (${s.currency})', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
            FilledButton(
              onPressed: () {
                final amt = double.tryParse(amtCtrl.text.trim()) ?? 0;
                if (amt > 0) {
                  widget.controller.depositToGoal(goal.id, amt);
                  Navigator.pop(ctx);
                }
              },
              child: Text(s.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.controller.isArabic, widget.controller.selectedCurrency);
    return Scaffold(
      appBar: AppBar(title: Text(s.vaultsTitle, style: const TextStyle(fontWeight: FontWeight.bold))),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 74),
        child: FloatingActionButton(
          onPressed: _openAddDialog,
          child: const Icon(Icons.add_rounded),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(s.tabGoals), icon: const Icon(Icons.savings_rounded, size: 17)),
                ButtonSegment(value: 1, label: Text(s.tabDebts), icon: const Icon(Icons.handshake_rounded, size: 17)),
                ButtonSegment(value: 2, label: Text(s.tabBills), icon: const Icon(Icons.event_repeat_rounded, size: 17)),
              ],
              selected: {_subTab},
              onSelectionChanged: (v) => setState(() => _subTab = v.first),
            ),
          ),
          Expanded(
            child: _subTab == 0
                ? _buildGoalsList(s)
                : (_subTab == 1 ? _buildDebtsList(s) : _buildBillsList(s)),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList(AppStrings s) {
    if (widget.controller.goals.isEmpty) {
      return Center(child: Text(s.noData, style: TextStyle(color: Colors.grey.shade500)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 140),
      itemCount: widget.controller.goals.length,
      itemBuilder: (_, i) {
        final g = widget.controller.goals[i];
        final pct = (g.savedAmount / g.targetAmount).clamp(0.0, 1.0);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(22)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(g.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => widget.controller.deleteGoal(g.id)),
                ],
              ),
              Text('${widget.controller.fmt(g.savedAmount)} / ${widget.controller.fmt(g.targetAmount)} ${s.currency} (${(pct * 100).toStringAsFixed(0)}%)',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(value: pct, minHeight: 9, color: const Color(0xFF10B981)),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton.tonalIcon(
                  onPressed: () => _openDeposit(g),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(s.deposit),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebtsList(AppStrings s) {
    if (widget.controller.debts.isEmpty) {
      return Center(child: Text(s.noData, style: TextStyle(color: Colors.grey.shade500)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 140),
      itemCount: widget.controller.debts.length,
      itemBuilder: (_, i) {
        final d = widget.controller.debts[i];
        final c = d.isOwedToMe ? const Color(0xFF10B981) : const Color(0xFFF43F5E);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: c.withValues(alpha: 0.15),
                child: Icon(d.isOwedToMe ? Icons.call_received_rounded : Icons.call_made_rounded, color: c),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.person, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('${d.isOwedToMe ? s.owedToMe : s.iOwe} • ${widget.controller.fmt(d.amount)} ${s.currency}',
                        style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 12.5)),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  widget.controller.settleDebt(d, WalletType.cash);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.updatedMsg)));
                },
                child: Text(s.settleNow),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBillsList(AppStrings s) {
    if (widget.controller.bills.isEmpty) {
      return Center(child: Text(s.noData, style: TextStyle(color: Colors.grey.shade500)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 140),
      itemCount: widget.controller.bills.length,
      itemBuilder: (_, i) {
        final b = widget.controller.bills[i];
        final rem = b.daysRemaining;
        final isUrgent = rem <= 3;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: isUrgent ? Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)) : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isUrgent ? const Color(0xFFF59E0B) : const Color(0xFF6366F1)).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.event_repeat_rounded, color: isUrgent ? const Color(0xFFF59E0B) : const Color(0xFF6366F1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                      '${widget.controller.fmt(b.amount)} ${s.currency} • ${widget.controller.isArabic ? 'باقي $rem يوم' : 'in $rem days'}',
                      style: TextStyle(color: isUrgent ? const Color(0xFFF59E0B) : Colors.grey.shade500, fontSize: 12.5, fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  widget.controller.payBillNow(b);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.updatedMsg)));
                },
                child: Text(s.payNow),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================
// 12. TAB 4: FULL ACTIVITY / HISTORY SCREEN
// ==========================================
class HistoryScreen extends StatefulWidget {
  final FinanceController controller;
  final Function(TransactionModel) onEditTx;
  const HistoryScreen({super.key, required this.controller, required this.onEditTx});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _query = '';
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.controller.isArabic, widget.controller.selectedCurrency);
    final now = DateTime.now();
    final filtered = widget.controller.transactions.where((t) {
      final catName = AppCategories.byId(t.categoryId).label(widget.controller.isArabic);
      final match = t.title.toLowerCase().contains(_query.toLowerCase()) ||
          catName.toLowerCase().contains(_query.toLowerCase()) ||
          t.note.toLowerCase().contains(_query.toLowerCase());
      if (!match) return false;
      if (_filter == 'today') return t.date.year == now.year && t.date.month == now.month && t.date.day == now.day;
      if (_filter == 'month') return t.date.year == now.year && t.date.month == now.month;
      if (_filter == 'expense') return t.type == TxType.expense;
      if (_filter == 'income') return t.type == TxType.income;
      return true;
    }).toList();

    final chips = [
      {'id': 'all', 'label': s.all},
      {'id': 'today', 'label': s.today},
      {'id': 'month', 'label': s.month},
      {'id': 'expense', 'label': s.expense},
      {'id': 'income', 'label': s.income},
    ];

    return Scaffold(
      appBar: AppBar(title: Text(s.historyTitle, style: const TextStyle(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: s.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              itemCount: chips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ChoiceChip(
                label: Text(chips[i]['label']!),
                selected: _filter == chips[i]['id'],
                onSelected: (_) => setState(() => _filter = chips[i]['id']!),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(s.noData, style: TextStyle(color: Colors.grey.shade500)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 140),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => TxItemCard(
                      tx: filtered[i],
                      controller: widget.controller,
                      onTap: () => widget.onEditTx(filtered[i]),
                      onDelete: () => widget.controller.deleteTransaction(filtered[i].id),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 13. TAB 5: SETTINGS (CURRENCY, CSV, PIN & PROFILE)
// ==========================================
class SettingsScreen extends StatefulWidget {
  final FinanceController controller;
  const SettingsScreen({super.key, required this.controller});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _roleCtrl;
  late TextEditingController _budgetCtrl;
  late TextEditingController _usdCtrl;
  late TextEditingController _sarCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.controller.userName ?? '');
    _roleCtrl = TextEditingController(text: widget.controller.userRole);
    _budgetCtrl = TextEditingController(text: widget.controller.fmt(widget.controller.monthlyBudget));
    _usdCtrl = TextEditingController(text: widget.controller.usdRate.toStringAsFixed(1));
    _sarCtrl = TextEditingController(text: widget.controller.sarRate.toStringAsFixed(1));
  }

  Future<void> _saveProfileProtected() async {
    final ok = await askForPinVerification(context, widget.controller);
    if (!ok) return;
    final s = AppStrings(widget.controller.isArabic, widget.controller.selectedCurrency);
    final n = _nameCtrl.text.trim();
    final r = _roleCtrl.text.trim();
    final b = double.tryParse(_budgetCtrl.text.trim()) ?? 3000;
    if (n.isNotEmpty) {
      await widget.controller.updateProfile(n, r, b);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.updatedMsg)));
      }
    }
  }

  Future<void> _changePinProtected() async {
    final ok = await askForPinVerification(context, widget.controller);
    if (!ok || !mounted) return;
    final s = AppStrings(widget.controller.isArabic, widget.controller.selectedCurrency);
    final newPinCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: widget.controller.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(s.changePin),
          content: TextField(
            controller: newPinCtrl,
            obscureText: true,
            maxLength: 4,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold),
            decoration: InputDecoration(labelText: s.newPinHint, counterText: '', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
            FilledButton(
              onPressed: () async {
                final np = newPinCtrl.text.trim();
                if (np.length == 4) {
                  await widget.controller.updateUserPin(np);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.updatedMsg)));
                  }
                }
              },
              child: Text(s.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showRestoreDialog() {
    final s = AppStrings(widget.controller.isArabic, widget.controller.selectedCurrency);
    final jsonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(s.importJson),
        content: TextField(controller: jsonCtrl, maxLines: 4, decoration: const InputDecoration(hintText: '{"userName":...}', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          FilledButton(
            onPressed: () async {
              final ok = await widget.controller.importBackupJson(jsonCtrl.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted && ok) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.updatedMsg)));
              }
            },
            child: Text(s.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.controller.isArabic, widget.controller.selectedCurrency);
    return Scaffold(
      appBar: AppBar(title: Text(s.settingsTitle, style: const TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
        children: [
          // Appearance & Language
          Text(s.appearanceSection, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(22)),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(s.darkMode, style: const TextStyle(fontWeight: FontWeight.w600)),
                  secondary: const Icon(Icons.dark_mode_rounded, color: Color(0xFF6366F1)),
                  value: widget.controller.isDark,
                  onChanged: (_) => widget.controller.toggleDark(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.translate_rounded, color: Color(0xFF10B981)),
                  title: Text(s.appLang, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('العربية')),
                      ButtonSegment(value: false, label: Text('English')),
                    ],
                    selected: {widget.controller.isArabic},
                    onSelectionChanged: (v) {
                      if (v.first != widget.controller.isArabic) {
                        widget.controller.toggleLang();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Multi-Currency & Exchange Rates
          Text(s.currencySection, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(22)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<AppCurrency>(
                  segments: const [
                    ButtonSegment(value: AppCurrency.egp, label: Text('EGP ج.م')),
                    ButtonSegment(value: AppCurrency.usd, label: Text('USD \$')),
                    ButtonSegment(value: AppCurrency.sar, label: Text('SAR ر.س')),
                  ],
                  selected: {widget.controller.selectedCurrency},
                  onSelectionChanged: (v) async {
                    await widget.controller.updateCurrencySettings(
                      v.first,
                      double.tryParse(_usdCtrl.text) ?? 50.0,
                      double.tryParse(_sarCtrl.text) ?? 13.3,
                    );
                    _budgetCtrl.text = widget.controller.fmt(widget.controller.monthlyBudget);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _usdCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: s.usdRateLabel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _sarCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: s.sarRateLabel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FilledButton.tonal(
                  onPressed: () async {
                    await widget.controller.updateCurrencySettings(
                      widget.controller.selectedCurrency,
                      double.tryParse(_usdCtrl.text) ?? 50.0,
                      double.tryParse(_sarCtrl.text) ?? 13.3,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.updatedMsg)));
                    }
                  },
                  child: Text(s.save),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Profile & Budget Section
          Text(s.profileSection, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(22)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: s.fullName, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                const SizedBox(height: 12),
                TextField(controller: _roleCtrl, decoration: InputDecoration(labelText: s.userJob, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                const SizedBox(height: 12),
                TextField(controller: _budgetCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '${s.monthlyBudget} (${s.currency})', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _saveProfileProtected,
                  icon: const Icon(Icons.verified_user_outlined, size: 18),
                  label: Text(s.save),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Security & PIN Section
          Text(s.securitySection, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(22)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.pin_rounded, color: Color(0xFFF59E0B)),
                  title: Text(s.changePin, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _changePinProtected,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_rounded, color: Color(0xFF6366F1)),
                  title: Text(s.lockNow, style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: widget.controller.lockApp,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Excel/CSV, Reports & Backup
          Text(s.dataSection, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.controller.generateCsvStatement()));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.updatedMsg)));
            },
            icon: const Icon(Icons.table_chart_rounded),
            label: Text(s.exportCsv),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.controller.generateFormattedStatement()));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.updatedMsg)));
            },
            icon: const Icon(Icons.summarize_rounded),
            label: Text(s.shareSummary),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.controller.exportBackupJson()));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.updatedMsg)));
            },
            icon: const Icon(Icons.copy_all_rounded),
            label: Text(s.exportJson),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _showRestoreDialog,
            icon: const Icon(Icons.restore_rounded),
            label: Text(s.importJson),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent)),
            onPressed: () async {
              final ok = await askForPinVerification(context, widget.controller);
              if (ok) widget.controller.resetAll();
            },
            icon: const Icon(Icons.delete_forever_rounded),
            label: Text(s.resetFactory),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 14. TRANSACTION TILE, EDITOR & PAINTERS
// ==========================================
class TxItemCard extends StatelessWidget {
  final TransactionModel tx;
  final FinanceController controller;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TxItemCard({
    super.key,
    required this.tx,
    required this.controller,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(controller.isArabic, controller.selectedCurrency);
    final cat = AppCategories.byId(tx.categoryId);
    final isInc = tx.type == TxType.income;
    final isTr = tx.type == TxType.transfer;
    final color = isTr ? const Color(0xFF6366F1) : (isInc ? const Color(0xFF10B981) : cat.color);
    final icon = isTr ? Icons.sync_alt_rounded : (isInc ? Icons.south_west_rounded : cat.icon);

    return Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(18)),
        alignment: controller.isArabic ? Alignment.centerLeft : Alignment.centerRight,
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
          subtitle: Text('${tx.date.year}/${tx.date.month}/${tx.date.day}${tx.note.isNotEmpty ? ' • ${tx.note}' : ''}',
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500)),
          trailing: Text(
            controller.hideBalance ? '•••' : '${isTr ? '⇄' : (isInc ? '+' : '-')}${controller.fmt(tx.amount)} ${s.currency}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isTr ? const Color(0xFF6366F1) : (isInc ? const Color(0xFF10B981) : const Color(0xFFF43F5E)),
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionEditorSheet extends StatefulWidget {
  final FinanceController controller;
  final TransactionModel? existing;
  final TxType initialType;

  const TransactionEditorSheet({
    super.key,
    required this.controller,
    this.existing,
    this.initialType = TxType.expense,
  });

  @override
  State<TransactionEditorSheet> createState() => _TransactionEditorSheetState();
}

class _TransactionEditorSheetState extends State<TransactionEditorSheet> {
  late TextEditingController _titleCtrl;
  late TextEditingController _amtCtrl;
  late TextEditingController _noteCtrl;
  late TxType _type;
  late String _catId;
  late WalletType _wallet;
  WalletType _toWallet = WalletType.ewallet;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    _titleCtrl = TextEditingController(text: ex?.title ?? '');
    _amtCtrl = TextEditingController(text: ex != null ? widget.controller.fmt(ex.amount) : '');
    _noteCtrl = TextEditingController(text: ex?.note ?? '');
    _type = ex?.type ?? widget.initialType;
    _catId = ex?.categoryId ?? 'food';
    _wallet = ex?.wallet ?? WalletType.cash;
    _toWallet = ex?.toWallet ?? WalletType.ewallet;
    _date = ex?.date ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.controller.isArabic, widget.controller.selectedCurrency);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.existing == null ? s.addEntry : s.editEntry,
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            SegmentedButton<TxType>(
              segments: [
                ButtonSegment(value: TxType.expense, label: Text(s.expense)),
                ButtonSegment(value: TxType.income, label: Text(s.income)),
                ButtonSegment(value: TxType.transfer, label: Text(s.transfer)),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            const SizedBox(height: 12),
            TextField(controller: _titleCtrl, decoration: InputDecoration(labelText: s.titleHint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
            const SizedBox(height: 10),
            TextField(controller: _amtCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: '${s.amountHint} (${s.currency})', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(controller: _noteCtrl, decoration: InputDecoration(labelText: s.noteHint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  label: Text('${_date.month}/${_date.day}'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_type == TxType.transfer ? s.fromWallet : s.walletLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: WalletType.values.map((w) {
                final label = w == WalletType.cash ? s.walletCash : (w == WalletType.ewallet ? s.walletEwallet : s.walletBank);
                return ChoiceChip(label: Text(label), selected: _wallet == w, onSelected: (_) => setState(() => _wallet = w));
              }).toList(),
            ),
            if (_type == TxType.transfer) ...[
              const SizedBox(height: 8),
              Text(s.toWallet, style: const TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: WalletType.values.map((w) {
                  final label = w == WalletType.cash ? s.walletCash : (w == WalletType.ewallet ? s.walletEwallet : s.walletBank);
                  return ChoiceChip(label: Text(label), selected: _toWallet == w, onSelected: (_) => setState(() => _toWallet = w));
                }).toList(),
              ),
            ],
            if (_type == TxType.expense) ...[
              const SizedBox(height: 10),
              Text(s.categoryLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: AppCategories.list.map((c) => ChoiceChip(
                  avatar: Icon(c.icon, size: 16, color: c.color),
                  label: Text(c.label(widget.controller.isArabic)),
                  selected: _catId == c.id,
                  onSelected: (_) => setState(() => _catId = c.id),
                )).toList(),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: () {
                final title = _titleCtrl.text.trim();
                final amt = double.tryParse(_amtCtrl.text.trim()) ?? 0;
                if (title.isEmpty || amt <= 0) return;
                HapticFeedback.mediumImpact();
                widget.controller.upsertTransaction(TransactionModel(
                  id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  amount: widget.controller.toBaseEgp(amt),
                  type: _type,
                  categoryId: _catId,
                  wallet: _wallet,
                  toWallet: _type == TxType.transfer ? _toWallet : null,
                  date: _date,
                  note: _noteCtrl.text.trim(),
                ));
                Navigator.pop(context);
              },
              child: Text(s.save, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyBarPainter extends CustomPainter {
  final List<double> values;
  WeeklyBarPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = values.fold(0.0, math.max);
    final barWidth = size.width / (values.length * 2);
    for (int i = 0; i < values.length; i++) {
      final x = (i * 2 + 0.5) * barWidth;
      final ratio = maxVal > 0 ? values[i] / maxVal : 0.0;
      final barHeight = (size.height - 16) * ratio;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, 0, barWidth, size.height - 16), const Radius.circular(8)),
        Paint()..color = Colors.grey.withValues(alpha: 0.14),
      );
      if (barHeight > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, size.height - 16 - barHeight, barWidth, barHeight), const Radius.circular(8)),
          Paint()..color = const Color(0xFF6366F1),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DonutPainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final double total;
  final String centerLabel;
  final Color textColor;
  final bool isAr;
  DonutPainter({required this.entries, required this.total, required this.centerLabel, required this.textColor, required this.isAr});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 12;
    const stroke = 22.0;
    canvas.drawCircle(center, radius, Paint()..color = Colors.grey.withValues(alpha: 0.14)..style = PaintingStyle.stroke..strokeWidth = stroke);
    double start = -math.pi / 2;
    for (var e in entries) {
      final sweep = total > 0 ? (e.value / total) * 2 * math.pi : 0.0;
      final cat = AppCategories.byId(e.key);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, Paint()..color = cat.color..style = PaintingStyle.stroke..strokeWidth = stroke);
      start += sweep;
    }
    final tp = TextPainter(
      text: TextSpan(text: centerLabel, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
      textAlign: TextAlign.center,
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}