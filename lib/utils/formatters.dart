import 'package:flutter_money_formatter/flutter_money_formatter.dart';

String formatCurrency(num value) {
  final FlutterMoneyFormatter fmf = FlutterMoneyFormatter(amount: value.toDouble());
  print(fmf.output.symbolOnLeft);
  return fmf.output.symbolOnLeft;
}
