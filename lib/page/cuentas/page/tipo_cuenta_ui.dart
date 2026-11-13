import 'package:flutter/material.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';

/// Ícono y nombre visible de cada tipo de cuenta.
class TipoCuentaUi {
  TipoCuentaUi._();

  static IconData icono(String tipo) => switch (tipo) {
        TipoCuenta.ahorros => Icons.savings_rounded,
        TipoCuenta.corriente => Icons.account_balance_rounded,
        TipoCuenta.digital => Icons.phone_iphone_rounded,
        TipoCuenta.tarjetaCredito => Icons.credit_card_rounded,
        TipoCuenta.prestamo => Icons.request_quote_rounded,
        _ => Icons.payments_rounded,
      };

  static String nombre(BuildContext context, String tipo) =>
      FFLocalizations.of(context).getText('cta_tipo_$tipo');
}
