/// Tipo de una cuenta donde vive el dinero (columna `cuentas.tipo_cuenta`).
/// Es una lista fija: permite reglas por tipo (el efectivo nunca paga GMF).
class TipoCuenta {
  /// Cuenta de ahorros (débito).
  static const ahorros = 'A';

  /// Cuenta corriente.
  static const corriente = 'C';

  /// Cuenta digital o billetera (Nequi, Daviplata...).
  static const digital = 'D';

  /// Dinero en efectivo o sin cuenta definida.
  static const efectivo = 'E';

  /// Tarjeta de crédito: deuda con cupo, intereses y cuota de manejo.
  static const tarjetaCredito = 'T';

  /// Préstamo (libre inversión, vehículo, hipotecario): deuda con cuota fija.
  static const prestamo = 'P';

  static const valores = [
    ahorros,
    corriente,
    digital,
    efectivo,
    tarjetaCredito,
    prestamo,
  ];

  /// Tipos que se crean desde el formulario general de cuentas.
  static const deActivo = [ahorros, corriente, digital, efectivo];

  /// Cuentas que representan una deuda: su saldo negativo es lo que se debe.
  static bool esPasivo(String tipo) => tipo == tarjetaCredito || tipo == prestamo;

  TipoCuenta._();

  static bool esValido(String? valor) => valores.contains(valor);

  /// El GMF (4x1000) solo aplica a cuentas bancarias de depósito.
  static bool puedePagarGmf(String tipo) =>
      tipo == ahorros || tipo == corriente || tipo == digital;
}
