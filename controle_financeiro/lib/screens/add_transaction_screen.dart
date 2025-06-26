import 'package:flutter/material.dart';
import 'package:controle_financeiro/models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final Function(String, double, DateTime, bool) addTransaction;
  final bool isIncome;

  const AddTransactionScreen(this.addTransaction, this.isIncome, {super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _valueController = TextEditingController();

  void _submitForm() {
    final title = _titleController.text;
    final value = double.tryParse(_valueController.text) ?? 0.0;

    if (title.isEmpty || value <= 0) return;

    // CORREÇÃO: Usar toUtc() diretamente mantendo todos os componentes do DateTime
    final utcDate = DateTime.now().toUtc(); // Isso é crucial para armazenamento correto

    widget.addTransaction(title, value, utcDate, widget.isIncome);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Descrição'),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _valueController,
            decoration: const InputDecoration(
              labelText: 'Valor (R\$)',
              prefixText: 'R\$ ',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isIncome ? Colors.green : Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Salvar ${widget.isIncome ? 'Entrada' : 'Saída'}',
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: _submitForm,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    super.dispose();
  }
}