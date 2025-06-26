import 'package:flutter/material.dart';
import 'package:controle_financeiro/models/transaction.dart';
import 'package:controle_financeiro/screens/add_transaction_screen.dart';
import 'package:controle_financeiro/screens/history_screen.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Transaction> _transactions = [];
  bool _isLoading = false;

  double get _totalBalance {
    return _transactions.fold(
        0.0, (sum, t) => t.isIncome ? sum + t.value : sum - t.value);
  }

  @override
  void initState() {
    super.initState();
    _fetchTransactionsFromServer();
  }

  Future<void> _fetchTransactionsFromServer() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final List<Transaction> loadedTransactions = data.map((item) {
          return Transaction(
            id: item['id'].toString(),
            title: item['title'],
            value: double.parse(item['valor'].toString()),
            date: DateTime.parse(item['data']),
            isIncome: item['isIncome'] == true,
          );
        }).toList();

        setState(() {
          _transactions.clear();
          _transactions.addAll(loadedTransactions);
        });

        debugPrint('Transações carregadas do servidor (${_transactions.length})');
      } else {
        debugPrint('Erro ao carregar dados: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(' Erro de conexão: $e');
    }
  }

  Future<void> _addTransaction(
      String title, double value, DateTime date, bool isIncome) async {
    final newTransaction = Transaction(
      id: date.millisecondsSinceEpoch.toString(),
      title: title,
      value: value,
      date: date,
      isIncome: isIncome,
    );

    debugPrint('Tentando salvar transação no servidor: $title - R\$ $value');

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .post(
        Uri.parse('http://10.0.2.2:3000/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'value': value,
          'date': date.toIso8601String(),
          'isIncome': isIncome,
        }),
      )
          .timeout(const Duration(seconds: 10));

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        debugPrint('Transação salva com sucesso! Resposta: ${response.body}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${responseData['message']}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        setState(() {
          _transactions.add(newTransaction);
          _isLoading = false;
        });
      } else {
        debugPrint(
            ' Erro no servidor: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(' Erro: ${responseData['message'] ?? 'Falha no servidor'}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(' Erro de conexão: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(' Falha na conexão: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startAddNewTransaction(BuildContext ctx, bool isIncome) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: AddTransactionScreen(_addTransaction, isIncome),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Finança Pessoal', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1976D2),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(_transactions),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF5F5F5),
                  Color(0xFFE3F2FD),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Column(
                    children: [
                      Text(
                        'Saldo Atual',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                              .format(_totalBalance),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: _totalBalance >= 0
                                ? const Color(0xFF388E3C)
                                : const Color(0xFFD32F2F),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Entrada',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF388E3C),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () => _startAddNewTransaction(context, true),
                      ),
                      const SizedBox(width: 25),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        label: const Text('Saída',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () => _startAddNewTransaction(context, false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
