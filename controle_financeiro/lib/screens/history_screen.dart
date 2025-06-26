import 'package:flutter/material.dart';
import 'package:controle_financeiro/models/transaction.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const HistoryScreen(this.transactions, {super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );
  List<Transaction> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _filterTransactions();
  }

  void _filterTransactions() {
    setState(() {
      final start = _dateRange.start.toUtc();
      final end = _dateRange.end.toUtc().add(const Duration(hours: 23, minutes: 59, seconds: 59));

      _filteredTransactions = widget.transactions.where((t) {
        final transactionDate = t.date.toUtc();
        return transactionDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
            transactionDate.isBefore(end.add(const Duration(seconds: 1)));
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }


  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _dateRange,
    );

    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
        _filterTransactions();
      });
    }
  }

  String _formatDateRange() {
    final startFormatted = DateFormat('dd/MM/yyyy').format(_dateRange.start);
    final endFormatted = DateFormat('dd/MM/yyyy').format(_dateRange.end);

    return startFormatted == endFormatted
        ? startFormatted
        : '$startFormatted - $endFormatted';
  }

  String _formatDateForRS(DateTime date) {
    final rsDate = date.toUtc().add(const Duration(hours: -3));
    return DateFormat('dd/MM/yyyy - HH:mm').format(rsDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Selecionar período',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F5F5), // Bege claro
              Color(0xFFE3F2FD), // Azul muito claro
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 20, color: Color(0xFF1976D2)),
                    const SizedBox(width: 8),
                    Text(
                      'Período: ${_formatDateRange()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _filteredTransactions.isEmpty
                  ? const Center(
                  child: Text('Nenhuma transação no período selecionado',
                      style: TextStyle(color: Color(0xFF666666))))
                  : ListView.builder(
                itemCount: _filteredTransactions.length,
                itemBuilder: (ctx, index) {
                  final tr = _filteredTransactions[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [

                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: tr.isIncome
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFEBEE),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                tr.isIncome
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: tr.isIncome
                                    ? const Color(0xFF388E3C)
                                    : const Color(0xFFD32F2F),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tr.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDateForRS(tr.date),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: 'pt_BR',
                                symbol: 'R\$',
                              ).format(tr.value),
                              style: TextStyle(
                                fontSize: 16,
                                color: tr.isIncome
                                    ? const Color(0xFF388E3C)
                                    : const Color(0xFFD32F2F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}