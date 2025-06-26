import 'package:intl/intl.dart';

class Transaction {
  final String id;
  final String title;
  final double value;
  final DateTime date;
  final bool isIncome;

  Transaction({
    required this.id,
    required this.title,
    required this.value,
    required this.date,
    required this.isIncome,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      value: map['value'],
      date: DateTime.parse(map['date']).toUtc(),
      isIncome: map['isIncome'],
    );
  }

  // Método CORRIGIDO para exibição no fuso do RS (GMT-3)
  String get formattedLocalDate {
    // Converte UTC para horário local do dispositivo
    final localDate = date.toLocal();


    final gmtOffset = localDate.timeZoneOffset;
    final rsOffset = const Duration(hours: -3);
    final adjustment = gmtOffset + rsOffset;
    final rsDate = localDate.add(adjustment);

    return DateFormat('dd/MM/yyyy - HH:mm', 'pt_BR').format(rsDate);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'value': value,
      'date': date.toIso8601String(),
      'isIncome': isIncome,
    };
  }
}