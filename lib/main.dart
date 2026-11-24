import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MasrofyApp(prefs: prefs));
}

class ExpenseItem {
  final String id;
  final String title;
  final double amount;
  final String categoryKey;
  final DateTime date;

  const ExpenseItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryKey,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'categoryKey': categoryKey,
        'date': date.toIso8601String(),
      };

  factory ExpenseItem.fromJson(Map<String, dynamic> json) => ExpenseItem(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        categoryKey: json['categoryKey'] as String,
        date: DateTime.parse(json['date'] as String),
      );
}

class MasrofyApp extends StatefulWidget {
  final SharedPreferences prefs;
  const MasrofyApp({super.key, required this.prefs});

  @override
  State<MasrofyApp> createState() => _MasrofyAppState();
}

class _MasrofyAppState extends State<MasrofyApp> {
  late bool isDark;
  late bool isArabic;
  late bool hasCompletedOnboarding;
  late String userName;
  late double weeklyLimit;
  late double monthlyLimit;
  late List<ExpenseItem> _expenses;

  @override
  void initState() {
    super.initState();
    isDark = widget.prefs.getBool('isDark') ?? false;
    isArabic = widget.prefs.getBool('isArabic') ?? true;
    hasCompletedOnboarding =
        widget.prefs.getBool('hasCompletedOnboarding') ?? false;
    userName = widget.prefs.getString('userName') ?? '';
    weeklyLimit = widget.prefs.getDouble('weeklyLimit') ?? 1000.0;
    monthlyLimit = widget.prefs.getDouble('monthlyLimit') ?? 4000.0;

    final rawList = widget.prefs.getStringList('expenses') ?? [];
    _expenses = rawList
        .map((e) =>
            ExpenseItem.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveExpensesToStorage() async {
    final encoded = _expenses.map((e) => jsonEncode(e.toJson())).toList();
    await widget.prefs.setStringList('expenses', encoded);
  }

  Future<void> _completeOnboarding({
    required String name,
    required double weekly,
    required double monthly,
    required bool arabic,
  }) async {
    await widget.prefs.setString('userName', name);
    await widget.prefs.setDouble('weeklyLimit', weekly);
    await widget.prefs.setDouble('monthlyLimit', monthly);
    await widget.prefs.setBool('isArabic', arabic);
    await widget.prefs.setBool('hasCompletedOnboarding', true);

    setState(() {
      userName = name;
      weeklyLimit = weekly;
      monthlyLimit = monthly;
      isArabic = arabic;
      hasCompletedOnboarding = true;
    });
  }

  void _toggleTheme() {
    setState(() => isDark = !isDark);
    widget.prefs.setBool('isDark', isDark);
  }

  void _toggleLanguage() {
    setState(() => isArabic = !isArabic);
    widget.prefs.setBool('isArabic', isArabic);
  }

  void _addExpense(ExpenseItem item) {
    setState(() {
      _expenses.insert(0, item);
      _expenses.sort((a, b) => b.date.compareTo(a.date));
    });
    _saveExpensesToStorage();
  }

  void _deleteExpense(String id) {
    setState(() {
      _expenses.removeWhere((item) => item.id == id);
    });
    _saveExpensesToStorage();
  }

  void _clearAllExpenses() {
    setState(() {
      _expenses.clear();
    });
    _saveExpensesToStorage();
  }

  void _updateLimits(double weekly, double monthly) {
    setState(() {
      weeklyLimit = weekly;
      monthlyLimit = monthly;
    });
    widget.prefs.setDouble('weeklyLimit', weekly);
    widget.prefs.setDouble('monthlyLimit', monthly);
  }

  void _updateUserName(String name) {
    setState(() {
      userName = name;
    });
    widget.prefs.setString('userName', name);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: isArabic ? 'مصروفي' : 'Masrofy',
      theme: ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light,
        colorSchemeSeed: Colors.teal,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: hasCompletedOnboarding
          ? MainShellPage(
              userName: userName,
              isDark: isDark,
              isArabic: isArabic,
              weeklyLimit: weeklyLimit,
              monthlyLimit: monthlyLimit,
              expenses: _expenses,
              onToggleTheme: _toggleTheme,
              onToggleLanguage: _toggleLanguage,
              onAddExpense: _addExpense,
              onDeleteExpense: _deleteExpense,
              onClearAllExpenses: _clearAllExpenses,
              onUpdateLimits: _updateLimits,
              onUpdateUserName: _updateUserName,
            )
          : WelcomeScreen(
              isArabic: isArabic,
              isDark: isDark,
              onToggleLanguage: _toggleLanguage,
              onToggleTheme: _toggleTheme,
              onFinish: _completeOnboarding,
            ),
    );
  }
}

class AppStrings {
  final bool ar;
  const AppStrings(this.ar);

  String get appName => ar ? 'مصروفي' : 'Masrofy';
  String get welcomeTitle => ar ? 'أهلاً بك في مصروفي' : 'Welcome to Masrofy';
  String get welcomeSubtitle => ar
      ? 'نظّم مصاريفك اليومية، وحدد ميزانيتك الأسبوعية والشهرية بسهولة.'
      : 'Track your daily expenses and manage weekly & monthly limits easily.';
  String get yourName => ar ? 'اسمك' : 'Your Name';
  String get enterNameHint => ar ? 'اكتب اسمك هنا...' : 'Enter your name...';
  String get weeklyBudget => ar ? 'الحد الأسبوعي (ج.م)' : 'Weekly Limit (EGP)';
  String get monthlyBudget => ar ? 'الحد الشهري (ج.م)' : 'Monthly Limit (EGP)';
  String get startNow => ar ? 'ابدأ الآن' : 'Get Started';

  String get navHome => ar ? 'الرئيسية' : 'Home';
  String get navHistory => ar ? 'السجل' : 'History';
  String get navAnalytics => ar ? 'الإحصائيات' : 'Analytics';
  String get navSettings => ar ? 'الإعدادات' : 'Settings';

  String helloUser(String name) => ar
      ? 'مرحباً، ${name.isEmpty ? "صديقي" : name}'
      : 'Hello, ${name.isEmpty ? "Friend" : name}';
  String get totalExpenses =>
      ar ? 'إجمالي المصروفات المسجلة' : 'Total Recorded Expenses';
  String get thisWeek => ar ? 'مصاريف هذا الأسبوع' : 'This Week';
  String get thisMonth => ar ? 'مصاريف هذا الشهر' : 'This Month';
  String get recentTransactions => ar ? 'أحدث المعاملات' : 'Recent Transactions';
  String get noExpensesYet => ar
      ? 'لا توجد مصروفات بعد. اضغط على زر (+) لإضافة أول مصروف!'
      : 'No expenses yet. Tap (+) to add your first expense!';

  String get addExpense => ar ? 'إضافة مصروف' : 'Add Expense';
  String get expenseTitle => ar ? 'اسم المصروف' : 'Expense Title';
  String get amount => ar ? 'المبلغ' : 'Amount';
  String get category => ar ? 'التصنيف' : 'Category';
  String get date => ar ? 'التاريخ' : 'Date';
  String get save => ar ? 'حفظ' : 'Save';
  String get currency => ar ? 'ج.م' : 'EGP';

  String get limitExceeded => ar ? 'تجاوزت الحد المسموح!' : 'Limit Exceeded!';
  String get nearLimit => ar ? 'اقتربت من الحد المسموح' : 'Approaching Limit';
  String get withinLimit => ar ? 'ضمن الميزانية' : 'Within Budget';

  String get categoryBreakdown =>
      ar ? 'توزيع المصاريف حسب التصنيف' : 'Spending by Category';
  String get settingsTitle => ar ? 'الإعدادات والميزانية' : 'Settings & Budget';
  String get appearance => ar ? 'المظهر الليلي' : 'Dark Mode';
  String get language => ar ? 'اللغة' : 'Language';
  String get switchLangLabel =>
      ar ? 'التبديل إلى الإنجليزية' : 'Switch to Arabic';
  String get updateBudget =>
      ar ? 'تحديث حدود الميزانية' : 'Update Budget Limits';
  String get savedSuccess =>
      ar ? 'تم حفظ التعديلات بنجاح' : 'Changes saved successfully';
  String get clearAll => ar ? 'مسح جميع المصاريف' : 'Clear All Expenses';

  String categoryName(String key) {
    switch (key) {
      case 'food':
        return ar ? 'طعام ومشروبات' : 'Food & Drinks';
      case 'transport':
        return ar ? 'مواصلات' : 'Transport';
      case 'study':
        return ar ? 'دراسة وكتب' : 'Study & Books';
      case 'bills':
        return ar ? 'فواتير واشتراكات' : 'Bills & Subscriptions';
      case 'shopping':
        return ar ? 'تسوق' : 'Shopping';
      default:
        return ar ? 'أخرى' : 'Other';
    }
  }

  IconData categoryIcon(String key) {
    switch (key) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_bus;
      case 'study':
        return Icons.menu_book;
      case 'bills':
        return Icons.receipt_long;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }
}

class WelcomeScreen extends StatefulWidget {
  final bool isArabic;
  final bool isDark;
  final VoidCallback onToggleLanguage;
  final VoidCallback onToggleTheme;
  final Future<void> Function({
    required String name,
    required double weekly,
    required double monthly,
    required bool arabic,
  }) onFinish;

  const WelcomeScreen({
    super.key,
    required this.isArabic,
    required this.isDark,
    required this.onToggleLanguage,
    required this.onToggleTheme,
    required this.onFinish,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameController = TextEditingController();
  final _weeklyController = TextEditingController(text: '1000');
  final _monthlyController = TextEditingController(text: '4000');

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.isArabic);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          TextButton.icon(
            onPressed: widget.onToggleLanguage,
            icon: const Icon(Icons.language),
            label: Text(widget.isArabic ? 'English' : 'عربي'),
          ),
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.teal.withValues(alpha: 0.15),
                child: const Icon(Icons.account_balance_wallet,
                    size: 44, color: Colors.teal),
              ),
              const SizedBox(height: 20),
              Text(
                s.welcomeTitle,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                s.welcomeSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: s.yourName,
                  hintText: s.enterNameHint,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _weeklyController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: s.weeklyBudget,
                  prefixIcon: const Icon(Icons.date_range),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _monthlyController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: s.monthlyBudget,
                  prefixIcon: const Icon(Icons.calendar_month),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  final weekly =
                      double.tryParse(_weeklyController.text.trim()) ?? 1000.0;
                  final monthly =
                      double.tryParse(_monthlyController.text.trim()) ?? 4000.0;
                  widget.onFinish(
                    name: _nameController.text.trim(),
                    weekly: weekly > 0 ? weekly : 1000.0,
                    monthly: monthly > 0 ? monthly : 4000.0,
                    arabic: widget.isArabic,
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text(s.startNow, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainShellPage extends StatefulWidget {
  final String userName;
  final bool isDark;
  final bool isArabic;
  final double weeklyLimit;
  final double monthlyLimit;
  final List<ExpenseItem> expenses;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLanguage;
  final void Function(ExpenseItem) onAddExpense;
  final void Function(String) onDeleteExpense;
  final VoidCallback onClearAllExpenses;
  final void Function(double, double) onUpdateLimits;
  final void Function(String) onUpdateUserName;

  const MainShellPage({
    super.key,
    required this.userName,
    required this.isDark,
    required this.isArabic,
    required this.weeklyLimit,
    required this.monthlyLimit,
    required this.expenses,
    required this.onToggleTheme,
    required this.onToggleLanguage,
    required this.onAddExpense,
    required this.onDeleteExpense,
    required this.onClearAllExpenses,
    required this.onUpdateLimits,
    required this.onUpdateUserName,
  });

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _selectedIndex = 0;

  double get _totalSpent =>
      widget.expenses.fold(0.0, (sum, item) => sum + item.amount);

  double get _weeklySpent {
    final now = DateTime.now();
    final weekAgo = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    return widget.expenses
        .where((e) => !e.date.isBefore(weekAgo))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get _monthlySpent {
    final now = DateTime.now();
    return widget.expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  String _formatDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  void _openAddExpenseSheet() {
    final s = AppStrings(widget.isArabic);
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'food';
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Directionality(
              textDirection:
                  widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      s.addExpense,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: s.expenseTitle,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: '${s.amount} (${s.currency})',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        labelText: s.category,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        'food',
                        'transport',
                        'study',
                        'bills',
                        'shopping',
                        'other'
                      ]
                          .map((key) => DropdownMenuItem(
                                value: key,
                                child: Text(s.categoryName(key)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedCategory = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text('${s.date}: ${_formatDate(selectedDate)}'),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () {
                        final title = titleController.text.trim();
                        final amount =
                            double.tryParse(amountController.text.trim());
                        if (title.isNotEmpty && amount != null && amount > 0) {
                          widget.onAddExpense(
                            ExpenseItem(
                              id: DateTime.now()
                                  .microsecondsSinceEpoch
                                  .toString(),
                              title: title,
                              amount: amount,
                              categoryKey: selectedCategory,
                              date: selectedDate,
                            ),
                          );
                          Navigator.pop(ctx);
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: Text(s.save),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.isArabic);
    final pages = [
      _buildHomePage(s),
      _buildHistoryPage(s),
      _buildAnalyticsPage(s),
      _buildSettingsPage(s),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(s.appName),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: widget.onToggleLanguage,
            icon: const Icon(Icons.language),
            tooltip: s.switchLangLabel,
          ),
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: s.appearance,
          ),
        ],
      ),
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: _openAddExpenseSheet,
              icon: const Icon(Icons.add),
              label: Text(s.addExpense),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: s.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: s.navHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.pie_chart_outline),
            selectedIcon: const Icon(Icons.pie_chart),
            label: s.navAnalytics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: s.navSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildLimitCard({
    required String title,
    required double spent,
    required double limit,
    required AppStrings s,
  }) {
    final ratio = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isOver = spent > limit;
    final isNear = !isOver && ratio >= 0.8;
    final barColor =
        isOver ? Colors.redAccent : (isNear ? Colors.orange : Colors.teal);
    final statusText =
        isOver ? s.limitExceeded : (isNear ? s.nearLimit : s.withinLimit);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: barColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                        color: barColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 10,
                backgroundColor: barColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${spent.toStringAsFixed(0)} / ${limit.toStringAsFixed(0)} ${s.currency}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage(AppStrings s) {
    final recent = widget.expenses.take(4).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          s.helloUser(widget.userName),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade400],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.totalExpenses,
                  style: const TextStyle(color: Colors.white70, fontSize: 15)),
              const SizedBox(height: 8),
              Text(
                '${_totalSpent.toStringAsFixed(2)} ${s.currency}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildLimitCard(
          title: s.thisWeek,
          spent: _weeklySpent,
          limit: widget.weeklyLimit,
          s: s,
        ),
        _buildLimitCard(
          title: s.thisMonth,
          spent: _monthlySpent,
          limit: widget.monthlyLimit,
          s: s,
        ),
        const SizedBox(height: 8),
        Text(
          s.recentTransactions,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (recent.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(
              s.noExpensesYet,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
          )
        else
          ...recent.map((item) => _buildExpenseTile(item, s)),
        const SizedBox(height: 70),
      ],
    );
  }

  Widget _buildExpenseTile(ExpenseItem item, AppStrings s) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withValues(alpha: 0.15),
          child: Icon(s.categoryIcon(item.categoryKey), color: Colors.teal),
        ),
        title: Text(item.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '${s.categoryName(item.categoryKey)} • ${_formatDate(item.date)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${item.amount.toStringAsFixed(0)} ${s.currency}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => widget.onDeleteExpense(item.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryPage(AppStrings s) {
    if (widget.expenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            s.noExpensesYet,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: widget.expenses.length,
      itemBuilder: (context, index) =>
          _buildExpenseTile(widget.expenses[index], s),
    );
  }

  Widget _buildAnalyticsPage(AppStrings s) {
    if (widget.expenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            s.noExpensesYet,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final Map<String, double> totalsByCat = {};
    for (final e in widget.expenses) {
      totalsByCat[e.categoryKey] = (totalsByCat[e.categoryKey] ?? 0) + e.amount;
    }

    final sortedEntries = totalsByCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          s.categoryBreakdown,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...sortedEntries.map((entry) {
          final pct = _totalSpent > 0 ? (entry.value / _totalSpent) : 0.0;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(s.categoryIcon(entry.key), color: Colors.teal),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          s.categoryName(entry.key),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      Text(
                        '${entry.value.toStringAsFixed(0)} ${s.currency} (${(pct * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSettingsPage(AppStrings s) {
    final nameCtrl = TextEditingController(text: widget.userName);
    final weeklyCtrl =
        TextEditingController(text: widget.weeklyLimit.toStringAsFixed(0));
    final monthlyCtrl =
        TextEditingController(text: widget.monthlyLimit.toStringAsFixed(0));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          s.settingsTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: Text(s.appearance),
                secondary:
                    Icon(widget.isDark ? Icons.dark_mode : Icons.light_mode),
                value: widget.isDark,
                onChanged: (_) => widget.onToggleTheme(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(s.language),
                subtitle: Text(widget.isArabic ? 'العربية' : 'English'),
                trailing: OutlinedButton(
                  onPressed: widget.onToggleLanguage,
                  child: Text(widget.isArabic ? 'English' : 'عربي'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: s.yourName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: weeklyCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: s.weeklyBudget,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: monthlyCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: s.monthlyBudget,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () {
                    final w = double.tryParse(weeklyCtrl.text.trim()) ??
                        widget.weeklyLimit;
                    final m = double.tryParse(monthlyCtrl.text.trim()) ??
                        widget.monthlyLimit;
                    widget.onUpdateUserName(nameCtrl.text.trim());
                    widget.onUpdateLimits(
                      w > 0 ? w : widget.weeklyLimit,
                      m > 0 ? m : widget.monthlyLimit,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(s.savedSuccess)),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: Text(s.updateBudget),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (widget.expenses.isNotEmpty)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: widget.onClearAllExpenses,
            icon: const Icon(Icons.delete_forever),
            label: Text(s.clearAll),
          ),
      ],
    );
  }
}