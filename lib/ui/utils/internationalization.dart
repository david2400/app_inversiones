import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleStorageKey = '__locale_key__';

class FFLocalizations {
  FFLocalizations(this.locale);

  final Locale locale;

  static FFLocalizations of(BuildContext context) =>
      Localizations.of<FFLocalizations>(context, FFLocalizations)!;

  static List<String> languages() => ['en', 'es', 'de', 'ar'];

  static late SharedPreferences _prefs;
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static Future storeLocale(String locale) =>
      _prefs.setString(_kLocaleStorageKey, locale);
  static Locale? getStoredLocale() {
    final locale = _prefs.getString(_kLocaleStorageKey);
    return locale != null && locale.isNotEmpty ? createLocale(locale) : null;
  }

  String get languageCode => locale.toString();
  String? get languageShortCode =>
      _languagesWithShortCode.contains(locale.toString())
          ? '${locale.toString()}_short'
          : null;
  int get languageIndex => languages().contains(languageCode)
      ? languages().indexOf(languageCode)
      : 0;

  String getText(String key) =>
      (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';

  String getVariableText({
    String? enText = '',
    String? esText = '',
    String? deText = '',
    String? arText = '',
  }) =>
      [enText, esText, deText, arText][languageIndex] ?? '';

  static const Set<String> _languagesWithShortCode = {
    'ar',
    'az',
    'ca',
    'cs',
    'da',
    'de',
    'dv',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'gr',
    'he',
    'hi',
    'hu',
    'it',
    'km',
    'ku',
    'mn',
    'ms',
    'no',
    'pt',
    'ro',
    'ru',
    'rw',
    'sv',
    'th',
    'uk',
    'vi',
  };
}

class FFLocalizationsDelegate extends LocalizationsDelegate<FFLocalizations> {
  const FFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    final language = locale.toString();
    return FFLocalizations.languages().contains(
      language.endsWith('_')
          ? language.substring(0, language.length - 1)
          : language,
    );
  }

  @override
  Future<FFLocalizations> load(Locale locale) =>
      SynchronousFuture<FFLocalizations>(FFLocalizations(locale));

  @override
  bool shouldReload(FFLocalizationsDelegate old) => false;
}

Locale createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

final kTranslationsMap = <Map<String, Map<String, String>>>[
  // General
  {
    'o07j3ttv': {
      'en': 'Nombre',
      'ar': 'البدء',
      'de': 'Loslegen',
      'es': 'Nombre',
    },
    'o08j3ttv': {
      'en': 'Descripcion',
      'ar': 'البدء',
      'de': 'Loslegen',
      'es': 'Descripcion',
    },
    'o09j3ttv': {
      'en': 'Acciones',
      'ar': 'البدء',
      'de': 'Loslegen',
      'es': 'Acciones',
    },
    'o10j3ttv': {
      'en': 'Dias',
      'ar': 'Dias',
      'de': 'Dias',
      'es': 'Dias',
    },
    'o11j3ttv': {
      'en': 'Meses',
      'ar': 'Meses',
      'de': 'Meses',
      'es': 'Meses',
    },
    'o12j3ttv': {
      'en': 'Años',
      'ar': 'Años',
      'de': 'Años',
      'es': 'Años',
    },
  },
  // login
  {
    'o07j3mgv': {
      'en': 'Welcome back',
      'ar': 'البدء',
      'de': 'Loslegen',
      'es': 'Empezar',
    },
    'fzxvw3mu': {
      'en': 'Login to access your account below.',
      'ar': 'قم بإنشاء حسابك أدناه.',
      'de': 'Erstellen Sie unten Ihr Konto.',
      'es': 'Crea tu cuenta a continuación.',
    },
    'a9j78va9': {
      'en': 'Email Address',
      'ar': 'عنوان البريد الالكترونى',
      'de': 'E-Mail-Addresse',
      'es': 'Dirección de correo electrónico',
    },
    'i7f18cve': {
      'en': 'Enter your email...',
      'ar': 'أدخل بريدك الإلكتروني ...',
      'de': 'Geben sie ihre E-Mail Adresse ein...',
      'es': 'Introduce tu correo electrónico...',
    },
    'wztjmbn8': {
      'en': 'Password',
      'ar': 'كلمة المرور',
      'de': 'Passwort',
      'es': 'Contraseña',
    },
    'lw1jpm1f': {
      'en': 'Enter your password...',
      'ar': 'ادخل رقمك السري...',
      'de': 'Geben Sie Ihr Passwort ein...',
      'es': 'Ingresa tu contraseña...',
    },
    'm2xyjvuf': {
      'en': 'Forgot Password?',
      'ar': 'هل نسيت كلمة السر؟',
      'de': 'Passwort vergessen?',
      'es': '¿Has olvidado tu contraseña?',
    },
    'qbmoi1av': {
      'en': 'Login',
      'ar': 'تسجيل الدخول',
      'de': 'Anmeldung',
      'es': 'Acceso',
    },
    'cjqb8ial': {
      'en': 'Don\'t have an account?',
      'ar': 'ليس لديك حساب؟',
      'de': 'Sie haben kein Konto?',
      'es': '¿No tienes una cuenta?',
    },
    'a0iimirx': {
      'en': 'Create',
      'ar': 'ليس لديك حساب؟',
      'de': 'Sie haben kein Konto?',
      'es': '¿No tienes una cuenta?',
    },
    '1zqiw31h': {
      'en': 'Continue as Guest',
      'ar': 'تواصل كضيف',
      'de': 'Als Gast fortfahren',
      'es': 'Continua como invitado',
    },
    '2bb3vct7': {
      'en': 'Home',
      'ar': 'مسكن',
      'de': 'Heim',
      'es': 'Casa',
    },
  },
  // register_account
  {
    'gpokmd81': {
      'en': 'Get Started',
      'ar': 'البدء',
      'de': 'Loslegen',
      'es': 'Empezar',
    },
    'oitrrwgg': {
      'en': 'Create your account below.',
      'ar': 'قم بإنشاء حسابك أدناه.',
      'de': 'Erstellen Sie unten Ihr Konto.',
      'es': 'Crea tu cuenta a continuación.',
    },
    'gcwdqm4g': {
      'en': 'Email Address',
      'ar': 'عنوان البريد الالكترونى',
      'de': 'E-Mail-Addresse',
      'es': 'Dirección de correo electrónico',
    },
    'iam0xgwx': {
      'en': 'Enter your email...',
      'ar': 'أدخل بريدك الإلكتروني ...',
      'de': 'Geben sie ihre E-Mail Adresse ein...',
      'es': 'Introduce tu correo electrónico...',
    },
    'bqv15dcf': {
      'en': 'Password',
      'ar': 'كلمة المرور',
      'de': 'Passwort',
      'es': 'Contraseña',
    },
    'joih97mn': {
      'en': 'Enter your password...',
      'ar': 'ادخل رقمك السري...',
      'de': 'Geben Sie Ihr Passwort ein...',
      'es': 'Ingresa tu contraseña...',
    },
    'rzpiwq9p': {
      'en': 'Confirm Password',
      'ar': 'تأكيد كلمة المرور',
      'de': 'Kennwort bestätigen',
      'es': 'Confirmar contraseña',
    },
    'eyfkffka': {
      'en': 'Enter your password...',
      'ar': 'ادخل رقمك السري...',
      'de': 'Geben Sie Ihr Passwort ein...',
      'es': 'Ingresa tu contraseña...',
    },
    '5kmjfwsk': {
      'en': 'Create Account',
      'ar': 'إنشاء حساب',
      'de': 'Benutzerkonto erstellen',
      'es': 'Crear una cuenta',
    },
    '3twynvfz': {
      'en': 'Login',
      'ar': 'هل لديك حساب؟',
      'de': 'Sie haben bereits ein Konto?',
      'es': '¿Ya tienes una cuenta?',
    },
    '9ssznj0g': {
      'en': 'Already have an account?',
      'ar': 'هل لديك حساب؟',
      'de': 'Sie haben bereits ein Konto?',
      'es': '¿Ya tienes una cuenta?',
    },
    '3ugmx2zp': {
      'en': 'Continue as Guest',
      'ar': 'تواصل كضيف',
      'de': 'Als Gast fortfahren',
      'es': 'Continua como invitado',
    },
    'momge5oj': {
      'en': 'Home',
      'ar': 'مسكن',
      'de': 'Heim',
      'es': 'Casa',
    },
  },
  //Admin Portafolio
  {
    'aptpkmd01': {
      'en': 'Renta Fija',
      'ar': 'Renta Fija',
      'de': 'Renta Fija',
      'es': 'Renta Fija',
    },
    'bpy92db5':{
      'en': 'Tipo de Cuenta',
      'ar': 'Tipo de Cuenta',
      'de': 'Tipo de Cuenta',
      'es': 'Tipo de Cuenta',
    },
    'aptpkmd02': {
      'en': 'Renta Variable',
      'ar': 'Renta Variable',
      'de': 'Renta Variable',
      'es': 'Renta Variable',
    },
    'xnadgj3u': {
      'en': 'Nombre de portafolio',
      'ar': 'مرحبا،',
      'de': 'Herzlich willkommen,',
      'es': 'Bienvenidos,',
    },
    'xnadgj5u': {
      'en': 'Numero de cuenta',
      'ar': 'مرحبا،',
      'de': 'Herzlich willkommen,',
      'es': 'Numero de cuenta',
    },
    'xnadgj6u': {
      'en': 'Portafolio',
      'ar': 'مرحبا،',
      'de': 'Herzlich willkommen,',
      'es': 'Portafolio',
    },
    'xnadgj7u': {
      'en': 'Tipo Portafolio',
      'ar': 'Tipo Portafolio',
      'de': 'Tipo Portafolio',
      'es': 'Tipo Portafolio',
    },
    'xnadgj8u': {
      'en': 'Cuenta excenta del 4x1000?',
      'ar': 'Cuenta excenta del 4x1000?',
      'de': 'Cuenta excenta del 4x1000?',
      'es': 'Cuenta excenta del 4x1000?',
    },
  },
  //Admin Frecuencia pago
  {
    'afdpkmd01': {
      'en': 'Frecuencia Pago',
      'ar': 'Frecuencia Pago',
      'de': 'Frecuencia Pago',
      'es': 'Frecuencia Pago',
    },
    'afdpkmd02': {
      'en': 'Tiempo',
      'ar': 'Tiempo',
      'de': 'Tiempo',
      'es': 'Tiempo',
    },
    'afdpkmd03': {
      'en': 'Formato',
      'ar': 'Formato',
      'de': 'Formato',
      'es': 'Formato',
    },
  },
  //Admin Motivos
  {
    'mtokmd01': {
      'en': 'Agregar motivo',
      'ar': 'Agregar motivo',
      'de': 'Agregar motivo',
      'es': 'Agregar motivo',
    },
  },
  //Frecuencia pago
  {
    'fdpokmd01': {
      'en': 'Agregar frecuencia pago',
      'ar': 'Agregar frecuencia pago',
      'de': 'Agregar frecuencia pago',
      'es': 'Agregar frecuencia pago',
    },
  },
  // Admin Tipo Transaccion
  {
    'tdtge1oj': {
      'en': 'Ingreso',
      'ar': 'Ingreso',
      'de': 'Ingreso',
      'es': 'Ingreso',
    },
    'tdtge2oj': {
      'en': 'Egreso',
      'ar': 'Egreso',
      'de': 'Egreso',
      'es': 'Egreso',
    },
    'tdtge3oj': {
      'en': 'Movimiento',
      'ar': 'Movimiento',
      'de': 'Movimiento',
      'es': 'Movimiento',
    },

    'tdtge5oj': {
      'en': 'Tipo de transferencia',
      'ar': 'Tipo de transferencia',
      'de': 'Tipo de transferencia',
      'es': 'Tipo de transferencia',
    },
    'tdtge6oj': {
      'en': 'Tipo de fuente',
      'ar': 'Tipo de fuente',
      'de': 'Tipo de fuente',
      'es': 'Tipo de fuente',
    },
    'tdtge7oj': {
      'en': 'Cuenta destino',
      'ar': 'Cuenta destino',
      'de': 'Cuenta destino',
      'es': 'Cuenta destino',
    },
    'tdtge8oj': {
      'en': 'Cuenta externa?',
      'ar': 'Cuenta externa?',
      'de': 'Cuenta externa?',
      'es': 'Cuenta externa?',
    },
  },

  // complete_profile
  {
    'yhcaf7r2': {
      'en': 'Complete Profile',
      'ar': 'الملف الشخصي الكامل',
      'de': 'Vollständiges Profil',
      'es': 'Perfil completo',
    },
    'r6npjsue': {
      'en': 'Upload a photo for us to easily identify you.',
      'ar': 'قم بتحميل صورة لنا للتعرف عليك بسهولة.',
      'de':
          'Laden Sie ein Foto hoch, damit wir Sie leicht identifizieren können.',
      'es': 'Sube una foto para que te identifiquemos fácilmente.',
    },
    'sdptn7dd': {
      'en': 'Your Name',
      'ar': 'اسمك',
      'de': 'Dein Name',
      'es': 'Tu nombre',
    },
    'n636qnrx': {
      'en': 'Your Age',
      'ar': 'عمرك',
      'de': 'Ihr Alter',
      'es': 'Su edad',
    },
    's7yvjzbs': {
      'en': 'i.e. 34',
      'ar': 'أي 34',
      'de': 'dh 34',
      'es': 'es decir, 34',
    },
    '72ii0waq': {
      'en': 'Your Title',
      'ar': 'لقبك',
      'de': 'Dein Titel',
      'es': 'Tu título',
    },
    'pf8glhkg': {
      'en': 'What is your position?',
      'ar': 'ماهوموقعك؟',
      'de': 'Wo befinden Sie sich?',
      'es': '¿Cual es tu posicion?',
    },
    'hbhd3bdt': {
      'en': 'Complete Profile',
      'ar': 'الملف الشخصي الكامل',
      'de': 'Vollständiges Profil',
      'es': 'Perfil completo',
    },
    'w75dikic': {
      'en': 'Skip for Now',
      'ar': 'تخطي في الوقت الراهن',
      'de': 'Für jetzt überspringen',
      'es': 'Saltar por ahora',
    },
    '1eac148w': {
      'en': 'Field is required',
      'ar': '',
      'de': '',
      'es': '',
    },
    'ew7dbn3s': {
      'en': 'Field is required',
      'ar': '',
      'de': '',
      'es': '',
    },
    'jhhlgzk5': {
      'en': 'Field is required',
      'ar': '',
      'de': '',
      'es': '',
    },
    '4k3jnl38': {
      'en': 'Home',
      'ar': 'مسكن',
      'de': 'Heim',
      'es': 'Casa',
    },
  },
  // forgotPassword
  {
    'g416xg9f': {
      'en': 'Forgot Password',
      'ar': 'هل نسيت كلمة السر',
      'de': 'Passwort vergessen',
      'es': 'Has olvidado tu contraseña',
    },
    'xaiad71o': {
      'en':
          'Enter the email associated with your account and we will send you a verification code.',
      'ar': 'أدخل البريد الإلكتروني المرتبط بحسابك وسنرسل لك رمز التحقق.',
      'de':
          'Geben Sie die mit Ihrem Konto verknüpfte E-Mail-Adresse ein und wir senden Ihnen einen Bestätigungscode.',
      'es':
          'Introduce el correo electrónico asociado a tu cuenta y te enviaremos un código de verificación.',
    },
    'u4nuk910': {
      'en': 'Email Address',
      'ar': 'عنوان البريد الالكترونى',
      'de': 'E-Mail-Addresse',
      'es': 'Dirección de correo electrónico',
    },
    '37kotxi0': {
      'en': 'Enter your email...',
      'ar': 'أدخل بريدك الإلكتروني ...',
      'de': 'Geben sie ihre E-Mail Adresse ein...',
      'es': 'Introduce tu correo electrónico...',
    },
    'hiwpaze1': {
      'en': 'Send Reset Link',
      'ar': 'أرسل رابط إعادة التعيين',
      'de': 'Zurücksetzen-Link senden',
      'es': 'Enviar enlace de reinicio',
    },
    '598b8d3m': {
      'en': 'Home',
      'ar': 'مسكن',
      'de': 'Heim',
      'es': 'Casa',
    },
  },
  // onboarding
  {
    'i8hl2uua': {
      'en': 'Create Budgets',
      'ar': 'إنشاء الميزانيات',
      'de': 'Erstellen Sie Budgets',
      'es': 'Crear presupuestos',
    },
    'hxtwax0y': {
      'en':
          'Create budgets that you can tie transactions too in order for easy tracking.',
      'ar':
          'قم بإنشاء ميزانيات يمكنك ربط المعاملات بها أيضًا من أجل التتبع السهل.',
      'de':
          'Erstellen Sie Budgets, mit denen Sie auch Transaktionen verknüpfen können, um sie einfach nachverfolgen zu können.',
      'es':
          'Cree presupuestos en los que también pueda vincular transacciones para facilitar el seguimiento.',
    },
    'mjy3ljln': {
      'en': 'Keep Track of Spending',
      'ar': 'تتبع الإنفاق',
      'de': 'Behalten Sie die Ausgaben im Auge',
      'es': 'Mantenga un registro de los gastos',
    },
    'uf9k1spp': {
      'en':
          'Easily add transactions and associate them with budgets that have been created.',
      'ar': 'أضف المعاملات بسهولة وربطها بالميزانيات التي تم إنشاؤها.',
      'de':
          'Fügen Sie ganz einfach Transaktionen hinzu und verknüpfen Sie sie mit erstellten Budgets.',
      'es':
          'Agregue fácilmente transacciones y asócielas con los presupuestos que se han creado.',
    },
    '9c4outzf': {
      'en': 'Budget Analysis',
      'ar': 'تحليل الميزانية',
      'de': 'Budgetanalyse',
      'es': 'Análisis de presupuesto',
    },
    'q30ina4f': {
      'en': 'Know where your budgets are and how they can be adjusted.',
      'ar': 'تعرف على مكان ميزانياتك وكيف يمكن تعديلها.',
      'de': 'Wissen, wo Ihre Budgets sind und wie sie angepasst werden können.',
      'es': 'Sepa dónde están sus presupuestos y cómo se pueden ajustar.',
    },
    'ypt7b97g': {
      'en': 'Create Your Budget',
      'ar': 'إنشاء ميزانيتك',
      'de': 'Erstellen Sie Ihr Budget',
      'es': 'Crea tu presupuesto',
    },
    'oo0kk9qe': {
      'en': 'Home',
      'ar': 'مسكن',
      'de': 'Heim',
      'es': 'Casa',
    },
  },
  // portafolioPage
  {
    'j12wmzzj': {
      'en': 'Nombre del portafolio',
      'ar': 'بطاقتي',
      'de': 'Meine Karte',
      'es': 'Nombre del portafolio',
    },
    'xn2so8km': {
      'en': 'Portafolios',
      'ar': 'بطاقتي',
      'de': 'Meine Karte',
      'es': 'Mi tarjeta',
    },
    '6t7n9ugd': {
      'en': 'Balance',
      'ar': 'الرصيد',
      'de': 'Gleichgewicht',
      'es': 'Equilibrio',
    },
    'h3086ma4': {
      'en': '\$7,630',
      'ar': '7630 دولارًا',
      'de': '\$7.630',
      'es': '\$7,630',
    },
    'lr97k2rc': {
      'en': '**** 0149',
      'ar': '**** 0149',
      'de': '**** 0149',
      'es': '**** 0149',
    },
    'l9racj60': {
      'en': '05/25',
      'ar': '05/25',
      'de': '25.05',
      'es': '25/05',
    },
    '9b0j67se': {
      'en': 'Income',
      'ar': 'دخل',
      'de': 'Einkommen',
      'es': 'Ingreso',
    },
    'axrvkhrv': {
      'en': '+\$12,402',
      'ar': '+ 12402 دولار',
      'de': '+12.402 \$',
      'es': '+\$12,402',
    },
    '0d7w9e0i': {
      'en': '4.5% ',
      'ar': '4.5٪',
      'de': '4,5 %',
      'es': '4,5%',
    },
    'mggh8wu7': {
      'en': 'Spending',
      'ar': 'الإنفاق',
      'de': 'Ausgaben',
      'es': 'Gasto',
    },
    'c5bszisf': {
      'en': '-\$8,392',
      'ar': '- 8،392 دولارًا',
      'de': '-8.392 \$',
      'es': '-\$8,392',
    },
    '85pb8msl': {
      'en': '4.5% ',
      'ar': '4.5٪',
      'de': '4,5 %',
      'es': '4,5%',
    },
    'yet7zk5d': {
      'en': 'Quick Service',
      'ar': 'خدمة سريعة',
      'de': 'Schneller Service',
      'es': 'Servicio rapido',
    },
    '8bnd6lco': {
      'en': 'Transfer',
      'ar': 'تحويل',
      'de': 'Transfer',
      'es': 'Transferir',
    },
    'roobc02h': {
      'en': 'Activity',
      'ar': 'بطاقة وقفة',
      'de': 'Pausenkarte',
      'es': 'Tarjeta de pausa',
    },
    '27pb7ji4': {
      'en': 'Transaction',
      'ar': 'عملية',
      'de': 'Transaktion',
      'es': 'Transacción',
    },
    'xs4cn7uk': {
      'en': 'Income',
      'ar': 'دخل',
      'de': 'Einkommen',
      'es': 'Ingreso',
    },
    'm8rhanhc': {
      'en': '•',
      'ar': '•',
      'de': '•',
      'es': '•',
    },
  },
  // transactions
  {
    'cd0zp71n': {
      'en': 'Transactions',
      'ar': 'ميزانيتي',
      'de': 'Mein Budget',
      'es': 'Mi presupuesto',
    },
    'hfwbiivj': {
      'en': 'Income',
      'ar': 'دخل',
      'de': 'Einkommen',
      'es': 'Ingreso',
    },
    'jjj3ydb1': {
      'en': 'Detalle de transaccion',
      'ar': 'Detalle de transaccion',
      'de': 'Detalle de transaccion',
      'es': 'Detalle de transaccion',
    },
    'ns4vt604': {
      'en': '4.5% ',
      'ar': '4.5٪',
      'de': '4,5 %',
      'es': '4,5%',
    },
    'wcsc04wg': {
      'en': 'Spending',
      'ar': 'الإنفاق',
      'de': 'Ausgaben',
      'es': 'Gasto',
    },
    'a5zzlh8f': {
      'en': '-\$8,392',
      'ar': '- 8،392 دولارًا',
      'de': '-8.392 \$',
      'es': '-\$8,392',
    },
    '8xnbsdnb': {
      'en': '4.5% ',
      'ar': '4.5٪',
      'de': '4,5 %',
      'es': '4,5%',
    },
    'c81i1ybg': {
      'en': 'Total Spent',
      'ar': 'إجمال الصرف',
      'de': 'Gesamtausgaben',
      'es': 'Total gastado',
    },
    'ah4t7cpx': {
      'en': 'Advertising Budget',
      'ar': 'ميزانية الإعلان',
      'de': 'Werbebudget',
      'es': 'Presupuesto publicitario',
    },
    '0tsohlub': {
      'en': '\$3,000',
      'ar': '3000 دولار',
      'de': '3.000 \$',
      'es': '\$3,000',
    },
    '5y1u9kxg': {
      'en': '4 Days Left',
      'ar': 'باقي 4 ايام',
      'de': 'noch 4 Tage',
      'es': '4 días restantes',
    },
    '4jknsif6': {
      'en': 'Total Spent',
      'ar': 'إجمال الصرف',
      'de': 'Gesamtausgaben',
      'es': 'Total gastado',
    },
    'o9rmbnd7': {
      'en': '\$2,502',
      'ar': '2،502 دولار',
      'de': '2.502 \$',
      'es': '\$2,502',
    },
    'fn6kvat8': {
      'en': 'Advertising Budget',
      'ar': 'ميزانية الإعلان',
      'de': 'Werbebudget',
      'es': 'Presupuesto publicitario',
    },
    '6uht91yb': {
      'en': '\$3,000',
      'ar': '3000 دولار',
      'de': '3.000 \$',
      'es': '\$3,000',
    },
    '1qm6rhod': {
      'en': '4 Days Left',
      'ar': 'باقي 4 ايام',
      'de': 'noch 4 Tage',
      'es': '4 días restantes',
    },
    '65tvvjcw': {
      'en': 'Total Spent',
      'ar': 'إجمال الصرف',
      'de': 'Gesamtausgaben',
      'es': 'Total gastado',
    },
    'c03678eq': {
      'en': '\$2,502',
      'ar': '2،502 دولار',
      'de': '2.502 \$',
      'es': '\$2,502',
    },
    'ofz2zvlc': {
      'en': '•',
      'ar': '•',
      'de': '•',
      'es': '•',
    },
  },
  // paymentDetailsPage
  {
    'j0yzgf4n': {
      'en': 'Details',
      'ar': 'تفاصيل',
      'de': 'Einzelheiten',
      'es': 'Detalles',
    },
    'zv72ekdw': {
      'en': 'Amount',
      'ar': 'مقدار',
      'de': 'Höhe',
      'es': 'Monto',
    },
    '0rjyjwed': {
      'en': 'Vendor',
      'ar': 'بائع',
      'de': 'Verkäufer',
      'es': 'Vendedor',
    },
    'eeyn6dk2': {
      'en': 'When',
      'ar': 'متى',
      'de': 'Wann',
      'es': 'Cuándo',
    },
    'lccxx6eu': {
      'en': 'Reason',
      'ar': 'سبب',
      'de': 'Grund',
      'es': 'Razón',
    },
    'jzyax4hn': {
      'en': 'Spent by',
      'ar': 'أنفقه',
      'de': 'Verbracht von',
      'es': 'gastado por',
    },
    'i4r9jqwn': {
      'en': 'Home',
      'ar': 'مسكن',
      'de': 'Heim',
      'es': 'Casa',
    },
  },
  // MY_profilePage
  {
    'f1bvbey3': {
      'en': 'My Account',
      'ar': 'حسابي',
      'de': 'Mein Konto',
      'es': 'Mi cuenta',
    },
    'i61y9ibx': {
      'en': 'Edit Profile',
      'ar': 'تعديل الملف الشخصي',
      'de': 'Profil bearbeiten',
      'es': 'Editar perfil',
    },
    '03k0vw86': {
      'en': 'Change Password',
      'ar': 'تغيير كلمة المرور',
      'de': 'Kennwort ändern',
      'es': 'Cambia la contraseña',
    },
    '6w6wv95p': {
      'en': 'Notification Settings',
      'ar': 'إعدادات الإشعار',
      'de': 'Benachrichtigungseinstellungen',
      'es': 'Configuración de las notificaciones',
    },
    '9aogde79': {
      'en': 'Tutorial',
      'ar': 'درس تعليمي',
      'de': 'Lernprogramm',
      'es': 'Tutorial',
    },
    'eojlfs66': {
      'en': 'Privacy Policy',
      'ar': 'سياسة الخصوصية',
      'de': 'Datenschutz-Bestimmungen',
      'es': 'Política de privacidad',
    },
    '2ll42t1u': {
      'en': 'Dark Mode',
      'ar': '',
      'de': '',
      'es': '',
    },
    '8d386226': {
      'en': 'Light Mode',
      'ar': '',
      'de': '',
      'es': '',
    },
    '8srr2k0j': {
      'en': '•',
      'ar': '•',
      'de': '•',
      'es': '•',
    },
  },
  // portafolioActiviyPage
  {
    'p0gf1lfy': {
      'en': 'Per Month',
      'ar': 'كل شهر',
      'de': 'Pro Monat',
      'es': 'Por mes',
    },
    'ti7ipegi': {
      'en': 'Total Spent',
      'ar': 'إجمال الصرف',
      'de': 'Gesamtausgaben',
      'es': 'Total gastado',
    },
    'ifi6fmsa': {
      'en': 'Transactions',
      'ar': 'المعاملات',
      'de': 'Transaktionen',
      'es': 'Actas',
    },
    'ak9m8szp': {
      'en': 'Income',
      'ar': 'دخل',
      'de': 'Einkommen',
      'es': 'Ingreso',
    },
    'l53kroui': {
      'en': 'Home',
      'ar': 'مسكن',
      'de': 'Heim',
      'es': 'Casa',
    },
  },
  // transferComplete
  {
    'xf8d4sm8': {
      'en': 'Transfer Complete',
      'ar': 'نقل كامل',
      'de': 'Übertragung vollständig',
      'es': 'transferencia completa',
    },
    'iq9jjji8': {
      'en':
          'Great work, you successfully transferred funds. It may take a few days for the funds to leave your account.',
      'ar':
          'عمل رائع ، لقد قمت بتحويل الأموال بنجاح. قد يستغرق خروج الأموال من حسابك بضعة أيام.',
      'de':
          'Großartige Arbeit, Sie haben erfolgreich Geld überwiesen. Es kann einige Tage dauern, bis das Geld von Ihrem Konto abgebucht wird.',
      'es':
          'Buen trabajo, transfirió fondos con éxito. Los fondos pueden tardar unos días en salir de su cuenta.',
    },
    'wrbg19ed': {
      'en': 'Okay',
      'ar': 'تمام',
      'de': 'Okay',
      'es': 'Okey',
    },
    'ndkybnrt': {
      'en': 'Home',
      'ar': 'مسكن',
      'de': 'Heim',
      'es': 'Casa',
    },
  },
  // addTransferFunds
  {
    'pe3o18oh': {
      'en': 'Tranferencia',
      'ar': 'تحويل الأموال',
      'de': 'Geld überweisen',
      'es': 'Transferir fondos',
    },
    '3ct4fj7p': {
      'en': 'Change Account',
      'ar': 'تغير الحساب',
      'de': 'Account wechseln',
      'es': 'Cambiar cuenta',
    },
    'r89hyhq3': {
      'en': 'Valor',
      'ar': 'Valor',
      'de': 'Valor',
      'es': 'Valor',
    },
    'ux9p5ab7': {
      'en': 'Internal Transfer',
      'ar': 'التحويل الداخلي',
      'de': 'Interner Transfer',
      'es': 'Transferencia interna',
    },
    'fbqc8gr5': {
      'en': 'External Transfer',
      'ar': 'التحويل الخارجي',
      'de': 'Externe Übertragung',
      'es': 'Transferencia externa',
    },
    '8qva4e69': {
      'en': 'ACH Payment',
      'ar': 'دفع ACH',
      'de': 'ACH-Zahlung',
      'es': 'Pago CCA',
    },
    '147fye16': {
      'en': 'Tipo de transferencia',
      'ar': '',
      'de': '',
      'es': 'Tipo de transferencia',
    },
    'unxwswr8': {
      'en': 'Internal Transfer',
      'ar': 'التحويل الداخلي',
      'de': 'Interner Transfer',
      'es': 'Transferencia interna',
    },
    'j3bxwj3a': {
      'en': 'External Transfer',
      'ar': 'التحويل الخارجي',
      'de': 'Externe Übertragung',
      'es': 'Transferencia externa',
    },
    'ni4dtp8k': {
      'en': 'ACH Payment',
      'ar': 'دفع ACH',
      'de': 'ACH-Zahlung',
      'es': 'Pago CCA',
    },
    'tcckgjcg': {
      'en': 'Motivo',
      'ar': '',
      'de': '',
      'es': '',
    },
    'w4smsh2i': {
      'en': 'Internal Transfer',
      'ar': 'التحويل الداخلي',
      'de': 'Interner Transfer',
      'es': 'Transferencia interna',
    },
    '6uxty3hy': {
      'en': 'External Transfer',
      'ar': 'التحويل الخارجي',
      'de': 'Externe Übertragung',
      'es': 'Transferencia externa',
    },
    'p4ngma0d': {
      'en': 'ACH Payment',
      'ar': 'دفع ACH',
      'de': 'ACH-Zahlung',
      'es': 'Pago CCA',
    },
    'uxo87fjc': {
      'en': 'Cuenta',
      'ar': '',
      'de': '',
      'es': '',
    },
    'uxo88fjc': {
      'en': 'Cuenta Alterna',
      'ar': '',
      'de': '',
      'es': '',
    },
    '4g3izkns': {
      'en': '\$ Amount',
      'ar': 'المبلغ بالدولار',
      'de': '\$ Betrag',
      'es': '\$ Monto',
    },

    'wngoi0v4': {
      'en': 'Your new account balance is:',
      'ar': 'رصيد حسابك الجديد هو:',
      'de': 'Ihr neuer Kontostand beträgt:',
      'es': 'El nuevo saldo de su cuenta es:',
    },
    'g6bfec2g': {
      'en': '\$7,630',
      'ar': '7630 دولارًا',
      'de': '\$7.630',
      'es': '\$7,630',
    },
    '40bws0gz': {
      'en': 'Amount',
      'ar': 'مقدار',
      'de': 'Höhe',
      'es': 'Monto',
    },
    'xaw2jdst': {
      'en': 'Send Transfer',
      'ar': 'أرسل حوالة',
      'de': 'Überweisung senden',
      'es': 'Enviar transferencia',
    },
    'xku4zxbe': {
      'en': 'Tap above to complete transfer',
      'ar': 'اضغط أعلاه لإكمال النقل',
      'de': 'Tippen Sie oben, um die Übertragung abzuschließen',
      'es': 'Toque arriba para completar la transferencia',
    },
    'imaejg7x': {
      'en': 'Home',
      'ar': 'مسكن',
      'de': 'Heim',
      'es': 'Home',
    },
  },
  // Tipo de proyecto
  {
    'wv1862lo': {
      'en': 'Create',
      'ar': 'طلب التمويل',
      'de': 'Geld anfordern',
      'es': 'Crear',
    },
    'xvj3fan8': {
      'en': '\$ Amount',
      'ar': 'المبلغ بالدولار',
      'de': '\$ Betrag',
      'es': '\$ Monto',
    },
    'wwjahvpl': {
      'en': 'Office Budget',
      'ar': 'ميزانية المكتب',
      'de': 'Bürobudget',
      'es': 'Presupuesto de oficina',
    },
    'sx0vvzxd': {
      'en': 'External Transfer',
      'ar': 'التحويل الخارجي',
      'de': 'Externe Übertragung',
      'es': 'Transferencia externa',
    },
    'ai453kej': {
      'en': 'ACH Payment',
      'ar': 'دفع ACH',
      'de': 'ACH-Zahlung',
      'es': 'Pago CCA',
    },
    'wo9cebk7': {
      'en': 'Select Transfer',
      'ar': '',
      'de': '',
      'es': '',
    },
    'ta6s45j6': {
      'en': 'Interes E.A',
      'ar': 'سبب',
      'de': 'Grund',
      'es': 'Razón',
    },
    'nbtu69zr': {
      'en': 'Frecuencia de pago',
      'ar': 'سبب',
      'de': 'Grund',
      'es': 'Razón',
    },

    'zjglv7a7': {
      'en': 'Tipo de renta/tasa',
      'ar': 'سبب',
      'de': 'Grund',
      'es': 'Razón',
    },
    'uvrt7im0': {
      'en': 'Request Funds',
      'ar': 'طلب التمويل',
      'de': 'Geld anfordern',
      'es': 'Pedír fondos',
    },
    '7y89msg9': {
      'en': 'Tap above to complete request',
      'ar': 'اضغط أعلاه لإكمال الطلب',
      'de': 'Tippen Sie oben, um die Anfrage abzuschließen',
      'es': 'Toque arriba para completar la solicitud',
    },
    'xk0bwox3': {
      'en': 'Home',
      'ar': 'مسكن',
      'de': 'Heim',
      'es': 'Casa',
    },
  },
  // Admin proyecto
  {
    'wv1862li': {
      'en': 'Proyectos',
      'ar': 'Proyectos',
      'de': 'Proyectos',
      'es': 'Proyectos',
    },
    'rcevwwju': {
      'en': 'Nombre del proyecto',
      'ar': 'سبب',
      'de': 'Grund',
      'es': 'Razón',
    },
    'ig2y6wx6': {
      'en': 'Tipo de proyecto',
      'ar': 'سبب',
      'de': 'Grund',
      'es': 'Razón',
    }
  },
  // editProfile
  {
    '4rzqov3y': {
      'en': 'Edit Profile',
      'ar': 'تعديل الملف الشخصي',
      'de': 'Profil bearbeiten',
      'es': 'Editar perfil',
    },
    'zoxan2gi': {
      'en': 'Change Photo',
      'ar': 'غير الصوره',
      'de': 'Foto ändern',
      'es': 'Cambiar foto',
    },
    '3p9y21e2': {
      'en': 'Your Name',
      'ar': 'اسمك',
      'de': 'Dein Name',
      'es': 'Tu nombre',
    },
    'dw9gmjdc': {
      'en': 'Please enter a valid number...',
      'ar': 'من فضلك أدخل رقما صالحا...',
      'de': 'Bitte geben Sie eine gültige Nummer ein...',
      'es': 'Por favor ingrese un número valido...',
    },
    'z4fstn5l': {
      'en': 'Email Address',
      'ar': 'عنوان البريد الالكترونى',
      'de': 'E-Mail-Addresse',
      'es': 'Dirección de correo electrónico',
    },
    'jozgvwyg': {
      'en': 'Your email',
      'ar': 'بريدك الالكتروني',
      'de': 'Deine E-Mail',
      'es': 'Tu correo electrónico',
    },
    '8h1cjk5a': {
      'en': 'Your Age',
      'ar': 'عمرك',
      'de': 'Ihr Alter',
      'es': 'Su edad',
    },
    '5v21r6gb': {
      'en': 'i.e. 34',
      'ar': 'أي 34',
      'de': 'dh 34',
      'es': 'es decir, 34',
    },
    'zvymbfia': {
      'en': 'Your Title',
      'ar': 'لقبك',
      'de': 'Dein Titel',
      'es': 'Tu título',
    },
    'i6edcl52': {
      'en': 'Save Changes',
      'ar': 'حفظ التغييرات',
      'de': 'Änderungen speichern',
      'es': 'Guardar cambios',
    },
    '59naq8ur': {
      'en': 'Home',
      'ar': 'مسكن',
      'de': 'Heim',
      'es': 'Casa',
    },
  },
  // changePassword
  {
    'l5iggwaz': {
      'en': 'Change Password',
      'ar': 'تغيير كلمة المرور',
      'de': 'Kennwort ändern',
      'es': 'Cambia la contraseña',
    },
    '2b97u8y5': {
      'en':
          'Enter the email associated with your account and we will send you link to reset your password.',
      'ar':
          'أدخل البريد الإلكتروني المرتبط بحسابك وسنرسل لك رابطًا لإعادة تعيين كلمة المرور الخاصة بك.',
      'de':
          'Geben Sie die mit Ihrem Konto verknüpfte E-Mail-Adresse ein und wir senden Ihnen einen Link zum Zurücksetzen Ihres Passworts.',
      'es':
          'Ingrese el correo electrónico asociado con su cuenta y le enviaremos un enlace para restablecer su contraseña.',
    },
    'ajy1c3r9': {
      'en': 'Email Address',
      'ar': 'عنوان البريد الالكترونى',
      'de': 'E-Mail-Addresse',
      'es': 'Dirección de correo electrónico',
    },
    'hsqfoxya': {
      'en': 'Enter your email...',
      'ar': 'أدخل بريدك الإلكتروني ...',
      'de': 'Geben sie ihre E-Mail Adresse ein...',
      'es': 'Introduce tu correo electrónico...',
    },
    'if4pz6lm': {
      'en': 'Send Reset Link',
      'ar': 'أرسل رابط إعادة التعيين',
      'de': 'Zurücksetzen-Link senden',
      'es': 'Enviar enlace de reinicio',
    },
    '5tvk9lv0': {
      'en': 'Home',
      'ar': 'مسكن',
      'de': 'Heim',
      'es': 'Casa',
    },
  },
  // notificationsSettings
  {
    'sc4ff4ce': {
      'en': 'Notifications',
      'ar': 'إشعارات',
      'de': 'Benachrichtigungen',
      'es': 'Notificaciones',
    },
    'r72zvrv5': {
      'en':
          'Choose what notifcations you want to recieve below and we will update the settings.',
      'ar': 'اختر الإشعارات التي تريد تلقيها أدناه وسنقوم بتحديث الإعدادات.',
      'de':
          'Wählen Sie unten aus, welche Benachrichtigungen Sie erhalten möchten, und wir aktualisieren die Einstellungen.',
      'es':
          'Elija qué notificaciones desea recibir a continuación y actualizaremos la configuración.',
    },
    'gjygkr0n': {
      'en': 'Push Notifications',
      'ar': 'دفع الإخطارات',
      'de': 'Mitteilungen',
      'es': 'Notificaciones push',
    },
    '3y3yhxbk': {
      'en':
          'Receive Push notifications from our application on a semi regular basis.',
      'ar': 'تلقي إشعارات من تطبيقنا على أساس شبه منتظم.',
      'de':
          'Erhalten Sie regelmäßig Push-Benachrichtigungen von unserer Anwendung.',
      'es':
          'Reciba notificaciones Push de nuestra aplicación de forma semi regular.',
    },
    '1ytebj35': {
      'en': 'Email Notifications',
      'ar': 'اشعارات البريد الالكتروني',
      'de': 'E-Mail Benachrichtigungen',
      'es': 'Notificaciónes de Correo Electrónico',
    },
    '9lvh5nst': {
      'en':
          'Receive email notifications from our marketing team about new features.',
      'ar':
          'تلقي إشعارات البريد الإلكتروني من فريق التسويق لدينا حول الميزات الجديدة.',
      'de':
          'Erhalten Sie E-Mail-Benachrichtigungen von unserem Marketingteam über neue Funktionen.',
      'es':
          'Reciba notificaciones por correo electrónico de nuestro equipo de marketing sobre nuevas funciones.',
    },
    '69d2j74u': {
      'en': 'Location Services',
      'ar': 'خدمات الموقع',
      'de': 'Standortdienste',
      'es': 'Servicios de localización',
    },
    '3k8cuv0d': {
      'en':
          'Allow us to track your location, this helps keep track of spending and keeps you safe.',
      'ar':
          'اسمح لنا بتتبع موقعك ، فهذا يساعد على تتبع الإنفاق ويحافظ على سلامتك.',
      'de':
          'Erlauben Sie uns, Ihren Standort zu verfolgen, dies hilft, die Ausgaben im Auge zu behalten und schützt Sie.',
      'es':
          'Permítanos rastrear su ubicación, esto ayuda a realizar un seguimiento de los gastos y lo mantiene seguro.',
    },
    'isgrgbfs': {
      'en': 'Save Changes',
      'ar': 'حفظ التغييرات',
      'de': 'Änderungen speichern',
      'es': 'Guardar cambios',
    },
    'a96mlyeh': {
      'en': 'Home',
      'ar': 'مسكن',
      'de': 'Heim',
      'es': 'Casa',
    },
  },
  // homePage
  {
    'ucqlrrlk': {
      'en': 'Welcome,',
      'ar': 'مرحبا،',
      'de': 'Herzlich willkommen,',
      'es': 'Bienvenidos,',
    },
    'c10wb3ot': {
      'en': 'Your account Details are below.',
      'ar': 'تفاصيل حسابك أدناه.',
      'de': 'Ihre Kontodetails sind unten.',
      'es': 'Los detalles de su cuenta se encuentran a continuación.',
    },
    '6z1sm34j': {
      'en': 'Total Balance',
      'ar': 'Total Balance',
      'de': 'Total Balance',
      'es': 'Total Balance',
    },
    'c0dls4u5': {
      'en': '\$25,202',
      'ar': '25202 دولار',
      'de': '25.202 \$',
      'es': '\$25,202',
    },
    '30yef7fj': {
      'en': 'Payroll Due',
      'ar': 'الرواتب المستحقة',
      'de': 'Gehaltsabrechnung fällig',
      'es': 'Vencimiento de nómina',
    },
    'zrx9e6tv': {
      'en': '\$12,245',
      'ar': '12245 دولارًا',
      'de': '12.245 \$',
      'es': '\$12,245',
    },
    '1cjqanzg': {
      'en': 'Debit Date',
      'ar': 'تاريخ الخصم',
      'de': 'Belastungsdatum',
      'es': 'Fecha de débito',
    },
    '726vrs60': {
      'en': 'Aug 31, 2021',
      'ar': '31 أغسطس 2021',
      'de': '31. August 2021',
      'es': '31 de agosto de 2021',
    },
    '4dgbx46t': {
      'en': '4 Days Left',
      'ar': 'باقي 4 ايام',
      'de': 'noch 4 Tage',
      'es': '4 días restantes',
    },
    'n87v5tth': {
      'en': 'Marketing Budget',
      'ar': 'ميزانية التسويق',
      'de': 'Werbehaushalt, Werbebudget',
      'es': 'Presupuesto de marketing',
    },
    'l5pw5c8c': {
      'en': '\$4,000',
      'ar': '4000 دولار',
      'de': '4.000 \$',
      'es': '\$4,000',
    },
    '7i0a44qa': {
      'en': 'Total Spent',
      'ar': 'إجمال الصرف',
      'de': 'Gesamtausgaben',
      'es': 'Total gastado',
    },
    '9a2ya1la': {
      'en': '\$3,402',
      'ar': '3،402 دولار',
      'de': '\$3.402',
      'es': '\$3,402',
    },
    'n1o498d9': {
      'en': '4 Days Left',
      'ar': 'باقي 4 ايام',
      'de': 'noch 4 Tage',
      'es': '4 días restantes',
    },
    'lmo3ko2i': {
      'en': 'Quick Services',
      'ar': 'خدمات سريعة',
      'de': 'Schnelle Dienste',
      'es': 'Servicios rápidos',
    },
    '774itrkn': {
      'en': 'My Bank',
      'ar': 'بنكي',
      'de': 'Meine Bank',
      'es': 'Mi banco',
    },
    'xs2as0vf': {
      'en': 'Transfer',
      'ar': 'تحويل',
      'de': 'Transfer',
      'es': 'Transferir',
    },
    'g8yaaa7f': {
      'en': 'Activity',
      'ar': 'نشاط',
      'de': 'Aktivität',
      'es': 'Actividad',
    },
    'nb29ps2o': {
      'en': '1 New Alert',
      'ar': '1 تنبيه جديد',
      'de': '1 Neue Benachrichtigung',
      'es': '1 nueva alerta',
    },
    'vgt9s153': {
      'en': 'View Now',
      'ar': 'عرض الآن',
      'de': 'Jetzt ansehen',
      'es': 'Ver ahora',
    },
    'pnvkw3b7': {
      'en':
          'We noticed a small charge that is out of character of this account, please review.',
      'ar': 'لقد لاحظنا تكلفة صغيرة خارجة عن طبيعة هذا الحساب ، يرجى المراجعة.',
      'de':
          'Wir haben eine kleine Belastung festgestellt, die für dieses Konto untypisch ist. Bitte überprüfen Sie diese.',
      'es':
          'Notamos un pequeño cargo que está fuera de lugar en esta cuenta, revíselo.',
    },
    'c805m53i': {
      'en': 'Home',
      'ar': 'مسكن',
      'de': 'Heim',
      'es': 'Casa',
    },
  },
  // homePage_alt
  {
    'xdh0z8qh': {
      'en': 'Welcome,',
      'ar': 'مرحبا،',
      'de': 'Herzlich willkommen,',
      'es': 'Bienvenidos,',
    },
    'v74pa882': {
      'en': 'Andrew',
      'ar': 'أندرو',
      'de': 'Andreas',
      'es': 'Andrés',
    },
    'rzpg3cvh': {
      'en': 'Your latest updates are below.',
      'ar': 'آخر التحديثات الخاصة بك أدناه.',
      'de': 'Ihre neuesten Updates sind unten.',
      'es': 'Sus últimas actualizaciones se encuentran a continuación.',
    },
    'flto6ti8': {
      'en': 'Total Balance',
      'ar': 'إجمالي الرصيد',
      'de': 'Gesamtsaldo',
      'es': 'Balance total',
    },
    'g07h0azf': {
      'en': '\$25,281',
      'ar': '25281 دولارًا',
      'de': '25.281 \$',
      'es': '\$25,281',
    },
    'v9ghmn0y': {
      'en': 'Total Balance',
      'ar': 'إجمالي الرصيد',
      'de': 'Gesamtsaldo',
      'es': 'Balance total',
    },
    '7vf40ybo': {
      'en': '\$25,281',
      'ar': '25281 دولارًا',
      'de': '25.281 \$',
      'es': '\$25,281',
    },
    'k4scs2cu': {
      'en': 'Total Balance',
      'ar': 'إجمالي الرصيد',
      'de': 'Gesamtsaldo',
      'es': 'Balance total',
    },
    'cvrbfozm': {
      'en': '\$25,281',
      'ar': '25281 دولارًا',
      'de': '25.281 \$',
      'es': '\$25,281',
    },
    'a33ldz0h': {
      'en': 'Next Payroll',
      'ar': 'كشوف المرتبات التالية',
      'de': 'Nächste Gehaltsabrechnung',
      'es': 'Nómina siguiente',
    },
    '3dgzzz79': {
      'en': '\$25,281',
      'ar': '25281 دولارًا',
      'de': '25.281 \$',
      'es': '\$25,281',
    },
    'hp28r17l': {
      'en': 'Debit Date',
      'ar': 'تاريخ الخصم',
      'de': 'Belastungsdatum',
      'es': 'Fecha de débito',
    },
    'k04gl6sz': {
      'en': 'Aug 31, 2021',
      'ar': '31 أغسطس 2021',
      'de': '31. August 2021',
      'es': '31 de agosto de 2021',
    },
    'd5tcdo3w': {
      'en': '4 days left',
      'ar': 'باقي 4 ايام',
      'de': 'noch 4 Tage',
      'es': '4 días restantes',
    },
    '8wofym4i': {
      'en': '1 New Alert',
      'ar': '1 تنبيه جديد',
      'de': '1 Neue Benachrichtigung',
      'es': '1 nueva alerta',
    },
    'kaq4nzj6': {
      'en': 'Fraud Alert',
      'ar': 'تنبيه الاحتيال',
      'de': 'Betrugsalarm',
      'es': 'Alerta de fraude',
    },
    '7zcrtqx6': {
      'en':
          'We noticed a small charge that is out of character of this account, please review.',
      'ar': 'لقد لاحظنا تكلفة صغيرة خارجة عن طبيعة هذا الحساب ، يرجى المراجعة.',
      'de':
          'Wir haben eine kleine Belastung festgestellt, die für dieses Konto untypisch ist. Bitte überprüfen Sie diese.',
      'es':
          'Notamos un pequeño cargo que está fuera de lugar en esta cuenta, revíselo.',
    },
    '23yxoc9m': {
      'en': 'View Now',
      'ar': 'عرض الآن',
      'de': 'Jetzt ansehen',
      'es': 'Ver ahora',
    },
    'a86mwddx': {
      'en': 'Marketing Budget',
      'ar': 'ميزانية التسويق',
      'de': 'Werbehaushalt, Werbebudget',
      'es': 'Presupuesto de marketing',
    },
    '6c2o39hz': {
      'en': '\$3,000',
      'ar': '3000 دولار',
      'de': '3.000 \$',
      'es': '\$3,000',
    },
    '5subrra4': {
      'en': 'Total Spent',
      'ar': 'إجمال الصرف',
      'de': 'Gesamtausgaben',
      'es': 'Total gastado',
    },
    '0wtm2m51': {
      'en': '\$2,502',
      'ar': '2،502 دولار',
      'de': '2.502 \$',
      'es': '\$2,502',
    },
    'bp9d56pc': {
      'en': '4 days left',
      'ar': 'باقي 4 ايام',
      'de': 'noch 4 Tage',
      'es': '4 días restantes',
    },
    'b8oj0pck': {
      'en': 'Team Name',
      'ar': 'اسم الفريق',
      'de': 'Teamname',
      'es': 'Nombre del equipo',
    },
    '87ospwsq': {
      'en': '\$5,000',
      'ar': '5000 دولار',
      'de': '5.000 \$',
      'es': '\$5,000',
    },
    'jzfejglt': {
      'en': 'Head of Design',
      'ar': 'رئيس قسم التصميم',
      'de': 'Leiter Design',
      'es': 'Jefe de Diseño',
    },
    'zm0lhm2a': {
      'en': '[Time Stamp]',
      'ar': '[الطابع الزمني]',
      'de': '[Zeitstempel]',
      'es': '[Marca de tiempo]',
    },
    '8hu2v2im': {
      'en': '•',
      'ar': '•',
      'de': '•',
      'es': '•',
    },
  },
  // budget_DELETE
  {
    'pozov0xz': {
      'en': 'Delete Budget',
      'ar': 'حذف الميزانية',
      'de': 'Budget löschen',
      'es': 'Eliminar presupuesto',
    },
    'aptjmof0': {
      'en':
          'If you delete this budget, your transactions will no longer be associated with it.',
      'ar': 'إذا حذفت هذه الميزانية ، فلن تكون معاملاتك مرتبطة بها بعد الآن.',
      'de':
          'Wenn Sie dieses Budget löschen, sind Ihre Transaktionen nicht mehr damit verknüpft.',
      'es':
          'Si elimina este presupuesto, sus transacciones ya no estarán asociadas a él.',
    },
    '9l7pbjcj': {
      'en': 'Delete Budget',
      'ar': 'حذف الميزانية',
      'de': 'Budget löschen',
      'es': 'Eliminar presupuesto',
    },
    'u0kr38at': {
      'en': 'Tap above to remove this bude',
      'ar': 'انقر فوق لإزالة هذا bude',
      'de': 'Tippen Sie oben, um diese Bude zu entfernen',
      'es': 'Toque arriba para eliminar este bude',
    },
    'b1xp801p': {
      'en': 'Home',
      'ar': 'مسكن',
      'de': 'Heim',
      'es': 'Casa',
    },
  },
  // Tipo Transferencia
  {
    'tdtox9t1s1': {
      'en': 'Add tipo trasnferencia',
      'ar': 'Add tipo trasnferencia',
      'de': 'Add tipo trasnferencia',
      'es': 'Add tipo trasnferencia',
    },
  },
  // proyects
  {
    'hhb6veym': {
      'en': 'Wallet Balance',
      'ar': 'رصيد المحفظة',
      'de': 'Wallet-Guthaben',
      'es': 'Saldo de la cartera',
    },
    'fgf8icmv': {
      'en': '\$23,000',
      'ar': '23000 دولار',
      'de': '23.000 \$',
      'es': '\$23,000',
    },
    '2rrr446m': {
      'en': 'currencies',
      'ar': 'currencies',
      'de': 'currencies',
      'es': 'currencies',
    },
    '8nac51xz': {
      'en': 'Transfer',
      'ar': 'تحويل',
      'de': 'Transfer',
      'es': 'Transferir',
    },
    's56t3xya': {
      'en': 'Activity',
      'ar': 'نشاط',
      'de': 'Aktivität',
      'es': 'Actividad',
    },
    'r04m9nxs': {
      'en': 'Add proyects',
      'ar': 'بنكي',
      'de': 'Meine Bank',
      'es': 'Mi banco',
    },
    'vewa5op5': {
      'en': 'Bitcoin',
      'ar': 'بيتكوين',
      'de': 'Bitcoin',
      'es': 'Bitcoin',
    },
    '9oun2uok': {
      'en': '\$7,302',
      'ar': '7302 دولار',
      'de': '\$7.302',
      'es': '\$7,302',
    },
    'yla7uncg': {
      'en': '32% of portfolio',
      'ar': '32٪ من المحفظة',
      'de': '32 % des Portfolios',
      'es': '32% de la cartera',
    },
    '7hsm7t9z': {
      'en': ' ',
      'ar': '',
      'de': '',
      'es': '',
    },
    'opob20j8': {
      'en': 'Solona',
      'ar': 'سولونا',
      'de': 'Solona',
      'es': 'Soloña',
    },
    'fi3cleyj': {
      'en': '\$7,302',
      'ar': '7302 دولار',
      'de': '\$7.302',
      'es': '\$7,302',
    },
    '606emxw1': {
      'en': '40% of portfolio',
      'ar': '40٪ من المحفظة',
      'de': '40 % des Portfolios',
      'es': '40% de la cartera',
    },
    'qx0ykpbm': {
      'en': ' ',
      'ar': '',
      'de': '',
      'es': '',
    },
    'l2io5lul': {
      'en': 'Dogecoin',
      'ar': 'دوجكوين',
      'de': 'Dogecoins',
      'es': 'dogecoin',
    },
    'krsyyttw': {
      'en': '\$7,302',
      'ar': '7302 دولار',
      'de': '\$7.302',
      'es': '\$7,302',
    },
    '4mvfe3pe': {
      'en': '40% of portfolio',
      'ar': '40٪ من المحفظة',
      'de': '40 % des Portfolios',
      'es': '40% de la cartera',
    },
    '6cm4jjje': {
      'en': ' ',
      'ar': '',
      'de': '',
      'es': '',
    },
    'vox9t1s0': {
      'en': 'Home',
      'ar': 'مسكن',
      'de': 'Heim',
      'es': 'Casa',
    },
  },
  // Tipo proyecto
  {
    'tpadgj1u': {
      'en': 'Add tipo transaccion',
      'ar': 'Add tipo transaccion،',
      'de': 'Add tipo transaccion,',
      'es': 'Add tipo transaccion,',
    },
  },
  // portafolioDetailPage
  {
    'xnadgj1u': {
      'en': 'Detalle',
      'ar': 'مرحبا،',
      'de': 'Herzlich willkommen,',
      'es': 'Bienvenidos,',
    },
    'xnadgj2u': {
      'en': 'Agregar Portafolio',
      'ar': 'مرحبا،',
      'de': 'Herzlich willkommen,',
      'es': 'Agregar Portafolio,',
    },
    'xnadgj4u': {
      'en': 'Welcome,',
      'ar': 'مرحبا،',
      'de': 'Herzlich willkommen,',
      'es': 'Bienvenidos,',
    },
    'pknlsgbc': {
      'en': 'Andrew',
      'ar': 'أندرو',
      'de': 'Andreas',
      'es': 'Andrés',
    },
    'vmxubknb': {
      'en': 'Your latest updates are below.',
      'ar': 'آخر التحديثات الخاصة بك أدناه.',
      'de': 'Ihre neuesten Updates sind unten.',
      'es': 'Sus últimas actualizaciones se encuentran a continuación.',
    },
    '0bjhwaz0': {
      'en': 'Option 1',
      'ar': '',
      'de': '',
      'es': '',
    },
    's8j4oxuy': {
      'en': 'Please select...',
      'ar': '',
      'de': '',
      'es': '',
    },
    'wcu2yk70': {
      'en': 'Search for an item...',
      'ar': '',
      'de': '',
      'es': '',
    },
    'npa8wdmw': {
      'en': 'Option 1',
      'ar': '',
      'de': '',
      'es': '',
    },
    'c7fvbto8': {
      'en': 'Please select...',
      'ar': '',
      'de': '',
      'es': '',
    },
    'pvl6ms9r': {
      'en': 'Search for an item...',
      'ar': '',
      'de': '',
      'es': '',
    },
    't3j0wdnk': {
      'en': 'Option 1',
      'ar': '',
      'de': '',
      'es': '',
    },
    'cw1n8hek': {
      'en': 'Please select...',
      'ar': '',
      'de': '',
      'es': '',
    },
    'wxtml0kg': {
      'en': 'Search for an item...',
      'ar': '',
      'de': '',
      'es': '',
    },
    'cjggcppn': {
      'en': 'Option 1',
      'ar': '',
      'de': '',
      'es': '',
    },
    'm9x2vsy5': {
      'en': 'Please select...',
      'ar': '',
      'de': '',
      'es': '',
    },
    'csv8wloh': {
      'en': 'Search for an item...',
      'ar': '',
      'de': '',
      'es': '',
    },
    'xvmk449f': {
      'en': 'Quick Service',
      'ar': 'خدمة سريعة',
      'de': 'Schneller Service',
      'es': 'Servicio rapido',
    },
    'xw3lkljd': {
      'en': 'Retiro',
      'ar': 'بنكي',
      'de': 'Meine Bank',
      'es': 'Retiro',
    },
    'l9rauiui': {
      'en': 'Transfer',
      'ar': 'تحويل',
      'de': 'Transfer',
      'es': 'Transferir',
    },
    'xxdq1tzd': {
      'en': 'Activity',
      'ar': 'نشاط',
      'de': 'Aktivität',
      'es': 'Actividad',
    },
    'bpkc110o': {
      'en': 'Portafolios',
      'ar': 'عملية',
      'de': 'Transaktion',
      'es': 'Portafolios',
    },
    'r13uhw9n': {
      'en': 'Transacciones',
      'ar': 'احصل على مكافآت بعيدة',
      'de': 'Go-Far-Prämien',
      'es': 'Transacciones',
    },
    'avy3an06': {
      'en': 'Income',
      'ar': 'دخل',
      'de': 'Einkommen',
      'es': 'Ingreso',
    },
    'npym38ai': {
      'en': '\$50.00',
      'ar': '50.00 دولارًا أمريكيًا',
      'de': '\$50,00',
      'es': '\$50.00',
    },
    'be6mty9b': {
      'en': 'Hello World',
      'ar': 'مرحبا بالعالم',
      'de': 'Hallo Welt',
      'es': 'Hola Mundo',
    },
    '3uebdebf': {
      'en': 'Go Far Rewards',
      'ar': 'احصل على مكافآت بعيدة',
      'de': 'Go-Far-Prämien',
      'es': 'Recompensas Ve Lejos',
    },
    'tilesq3d': {
      'en': 'Income',
      'ar': 'دخل',
      'de': 'Einkommen',
      'es': 'Ingreso',
    },
    'sd8zd16p': {
      'en': '\$50.00',
      'ar': '50.00 دولارًا أمريكيًا',
      'de': '\$50,00',
      'es': '\$50.00',
    },
    '5kqft89q': {
      'en': 'Hello World',
      'ar': 'مرحبا بالعالم',
      'de': 'Hallo Welt',
      'es': 'Hola Mundo',
    },
    'j2auhz4g': {
      'en': 'Go Far Rewards',
      'ar': 'احصل على مكافآت بعيدة',
      'de': 'Go-Far-Prämien',
      'es': 'Recompensas Ve Lejos',
    },
    'bubip62r': {
      'en': 'Income',
      'ar': 'دخل',
      'de': 'Einkommen',
      'es': 'Ingreso',
    },
    '2keaoz3o': {
      'en': '\$50.00',
      'ar': '50.00 دولارًا أمريكيًا',
      'de': '\$50,00',
      'es': '\$50.00',
    },
    '02mq64si': {
      'en': 'Hello World',
      'ar': 'مرحبا بالعالم',
      'de': 'Hallo Welt',
      'es': 'Hola Mundo',
    },
    'tbg31o3c': {
      'en': 'Go Far Rewards',
      'ar': 'احصل على مكافآت بعيدة',
      'de': 'Go-Far-Prämien',
      'es': 'Recompensas Ve Lejos',
    },
    '0i62m9lp': {
      'en': 'Income',
      'ar': 'دخل',
      'de': 'Einkommen',
      'es': 'Ingreso',
    },
    'zg4zhpde': {
      'en': '\$50.00',
      'ar': '50.00 دولارًا أمريكيًا',
      'de': '\$50,00',
      'es': '\$50.00',
    },
    'ip1tbax1': {
      'en': 'Hello World',
      'ar': 'مرحبا بالعالم',
      'de': 'Hallo Welt',
      'es': 'Hola Mundo',
    },
    'df0rvya1': {
      'en': 'Home',
      'ar': 'مسكن',
      'de': 'Heim',
      'es': 'Casa',
    },
  },
  // bookAppointment
  {
    'sfzj3riz': {
      'en': 'Book Appointment',
      'ar': 'موعد الكتاب',
      'de': 'Einen Termin verabreden',
      'es': 'Reservar una cita',
    },
    '4skzh9os': {
      'en':
          'Fill out the information below in order to book your appointment with our office.',
      'ar': 'املأ المعلومات أدناه من أجل حجز موعدك مع مكتبنا.',
      'de':
          'Füllen Sie die folgenden Informationen aus, um Ihren Termin in unserem Büro zu buchen.',
      'es':
          'Complete la información a continuación para reservar su cita con nuestra oficina.',
    },
    'b87tcas2': {
      'en': 'Emails will be sent to:',
      'ar': 'سيتم إرسال رسائل البريد الإلكتروني إلى:',
      'de': 'E-Mails werden gesendet an:',
      'es': 'Los correos electrónicos serán enviados a:',
    },
    'iicnw3dq': {
      'en': 'Booking For',
      'ar': 'الحجز لـ',
      'de': 'Buchung für',
      'es': 'reserva para',
    },
    '5tkkg4yu': {
      'en': 'Type of Appointment',
      'ar': 'نوع التعيين',
      'de': 'Art der Ernennung',
      'es': 'Tipo de cita',
    },
    '7w5m45zt': {
      'en': 'Doctors Visit',
      'ar': 'زيارة الأطباء',
      'de': 'Arztbesuch',
      'es': 'Visita de médicos',
    },
    'bmfmxg71': {
      'en': 'Routine Checkup',
      'ar': 'فحص روتيني حتى',
      'de': 'Routineuntersuchung',
      'es': 'Chequeo de rutina',
    },
    'prt95f0g': {
      'en': 'Scan/Update',
      'ar': 'مسح / تحديث',
      'de': 'Scannen/Aktualisieren',
      'es': 'Escanear/Actualizar',
    },
    '7ohalsg9': {
      'en': 'What\'s the problem?',
      'ar': 'ما هي المشكلة؟',
      'de': 'Was ist das Problem?',
      'es': '¿Cuál es el problema?',
    },
    'xukiv2ku': {
      'en': 'Choose Date',
      'ar': 'اختر موعدا',
      'de': 'Wählen Sie Datum',
      'es': 'Elija fecha',
    },
    'lpc88cht': {
      'en': 'Cancel',
      'ar': 'يلغي',
      'de': 'Abbrechen',
      'es': 'Cancelar',
    },
    'b5umyycx': {
      'en': 'Book Now',
      'ar': 'احجز الآن',
      'de': 'buchen Sie jetzt',
      'es': 'Reservar ahora',
    },
  },
  // bookingOld
  {
    '8laf5zmk': {
      'en': 'Book Appointment',
      'ar': 'موعد الكتاب',
      'de': 'Einen Termin verabreden',
      'es': 'Reservar una cita',
    },
    'udwhsu8p': {
      'en':
          'Fill out the information below in order to book your appointment with our office.',
      'ar': 'املأ المعلومات أدناه من أجل حجز موعدك مع مكتبنا.',
      'de':
          'Füllen Sie die folgenden Informationen aus, um Ihren Termin in unserem Büro zu buchen.',
      'es':
          'Complete la información a continuación para reservar su cita con nuestra oficina.',
    },
    'm6f5lawq': {
      'en': 'Email Address',
      'ar': 'عنوان البريد الالكترونى',
      'de': 'E-Mail-Addresse',
      'es': 'Dirección de correo electrónico',
    },
    'yz52729g': {
      'en': 'Booking For',
      'ar': 'الحجز لـ',
      'de': 'Buchung für',
      'es': 'reserva para',
    },
    'hdmqdmzq': {
      'en': 'Type of Appointment',
      'ar': 'نوع التعيين',
      'de': 'Art der Ernennung',
      'es': 'Tipo de cita',
    },
    'stpxpct6': {
      'en': 'Doctors Visit',
      'ar': 'زيارة الأطباء',
      'de': 'Arztbesuch',
      'es': 'Visita de médicos',
    },
    'wvgk6obb': {
      'en': 'Routine Checkup',
      'ar': 'فحص روتيني حتى',
      'de': 'Routineuntersuchung',
      'es': 'Chequeo de rutina',
    },
    'xt7ujyt8': {
      'en': 'Scan/Update',
      'ar': 'مسح / تحديث',
      'de': 'Scannen/Aktualisieren',
      'es': 'Escanear/Actualizar',
    },
    'andpn0t0': {
      'en': 'What\'s the problem?',
      'ar': 'ما هي المشكلة؟',
      'de': 'Was ist das Problem?',
      'es': '¿Cuál es el problema?',
    },
    'ycaso9dc': {
      'en': 'Choose Date',
      'ar': 'اختر موعدا',
      'de': 'Wählen Sie Datum',
      'es': 'Elija fecha',
    },
    '2pmd2p3w': {
      'en': 'Cancel',
      'ar': 'يلغي',
      'de': 'Abbrechen',
      'es': 'Cancelar',
    },
    '13j05r8j': {
      'en': 'Book Now',
      'ar': 'احجز الآن',
      'de': 'buchen Sie jetzt',
      'es': 'Reservar ahora',
    },
  },
  // editBooking
  {
    '6j668hma': {
      'en': 'Edit Appointment',
      'ar': 'تحرير موعد',
      'de': 'Termin bearbeiten',
      'es': 'Editar cita',
    },
    'cbp936ta': {
      'en': 'Edit the fields below in order to change your appointment.',
      'ar': 'قم بتحرير الحقول أدناه لتغيير موعدك.',
      'de': 'Bearbeiten Sie die Felder unten, um Ihren Termin zu ändern.',
      'es': 'Edite los campos a continuación para cambiar su cita.',
    },
    '6btfslje': {
      'en': 'Emails will be sent to:',
      'ar': 'سيتم إرسال رسائل البريد الإلكتروني إلى:',
      'de': 'E-Mails werden gesendet an:',
      'es': 'Los correos electrónicos serán enviados a:',
    },
    'mhko6q8p': {
      'en': 'Booking For',
      'ar': 'الحجز لـ',
      'de': 'Buchung für',
      'es': 'reserva para',
    },
    'shqcgjqe': {
      'en': 'Type of Appointment',
      'ar': 'نوع التعيين',
      'de': 'Art der Ernennung',
      'es': 'Tipo de cita',
    },
    '5ixhbnsd': {
      'en': 'Doctors Visit',
      'ar': 'زيارة الأطباء',
      'de': 'Arztbesuch',
      'es': 'Visita de médicos',
    },
    'db46hhfw': {
      'en': 'Routine Checkup',
      'ar': 'فحص روتيني حتى',
      'de': 'Routineuntersuchung',
      'es': 'Chequeo de rutina',
    },
    'e1zm6kzh': {
      'en': 'Scan/Update',
      'ar': 'مسح / تحديث',
      'de': 'Scannen/Aktualisieren',
      'es': 'Escanear/Actualizar',
    },
    'oy6qvd33': {
      'en': 'What\'s the problem?',
      'ar': 'ما هي المشكلة؟',
      'de': 'Was ist das Problem?',
      'es': '¿Cuál es el problema?',
    },
    '9emhgrhs': {
      'en': 'Choose Date',
      'ar': 'اختر موعدا',
      'de': 'Wählen Sie Datum',
      'es': 'Elija Fecha',
    },
    '2bzoinpy': {
      'en': 'Cancel',
      'ar': 'يلغي',
      'de': 'Abbrechen',
      'es': 'Cancelar',
    },
    'gjnq0j86': {
      'en': 'Save Changes',
      'ar': 'حفظ التغييرات',
      'de': 'Änderungen speichern',
      'es': 'Guardar cambios',
    },
  },
  // pauseCard
  {
    'dt7m486y': {
      'en': 'Pause Card',
      'ar': 'بطاقة وقفة',
      'de': 'Pausenkarte',
      'es': 'Tarjeta de pausa',
    },
    '6edae99k': {
      'en': 'Are you sure you want to pause your card?',
      'ar': 'هل أنت متأكد أنك تريد إيقاف بطاقتك مؤقتًا؟',
      'de': 'Möchten Sie Ihre Karte wirklich pausieren?',
      'es': '¿Seguro que quieres pausar tu tarjeta?',
    },
    'omtrfcm5': {
      'en': 'Nevermind',
      'ar': 'لا بأس',
      'de': 'egal',
      'es': 'No importa',
    },
    'hw07mkb9': {
      'en': 'Yes, Pause',
      'ar': 'نعم توقف',
      'de': 'Ja, Pause',
      'es': 'Sí, pausa',
    },
  },
  // Miscellaneous
  {
    'lzyb73wy': {
      'en': '',
      'ar': '',
      'de': '',
      'es': '',
    },
    'kx9cdks4': {
      'en': '',
      'ar': '',
      'de': '',
      'es': '',
    },
    'efvtwj7k': {
      'en': '',
      'ar': '',
      'de': '',
      'es': '',
    },
    'ec5hfa1e': {
      'en': '',
      'ar': '',
      'de': '',
      'es': '',
    },
    'q5ljwvfo': {
      'en': '',
      'ar': '',
      'de': '',
      'es': '',
    },
    'j4rmwb3h': {
      'en': '',
      'ar': '',
      'de': '',
      'es': '',
    },
    '6ah1b18f': {
      'en': '',
      'ar': '',
      'de': '',
      'es': '',
    },
    '2kos1hen': {
      'en': '',
      'ar': '',
      'de': '',
      'es': '',
    },
    'aox3s4fb': {
      'en': '',
      'ar': '',
      'de': '',
      'es': '',
    },
    'l8hv5a7z': {
      'en': '',
      'ar': '',
      'de': '',
      'es': '',
    },
    '4pjwb70a': {
      'en': '',
      'ar': '',
      'de': '',
      'es': '',
    },
    '0xlokf4y': {
      'en': '',
      'ar': '',
      'de': '',
      'es': '',
    },
    '8twlwiwt': {
      'en': '',
      'ar': '',
      'de': '',
      'es': '',
    },
    't4xzlq9q': {
      'en': '',
      'ar': '',
      'de': '',
      'es': '',
    },
    '513nj4m0': {
      'en': '',
      'ar': '',
      'de': '',
      'es': '',
    },
    'a1jxfgju': {
      'en': '',
      'ar': '',
      'de': '',
      'es': '',
    },
  },
  // Dashboard financiero
  {
    'dash_por_motivo': {
      'en': 'Where the money went this month',
      'ar': 'أين ذهب المال هذا الشهر',
      'de': 'Wohin das Geld diesen Monat ging',
      'es': '¿A dónde se fue el dinero este mes?',
    },
    'dash_sin_motivo': {
      'en': 'No reason',
      'ar': 'بدون سبب',
      'de': 'Ohne Grund',
      'es': 'Sin motivo',
    },
    'dash_sin_egresos': {
      'en': 'No spending this month',
      'ar': 'لا توجد مصروفات هذا الشهر',
      'de': 'Keine Ausgaben in diesem Monat',
      'es': 'Sin egresos este mes',
    },
    'dash_titulo': {
      'en': 'Financial summary',
      'ar': 'الملخص المالي',
      'de': 'Finanzübersicht',
      'es': 'Resumen financiero',
    },
    'dash_saldo_total': {
      'en': 'Total balance',
      'ar': 'إجمالي الرصيد',
      'de': 'Gesamtsaldo',
      'es': 'Saldo total',
    },
    'dash_ingresos_mes': {
      'en': 'Income this month',
      'ar': 'دخل هذا الشهر',
      'de': 'Einnahmen des Monats',
      'es': 'Ingresos del mes',
    },
    'dash_egresos_mes': {
      'en': 'Spending this month',
      'ar': 'مصروفات هذا الشهر',
      'de': 'Ausgaben des Monats',
      'es': 'Egresos del mes',
    },
    'dash_gmf_mes': {
      'en': '4x1000 tax this month',
      'ar': 'ضريبة 4x1000 لهذا الشهر',
      'de': '4x1000-Steuer des Monats',
      'es': '4x1000 del mes',
    },
    'dash_neto_mes': {
      'en': 'Net this month',
      'ar': 'صافي الشهر',
      'de': 'Monatsergebnis',
      'es': 'Resultado del mes',
    },
    'dash_historico': {
      'en': 'Income vs spending (6 months)',
      'ar': 'الدخل مقابل المصروفات (6 أشهر)',
      'de': 'Einnahmen vs. Ausgaben (6 Monate)',
      'es': 'Ingresos vs egresos (6 meses)',
    },
    'dash_ingresos': {
      'en': 'Income',
      'ar': 'الدخل',
      'de': 'Einnahmen',
      'es': 'Ingresos',
    },
    'dash_egresos': {
      'en': 'Spending',
      'ar': 'المصروفات',
      'de': 'Ausgaben',
      'es': 'Egresos',
    },
    'dash_portafolios': {
      'en': 'Balance by portfolio',
      'ar': 'الرصيد حسب المحفظة',
      'de': 'Saldo pro Portfolio',
      'es': 'Saldo por portafolio',
    },
    'dash_movimientos': {
      'en': 'Latest transactions',
      'ar': 'أحدث الحركات',
      'de': 'Letzte Bewegungen',
      'es': 'Últimos movimientos',
    },
    'dash_sin_movimientos': {
      'en': 'No transactions yet',
      'ar': 'لا توجد حركات بعد',
      'de': 'Noch keine Bewegungen',
      'es': 'Aún no hay movimientos',
    },
    'dash_sin_portafolios': {
      'en': 'You have no portfolios yet. Create a project and a portfolio to start tracking your money.',
      'ar': 'ليس لديك محافظ بعد. أنشئ مشروعًا ومحفظة لبدء تتبع أموالك.',
      'de': 'Du hast noch keine Portfolios. Erstelle ein Projekt und ein Portfolio, um dein Geld zu erfassen.',
      'es': 'Aún no tienes portafolios. Crea un proyecto y un portafolio para empezar a registrar tu dinero.',
    },
    'dash_crear_portafolio': {
      'en': 'Go to projects',
      'ar': 'الانتقال إلى المشاريع',
      'de': 'Zu den Projekten',
      'es': 'Ir a proyectos',
    },
    'dash_error': {
      'en': 'Could not load the summary',
      'ar': 'تعذر تحميل الملخص',
      'de': 'Übersicht konnte nicht geladen werden',
      'es': 'No se pudo cargar el resumen',
    },
    'dash_reintentar': {
      'en': 'Retry',
      'ar': 'إعادة المحاولة',
      'de': 'Erneut versuchen',
      'es': 'Reintentar',
    },
  },
  // Movimientos
  {
    'mov_anular': {
      'en': 'Void',
      'ar': 'إلغاء',
      'de': 'Stornieren',
      'es': 'Anular',
    },
    'mov_anular_titulo': {
      'en': 'Void transaction?',
      'ar': 'إلغاء الحركة؟',
      'de': 'Bewegung stornieren?',
      'es': '¿Anular movimiento?',
    },
    'mov_anular_mensaje': {
      'en': 'The transaction will no longer count toward balances. It is kept in history and cannot be edited; to correct it, register it again.',
      'ar': 'لن تُحتسب الحركة في الأرصدة. تبقى في السجل ولا يمكن تعديلها؛ لتصحيحها سجّلها من جديد.',
      'de': 'Die Bewegung zählt nicht mehr zum Saldo. Sie bleibt im Verlauf und kann nicht bearbeitet werden; zur Korrektur erneut erfassen.',
      'es': 'El movimiento dejará de contar en los saldos. Queda en el historial y no se puede editar; para corregirlo, regístralo de nuevo.',
    },
    'mov_cancelar': {
      'en': 'Cancel',
      'ar': 'إلغاء الأمر',
      'de': 'Abbrechen',
      'es': 'Cancelar',
    },
    'mov_anulado': {
      'en': 'Transaction voided',
      'ar': 'تم إلغاء الحركة',
      'de': 'Bewegung storniert',
      'es': 'Movimiento anulado',
    },
  },
  // Respaldo y menú
  {
    'menu_inicio': {
      'en': 'Home',
      'ar': 'الرئيسية',
      'de': 'Start',
      'es': 'Inicio',
    },
    'menu_respaldo': {
      'en': 'Backup',
      'ar': 'النسخ الاحتياطي',
      'de': 'Sicherung',
      'es': 'Respaldo',
    },
    'resp_titulo': {
      'en': 'Backup and restore',
      'ar': 'النسخ الاحتياطي والاستعادة',
      'de': 'Sichern und wiederherstellen',
      'es': 'Respaldo y restauración',
    },
    'resp_intro': {
      'en': 'Your data is stored only on this device. Save a copy regularly in a safe place (an external drive or a synced cloud folder).',
      'ar': 'تُحفظ بياناتك على هذا الجهاز فقط. احفظ نسخة بانتظام في مكان آمن.',
      'de': 'Deine Daten werden nur auf diesem Gerät gespeichert. Speichere regelmäßig eine Kopie an einem sicheren Ort.',
      'es': 'Tus datos se guardan solo en este dispositivo. Guarda una copia con frecuencia en un lugar seguro (un disco externo o una carpeta sincronizada en la nube).',
    },
    'resp_exportar': {
      'en': 'Create backup',
      'ar': 'إنشاء نسخة احتياطية',
      'de': 'Sicherung erstellen',
      'es': 'Crear respaldo',
    },
    'resp_exportar_desc': {
      'en': 'Copies all your data to a .db file in the folder you choose.',
      'ar': 'ينسخ جميع بياناتك إلى ملف .db في المجلد الذي تختاره.',
      'de': 'Kopiert alle Daten in eine .db-Datei im gewählten Ordner.',
      'es': 'Copia todos tus datos en un archivo .db en la carpeta que elijas.',
    },
    'resp_restaurar': {
      'en': 'Restore',
      'ar': 'استعادة',
      'de': 'Wiederherstellen',
      'es': 'Restaurar',
    },
    'resp_restaurar_desc': {
      'en': 'Replaces the current data with a backup file. A safety copy of the current data is kept on this device.',
      'ar': 'يستبدل البيانات الحالية بملف نسخة احتياطية مع الاحتفاظ بنسخة من البيانات الحالية.',
      'de': 'Ersetzt die aktuellen Daten durch eine Sicherung. Eine Kopie der aktuellen Daten bleibt auf dem Gerät.',
      'es': 'Reemplaza los datos actuales por un archivo de respaldo. Se guarda una copia de seguridad de los datos actuales en este dispositivo.',
    },
    'resp_restaurar_titulo': {
      'en': 'Restore backup?',
      'ar': 'استعادة النسخة الاحتياطية؟',
      'de': 'Sicherung wiederherstellen?',
      'es': '¿Restaurar respaldo?',
    },
    'resp_restaurar_mensaje': {
      'en': 'All current data will be replaced by the selected backup.',
      'ar': 'سيتم استبدال جميع البيانات الحالية بالنسخة المختارة.',
      'de': 'Alle aktuellen Daten werden durch die gewählte Sicherung ersetzt.',
      'es': 'Todos los datos actuales serán reemplazados por los del respaldo que selecciones.',
    },
    'resp_elegir_carpeta': {
      'en': 'Choose where to save the backup',
      'ar': 'اختر مكان حفظ النسخة',
      'de': 'Speicherort wählen',
      'es': 'Elige dónde guardar el respaldo',
    },
    'resp_elegir_archivo': {
      'en': 'Choose the backup file',
      'ar': 'اختر ملف النسخة الاحتياطية',
      'de': 'Sicherungsdatei wählen',
      'es': 'Elige el archivo de respaldo',
    },
    'resp_exportado': {
      'en': 'Backup saved:',
      'ar': 'تم حفظ النسخة:',
      'de': 'Sicherung gespeichert:',
      'es': 'Respaldo guardado:',
    },
    'resp_restaurado': {
      'en': 'Data restored',
      'ar': 'تمت استعادة البيانات',
      'de': 'Daten wiederhergestellt',
      'es': 'Datos restaurados',
    },
  },
].reduce((a, b) => a..addAll(b));
