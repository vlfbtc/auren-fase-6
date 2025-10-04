import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import 'add_transaction_screen.dart';
import 'insights_screen.dart';
import 'about_screen.dart';

import 'package:auren/features/auth/domain/models/transaction.dart';
import 'package:auren/features/auth/data/repositories/transaction_repository.dart';

class MonthlyFinancialData {
  final String month;
  final double income;
  final double expense;

  MonthlyFinancialData({
    required this.month,
    required this.income,
    required this.expense,
  });
}

class CategoryExpenseData {
  final String category;
  final double amount;
  final Color color;

  CategoryExpenseData({
    required this.category,
    required this.amount,
    required this.color,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _loadedOnce = false;

  // Dados
  List<MonthlyFinancialData> _monthlyData = []; // calculado da API
  List<CategoryExpenseData> _categoryExpenseData = []; // calculado da API
  List<Transaction> _recentTransactions = [];

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const InsightsScreen(showAppBar: false),
      const AboutScreen(showAppBar: false),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedOnce) {
      _loadedOnce = true;
      _loadData();
    }
  }

  TransactionRepository get _txRepo =>
      RepositoryProvider.of<TransactionRepository>(context);

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final txs = await _txRepo.fetchTransactions(limit: 120);
      debugPrint('HOME got txs: ${txs.length}');
      if (txs.isNotEmpty) debugPrint('first tx: ${txs.first.toCreateJson()}');
      final monthly = _buildMonthlyData(txs);
      final cats = _buildCategoryExpenseData(
        txs.where((t) => t.type == TransactionType.expense).toList(),
      );

      if (!mounted) return;
      setState(() {
        _recentTransactions = txs;
        _monthlyData = monthly;
        _categoryExpenseData = cats;
        _isLoading = false;
      });
      debugPrint('UI -> transações: ${txs.length}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
    }
  }

  List<MonthlyFinancialData> _buildMonthlyData(List<Transaction> txs) {
    final now = DateTime.now();
    // meses: atual e 5 anteriores
    final months = List.generate(6, (i) {
      final d = DateTime(now.year, now.month - (5 - i), 1);
      return DateTime(d.year, d.month, 1);
    });

    final Map<int, double> incomeByMonth = {};
    final Map<int, double> expenseByMonth = {};
    for (final m in months) {
      final key = m.year * 100 + m.month;
      incomeByMonth[key] = 0;
      expenseByMonth[key] = 0;
    }

    for (final t in txs) {
      final key = t.date.year * 100 + t.date.month;
      if (incomeByMonth.containsKey(key)) {
        if (t.type == TransactionType.income) {
          incomeByMonth[key] = (incomeByMonth[key] ?? 0) + t.amount;
        } else {
          expenseByMonth[key] = (expenseByMonth[key] ?? 0) + t.amount;
        }
      }
    }

    final monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

    return months.map((m) {
      final key = m.year * 100 + m.month;
      return MonthlyFinancialData(
        month: monthNames[m.month - 1],
        income: (incomeByMonth[key] ?? 0),
        expense: (expenseByMonth[key] ?? 0),
      );
    }).toList();
  }

  List<CategoryExpenseData> _buildCategoryExpenseData(List<Transaction> expenses) {
    final Map<String, double> sumByCat = {};
    for (final t in expenses) {
      sumByCat[t.category] = (sumByCat[t.category] ?? 0) + t.amount;
    }

    if (sumByCat.isEmpty) return [];

    final palette = <Color>[
      const Color(0xFF4ECDC4),
      const Color(0xFFFF6B6B),
      const Color(0xFFFFE66D),
      const Color(0xFF1A535C),
      const Color(0xFF66D7D1),
      const Color(0xFFF9CF00),
      const Color(0xFFF19A3E),
      const Color(0xFF445E93),
      const Color(0xFF6B4E71),
    ];

    int i = 0;
    return sumByCat.entries.map((e) {
      final c = palette[i % palette.length];
      i++;
      return CategoryExpenseData(category: e.key, amount: e.value, color: c);
    }).toList();
  }

  // UI (layout original mantido)
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Auren', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: _selectedIndex == 0
          ? _buildHomeContent()
          : _screens[_selectedIndex - 2],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            setState(() => _selectedIndex = 0);
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTransactionScreen(
                  onTransactionAdded: _addTransaction,
                ),
              ),
            ).then((added) {
              if (added == true) _loadData();
            });
          } else if (index >= 2 && index <= 4) {
            setState(() => _selectedIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Adicionar'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Insights'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Creditos'),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    final primaryColor = Theme.of(context).primaryColor;

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando suas informações financeiras...')
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const SizedBox(height: 24),

            // Visão mensal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Visão Mensal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: KeyedSubtree(
                      key: ValueKey('bars_${_monthlyData.length}_${_monthlyData.fold<double>(0,(s,e)=>s+e.income+e.expense)}'),
                      child: _buildMonthlyBarChart(primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Categorias de Despesas (somente expenses)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Categorias de Despesas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildCategoryPieChart(),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Transações recentes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transações Recentes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, color: primaryColor),
                        onPressed: _loadData,
                        tooltip: 'Atualizar transações',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _recentTransactions.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text('Nenhuma transação recente',
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  )
                      : ListView.builder(
                    key: ValueKey('transactions_${_recentTransactions.length}_${_recentTransactions.fold<int>(0, (a, b) => a ^ (b.id ?? 0))}'),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentTransactions.length,
                    itemBuilder: (context, index) =>
                        _buildTransactionItem(_recentTransactions[index]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyBarChart(Color primaryColor) {
    final maxY = _getMaxValue() * 1.2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY <= 0 ? 100 : maxY,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tooltipBorderRadius: BorderRadius.circular(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final data = _monthlyData[group.x.toInt()];
                return BarTooltipItem(
                  rodIndex == 0
                      ? 'Income: R\$${data.income.toStringAsFixed(2)}'
                      : 'Expense: R\$${data.expense.toStringAsFixed(2)}',
                  const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  if (value >= _monthlyData.length || value < 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      _monthlyData[value.toInt()].month,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: _getBarGroups(primaryColor),
        ),
      ),
    );
  }

  double _getMaxValue() {
    double max = 0;
    for (var data in _monthlyData) {
      if (data.income > max) max = data.income;
      if (data.expense > max) max = data.expense;
    }
    return max;
  }

  List<BarChartGroupData> _getBarGroups(Color primaryColor) {
    return List.generate(_monthlyData.length, (i) {
      return BarChartGroupData(
        x: i,
        groupVertically: true,
        barRods: [
          BarChartRodData(
            toY: _monthlyData[i].income,
            color: primaryColor,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4), topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: _monthlyData[i].expense,
            color: primaryColor.withOpacity(0.5),
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4), topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCategoryPieChart() {
    if (_categoryExpenseData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Sem despesas categorizáveis no período')),
      );
    }

    final totalExpense = _categoryExpenseData.fold<double>(
        0, (sum, item) => sum + item.amount);
    const chartHeight = 240.0;
    final useScrollableLegend = _categoryExpenseData.length > 5;

    return SizedBox(
      height: chartHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: PieChart(
                key: ValueKey('pie_${_categoryExpenseData.length}_${_categoryExpenseData.fold<double>(0,(s,e)=>s+e.amount)}'),
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                  sections: _categoryExpenseData.map((data) {
                    final percentage = totalExpense == 0
                        ? 0
                        : (data.amount / totalExpense) * 100;
                    return PieChartSectionData(
                      color: data.color,
                      value: data.amount,
                      title: '${percentage.toStringAsFixed(0)}%',
                      radius: 55,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      badgePositionPercentageOffset: 0.98,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: useScrollableLegend
                  ? ListView.builder(
                key: ValueKey('transactions_${_recentTransactions.length}_${_recentTransactions.isNotEmpty ? _recentTransactions.first.id : 0}'),
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: _categoryExpenseData.length,
                itemBuilder: (context, index) =>
                    _buildLegendItem(_categoryExpenseData[index]),
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _categoryExpenseData
                    .map((data) => _buildLegendItem(data))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(CategoryExpenseData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(color: data.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'R\$ ${data.amount.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction t) {
    final String formattedDate = '${t.date.day}/${t.date.month}/${t.date.year}';
    final isExpense = t.type == TransactionType.expense;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categoria + descrição
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.category,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // Valor
          Text(
            'R\$ ${t.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isExpense ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addTransaction(Transaction t) async {
    setState(() => _isLoading = true);
    try {
      await _txRepo.addTransaction(t);
      await _loadData(); // recarrega lista + gráficos
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Transação adicionada com sucesso!')));
      setState(() => _selectedIndex = 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Erro ao adicionar transação: $e')));
    }
  }
}
