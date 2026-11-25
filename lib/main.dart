import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MasrofyProApp());
}

// ==========================================
// 1. LOCALIZATION HELPER (AR / EN)
// ==========================================
class AppStrings {
  final bool isAr;
  const AppStrings(this.isAr);

  String get appTitle => isAr ? 'مصروفي برو' : 'Masrofy Pro';
  String get welcomeTitle => isAr ? 'أهلاً بك في مصروفي' : 'Welcome to Masrofy';
  String get welcomeSub => isAr
      ? 'ابدأ رحلتك في تنظيم مصاريفك وميزانيتك الشهرية بذكاء'
      : 'Start organizing your daily expenses and monthly budget smartly';
  String get enterYourName => isAr ? 'اكتب اسمك' : 'Enter your name';
  String get monthlyBudgetLabel =>
      isAr ? 'الميزانية الشهرية المستهدفة (ج.م)' : 'Target Monthly Budget (EGP)';
  String get startNow => isAr ? 'ابدأ الاستخدام الآن' : 'Get Started';
  String get currency => isAr ? 'ج.م' : 'EGP';

  // Navigation Tabs
  String get navHome => isAr ? 'الرئيسية' : 'Home';
  String get navAnalytics => isAr ? 'الإحصائيات' : 'Analytics';
  String get navHistory => isAr ? 'السجل' : 'History';
  String get navSettings => isAr ? 'الإعدادات' : 'Settings';

  // Home & Balance
  String greeting(String name) => isAr ? 'أهلاً بك، $name 👋' : 'Welcome, $name 👋';
  String get subtitleHome =>
      isAr ? 'ملخص وضعك المالي اليوم' : 'Your financial overview today';
  String get currentBalance => isAr ? 'الرصيد الحالي المتاح' : 'Current Available Balance';
  String get totalIncome => isAr ? 'إجمالي الدخل' : 'Total Income';
  String get totalExpense => isAr ? 'إجمالي المصروفات' : 'Total Expenses';
  String get budgetUsage => isAr ? 'استهلاك ميزانية الشهر' : 'Monthly Budget Usage';
  String get recentTransactions => isAr ? 'أحدث العمليات' : 'Recent Transactions';
  String get seeAll => isAr ? 'عرض الكل' : 'See All';
  String get newTransaction => isAr ? 'عملية جديدة' : 'New Entry';

  // Analytics
  String get analyticsTitle => isAr ? 'التحليل المالي والإحصائيات' : 'Financial Analytics';
  String get expenseByCategory =>
      isAr ? 'توزيع المصروفات حسب الفئة' : 'Expenses by Category';
  String get noAnalyticsData => isAr
      ? 'سجّل بعض المصروفات أولاً لعرض الرسوم البيانية'
      : 'Add some expenses first to view analytics charts';

  // History & Filters
  String get historyTitle => isAr ? 'سجل المعاملات الكامل' : 'Full Transaction History';
  String get searchHint =>
      isAr ? 'ابحث بالاسم أو الفئة...' : 'Search by title or category...';
  String get filterAll => isAr ? 'الكل' : 'All';
  String get filterToday => isAr ? 'اليوم' : 'Today';
  String get filterMonth => isAr ? 'هذا الشهر' : 'This Month';
  String get filterExpense => isAr ? 'مصروفات' : 'Expenses';
  String get filterIncome => isAr ? 'دخل' : 'Income';
  String get noTransactions =>
      isAr ? 'لا توجد عمليات مطابقة حالياً' : 'No matching transactions found';

  // Add Sheet
  String get addEntryTitle => isAr ? 'إضافة عملية مالية جديدة' : 'Add New Transaction';
  String get expenseLabel => isAr ? 'مصروف' : 'Expense';
  String get incomeLabel => isAr ? 'دخل / رصيد' : 'Income';
  String get titleHintExpense => isAr
      ? 'تفاصيل المصروف (مثلاً: غداء، مواصلات)'
      : 'Expense title (e.g., Lunch, Transport)';
  String get titleHintIncome => isAr
      ? 'مصدر الدخل (مثلاً: مصروف الشهر، مكافأة)'
      : 'Income source (e.g., Allowance, Bonus)';
  String get amountLabel => isAr ? 'المبلغ' : 'Amount';
  String get chooseCategory => isAr ? 'اختر الفئة:' : 'Choose Category:';
  String get dateLabel => isAr ? 'التاريخ' : 'Date';
  String get saveBtn => isAr ? 'حفظ العملية' : 'Save Transaction';

  // Settings
  String get settingsTitle => isAr ? 'الإعدادات والحساب' : 'Settings & Profile';
  String get profileSection => isAr ? 'البيانات الشخصية والميزانية' : 'Profile & Budget';
  String get saveChanges => isAr ? 'حفظ التعديلات' : 'Save Changes';
  String get savedSuccess => isAr ? 'تم حفظ التعديلات بنجاح' : 'Changes saved successfully';
  String get appearanceSection => isAr ? 'المظهر واللغة' : 'Appearance & Language';
  String get darkModeTitle => isAr ? 'الوضع الليلي (Dark Mode)' : 'Dark Mode';
  String get languageTitle => isAr ? 'لغة التطبيق' : 'App Language';
  String get languageValue => isAr ? 'العربية' : 'English';
  String get clearDataBtn => isAr ? 'مسح جميع البيانات والبدء من جديد' : 'Reset All Data';
  String get clearConfirmTitle => isAr ? 'تأكيد مسح البيانات' : 'Confirm Reset';
  String get clearConfirmMsg => isAr
      ? 'سيتم حذف جميع المعاملات وإعادة التطبيق لشاشة البداية. هل أنت متأكد؟'
      : 'All transactions will be deleted and the app will reset. Are you sure?';
  String get cancel => isAr ? 'إلغاء' : 'Cancel';
  String get confirm => isAr ? 'تأكيد' : 'Confirm';
  String deletedMsg(String title) => isAr ? 'تم حذف "$title"' : 'Deleted "$title"';
  String get undo => isAr ? 'تراجع' : 'Undo';
}

// ==========================================
// 2. DATA MODELS & CATEGORIES
// ==========================================
enum TransactionType { expense, income }

class CategoryInfo {
  final String id;
  final String nameAr;
  final String nameEn;
  final IconData icon;
  final Color color;

  const CategoryInfo({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.icon,
    required this.color,
  });

  String getName(bool isAr) => isAr ? nameAr : nameEn;
}

class AppCategories {
  static const List<CategoryInfo> expenseCategories = [
    CategoryInfo(
        id: 'food',
        nameAr: 'طعام ومشروبات',
        nameEn: 'Food & Drinks',
        icon: Icons.restaurant_rounded,
        color: Color(0xFFF97316)),
    CategoryInfo(
        id: 'transport',
        nameAr: 'مواصلات',
        nameEn: 'Transport',
        icon: Icons.directions_bus_rounded,
        color: Color(0xFF3B82F6)),
    CategoryInfo(
        id: 'study',
        nameAr: 'دراسة وكتب',
        nameEn: 'Study & Books',
        icon: Icons.menu_book_rounded,
        color: Color(0xFF8B5CF6)),
    CategoryInfo(
        id: 'bills',
        nameAr: 'فواتير وإنترنت',
        nameEn: 'Bills & Internet',
        icon: Icons.wifi_rounded,
        color: Color(0xFFEC4899)),
    CategoryInfo(
        id: 'shopping',
        nameAr: 'تسوق وملابس',
        nameEn: 'Shopping',
        icon: Icons.shopping_bag_rounded,
        color: Color(0xFF14B8A6)),
    CategoryInfo(
        id: 'health',
        nameAr: 'صحة وصيدلية',
        nameEn: 'Health',
        icon: Icons.medical_services_rounded,
        color: Color(0xFFEF4444)),
    CategoryInfo(
        id: 'other',
        nameAr: 'أخرى',
        nameEn: 'Other',
        icon: Icons.category_rounded,
        color: Color(0xFF64748B)),
  ];

  static const CategoryInfo incomeCategory = CategoryInfo(
    id: 'income',
    nameAr: 'دخل / رصيد',
    nameEn: 'Income / Deposit',
    icon: Icons.account_balance_wallet_rounded,
    color: Color(0xFF10B981),
  );

  static CategoryInfo getById(String id, TransactionType type) {
    if (type == TransactionType.income) return incomeCategory;
    return expenseCategories.firstWhere(
      (c) => c.id == id,
      orElse: () => expenseCategories.last,
    );
  }
}

class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;

  TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type == TransactionType.income ? 'income' : 'expense',
        'categoryId': categoryId,
        'date': date.toIso8601String(),
      };

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      categoryId: json['categoryId'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

// ==========================================
// 3. MAIN APP ROOT
// ==========================================
class MasrofyProApp extends StatefulWidget {
  const MasrofyProApp({super.key});

  @override
  State<MasrofyProApp> createState() => _MasrofyProAppState();
}

class _MasrofyProAppState extends State<MasrofyProApp> {
  bool _isDarkMode = true;
  bool _isArabic = true;
  String? _userName;
  double _monthlyBudget = 3000.0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadAppSettings();
  }

  Future<void> _loadAppSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('masrofy_dark') ?? true;
      _isArabic = prefs.getBool('masrofy_lang_ar') ?? true;
      _userName = prefs.getString('masrofy_username');
      _monthlyBudget = prefs.getDouble('masrofy_budget') ?? 3000.0;
      _isInitialized = true;
    });
  }

  Future<void> _completeOnboarding(String name, double budget, bool isAr) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('masrofy_username', name);
    await prefs.setDouble('masrofy_budget', budget);
    await prefs.setBool('masrofy_lang_ar', isAr);
    setState(() {
      _userName = name;
      _monthlyBudget = budget;
      _isArabic = isAr;
    });
  }

  Future<void> _updateProfile(String name, double budget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('masrofy_username', name);
    await prefs.setDouble('masrofy_budget', budget);
    setState(() {
      _userName = name;
      _monthlyBudget = budget;
    });
  }

  Future<void> _toggleTheme(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('masrofy_dark', val);
    setState(() => _isDarkMode = val);
  }

  Future<void> _toggleLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final nextLang = !_isArabic;
    await prefs.setBool('masrofy_lang_ar', nextLang);
    setState(() => _isArabic = nextLang);
  }

  Future<void> _resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      _userName = null;
      _monthlyBudget = 3000.0;
      _isDarkMode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0D9488);
    final strings = AppStrings(_isArabic);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: strings.appTitle,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: primaryTeal,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        cardColor: Colors.white,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: primaryTeal,
        scaffoldBackgroundColor: const Color(0xFF0B1120),
        cardColor: const Color(0xFF1E293B),
      ),
      home: Directionality(
        textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: !_isInitialized
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : (_userName == null || _userName!.trim().isEmpty)
                ? OnboardingScreen(
                    isArabic: _isArabic,
                    onToggleLanguage: _toggleLanguage,
                    onComplete: _completeOnboarding,
                  )
                : MainNavigationShell(
                    userName: _userName!,
                    monthlyBudget: _monthlyBudget,
                    isDarkMode: _isDarkMode,
                    isArabic: _isArabic,
                    onToggleTheme: _toggleTheme,
                    onToggleLanguage: _toggleLanguage,
                    onUpdateProfile: _updateProfile,
                    onResetAll: _resetAll,
                  ),
      ),
    );
  }
}

// ==========================================
// 4. ONBOARDING WELCOME SCREEN
// ==========================================
class OnboardingScreen extends StatefulWidget {
  final bool isArabic;
  final VoidCallback onToggleLanguage;
  final Future<void> Function(String name, double budget, bool isAr) onComplete;

  const OnboardingScreen({
    super.key,
    required this.isArabic,
    required this.onToggleLanguage,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController(text: '3000');

  void _submit() {
    final name = _nameCtrl.text.trim();
    final budget = double.tryParse(_budgetCtrl.text.trim()) ?? 3000.0;
    if (name.isEmpty) return;
    widget.onComplete(name, budget > 0 ? budget : 3000.0, widget.isArabic);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.isArabic);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: widget.onToggleLanguage,
            icon: const Icon(Icons.language_rounded),
            label: Text(widget.isArabic ? 'English' : 'العربية'),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 44,
                  color: Color(0xFF0D9488),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                s.welcomeTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                s.welcomeSub,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: s.enterYourName,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _budgetCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: s.monthlyBudgetLabel,
                  prefixIcon: const Icon(Icons.savings_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _submit,
                child: Text(
                  s.startNow,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 5. MULTI-SCREEN NAVIGATION SHELL (4 TABS)
// ==========================================
class MainNavigationShell extends StatefulWidget {
  final String userName;
  final double monthlyBudget;
  final bool isDarkMode;
  final bool isArabic;
  final ValueChanged<bool> onToggleTheme;
  final VoidCallback onToggleLanguage;
  final Future<void> Function(String name, double budget) onUpdateProfile;
  final Future<void> Function() onResetAll;

  const MainNavigationShell({
    super.key,
    required this.userName,
    required this.monthlyBudget,
    required this.isDarkMode,
    required this.isArabic,
    required this.onToggleTheme,
    required this.onToggleLanguage,
    required this.onUpdateProfile,
    required this.onResetAll,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  List<TransactionItem> _transactions = [];
  bool _loadingTx = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('masrofy_v2_tx_list');
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _transactions = decoded
          .map((e) => TransactionItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    }
    setState(() => _loadingTx = false);
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_transactions.map((e) => e.toJson()).toList());
    await prefs.setString('masrofy_v2_tx_list', encoded);
  }

  void _addTransaction(TransactionItem item) {
    setState(() {
      _transactions.insert(0, item);
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    });
    _saveTransactions();
  }

  void _deleteTransaction(TransactionItem item) {
    final s = AppStrings(widget.isArabic);
    final idx = _transactions.indexOf(item);
    setState(() => _transactions.remove(item));
    _saveTransactions();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.deletedMsg(item.title)),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: s.undo,
          onPressed: () {
            setState(() => _transactions.insert(idx, item));
            _saveTransactions();
          },
        ),
      ),
    );
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AddTransactionSheet(
          isArabic: widget.isArabic,
          onAdd: _addTransaction,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.isArabic);

    if (_loadingTx) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = [
      HomeTabScreen(
        userName: widget.userName,
        monthlyBudget: widget.monthlyBudget,
        transactions: _transactions,
        isArabic: widget.isArabic,
        onDelete: _deleteTransaction,
        onGoToHistory: () => setState(() => _currentIndex = 2),
        onToggleLanguage: widget.onToggleLanguage,
      ),
      AnalyticsTabScreen(
        transactions: _transactions,
        monthlyBudget: widget.monthlyBudget,
        isArabic: widget.isArabic,
        isDarkMode: widget.isDarkMode,
      ),
      HistoryTabScreen(
        transactions: _transactions,
        isArabic: widget.isArabic,
        onDelete: _deleteTransaction,
      ),
      SettingsTabScreen(
        userName: widget.userName,
        monthlyBudget: widget.monthlyBudget,
        isDarkMode: widget.isDarkMode,
        isArabic: widget.isArabic,
        onToggleTheme: widget.onToggleTheme,
        onToggleLanguage: widget.onToggleLanguage,
        onUpdateProfile: widget.onUpdateProfile,
        onResetAll: widget.onResetAll,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      floatingActionButton: _currentIndex == 0 || _currentIndex == 2
          ? FloatingActionButton.extended(
              onPressed: _openAddSheet,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                s.newTransaction,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: s.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: const Icon(Icons.pie_chart_rounded),
            label: s.navAnalytics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long_rounded),
            label: s.navHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: s.navSettings,
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 6. TAB 1: HOME DASHBOARD
// ==========================================
class HomeTabScreen extends StatelessWidget {
  final String userName;
  final double monthlyBudget;
  final List<TransactionItem> transactions;
  final bool isArabic;
  final Function(TransactionItem) onDelete;
  final VoidCallback onGoToHistory;
  final VoidCallback onToggleLanguage;

  const HomeTabScreen({
    super.key,
    required this.userName,
    required this.monthlyBudget,
    required this.transactions,
    required this.isArabic,
    required this.onDelete,
    required this.onGoToHistory,
    required this.onToggleLanguage,
  });

  double get _totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get _totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get _monthExpense {
    final now = DateTime.now();
    return transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  String _getSmartInsight(AppStrings s) {
    if (transactions.isEmpty) {
      return isArabic
          ? 'اضغط على "عملية جديدة" لتسجيل دخلك أو مصاريفك اليومية.'
          : 'Tap "New Entry" to start logging your income and daily expenses.';
    }
    final ratio = monthlyBudget > 0 ? (_monthExpense / monthlyBudget) : 0.0;
    if (ratio >= 1.0) {
      return isArabic
          ? 'تنبيه: تجاوزت الميزانية الشهرية (${monthlyBudget.toStringAsFixed(0)} ${s.currency})!'
          : 'Alert: You exceeded your monthly budget (${monthlyBudget.toStringAsFixed(0)} ${s.currency})!';
    } else if (ratio >= 0.8) {
      return isArabic
          ? 'انتبه: استهلكت ${(ratio * 100).toStringAsFixed(0)}% من ميزانية الشهر.'
          : 'Heads up: You used ${(ratio * 100).toStringAsFixed(0)}% of your monthly budget.';
    }
    return isArabic
        ? 'وضعك المالي متوازن! متبقي ${(monthlyBudget - _monthExpense).clamp(0, double.infinity).toStringAsFixed(0)} ${s.currency} من ميزانية الشهر.'
        : 'Great job! ${(monthlyBudget - _monthExpense).clamp(0, double.infinity).toStringAsFixed(0)} ${s.currency} left in this month\'s budget.';
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(isArabic);
    final balance = _totalIncome - _totalExpense;
    final progress =
        monthlyBudget > 0 ? (_monthExpense / monthlyBudget).clamp(0.0, 1.0) : 0.0;

    Color progressColor = const Color(0xFF34D399);
    if (progress >= 0.85) {
      progressColor = const Color(0xFFF87171);
    } else if (progress >= 0.6) {
      progressColor = const Color(0xFFFBBF24);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.greeting(userName),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              s.subtitleHome,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: onToggleLanguage,
            icon: const Icon(Icons.language_rounded, size: 18),
            label: Text(isArabic ? 'EN' : 'عربي'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF115E59)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.currentBalance,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '${balance.toStringAsFixed(2)} ${s.currency}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _miniStat(
                        s.totalIncome,
                        '${_totalIncome.toStringAsFixed(0)} ${s.currency}',
                        Icons.arrow_downward_rounded,
                        const Color(0xFF6EE7B7),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _miniStat(
                        s.totalExpense,
                        '${_totalExpense.toStringAsFixed(0)} ${s.currency}',
                        Icons.arrow_upward_rounded,
                        const Color(0xFFFCA5A5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${s.budgetUsage} (${_monthExpense.toStringAsFixed(0)}/${monthlyBudget.toStringAsFixed(0)})',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF0D9488).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Color(0xFF0D9488), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _getSmartInsight(s),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.recentTransactions,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (transactions.isNotEmpty)
                TextButton(
                  onPressed: onGoToHistory,
                  child: Text(s.seeAll),
                ),
            ],
          ),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_rounded, size: 52, color: Colors.grey.shade500),
                  const SizedBox(height: 8),
                  Text(
                    s.noTransactions,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          else
            ...transactions.take(5).map(
                  (item) => TransactionTileWidget(
                    item: item,
                    isArabic: isArabic,
                    onDelete: () => onDelete(item),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String val, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                Text(
                  val,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 7. TAB 2: ANALYTICS & CHARTS SCREEN
// ==========================================
class AnalyticsTabScreen extends StatelessWidget {
  final List<TransactionItem> transactions;
  final double monthlyBudget;
  final bool isArabic;
  final bool isDarkMode;

  const AnalyticsTabScreen({
    super.key,
    required this.transactions,
    required this.monthlyBudget,
    required this.isArabic,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(isArabic);
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
    final totalExp = expenses.fold(0.0, (sum, e) => sum + e.amount);

    final Map<String, double> catMap = {};
    for (var e in expenses) {
      catMap[e.categoryId] = (catMap[e.categoryId] ?? 0) + e.amount;
    }
    final sorted = catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: Text(s.analyticsTitle)),
      body: expenses.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart_outline_rounded,
                        size: 64, color: Colors.grey.shade500),
                    const SizedBox(height: 12),
                    Text(
                      s.noAnalyticsData,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      Text(
                        s.expenseByCategory,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 170,
                        height: 170,
                        child: CustomPaint(
                          painter: DonutChartPainter(
                            data: sorted,
                            total: totalExp,
                            centerText: '${totalExp.toStringAsFixed(0)}\n${s.currency}',
                            textColor: isDarkMode ? Colors.white : Colors.black87,
                            isArabic: isArabic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...sorted.map((entry) {
                  final cat = AppCategories.getById(entry.key, TransactionType.expense);
                  final pct = totalExp > 0 ? (entry.value / totalExp) : 0.0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: cat.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(cat.icon, color: cat.color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                cat.getName(isArabic),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              '${entry.value.toStringAsFixed(0)} ${s.currency} (${(pct * 100).toStringAsFixed(0)}%)',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 6,
                            backgroundColor: cat.color.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                          ),
                        ),
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
// 8. TAB 3: FULL HISTORY & SEARCH SCREEN
// ==========================================
class HistoryTabScreen extends StatefulWidget {
  final List<TransactionItem> transactions;
  final bool isArabic;
  final Function(TransactionItem) onDelete;

  const HistoryTabScreen({
    super.key,
    required this.transactions,
    required this.isArabic,
    required this.onDelete,
  });

  @override
  State<HistoryTabScreen> createState() => _HistoryTabScreenState();
}

class _HistoryTabScreenState extends State<HistoryTabScreen> {
  String _query = '';
  String _filter = 'all';

  List<TransactionItem> get _filtered {
    final now = DateTime.now();
    return widget.transactions.where((t) {
      final catName = AppCategories.getById(t.categoryId, t.type).getName(widget.isArabic);
      final matchText = t.title.toLowerCase().contains(_query.toLowerCase()) ||
          catName.toLowerCase().contains(_query.toLowerCase());
      if (!matchText) return false;

      switch (_filter) {
        case 'today':
          return t.date.year == now.year &&
              t.date.month == now.month &&
              t.date.day == now.day;
        case 'month':
          return t.date.year == now.year && t.date.month == now.month;
        case 'expense':
          return t.type == TransactionType.expense;
        case 'income':
          return t.type == TransactionType.income;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.isArabic);
    final items = _filtered;

    final filters = [
      {'id': 'all', 'label': s.filterAll},
      {'id': 'today', 'label': s.filterToday},
      {'id': 'month', 'label': s.filterMonth},
      {'id': 'expense', 'label': s.filterExpense},
      {'id': 'income', 'label': s.filterIncome},
    ];

    return Scaffold(
      appBar: AppBar(title: Text(s.historyTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: s.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final f = filters[i];
                return ChoiceChip(
                  label: Text(f['label']!),
                  selected: _filter == f['id'],
                  onSelected: (_) => setState(() => _filter = f['id']!),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      s.noTransactions,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) => TransactionTileWidget(
                      item: items[i],
                      isArabic: widget.isArabic,
                      onDelete: () => widget.onDelete(items[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 9. TAB 4: SETTINGS & PROFILE SCREEN
// ==========================================
class SettingsTabScreen extends StatefulWidget {
  final String userName;
  final double monthlyBudget;
  final bool isDarkMode;
  final bool isArabic;
  final ValueChanged<bool> onToggleTheme;
  final VoidCallback onToggleLanguage;
  final Future<void> Function(String name, double budget) onUpdateProfile;
  final Future<void> Function() onResetAll;

  const SettingsTabScreen({
    super.key,
    required this.userName,
    required this.monthlyBudget,
    required this.isDarkMode,
    required this.isArabic,
    required this.onToggleTheme,
    required this.onToggleLanguage,
    required this.onUpdateProfile,
    required this.onResetAll,
  });

  @override
  State<SettingsTabScreen> createState() => _SettingsTabScreenState();
}

class _SettingsTabScreenState extends State<SettingsTabScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _budgetCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.userName);
    _budgetCtrl = TextEditingController(text: widget.monthlyBudget.toStringAsFixed(0));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.isArabic);

    return Scaffold(
      appBar: AppBar(title: Text(s.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            s.profileSection,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: s.enterYourName,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _budgetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: s.monthlyBudgetLabel,
                    prefixIcon: const Icon(Icons.savings_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () async {
                    final n = _nameCtrl.text.trim();
                    final b = double.tryParse(_budgetCtrl.text.trim());
                    if (n.isNotEmpty && b != null && b > 0) {
                      await widget.onUpdateProfile(n, b);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s.savedSuccess)),
                        );
                      }
                    }
                  },
                  child: Text(s.saveChanges),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            s.appearanceSection,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_rounded),
                  title: Text(s.darkModeTitle),
                  value: widget.isDarkMode,
                  onChanged: widget.onToggleTheme,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text(s.languageTitle),
                  trailing: FilledButton.tonal(
                    onPressed: widget.onToggleLanguage,
                    child: Text(s.languageValue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.delete_forever_rounded),
            label: Text(s.clearDataBtn),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => Directionality(
                  textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: AlertDialog(
                    title: Text(s.clearConfirmTitle),
                    content: Text(s.clearConfirmMsg),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(s.cancel),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {
                          Navigator.pop(ctx);
                          widget.onResetAll();
                        },
                        child: Text(s.confirm),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 10. SHARED WIDGETS & PAINTERS
// ==========================================
class TransactionTileWidget extends StatelessWidget {
  final TransactionItem item;
  final bool isArabic;
  final VoidCallback onDelete;

  const TransactionTileWidget({
    super.key,
    required this.item,
    required this.isArabic,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(isArabic);
    final cat = AppCategories.getById(item.categoryId, item.type);
    final isIncome = item.type == TransactionType.income;
    final dateStr =
        '${item.date.year}/${item.date.month.toString().padLeft(2, '0')}/${item.date.day.toString().padLeft(2, '0')}';

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(cat.icon, color: cat.color),
          ),
          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            '${cat.getName(isArabic)} • $dateStr',
            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
          ),
          trailing: Text(
            '${isIncome ? '+' : '-'}${item.amount.toStringAsFixed(0)} ${s.currency}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
          ),
        ),
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> data;
  final double total;
  final String centerText;
  final Color textColor;
  final bool isArabic;

  DonutChartPainter({
    required this.data,
    required this.total,
    required this.centerText,
    required this.textColor,
    required this.isArabic,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    const strokeWidth = 22.0;

    final bgPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    if (total > 0) {
      double startAngle = -math.pi / 2;
      for (var entry in data) {
        final sweepAngle = (entry.value / total) * 2 * math.pi;
        final cat = AppCategories.getById(entry.key, TransactionType.expense);
        final paint = Paint()
          ..color = cat.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
        startAngle += sweepAngle;
      }
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: centerText,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AddTransactionSheet extends StatefulWidget {
  final bool isArabic;
  final Function(TransactionItem) onAdd;

  const AddTransactionSheet({
    super.key,
    required this.isArabic,
    required this.onAdd,
  });

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  TransactionType _type = TransactionType.expense;
  String _selectedCatId = 'food';
  DateTime _selectedDate = DateTime.now();

  void _submit() {
    final title = _titleCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (title.isEmpty || amount == null || amount <= 0) return;

    widget.onAdd(
      TransactionItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: amount,
        type: _type,
        categoryId: _type == TransactionType.income ? 'income' : _selectedCatId,
        date: _selectedDate,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.isArabic);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.addEntryTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SegmentedButton<TransactionType>(
              segments: [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text(s.expenseLabel),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text(s.incomeLabel),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (val) => setState(() => _type = val.first),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: _type == TransactionType.expense
                    ? s.titleHintExpense
                    : s.titleHintIncome,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '${s.amountLabel} (${s.currency})',
                prefixIcon: const Icon(Icons.payments_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            if (_type == TransactionType.expense) ...[
              const SizedBox(height: 14),
              Text(s.chooseCategory, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppCategories.expenseCategories.map((cat) {
                  final isSel = _selectedCatId == cat.id;
                  return ChoiceChip(
                    avatar: Icon(cat.icon, size: 16, color: isSel ? Colors.white : cat.color),
                    label: Text(cat.getName(widget.isArabic)),
                    selected: isSel,
                    onSelected: (_) => setState(() => _selectedCatId = cat.id),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 14),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: Text(
                '${s.dateLabel}: ${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _submit,
              child: Text(
                s.saveBtn,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}