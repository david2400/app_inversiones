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
  },
  // forgotPassword
  {
    'xaiad71o': {
      'en':
          'Enter the email associated with your account and we will send you a verification code.',
      'ar': 'أدخل البريد الإلكتروني المرتبط بحسابك وسنرسل لك رمز التحقق.',
      'de':
          'Geben Sie die mit Ihrem Konto verknüpfte E-Mail-Adresse ein und wir senden Ihnen einen Bestätigungscode.',
      'es':
          'Introduce el correo electrónico asociado a tu cuenta y te enviaremos un código de verificación.',
    },
  },
  // onboarding
  {
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
    'uf9k1spp': {
      'en':
          'Easily add transactions and associate them with budgets that have been created.',
      'ar': 'أضف المعاملات بسهولة وربطها بالميزانيات التي تم إنشاؤها.',
      'de':
          'Fügen Sie ganz einfach Transaktionen hinzu und verknüpfen Sie sie mit erstellten Budgets.',
      'es':
          'Agregue fácilmente transacciones y asócielas con los presupuestos que se han creado.',
    },
  },
  // portafolioPage
  {
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
    '85pb8msl': {
      'en': '4.5% ',
      'ar': '4.5٪',
      'de': '4,5 %',
      'es': '4,5%',
    },
  },
  // transactions
  {
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
  },
  // paymentDetailsPage
  {
  },
  // MY_profilePage
  {
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
  },
  // addTransferFunds
  {
    'r89hyhq3': {
      'en': 'Valor',
      'ar': 'Valor',
      'de': 'Valor',
      'es': 'Valor',
    },
    '147fye16': {
      'en': 'Tipo de transferencia',
      'ar': '',
      'de': '',
      'es': 'Tipo de transferencia',
    },
    'tcckgjcg': {
      'en': 'Reason',
      'ar': 'السبب',
      'de': 'Grund',
      'es': 'Motivo',
    },
    'uxo88fjc': {
      'en': 'Cuenta Alterna',
      'ar': '',
      'de': '',
      'es': '',
    },

    'xaw2jdst': {
      'en': 'Send Transfer',
      'ar': 'أرسل حوالة',
      'de': 'Überweisung senden',
      'es': 'Enviar transferencia',
    },
  },
  // Tipo de proyecto
  {
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
  },
  // notificationsSettings
  {
    'r72zvrv5': {
      'en':
          'Choose what notifcations you want to recieve below and we will update the settings.',
      'ar': 'اختر الإشعارات التي تريد تلقيها أدناه وسنقوم بتحديث الإعدادات.',
      'de':
          'Wählen Sie unten aus, welche Benachrichtigungen Sie erhalten möchten, und wir aktualisieren die Einstellungen.',
      'es':
          'Elija qué notificaciones desea recibir a continuación y actualizaremos la configuración.',
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
  },
  // homePage
  {
    '6z1sm34j': {
      'en': 'Total Balance',
      'ar': 'Total Balance',
      'de': 'Total Balance',
      'es': 'Total Balance',
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
  },
  // homePage_alt
  {
    '7zcrtqx6': {
      'en':
          'We noticed a small charge that is out of character of this account, please review.',
      'ar': 'لقد لاحظنا تكلفة صغيرة خارجة عن طبيعة هذا الحساب ، يرجى المراجعة.',
      'de':
          'Wir haben eine kleine Belastung festgestellt, die für dieses Konto untypisch ist. Bitte überprüfen Sie diese.',
      'es':
          'Notamos un pequeño cargo que está fuera de lugar en esta cuenta, revíselo.',
    },
  },
  // budget_DELETE
  {
    'aptjmof0': {
      'en':
          'If you delete this budget, your transactions will no longer be associated with it.',
      'ar': 'إذا حذفت هذه الميزانية ، فلن تكون معاملاتك مرتبطة بها بعد الآن.',
      'de':
          'Wenn Sie dieses Budget löschen, sind Ihre Transaktionen nicht mehr damit verknüpft.',
      'es':
          'Si elimina este presupuesto, sus transacciones ya no estarán asociadas a él.',
    },
  },
  // Tipo Transferencia
  {
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
  },
  // bookAppointment
  {
    '4skzh9os': {
      'en':
          'Fill out the information below in order to book your appointment with our office.',
      'ar': 'املأ المعلومات أدناه من أجل حجز موعدك مع مكتبنا.',
      'de':
          'Füllen Sie die folgenden Informationen aus, um Ihren Termin in unserem Büro zu buchen.',
      'es':
          'Complete la información a continuación para reservar su cita con nuestra oficina.',
    },
  },
  // bookingOld
  {
    'udwhsu8p': {
      'en':
          'Fill out the information below in order to book your appointment with our office.',
      'ar': 'املأ المعلومات أدناه من أجل حجز موعدك مع مكتبنا.',
      'de':
          'Füllen Sie die folgenden Informationen aus, um Ihren Termin in unserem Büro zu buchen.',
      'es':
          'Complete la información a continuación para reservar su cita con nuestra oficina.',
    },
  },
  // editBooking
  {
  },
  // pauseCard
  {
  },
  // Miscellaneous
  {
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
    'exp_titulo': {
      'en': 'Export transactions (CSV)',
      'ar': 'تصدير الحركات (CSV)',
      'de': 'Bewegungen exportieren (CSV)',
      'es': 'Exportar movimientos (CSV)',
    },
    'exp_desc': {
      'en': 'Creates a file you can open in Excel or Google Sheets with every active transaction of the chosen period.',
      'ar': 'ينشئ ملفًا يمكن فتحه في Excel أو Google Sheets بجميع الحركات النشطة للفترة المختارة.',
      'de': 'Erstellt eine Datei für Excel oder Google Sheets mit allen aktiven Bewegungen des Zeitraums.',
      'es': 'Crea un archivo que puedes abrir en Excel o Google Sheets con todos los movimientos activos del periodo elegido.',
    },
    'exp_accion': {
      'en': 'Export',
      'ar': 'تصدير',
      'de': 'Exportieren',
      'es': 'Exportar',
    },
    'exp_mes': {
      'en': 'This month',
      'ar': 'هذا الشهر',
      'de': 'Dieser Monat',
      'es': 'Este mes',
    },
    'exp_anio': {
      'en': 'This year',
      'ar': 'هذه السنة',
      'de': 'Dieses Jahr',
      'es': 'Este año',
    },
    'exp_todo': {
      'en': 'All',
      'ar': 'الكل',
      'de': 'Alles',
      'es': 'Todo',
    },
    'exp_exportado': {
      'en': 'File exported:',
      'ar': 'تم تصدير الملف:',
      'de': 'Datei exportiert:',
      'es': 'Archivo exportado:',
    },
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
      'en': 'Backup and export',
      'ar': 'النسخ الاحتياطي والتصدير',
      'de': 'Sichern und exportieren',
      'es': 'Respaldo y exportación',
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
  // Reportes
  {
    'rep_evolucion': {
      'en': 'Balance over the year',
      'ar': 'تطور الرصيد',
      'de': 'Saldoentwicklung',
      'es': 'Evolución del saldo',
    },
    'rep_evolucion_ayuda': {
      'en': 'Balance at the end of each month. Starting balance on Jan 1:',
      'ar': 'الرصيد في نهاية كل شهر. الرصيد في 1 يناير:',
      'de': 'Saldo am Monatsende. Anfangssaldo am 1. Januar:',
      'es': 'Saldo al cierre de cada mes. Saldo al 1 de enero:',
    },
    'menu_reportes': {
      'en': 'Reports',
      'ar': 'التقارير',
      'de': 'Berichte',
      'es': 'Reportes',
    },
    'rep_titulo': {
      'en': 'Annual report',
      'ar': 'التقرير السنوي',
      'de': 'Jahresbericht',
      'es': 'Reporte anual',
    },
    'rep_todos': {
      'en': 'All projects',
      'ar': 'جميع المشاريع',
      'de': 'Alle Projekte',
      'es': 'Todos los proyectos',
    },
    'rep_mes': {
      'en': 'Month',
      'ar': 'الشهر',
      'de': 'Monat',
      'es': 'Mes',
    },
    'rep_ingresos': {
      'en': 'Income',
      'ar': 'الدخل',
      'de': 'Einnahmen',
      'es': 'Ingresos',
    },
    'rep_egresos': {
      'en': 'Spending',
      'ar': 'المصروفات',
      'de': 'Ausgaben',
      'es': 'Egresos',
    },
    'rep_gmf': {
      'en': '4x1000 tax',
      'ar': 'ضريبة 4x1000',
      'de': '4x1000-Steuer',
      'es': '4x1000',
    },
    'rep_neto': {
      'en': 'Net',
      'ar': 'الصافي',
      'de': 'Netto',
      'es': 'Neto',
    },
    'rep_total': {
      'en': 'Total',
      'ar': 'الإجمالي',
      'de': 'Gesamt',
      'es': 'Total',
    },
  },
  // Terceros, formulario de movimientos y reportes de flujo
  {
    'menu_terceros': {
      'en': 'Payers and payees',
      'ar': 'الأطراف',
      'de': 'Gegenparteien',
      'es': 'Terceros',
    },
    'ter_titulo': {
      'en': 'Payers and payees',
      'ar': 'الأطراف',
      'de': 'Gegenparteien',
      'es': 'Terceros',
    },
    'ter_vacio': {
      'en': 'Add who pays you (employer, clients) and whom you pay (landlord, stores, services). Then pick them when you record a transaction.',
      'ar': 'أضف من يدفع لك ومن تدفع له، ثم اخترهم عند تسجيل حركة.',
      'de': 'Füge hinzu, wer dich bezahlt und wen du bezahlst. Wähle sie dann bei einer Bewegung aus.',
      'es': 'Agrega quién te paga (empleador, clientes) y a quién le pagas (arrendador, tiendas, servicios). Luego elígelos al registrar un movimiento.',
    },
    'ter_nuevo': {
      'en': 'New payer/payee',
      'ar': 'طرف جديد',
      'de': 'Neue Gegenpartei',
      'es': 'Nuevo tercero',
    },
    'ter_editar': {
      'en': 'Edit payer/payee',
      'ar': 'تعديل الطرف',
      'de': 'Gegenpartei bearbeiten',
      'es': 'Editar tercero',
    },
    'ter_nombre': {
      'en': 'Name',
      'ar': 'الاسم',
      'de': 'Name',
      'es': 'Nombre',
    },
    'ter_descripcion': {
      'en': 'Description (optional)',
      'ar': 'الوصف (اختياري)',
      'de': 'Beschreibung (optional)',
      'es': 'Descripción (opcional)',
    },
    'ter_guardar': {
      'en': 'Save',
      'ar': 'حفظ',
      'de': 'Speichern',
      'es': 'Guardar',
    },
    'ter_eliminar': {
      'en': 'Delete',
      'ar': 'حذف',
      'de': 'Löschen',
      'es': 'Eliminar',
    },
    'ter_eliminar_titulo': {
      'en': 'Delete payer/payee?',
      'ar': 'حذف الطرف؟',
      'de': 'Gegenpartei löschen?',
      'es': '¿Eliminar tercero?',
    },
    'frm_titulo': {
      'en': 'New transaction',
      'ar': 'حركة جديدة',
      'de': 'Neue Bewegung',
      'es': 'Nuevo movimiento',
    },
    'frm_tipo': {
      'en': 'Transaction type',
      'ar': 'نوع الحركة',
      'de': 'Bewegungsart',
      'es': 'Tipo de movimiento',
    },
    'frm_ingreso': {
      'en': 'Income',
      'ar': 'دخل',
      'de': 'Einnahme',
      'es': 'Ingreso',
    },
    'frm_egreso': {
      'en': 'Expense',
      'ar': 'مصروف',
      'de': 'Ausgabe',
      'es': 'Egreso',
    },
    'frm_transferencia': {
      'en': 'Transfer',
      'ar': 'تحويل',
      'de': 'Überweisung',
      'es': 'Transferencia',
    },
    'frm_valor': {
      'en': 'Amount',
      'ar': 'المبلغ',
      'de': 'Betrag',
      'es': 'Valor',
    },
    'frm_fecha': {
      'en': 'Date',
      'ar': 'التاريخ',
      'de': 'Datum',
      'es': 'Fecha',
    },
    'frm_cuenta_entra': {
      'en': 'Account that receives the money',
      'ar': 'الحساب المستلم',
      'de': 'Empfangendes Konto',
      'es': '¿A qué cuenta entra el dinero?',
    },
    'frm_cuenta_sale': {
      'en': 'Account the money leaves from',
      'ar': 'الحساب المصدر',
      'de': 'Ausgangskonto',
      'es': '¿De qué cuenta sale el dinero?',
    },
    'frm_hacia': {
      'en': 'Send to',
      'ar': 'إلى أين؟',
      'de': 'Wohin?',
      'es': '¿Hacia dónde va?',
    },
    'frm_mi_cuenta': {
      'en': 'My account',
      'ar': 'حسابي',
      'de': 'Mein Konto',
      'es': 'Mi cuenta',
    },
    'frm_cuenta_externa': {
      'en': 'External account',
      'ar': 'حساب خارجي',
      'de': 'Externes Konto',
      'es': 'Cuenta externa',
    },
    'frm_cuenta_externa_dato': {
      'en': 'External account (bank, number, person)',
      'ar': 'الحساب الخارجي (البنك، الرقم، الاسم)',
      'de': 'Externes Konto (Bank, Nummer, Inhaber)',
      'es': 'Cuenta externa (banco, número, titular)',
    },
    'frm_cuenta_destino': {
      'en': 'Destination account',
      'ar': 'الحساب الوجهة',
      'de': 'Zielkonto',
      'es': 'Cuenta destino',
    },
    'frm_quien_pago': {
      'en': 'Who paid you? (optional)',
      'ar': 'من دفع لك؟ (اختياري)',
      'de': 'Wer hat bezahlt? (optional)',
      'es': '¿Quién te pagó? (opcional)',
    },
    'frm_a_quien': {
      'en': 'Who did you pay? (optional)',
      'ar': 'لمن دفعت؟ (اختياري)',
      'de': 'Wen hast du bezahlt? (optional)',
      'es': '¿A quién le pagaste? (opcional)',
    },
    'frm_motivo': {
      'en': 'Reason / category (optional)',
      'ar': 'السبب / الفئة (اختياري)',
      'de': 'Grund / Kategorie (optional)',
      'es': 'Motivo / categoría (opcional)',
    },
    'frm_descripcion': {
      'en': 'Description (optional)',
      'ar': 'الوصف (اختياري)',
      'de': 'Beschreibung (optional)',
      'es': 'Descripción (opcional)',
    },
    'frm_gmf': {
      'en': '4x1000 tax',
      'ar': 'ضريبة 4x1000',
      'de': '4x1000-Steuer',
      'es': '4x1000',
    },
    'frm_total_debitado': {
      'en': 'Total debited',
      'ar': 'إجمالي الخصم',
      'de': 'Gesamtbelastung',
      'es': 'Total a debitar',
    },
    'frm_saldo_actual': {
      'en': 'Current balance',
      'ar': 'الرصيد الحالي',
      'de': 'Aktueller Saldo',
      'es': 'Saldo actual',
    },
    'frm_saldo_despues': {
      'en': 'Balance after',
      'ar': 'الرصيد بعد',
      'de': 'Saldo danach',
      'es': 'Saldo después',
    },
    'frm_saldo_insuficiente': {
      'en': 'Insufficient balance: the transaction will be rejected.',
      'ar': 'الرصيد غير كافٍ: سيتم رفض الحركة.',
      'de': 'Unzureichender Saldo: die Bewegung wird abgelehnt.',
      'es': 'Saldo insuficiente: el movimiento será rechazado.',
    },
    'frm_guardar': {
      'en': 'Save transaction',
      'ar': 'حفظ الحركة',
      'de': 'Bewegung speichern',
      'es': 'Guardar movimiento',
    },
    'frm_guardado': {
      'en': 'Transaction saved',
      'ar': 'تم حفظ الحركة',
      'de': 'Bewegung gespeichert',
      'es': 'Movimiento guardado',
    },
    'frm_ninguno': {
      'en': 'None',
      'ar': 'لا شيء',
      'de': 'Keine',
      'es': 'Ninguno',
    },
    'frm_seleccione': {
      'en': 'Select…',
      'ar': 'اختر…',
      'de': 'Auswählen…',
      'es': 'Selecciona…',
    },
    'frm_error_tipo': {
      'en': 'Select the transaction type',
      'ar': 'اختر نوع الحركة',
      'de': 'Wähle die Bewegungsart',
      'es': 'Selecciona el tipo de movimiento',
    },
    'frm_error_valor': {
      'en': 'Enter an amount greater than zero',
      'ar': 'أدخل مبلغًا أكبر من صفر',
      'de': 'Gib einen Betrag größer als null ein',
      'es': 'Ingresa un valor mayor a cero',
    },
    'frm_error_cuenta': {
      'en': 'Select the account',
      'ar': 'اختر الحساب',
      'de': 'Wähle das Konto',
      'es': 'Selecciona la cuenta',
    },
    'frm_error_destino': {
      'en': 'Select the destination account',
      'ar': 'اختر الحساب الوجهة',
      'de': 'Wähle das Zielkonto',
      'es': 'Selecciona la cuenta destino',
    },
    'frm_error_externa': {
      'en': 'Enter the external account',
      'ar': 'أدخل الحساب الخارجي',
      'de': 'Gib das externe Konto ein',
      'es': 'Escribe la cuenta externa',
    },
    'det_fecha': {
      'en': 'Date',
      'ar': 'التاريخ',
      'de': 'Datum',
      'es': 'Fecha',
    },
    'det_cuenta': {
      'en': 'Account',
      'ar': 'الحساب',
      'de': 'Konto',
      'es': 'Cuenta',
    },
    'det_tercero': {
      'en': 'Payer / payee',
      'ar': 'الطرف',
      'de': 'Gegenpartei',
      'es': 'Tercero',
    },
    'det_gmf': {
      'en': '4x1000 tax',
      'ar': 'ضريبة 4x1000',
      'de': '4x1000-Steuer',
      'es': '4x1000',
    },
    'det_recorrido': {
      'en': 'Money flow',
      'ar': 'مسار المال',
      'de': 'Geldfluss',
      'es': 'Recorrido del dinero',
    },
    'det_desde': {
      'en': 'From',
      'ar': 'من',
      'de': 'Von',
      'es': 'Desde',
    },
    'det_hacia': {
      'en': 'To',
      'ar': 'إلى',
      'de': 'An',
      'es': 'Hacia',
    },
    'det_detalles': {
      'en': 'Details',
      'ar': 'التفاصيل',
      'de': 'Details',
      'es': 'Detalles',
    },
    'det_tipo': {
      'en': 'Type',
      'ar': 'النوع',
      'de': 'Art',
      'es': 'Tipo',
    },
    'det_motivo': {
      'en': 'Reason',
      'ar': 'السبب',
      'de': 'Grund',
      'es': 'Motivo',
    },
    'det_descripcion': {
      'en': 'Description',
      'ar': 'الوصف',
      'de': 'Beschreibung',
      'es': 'Descripción',
    },
    'det_cuenta_externa': {
      'en': 'External account',
      'ar': 'حساب خارجي',
      'de': 'Externes Konto',
      'es': 'Cuenta externa',
    },
    'det_valor': {
      'en': 'Amount',
      'ar': 'المبلغ',
      'de': 'Betrag',
      'es': 'Valor',
    },
    'det_total_debitado': {
      'en': 'Total debited',
      'ar': 'إجمالي الخصم',
      'de': 'Gesamtbelastung',
      'es': 'Total debitado',
    },
    'det_error': {
      'en': 'The transaction could not be loaded.',
      'ar': 'تعذر تحميل الحركة.',
      'de': 'Die Bewegung konnte nicht geladen werden.',
      'es': 'No se pudo cargar el movimiento.',
    },
    'det_reintentar': {
      'en': 'Retry',
      'ar': 'إعادة المحاولة',
      'de': 'Erneut versuchen',
      'es': 'Reintentar',
    },
    'det_anular_movimiento': {
      'en': 'Void transaction',
      'ar': 'إلغاء الحركة',
      'de': 'Bewegung stornieren',
      'es': 'Anular movimiento',
    },
    'det_anular_ayuda': {
      'en': 'Voiding removes it from balances and cannot be undone. To correct it, void it and register it again.',
      'ar': 'الإلغاء يزيلها من الأرصدة ولا يمكن التراجع عنه. لتصحيحها ألغها وسجّلها من جديد.',
      'de': 'Stornieren entfernt sie aus den Salden und kann nicht rückgängig gemacht werden. Zur Korrektur stornieren und neu erfassen.',
      'es': 'Anular lo excluye de los saldos y no se puede deshacer. Para corregirlo, anúlalo y regístralo de nuevo.',
    },
    'dash_por_origen': {
      'en': 'Where the money came from this month',
      'ar': 'من أين جاء المال هذا الشهر',
      'de': 'Woher das Geld diesen Monat kam',
      'es': '¿De dónde vino el dinero este mes?',
    },
    'dash_sin_especificar': {
      'en': 'Not specified',
      'ar': 'غير محدد',
      'de': 'Nicht angegeben',
      'es': 'Sin especificar',
    },
    'dash_sin_ingresos': {
      'en': 'No income in this period',
      'ar': 'لا يوجد دخل في هذه الفترة',
      'de': 'Keine Einnahmen in diesem Zeitraum',
      'es': 'Sin ingresos en este periodo',
    },
    'dash_otros': {
      'en': 'Others',
      'ar': 'أخرى',
      'de': 'Andere',
      'es': 'Otros',
    },
    'rep_origen': {
      'en': 'Where the money came from',
      'ar': 'من أين جاء المال؟',
      'de': 'Woher kam das Geld?',
      'es': '¿De dónde vino el dinero?',
    },
    'rep_origen_ayuda': {
      'en': 'Income by payer (or reason if none was recorded)',
      'ar': 'الدخل حسب الطرف (أو السبب)',
      'de': 'Einnahmen nach Gegenpartei (oder Grund)',
      'es': 'Ingresos por tercero (o por motivo si no se registró)',
    },
    'rep_destino': {
      'en': 'Where the money went',
      'ar': 'إلى أين ذهب المال؟',
      'de': 'Wohin ging das Geld?',
      'es': '¿A dónde se fue el dinero?',
    },
    'rep_destino_ayuda': {
      'en': 'Expenses by payee, external account or reason',
      'ar': 'المصروفات حسب الطرف أو الحساب الخارجي أو السبب',
      'de': 'Ausgaben nach Gegenpartei, externem Konto oder Grund',
      'es': 'Egresos por tercero, cuenta externa o motivo',
    },
    'rep_motivo': {
      'en': 'What it was spent on',
      'ar': 'فيم أُنفق؟',
      'de': 'Wofür wurde ausgegeben?',
      'es': '¿En qué se gastó?',
    },
    'rep_motivo_ayuda': {
      'en': 'Expenses by reason / category',
      'ar': 'المصروفات حسب السبب / الفئة',
      'de': 'Ausgaben nach Grund / Kategorie',
      'es': 'Egresos por motivo / categoría',
    },
    'rep_flujos': {
      'en': 'Transfers between accounts',
      'ar': 'الحركات بين الحسابات',
      'de': 'Bewegungen zwischen Konten',
      'es': 'Movimientos entre cuentas',
    },
    'rep_flujos_ayuda': {
      'en': 'From which account to which, and the 4x1000 paid',
      'ar': 'من أي حساب إلى أي حساب وضريبة 4x1000',
      'de': 'Von welchem Konto zu welchem, und die gezahlte Steuer',
      'es': 'De qué cuenta a cuál, y el 4x1000 pagado',
    },
    'rep_sin_flujos': {
      'en': 'No transfers in this period',
      'ar': 'لا توجد تحويلات في هذه الفترة',
      'de': 'Keine Überweisungen in diesem Zeitraum',
      'es': 'Sin transferencias en este periodo',
    },
    'rep_cuenta_externa': {
      'en': 'external account',
      'ar': 'حساب خارجي',
      'de': 'externes Konto',
      'es': 'cuenta externa',
    },
  },
  // Historial de movimientos
  {
    'his_ver_completo': {
      'en': 'Showing the latest 200. See the full history',
      'ar': 'عرض أحدث 200. عرض السجل الكامل',
      'de': 'Die letzten 200 werden angezeigt. Vollständigen Verlauf anzeigen',
      'es': 'Se muestran los 200 más recientes. Ver historial completo',
    },
    'por_saldo_inicial': {
      'en': 'Opening balance (optional)',
      'ar': 'الرصيد الافتتاحي (اختياري)',
      'de': 'Anfangssaldo (optional)',
      'es': 'Saldo inicial (opcional)',
    },
    'por_saldo_inicial_ayuda': {
      'en': 'Money already in this account; recorded as an income',
      'ar': 'المال الموجود بالفعل؛ يُسجَّل كدخل',
      'de': 'Bereits vorhandenes Geld; wird als Einnahme erfasst',
      'es': 'Dinero que ya hay en la cuenta; se registra como un ingreso',
    },
    'menu_movimientos': {
      'en': 'Transactions',
      'ar': 'الحركات',
      'de': 'Bewegungen',
      'es': 'Movimientos',
    },
    'his_titulo': {
      'en': 'Transactions',
      'ar': 'الحركات',
      'de': 'Bewegungen',
      'es': 'Movimientos',
    },
    'his_buscar': {
      'en': 'Search description, payer, reason or account',
      'ar': 'ابحث في الوصف أو الطرف أو السبب أو الحساب',
      'de': 'Beschreibung, Gegenpartei, Grund oder Konto suchen',
      'es': 'Buscar descripción, tercero, motivo o cuenta',
    },
    'his_mes_anterior': {
      'en': 'Last month',
      'ar': 'الشهر الماضي',
      'de': 'Letzter Monat',
      'es': 'Mes anterior',
    },
    'his_todos': {
      'en': 'All',
      'ar': 'الكل',
      'de': 'Alle',
      'es': 'Todos',
    },
    'his_mas_filtros': {
      'en': 'More filters',
      'ar': 'مرشحات إضافية',
      'de': 'Weitere Filter',
      'es': 'Más filtros',
    },
    'his_vacio': {
      'en': 'No transactions match the filters',
      'ar': 'لا توجد حركات مطابقة',
      'de': 'Keine Bewegungen für diese Filter',
      'es': 'No hay movimientos con estos filtros',
    },
    'his_truncado': {
      'en': 'Showing',
      'ar': 'عرض',
      'de': 'Angezeigt',
      'es': 'Mostrando',
    },
  },
  // Presupuestos
  {
    'menu_presupuestos': {
      'en': 'Budgets',
      'ar': 'الميزانيات',
      'de': 'Budgets',
      'es': 'Presupuestos',
    },
    'pre_titulo': {
      'en': 'Monthly budgets',
      'ar': 'الميزانيات الشهرية',
      'de': 'Monatsbudgets',
      'es': 'Presupuestos del mes',
    },
    'pre_nuevo': {
      'en': 'New budget',
      'ar': 'ميزانية جديدة',
      'de': 'Neues Budget',
      'es': 'Nuevo presupuesto',
    },
    'pre_editar': {
      'en': 'Edit budget',
      'ar': 'تعديل الميزانية',
      'de': 'Budget bearbeiten',
      'es': 'Editar presupuesto',
    },
    'pre_monto': {
      'en': 'Monthly limit',
      'ar': 'الحد الشهري',
      'de': 'Monatslimit',
      'es': 'Límite mensual',
    },
    'pre_error_motivo': {
      'en': 'Select a reason',
      'ar': 'اختر سببًا',
      'de': 'Wähle einen Grund',
      'es': 'Selecciona un motivo',
    },
    'pre_vacio': {
      'en': 'Set a monthly limit per reason (Groceries, Transport...) and see how much you have left this month.',
      'ar': 'حدد حدًا شهريًا لكل سبب وتابع المتبقي هذا الشهر.',
      'de': 'Lege ein Monatslimit pro Grund fest und sieh, wie viel übrig ist.',
      'es': 'Define un límite mensual por motivo (Mercado, Transporte…) y mira cuánto te queda este mes.',
    },
    'pre_total_mes': {
      'en': 'Spent this month',
      'ar': 'المصروف هذا الشهر',
      'de': 'Diesen Monat ausgegeben',
      'es': 'Gastado este mes',
    },
    'pre_disponible': {
      'en': 'Left:',
      'ar': 'المتبقي:',
      'de': 'Verfügbar:',
      'es': 'Disponible:',
    },
    'pre_excedido': {
      'en': 'Over by',
      'ar': 'تجاوز بمقدار',
      'de': 'Überschritten um',
      'es': 'Excedido en',
    },
    'dash_presupuestos': {
      'en': 'Budgets this month',
      'ar': 'ميزانيات الشهر',
      'de': 'Budgets des Monats',
      'es': 'Presupuestos del mes',
    },
    'dash_ver_todos': {
      'en': 'See all',
      'ar': 'عرض الكل',
      'de': 'Alle anzeigen',
      'es': 'Ver todos',
    },
  },
  // Movimientos fijos
  {
    'menu_app': {
      'en': 'My finances',
      'ar': 'أموالي',
      'de': 'Meine Finanzen',
      'es': 'Mis finanzas',
    },
    'menu_fijos': {
      'en': 'Recurring',
      'ar': 'الحركات الثابتة',
      'de': 'Daueraufträge',
      'es': 'Movimientos fijos',
    },
    'fij_titulo': {
      'en': 'Recurring transactions',
      'ar': 'الحركات الثابتة',
      'de': 'Wiederkehrende Bewegungen',
      'es': 'Movimientos fijos',
    },
    'fij_vacio': {
      'en': 'No recurring transactions yet. When you record one (rent, salary, utilities), turn on "Repeat every month".',
      'ar': 'لا توجد حركات ثابتة بعد. فعّل "التكرار كل شهر" عند التسجيل.',
      'de': 'Noch keine wiederkehrenden Bewegungen. Aktiviere beim Erfassen "Jeden Monat wiederholen".',
      'es': 'Aún no tienes movimientos fijos. Al registrar uno (arriendo, salario, servicios), activa "Repetir cada mes".',
    },
    'fij_editar': {
      'en': 'Edit recurring transaction',
      'ar': 'تعديل الحركة الثابتة',
      'de': 'Wiederkehrende Bewegung bearbeiten',
      'es': 'Editar movimiento fijo',
    },
    'fij_dia': {
      'en': 'Day of the month (1-31)',
      'ar': 'يوم الشهر (1-31)',
      'de': 'Tag des Monats (1-31)',
      'es': 'Día del mes (1-31)',
    },
    'fij_registrado': {
      'en': 'Recorded this month',
      'ar': 'مسجل هذا الشهر',
      'de': 'Diesen Monat erfasst',
      'es': 'Registrado este mes',
    },
    'fij_pendiente': {
      'en': 'Pending',
      'ar': 'معلق',
      'de': 'Ausstehend',
      'es': 'Pendiente',
    },
    'fij_pausado': {
      'en': 'Paused',
      'ar': 'موقوف',
      'de': 'Pausiert',
      'es': 'Pausado',
    },
    'fij_registrar': {
      'en': 'Record',
      'ar': 'تسجيل',
      'de': 'Erfassen',
      'es': 'Registrar',
    },
    'fij_pausar': {
      'en': 'Pause',
      'ar': 'إيقاف مؤقت',
      'de': 'Pausieren',
      'es': 'Pausar',
    },
    'fij_reactivar': {
      'en': 'Resume',
      'ar': 'استئناف',
      'de': 'Fortsetzen',
      'es': 'Reactivar',
    },
    'frm_repetir': {
      'en': 'Repeat every month',
      'ar': 'التكرار كل شهر',
      'de': 'Jeden Monat wiederholen',
      'es': 'Repetir cada mes',
    },
    'frm_repetir_ayuda': {
      'en': 'Saved as a recurring transaction on day',
      'ar': 'تُحفظ كحركة ثابتة في اليوم',
      'de': 'Als Dauerauftrag gespeichert am Tag',
      'es': 'Se guarda como movimiento fijo el día',
    },
    'frm_nombre_fijo': {
      'en': 'Name (e.g. Rent, Salary)',
      'ar': 'الاسم (مثل الإيجار، الراتب)',
      'de': 'Name (z. B. Miete, Gehalt)',
      'es': 'Nombre (ej. Arriendo, Salario)',
    },
    'dash_pendientes': {
      'en': 'Pending this month',
      'ar': 'المعلقة هذا الشهر',
      'de': 'Diesen Monat ausstehend',
      'es': 'Pendientes este mes',
    },
  },
  // Ajuste de saldo
  {
    'aju_titulo': {
      'en': 'Adjust balance',
      'ar': 'تسوية الرصيد',
      'de': 'Saldo anpassen',
      'es': 'Ajustar saldo',
    },
    'aju_saldo_app': {
      'en': 'Balance in the app',
      'ar': 'الرصيد في التطبيق',
      'de': 'Saldo in der App',
      'es': 'Saldo en la app',
    },
    'aju_saldo_real': {
      'en': 'Real balance (bank statement)',
      'ar': 'الرصيد الفعلي (حسب البنك)',
      'de': 'Tatsächlicher Saldo (Bank)',
      'es': 'Saldo real (según el banco)',
    },
    'aju_ingreso': {
      'en': 'An income will be recorded for',
      'ar': 'سيُسجَّل دخل بمبلغ',
      'de': 'Es wird eine Einnahme erfasst über',
      'es': 'Se registrará un ingreso por',
    },
    'aju_egreso': {
      'en': 'An expense will be recorded for',
      'ar': 'سيُسجَّل مصروف بمبلغ',
      'de': 'Es wird eine Ausgabe erfasst über',
      'es': 'Se registrará un egreso por',
    },
    'aju_ayuda': {
      'en': 'Use it when the app does not match your bank. It is recorded as "Balance adjustment", without the 4x1000 tax.',
      'ar': 'استخدمه عندما لا يتطابق التطبيق مع البنك. يُسجَّل بدون ضريبة 4x1000.',
      'de': 'Verwende es, wenn die App nicht mit der Bank übereinstimmt. Ohne 4x1000-Steuer.',
      'es': 'Úsalo cuando la app no cuadre con tu banco. Queda registrado como "Ajuste de saldo", sin 4x1000.',
    },
    'aju_confirmar': {
      'en': 'Adjust',
      'ar': 'تسوية',
      'de': 'Anpassen',
      'es': 'Ajustar',
    },
    'aju_hecho': {
      'en': 'Balance adjusted',
      'ar': 'تمت تسوية الرصيد',
      'de': 'Saldo angepasst',
      'es': 'Saldo ajustado',
    },
    // Motivos (pantalla de listado)
    'mot_titulo': {
      'en': 'Reasons',
      'ar': 'الأسباب',
      'de': 'Gründe',
      'es': 'Motivos',
    },
    'mot_subtitulo': {
      'en': 'Classify why money comes in or goes out.',
      'ar': 'صنّف سبب دخول المال أو خروجه.',
      'de': 'Ordne zu, warum Geld ein- oder ausgeht.',
      'es': 'Clasifica por qué entra o sale el dinero.',
    },
    'mot_agregar': {
      'en': 'New reason',
      'ar': 'سبب جديد',
      'de': 'Neuer Grund',
      'es': 'Nuevo motivo',
    },
    'mot_vacio': {
      'en': 'You have no reasons yet. Create one to classify your income and expenses.',
      'ar': 'لا توجد أسباب بعد. أنشئ سببًا لتصنيف دخلك ومصروفاتك.',
      'de': 'Noch keine Gründe vorhanden. Lege einen an, um Einnahmen und Ausgaben zu ordnen.',
      'es': 'Aún no tienes motivos. Crea uno para clasificar tus ingresos y egresos.',
    },
    'mot_error': {
      'en': 'Reasons could not be loaded.',
      'ar': 'تعذّر تحميل الأسباب.',
      'de': 'Die Gründe konnten nicht geladen werden.',
      'es': 'No se pudieron cargar los motivos.',
    },
    'mot_reintentar': {
      'en': 'Retry',
      'ar': 'إعادة المحاولة',
      'de': 'Erneut versuchen',
      'es': 'Reintentar',
    },
    'mot_sin_descripcion': {
      'en': 'No description',
      'ar': 'بدون وصف',
      'de': 'Keine Beschreibung',
      'es': 'Sin descripción',
    },
    'mot_total': {
      'en': 'registered',
      'ar': 'مسجّلة',
      'de': 'erfasst',
      'es': 'registrados',
    },
    // portafolio_detail_page / portafolio_activity_page (pdet_ / pact_)
    'pdet_titulo': {
      'en': 'Portfolio detail',
      'ar': 'تفاصيل المحفظة',
      'de': 'Portfolio-Details',
      'es': 'Detalle del portafolio',
    },
    'pdet_cerrar': {
      'en': 'Close',
      'ar': 'إغلاق',
      'de': 'Schließen',
      'es': 'Cerrar',
    },
    'pdet_filtros': {
      'en': 'Filters',
      'ar': 'عوامل التصفية',
      'de': 'Filter',
      'es': 'Filtros',
    },
    'pdet_ruta_no_disponible': {
      'en': 'This option is not available yet.',
      'ar': 'هذا الخيار غير متاح بعد.',
      'de': 'Diese Option ist noch nicht verfügbar.',
      'es': 'Esta opción aún no está disponible.',
    },
    'pact_titulo': {
      'en': 'Portfolio activity',
      'ar': 'نشاط المحفظة',
      'de': 'Portfolio-Aktivität',
      'es': 'Actividad del portafolio',
    },
    'pact_eliminar_no_disponible': {
      'en': 'Delete (not available yet)',
      'ar': 'حذف (غير متاح بعد)',
      'de': 'Löschen (noch nicht verfügbar)',
      'es': 'Eliminar (aún no disponible)',
    },
    'pact_monto_mensual': {
      'en': 'Monthly amount',
      'ar': 'المبلغ الشهري',
      'de': 'Monatlicher Betrag',
      'es': 'Monto mensual',
    },
    'pact_tendencia': {
      'en': 'Trend',
      'ar': 'الاتجاه',
      'de': 'Verlauf',
      'es': 'Tendencia',
    },
    'pact_tendencia_ayuda': {
      'en': 'Portfolio movements over time',
      'ar': 'حركات المحفظة عبر الزمن',
      'de': 'Bewegungen des Portfolios im Zeitverlauf',
      'es': 'Movimientos del portafolio en el tiempo',
    },
    'pact_grafico_vacio': {
      'en': 'There is no data to chart yet.',
      'ar': 'لا توجد بيانات للرسم بعد.',
      'de': 'Noch keine Daten für das Diagramm.',
      'es': 'Aún no hay datos para graficar.',
    },
    'pact_movimientos_vacio': {
      'en': 'This portfolio has no movements yet.',
      'ar': 'لا توجد حركات في هذه المحفظة بعد.',
      'de': 'Dieses Portfolio hat noch keine Bewegungen.',
      'es': 'Este portafolio aún no tiene movimientos.',
    },
    // Portafolios (port_) y formulario de portafolio (aport_).
    'port_titulo': {
      'en': 'Portfolios',
      'ar': 'المحافظ',
      'de': 'Portfolios',
      'es': 'Portafolios',
    },
    'port_cerrar': {
      'en': 'Close',
      'ar': 'إغلاق',
      'de': 'Schließen',
      'es': 'Cerrar',
    },
    'port_saldo_total': {
      'en': 'Total balance',
      'ar': 'الرصيد الإجمالي',
      'de': 'Gesamtsaldo',
      'es': 'Saldo total',
    },
    'port_saldo_ayuda': {
      'en': 'Project income minus expenses and taxes',
      'ar': 'دخل المشروع ناقص المصروفات والضرائب',
      'de': 'Einnahmen des Projekts minus Ausgaben und Steuern',
      'es': 'Ingresos del proyecto menos egresos e impuestos',
    },
    'port_ingresos': {
      'en': 'Income',
      'ar': 'الدخل',
      'de': 'Einnahmen',
      'es': 'Ingresos',
    },
    'port_salidas': {
      'en': 'Expenses and taxes',
      'ar': 'المصروفات والضرائب',
      'de': 'Ausgaben und Steuern',
      'es': 'Egresos e impuestos',
    },
    'port_nuevo_movimiento': {
      'en': 'New transaction',
      'ar': 'حركة جديدة',
      'de': 'Neue Buchung',
      'es': 'Nuevo movimiento',
    },
    'port_actividad': {
      'en': 'Activity',
      'ar': 'النشاط',
      'de': 'Aktivität',
      'es': 'Actividad',
    },
    'port_cuentas': {
      'en': 'accounts',
      'ar': 'حسابات',
      'de': 'Konten',
      'es': 'cuentas',
    },
    'port_cuentas_ayuda': {
      'en': 'Tap an account to see its transactions',
      'ar': 'اضغط على حساب لعرض حركاته',
      'de': 'Tippe auf ein Konto, um seine Buchungen zu sehen',
      'es': 'Toca una cuenta para ver sus movimientos',
    },
    'port_nuevo': {
      'en': 'New portfolio',
      'ar': 'محفظة جديدة',
      'de': 'Neues Portfolio',
      'es': 'Nuevo portafolio',
    },
    'port_vacio': {
      'en': 'This project has no portfolios yet. Create one to record its transactions.',
      'ar': 'لا توجد محافظ في هذا المشروع بعد. أنشئ محفظة لتسجيل حركاته.',
      'de': 'Dieses Projekt hat noch keine Portfolios. Lege eines an, um Buchungen zu erfassen.',
      'es': 'Este proyecto aún no tiene portafolios. Crea uno para registrar sus movimientos.',
    },
    'port_error': {
      'en': 'Portfolios could not be loaded.',
      'ar': 'تعذّر تحميل المحافظ.',
      'de': 'Die Portfolios konnten nicht geladen werden.',
      'es': 'No se pudieron cargar los portafolios.',
    },
    'port_error_saldo': {
      'en': 'The balance could not be calculated.',
      'ar': 'تعذّر حساب الرصيد.',
      'de': 'Der Saldo konnte nicht berechnet werden.',
      'es': 'No se pudo calcular el saldo.',
    },
    'port_reintentar': {
      'en': 'Retry',
      'ar': 'إعادة المحاولة',
      'de': 'Erneut versuchen',
      'es': 'Reintentar',
    },
    'port_cuenta': {
      'en': 'Account',
      'ar': 'حساب',
      'de': 'Konto',
      'es': 'Cuenta',
    },
    'port_interes_ea': {
      'en': '% p.a.',
      'ar': '% سنويًا',
      'de': '% p.a.',
      'es': '% E.A.',
    },
    'port_sin_detalle': {
      'en': 'No account number',
      'ar': 'بدون رقم حساب',
      'de': 'Keine Kontonummer',
      'es': 'Sin número de cuenta',
    },
    'port_exenta': {
      'en': 'GMF exempt',
      'ar': 'معفاة من 4x1000',
      'de': 'GMF-befreit',
      'es': 'Exenta 4x1000',
    },
    'aport_titulo': {
      'en': 'New portfolio',
      'ar': 'محفظة جديدة',
      'de': 'Neues Portfolio',
      'es': 'Nuevo portafolio',
    },
    'aport_seccion_cuenta': {
      'en': 'Account details',
      'ar': 'بيانات الحساب',
      'de': 'Kontodaten',
      'es': 'Datos de la cuenta',
    },
    'aport_seccion_condiciones': {
      'en': 'Terms',
      'ar': 'الشروط',
      'de': 'Konditionen',
      'es': 'Condiciones',
    },
    'aport_seccion_condiciones_ayuda': {
      'en': 'Type, yield and taxes',
      'ar': 'النوع والعائد والضرائب',
      'de': 'Art, Rendite und Steuern',
      'es': 'Tipo, rendimiento e impuestos',
    },
    'aport_seccion_notas': {
      'en': 'Notes',
      'ar': 'ملاحظات',
      'de': 'Notizen',
      'es': 'Notas',
    },
    'aport_nombre': {
      'en': 'Portfolio name',
      'ar': 'اسم المحفظة',
      'de': 'Name des Portfolios',
      'es': 'Nombre del portafolio',
    },
    'aport_nombre_requerido': {
      'en': 'Enter the portfolio name',
      'ar': 'أدخل اسم المحفظة',
      'de': 'Gib den Namen des Portfolios ein',
      'es': 'Escribe el nombre del portafolio',
    },
    'aport_nro_cuenta': {
      'en': 'Account number (optional)',
      'ar': 'رقم الحساب (اختياري)',
      'de': 'Kontonummer (optional)',
      'es': 'Número de cuenta (opcional)',
    },
    'aport_tipo_cuenta': {
      'en': 'Account type',
      'ar': 'نوع الحساب',
      'de': 'Kontoart',
      'es': 'Tipo de cuenta',
    },
    'aport_frecuencia': {
      'en': 'Payment frequency',
      'ar': 'تكرار الدفع',
      'de': 'Zahlungshäufigkeit',
      'es': 'Frecuencia de pago',
    },
    'aport_interes': {
      'en': 'Effective annual interest',
      'ar': 'الفائدة السنوية الفعلية',
      'de': 'Effektiver Jahreszins',
      'es': 'Interés efectivo anual',
    },
    'aport_tipo_renta': {
      'en': 'Income type',
      'ar': 'نوع العائد',
      'de': 'Ertragsart',
      'es': 'Tipo de renta',
    },
    'aport_seleccione': {
      'en': 'Select an option',
      'ar': 'اختر خيارًا',
      'de': 'Option auswählen',
      'es': 'Selecciona una opción',
    },
    'aport_exenta': {
      'en': 'Account exempt from 4x1000 (GMF)',
      'ar': 'حساب معفى من ضريبة 4x1000',
      'de': 'Konto von der 4x1000-Steuer (GMF) befreit',
      'es': 'Cuenta exenta del 4x1000 (GMF)',
    },
    'aport_exenta_ayuda': {
      'en': 'If not exempt, 4x1000 is charged on expenses and transfers leaving this account.',
      'ar': 'إذا لم يكن معفى، تُحتسب ضريبة 4x1000 على المصروفات والتحويلات الخارجة من هذا الحساب.',
      'de': 'Ohne Befreiung wird auf Ausgaben und Überweisungen von diesem Konto 4x1000 berechnet.',
      'es': 'Si no es exenta, se cobra el 4x1000 en los egresos y transferencias que salen de esta cuenta.',
    },
    'aport_descripcion': {
      'en': 'Description (optional)',
      'ar': 'الوصف (اختياري)',
      'de': 'Beschreibung (optional)',
      'es': 'Descripción (opcional)',
    },
    'aport_guardar': {
      'en': 'Save portfolio',
      'ar': 'حفظ المحفظة',
      'de': 'Portfolio speichern',
      'es': 'Guardar portafolio',
    },
    'aport_guardado': {
      'en': 'Portfolio created',
      'ar': 'تم إنشاء المحفظة',
      'de': 'Portfolio erstellt',
      'es': 'Portafolio creado',
    },
    'aport_error_catalogos': {
      'en': 'Account types and payment frequencies could not be loaded.',
      'ar': 'تعذّر تحميل أنواع الحسابات وتكرارات الدفع.',
      'de': 'Kontoarten und Zahlungshäufigkeiten konnten nicht geladen werden.',
      'es': 'No se pudieron cargar los tipos de cuenta y las frecuencias de pago.',
    },
    // trx_ / trxok_: movimientos de la cuenta y confirmación
    'trx_titulo': {
      'en': 'Account transactions',
      'ar': 'حركات الحساب',
      'de': 'Kontobewegungen',
      'es': 'Movimientos de la cuenta',
    },
    'trx_saldo': {
      'en': 'Available balance',
      'ar': 'الرصيد المتاح',
      'de': 'Verfügbarer Saldo',
      'es': 'Saldo disponible',
    },
    'trx_ingresos': {
      'en': 'Income',
      'ar': 'الدخل',
      'de': 'Einnahmen',
      'es': 'Ingresos',
    },
    'trx_salidas': {
      'en': 'Outflows',
      'ar': 'المصروفات',
      'de': 'Ausgänge',
      'es': 'Salidas',
    },
    'trx_incluye_gmf': {
      'en': 'Outflows include 4x1000 tax (GMF):',
      'ar': 'تشمل المصروفات ضريبة 4x1000 (GMF):',
      'de': 'Ausgänge enthalten die 4x1000-Steuer (GMF):',
      'es': 'Las salidas incluyen el 4x1000 (GMF):',
    },
    'trx_gmf': {
      'en': 'GMF',
      'ar': 'GMF',
      'de': 'GMF',
      'es': 'GMF',
    },
    'trx_movimientos': {
      'en': 'Transactions',
      'ar': 'الحركات',
      'de': 'Bewegungen',
      'es': 'Movimientos',
    },
    'trx_registros': {
      'en': 'records',
      'ar': 'سجلات',
      'de': 'Einträge',
      'es': 'registros',
    },
    'trx_nuevo': {
      'en': 'New transaction',
      'ar': 'حركة جديدة',
      'de': 'Neue Bewegung',
      'es': 'Nuevo movimiento',
    },
    'trx_registrar': {
      'en': 'Record transaction',
      'ar': 'تسجيل حركة',
      'de': 'Bewegung erfassen',
      'es': 'Registrar movimiento',
    },
    'trx_vacio': {
      'en': 'This account has no transactions yet. Record the first one to start tracking its balance.',
      'ar': 'لا توجد حركات في هذا الحساب بعد. سجّل الحركة الأولى لبدء متابعة رصيده.',
      'de': 'Dieses Konto hat noch keine Bewegungen. Erfasse die erste, um den Saldo zu verfolgen.',
      'es': 'Esta cuenta aún no tiene movimientos. Registra el primero para empezar a seguir su saldo.',
    },
    'trx_error': {
      'en': 'The account transactions could not be loaded.',
      'ar': 'تعذّر تحميل حركات الحساب.',
      'de': 'Die Kontobewegungen konnten nicht geladen werden.',
      'es': 'No se pudieron cargar los movimientos de la cuenta.',
    },
    'trx_reintentar': {
      'en': 'Retry',
      'ar': 'إعادة المحاولة',
      'de': 'Erneut versuchen',
      'es': 'Reintentar',
    },
    'trx_volver_cuentas': {
      'en': 'Back to accounts',
      'ar': 'العودة إلى الحسابات',
      'de': 'Zurück zu den Konten',
      'es': 'Volver a las cuentas',
    },
    'trxok_titulo': {
      'en': 'Transaction recorded',
      'ar': 'تم تسجيل الحركة',
      'de': 'Bewegung erfasst',
      'es': 'Movimiento registrado',
    },
    'trxok_mensaje': {
      'en': 'The transaction was saved and the account balances are already updated.',
      'ar': 'تم حفظ الحركة وتحديث أرصدة الحسابات.',
      'de': 'Die Bewegung wurde gespeichert und die Kontosalden sind bereits aktualisiert.',
      'es': 'El movimiento quedó guardado y los saldos de las cuentas ya están actualizados.',
    },
    'trxok_continuar': {
      'en': 'Go to projects',
      'ar': 'الذهاب إلى المشاريع',
      'de': 'Zu den Projekten',
      'es': 'Ir a proyectos',
    },
    'proy_titulo': {
      'en': 'Projects',
      'ar': 'المشاريع',
      'de': 'Projekte',
      'es': 'Proyectos',
    },
    'proy_subtitulo': {
      'en': 'Group your portfolios and transactions by project.',
      'ar': 'جمّع محافظك وحركاتك حسب المشروع.',
      'de': 'Gruppiere Portfolios und Bewegungen nach Projekt.',
      'es': 'Agrupa tus portafolios y movimientos por proyecto.',
    },
    'proy_agregar': {
      'en': 'New project',
      'ar': 'مشروع جديد',
      'de': 'Neues Projekt',
      'es': 'Nuevo proyecto',
    },
    'proy_vacio': {
      'en': 'You have no projects yet. Create one to group your portfolios.',
      'ar': 'لا توجد مشاريع بعد. أنشئ مشروعًا لتجميع محافظك.',
      'de': 'Noch keine Projekte vorhanden. Lege eines an, um deine Portfolios zu gruppieren.',
      'es': 'Aún no tienes proyectos. Crea uno para agrupar tus portafolios.',
    },
    'proy_error': {
      'en': 'Projects could not be loaded.',
      'ar': 'تعذّر تحميل المشاريع.',
      'de': 'Die Projekte konnten nicht geladen werden.',
      'es': 'No se pudieron cargar los proyectos.',
    },
    'proy_reintentar': {
      'en': 'Retry',
      'ar': 'إعادة المحاولة',
      'de': 'Erneut versuchen',
      'es': 'Reintentar',
    },
    'proy_sin_descripcion': {
      'en': 'No description',
      'ar': 'بدون وصف',
      'de': 'Keine Beschreibung',
      'es': 'Sin descripción',
    },
    'proy_total': {
      'en': 'registered',
      'ar': 'مسجّلة',
      'de': 'erfasst',
      'es': 'registrados',
    },
    'proy_ver_portafolios': {
      'en': 'View portfolios',
      'ar': 'عرض المحافظ',
      'de': 'Portfolios anzeigen',
      'es': 'Ver portafolios',
    },
    'tproy_titulo': {
      'en': 'Project types',
      'ar': 'أنواع المشاريع',
      'de': 'Projekttypen',
      'es': 'Tipos de proyecto',
    },
    'tproy_subtitulo': {
      'en': 'Classify your projects by type.',
      'ar': 'صنّف مشاريعك حسب النوع.',
      'de': 'Ordne deine Projekte nach Typ.',
      'es': 'Clasifica tus proyectos por tipo.',
    },
    'tproy_agregar': {
      'en': 'New type',
      'ar': 'نوع جديد',
      'de': 'Neuer Typ',
      'es': 'Nuevo tipo',
    },
    'tproy_vacio': {
      'en': 'You have no project types yet. Create one to classify your projects.',
      'ar': 'لا توجد أنواع مشاريع بعد. أنشئ نوعًا لتصنيف مشاريعك.',
      'de': 'Noch keine Projekttypen vorhanden. Lege einen an, um deine Projekte zu ordnen.',
      'es': 'Aún no tienes tipos de proyecto. Crea uno para clasificar tus proyectos.',
    },
    'tproy_error': {
      'en': 'Project types could not be loaded.',
      'ar': 'تعذّر تحميل أنواع المشاريع.',
      'de': 'Die Projekttypen konnten nicht geladen werden.',
      'es': 'No se pudieron cargar los tipos de proyecto.',
    },
    'tproy_reintentar': {
      'en': 'Retry',
      'ar': 'إعادة المحاولة',
      'de': 'Erneut versuchen',
      'es': 'Reintentar',
    },
    'tproy_sin_descripcion': {
      'en': 'No description',
      'ar': 'بدون وصف',
      'de': 'Keine Beschreibung',
      'es': 'Sin descripción',
    },
    'tproy_total': {
      'en': 'registered',
      'ar': 'مسجّلة',
      'de': 'erfasst',
      'es': 'registrados',
    },
    'frec_titulo': {
      'en': 'Payment frequencies',
      'ar': 'تكرارات الدفع',
      'de': 'Zahlungsintervalle',
      'es': 'Frecuencias de pago',
    },
    'frec_subtitulo': {
      'en': 'How often a payment or return repeats.',
      'ar': 'عدد مرات تكرار الدفعة أو العائد.',
      'de': 'Wie oft sich eine Zahlung oder Rendite wiederholt.',
      'es': 'Cada cuánto se repite un pago o rendimiento.',
    },
    'frec_agregar': {
      'en': 'New frequency',
      'ar': 'تكرار جديد',
      'de': 'Neues Intervall',
      'es': 'Nueva frecuencia',
    },
    'frec_vacio': {
      'en': 'You have no payment frequencies yet. Create one to schedule your payments.',
      'ar': 'لا توجد تكرارات دفع بعد. أنشئ تكرارًا لجدولة مدفوعاتك.',
      'de': 'Noch keine Zahlungsintervalle vorhanden. Lege eines an, um deine Zahlungen zu planen.',
      'es': 'Aún no tienes frecuencias de pago. Crea una para programar tus pagos.',
    },
    'frec_error': {
      'en': 'Payment frequencies could not be loaded.',
      'ar': 'تعذّر تحميل تكرارات الدفع.',
      'de': 'Die Zahlungsintervalle konnten nicht geladen werden.',
      'es': 'No se pudieron cargar las frecuencias de pago.',
    },
    'frec_reintentar': {
      'en': 'Retry',
      'ar': 'إعادة المحاولة',
      'de': 'Erneut versuchen',
      'es': 'Reintentar',
    },
    'frec_total': {
      'en': 'registered',
      'ar': 'مسجّلة',
      'de': 'erfasst',
      'es': 'registradas',
    },
    'frec_cada': {
      'en': 'Every',
      'ar': 'كل',
      'de': 'Alle',
      'es': 'Cada',
    },
    'frec_dia': {
      'en': 'day',
      'ar': 'يوم',
      'de': 'Tag',
      'es': 'día',
    },
    'frec_dias': {
      'en': 'days',
      'ar': 'أيام',
      'de': 'Tage',
      'es': 'días',
    },
    'frec_mes': {
      'en': 'month',
      'ar': 'شهر',
      'de': 'Monat',
      'es': 'mes',
    },
    'frec_meses': {
      'en': 'months',
      'ar': 'أشهر',
      'de': 'Monate',
      'es': 'meses',
    },
    'frec_anio': {
      'en': 'year',
      'ar': 'سنة',
      'de': 'Jahr',
      'es': 'año',
    },
    'frec_anios': {
      'en': 'years',
      'ar': 'سنوات',
      'de': 'Jahre',
      'es': 'años',
    },
    'frec_en_dias': {
      'en': 'Daily-based frequency',
      'ar': 'تكرار بالأيام',
      'de': 'Intervall in Tagen',
      'es': 'Frecuencia en días',
    },
    'frec_en_meses': {
      'en': 'Monthly-based frequency',
      'ar': 'تكرار بالأشهر',
      'de': 'Intervall in Monaten',
      'es': 'Frecuencia en meses',
    },
    'frec_en_anios': {
      'en': 'Yearly-based frequency',
      'ar': 'تكرار بالسنوات',
      'de': 'Intervall in Jahren',
      'es': 'Frecuencia en años',
    },
    'frec_formato_desconocido': {
      'en': 'Unknown unit',
      'ar': 'وحدة غير معروفة',
      'de': 'Unbekannte Einheit',
      'es': 'Unidad desconocida',
    },
    'ttrx_titulo': {
      'en': 'Transaction types',
      'ar': 'أنواع المعاملات',
      'de': 'Transaktionstypen',
      'es': 'Tipos de transacción',
    },
    'ttrx_subtitulo': {
      'en': 'Define whether money comes in, goes out or moves between accounts.',
      'ar': 'حدّد ما إذا كان المال يدخل أو يخرج أو ينتقل بين الحسابات.',
      'de': 'Lege fest, ob Geld eingeht, ausgeht oder zwischen Konten wechselt.',
      'es': 'Define si el dinero entra, sale o se mueve entre cuentas.',
    },
    'ttrx_agregar': {
      'en': 'New type',
      'ar': 'نوع جديد',
      'de': 'Neuer Typ',
      'es': 'Nuevo tipo',
    },
    'ttrx_vacio': {
      'en': 'You have no transaction types yet. Create one to record your transactions.',
      'ar': 'لا توجد أنواع معاملات بعد. أنشئ نوعًا لتسجيل حركاتك.',
      'de': 'Noch keine Transaktionstypen vorhanden. Lege einen an, um Bewegungen zu erfassen.',
      'es': 'Aún no tienes tipos de transacción. Crea uno para registrar tus movimientos.',
    },
    'ttrx_error': {
      'en': 'Transaction types could not be loaded.',
      'ar': 'تعذّر تحميل أنواع المعاملات.',
      'de': 'Die Transaktionstypen konnten nicht geladen werden.',
      'es': 'No se pudieron cargar los tipos de transacción.',
    },
    'ttrx_reintentar': {
      'en': 'Retry',
      'ar': 'إعادة المحاولة',
      'de': 'Erneut versuchen',
      'es': 'Reintentar',
    },
    'ttrx_sin_descripcion': {
      'en': 'No description',
      'ar': 'بدون وصف',
      'de': 'Keine Beschreibung',
      'es': 'Sin descripción',
    },
    'ttrx_total': {
      'en': 'registered',
      'ar': 'مسجّلة',
      'de': 'erfasst',
      'es': 'registrados',
    },
    'ttrx_ingreso': {
      'en': 'Income',
      'ar': 'دخل',
      'de': 'Einnahme',
      'es': 'Ingreso',
    },
    'ttrx_egreso': {
      'en': 'Expense',
      'ar': 'مصروف',
      'de': 'Ausgabe',
      'es': 'Egreso',
    },
    'ttrx_movimiento': {
      'en': 'Transfer',
      'ar': 'تحويل',
      'de': 'Umbuchung',
      'es': 'Movimiento',
    },
    'ttrx_sin_tipo': {
      'en': 'Unclassified',
      'ar': 'غير مصنّف',
      'de': 'Nicht zugeordnet',
      'es': 'Sin clasificar',
    },
    // --- Formularios de catálogo (form_, atrx_, aproy_, atproy_, amot_, afrec_) ---
    'form_nombre': {
      'en': 'Name',
      'ar': 'الاسم',
      'de': 'Name',
      'es': 'Nombre',
    },
    'form_descripcion': {
      'en': 'Description',
      'ar': 'الوصف',
      'de': 'Beschreibung',
      'es': 'Descripción',
    },
    'form_opcional': {
      'en': 'Optional',
      'ar': 'اختياري',
      'de': 'Optional',
      'es': 'Opcional',
    },
    'form_nombre_requerido': {
      'en': 'Enter a name.',
      'ar': 'أدخل اسمًا.',
      'de': 'Gib einen Namen ein.',
      'es': 'Escribe un nombre.',
    },
    'form_seleccion_requerida': {
      'en': 'Select an option.',
      'ar': 'اختر خيارًا.',
      'de': 'Wähle eine Option.',
      'es': 'Selecciona una opción.',
    },
    'form_guardar': {
      'en': 'Save',
      'ar': 'حفظ',
      'de': 'Speichern',
      'es': 'Guardar',
    },
    'form_descartar_titulo': {
      'en': 'Discard changes?',
      'ar': 'تجاهل التغييرات؟',
      'de': 'Änderungen verwerfen?',
      'es': '¿Descartar cambios?',
    },
    'form_descartar_mensaje': {
      'en': 'The data you entered will be lost.',
      'ar': 'ستفقد البيانات التي أدخلتها.',
      'de': 'Die eingegebenen Daten gehen verloren.',
      'es': 'Los datos que escribiste se perderán.',
    },
    'form_descartar': {
      'en': 'Discard',
      'ar': 'تجاهل',
      'de': 'Verwerfen',
      'es': 'Descartar',
    },
    'form_seguir_editando': {
      'en': 'Keep editing',
      'ar': 'متابعة التعديل',
      'de': 'Weiter bearbeiten',
      'es': 'Seguir editando',
    },
    'atrx_titulo': {
      'en': 'New transaction type',
      'ar': 'نوع معاملة جديد',
      'de': 'Neuer Buchungstyp',
      'es': 'Nuevo tipo de transacción',
    },
    'atrx_ayuda': {
      'en': 'Defines how a movement is classified: income, expense or transfer between your accounts.',
      'ar': 'يحدد كيفية تصنيف الحركة: دخل أو مصروف أو تحويل بين حساباتك.',
      'de': 'Legt fest, wie eine Bewegung eingeordnet wird: Einnahme, Ausgabe oder Überweisung zwischen deinen Konten.',
      'es': 'Define cómo se clasifica un movimiento: ingreso, egreso o transferencia entre tus cuentas.',
    },
    'atrx_tipo_fuente': {
      'en': 'Movement nature',
      'ar': 'طبيعة الحركة',
      'de': 'Art der Bewegung',
      'es': 'Naturaleza del movimiento',
    },
    'atrx_tipo_fuente_ayuda': {
      'en': 'Determines whether it adds to or subtracts from the balance.',
      'ar': 'يحدد ما إذا كانت تضيف إلى الرصيد أو تخصم منه.',
      'de': 'Bestimmt, ob der Saldo steigt oder sinkt.',
      'es': 'Determina si suma o resta al saldo.',
    },
    'atrx_fuente_ingreso': {
      'en': 'Income',
      'ar': 'دخل',
      'de': 'Einnahme',
      'es': 'Ingreso',
    },
    'atrx_fuente_egreso': {
      'en': 'Expense',
      'ar': 'مصروف',
      'de': 'Ausgabe',
      'es': 'Egreso',
    },
    'atrx_fuente_transferencia': {
      'en': 'Transfer between accounts',
      'ar': 'تحويل بين الحسابات',
      'de': 'Überweisung zwischen Konten',
      'es': 'Transferencia entre cuentas',
    },
    'atrx_guardado': {
      'en': 'Transaction type saved',
      'ar': 'تم حفظ نوع المعاملة',
      'de': 'Buchungstyp gespeichert',
      'es': 'Tipo de transacción guardado',
    },
    'aproy_titulo': {
      'en': 'New project',
      'ar': 'مشروع جديد',
      'de': 'Neues Projekt',
      'es': 'Nuevo proyecto',
    },
    'aproy_ayuda': {
      'en': 'Groups portfolios and movements under a single goal.',
      'ar': 'يجمع المحافظ والحركات تحت هدف واحد.',
      'de': 'Fasst Portfolios und Bewegungen unter einem Ziel zusammen.',
      'es': 'Agrupa portafolios y movimientos bajo un mismo objetivo.',
    },
    'aproy_nombre': {
      'en': 'Project name',
      'ar': 'اسم المشروع',
      'de': 'Projektname',
      'es': 'Nombre del proyecto',
    },
    'aproy_guardado': {
      'en': 'Project saved',
      'ar': 'تم حفظ المشروع',
      'de': 'Projekt gespeichert',
      'es': 'Proyecto guardado',
    },
    'atproy_titulo': {
      'en': 'New project type',
      'ar': 'نوع مشروع جديد',
      'de': 'Neuer Projekttyp',
      'es': 'Nuevo tipo de proyecto',
    },
    'atproy_ayuda': {
      'en': 'Classifies your projects, for example: real estate, business or savings.',
      'ar': 'يصنّف مشاريعك، مثل: عقارات أو أعمال أو ادخار.',
      'de': 'Ordnet deine Projekte ein, z. B. Immobilien, Geschäft oder Sparen.',
      'es': 'Clasifica tus proyectos, por ejemplo: inmobiliario, negocio o ahorro.',
    },
    'atproy_guardado': {
      'en': 'Project type saved',
      'ar': 'تم حفظ نوع المشروع',
      'de': 'Projekttyp gespeichert',
      'es': 'Tipo de proyecto guardado',
    },
    'amot_titulo': {
      'en': 'New reason',
      'ar': 'سبب جديد',
      'de': 'Neuer Grund',
      'es': 'Nuevo motivo',
    },
    'amot_ayuda': {
      'en': 'Explains why money comes in or goes out, for example: salary, rent or groceries.',
      'ar': 'يوضح سبب دخول المال أو خروجه، مثل: الراتب أو الإيجار أو البقالة.',
      'de': 'Erklärt, warum Geld eingeht oder ausgeht, z. B. Gehalt, Miete oder Einkauf.',
      'es': 'Indica por qué entra o sale el dinero, por ejemplo: salario, arriendo o mercado.',
    },
    'amot_guardado': {
      'en': 'Reason saved',
      'ar': 'تم حفظ السبب',
      'de': 'Grund gespeichert',
      'es': 'Motivo guardado',
    },
    'afrec_titulo': {
      'en': 'New payment frequency',
      'ar': 'تكرار دفع جديد',
      'de': 'Neue Zahlungsfrequenz',
      'es': 'Nueva frecuencia de pago',
    },
    'afrec_ayuda': {
      'en': 'How often a payment repeats: for example, every 15 days or every 1 month.',
      'ar': 'عدد مرات تكرار الدفع: مثلًا كل 15 يومًا أو كل شهر.',
      'de': 'Wie oft sich eine Zahlung wiederholt: z. B. alle 15 Tage oder jeden Monat.',
      'es': 'Cada cuánto se repite un pago: por ejemplo, cada 15 días o cada 1 mes.',
    },
    'afrec_cantidad': {
      'en': 'Every',
      'ar': 'كل',
      'de': 'Alle',
      'es': 'Cada',
    },
    'afrec_unidad': {
      'en': 'Unit',
      'ar': 'الوحدة',
      'de': 'Einheit',
      'es': 'Unidad',
    },
    'afrec_dias': {
      'en': 'Days',
      'ar': 'أيام',
      'de': 'Tage',
      'es': 'Días',
    },
    'afrec_meses': {
      'en': 'Months',
      'ar': 'أشهر',
      'de': 'Monate',
      'es': 'Meses',
    },
    'afrec_anios': {
      'en': 'Years',
      'ar': 'سنوات',
      'de': 'Jahre',
      'es': 'Años',
    },
    'afrec_guardado': {
      'en': 'Payment frequency saved',
      'ar': 'تم حفظ تكرار الدفع',
      'de': 'Zahlungsfrequenz gespeichert',
      'es': 'Frecuencia de pago guardada',
    },
    // Cuentas (cta_)
    'menu_cuentas': {
      'en': 'Accounts',
      'ar': 'الحسابات',
      'de': 'Konten',
      'es': 'Cuentas',
    },
    'cta_titulo': {
      'en': 'Accounts',
      'ar': 'الحسابات',
      'de': 'Konten',
      'es': 'Cuentas',
    },
    'cta_total': {
      'en': 'Total in accounts',
      'ar': 'الإجمالي في الحسابات',
      'de': 'Summe auf Konten',
      'es': 'Total en cuentas',
    },
    'cta_total_ayuda': {
      'en': 'Sum of every account with its pockets and CDs',
      'ar': 'مجموع كل الحسابات مع جيوبها',
      'de': 'Summe aller Konten mit ihren Unterkonten',
      'es': 'Suma de todas las cuentas con sus cajitas y CDTs',
    },
    'cta_nueva': {
      'en': 'New account',
      'ar': 'حساب جديد',
      'de': 'Neues Konto',
      'es': 'Nueva cuenta',
    },
    'cta_editar_titulo': {
      'en': 'Edit account',
      'ar': 'تعديل الحساب',
      'de': 'Konto bearbeiten',
      'es': 'Editar cuenta',
    },
    'cta_error': {
      'en': 'Accounts could not be loaded',
      'ar': 'تعذر تحميل الحسابات',
      'de': 'Konten konnten nicht geladen werden',
      'es': 'No se pudieron cargar las cuentas',
    },
    'cta_reintentar': {
      'en': 'Retry',
      'ar': 'إعادة المحاولة',
      'de': 'Erneut versuchen',
      'es': 'Reintentar',
    },
    'cta_tipo_A': {
      'en': 'Savings',
      'ar': 'توفير',
      'de': 'Sparkonto',
      'es': 'Ahorros',
    },
    'cta_tipo_C': {
      'en': 'Checking',
      'ar': 'جاري',
      'de': 'Girokonto',
      'es': 'Corriente',
    },
    'cta_tipo_D': {
      'en': 'Digital / wallet',
      'ar': 'رقمي / محفظة',
      'de': 'Digital / Wallet',
      'es': 'Digital / billetera',
    },
    'cta_tipo_E': {
      'en': 'Cash',
      'ar': 'نقدي',
      'de': 'Bargeld',
      'es': 'Efectivo',
    },
    'cta_paga_gmf': {
      'en': 'Pays 4x1000',
      'ar': 'يدفع 4x1000',
      'de': 'Zahlt 4x1000',
      'es': 'Paga 4x1000',
    },
    'cta_exenta_gmf': {
      'en': '4x1000 exempt',
      'ar': 'معفى من 4x1000',
      'de': 'Von 4x1000 befreit',
      'es': 'Exenta de 4x1000',
    },
    'cta_ayuda': {
      'en': 'An account is where your money lives: bank, digital wallet or cash. It is created with its main portfolio, where its transactions are recorded.',
      'ar': 'الحساب هو مكان أموالك: بنك أو محفظة رقمية أو نقد. يُنشأ مع محفظته الرئيسية.',
      'de': 'Ein Konto ist der Ort deines Geldes: Bank, digitale Wallet oder Bargeld. Es wird mit seinem Hauptportfolio erstellt.',
      'es': 'Una cuenta es donde vive tu dinero: banco, billetera digital o efectivo. Se crea con su portafolio principal, donde se registran sus movimientos.',
    },
    'cta_nombre': {
      'en': 'Name (e.g. Bank savings)',
      'ar': 'الاسم',
      'de': 'Name (z. B. Sparkonto Bank)',
      'es': 'Nombre (ej. Bancolombia Ahorros)',
    },
    'cta_tipo': {
      'en': 'Account type',
      'ar': 'نوع الحساب',
      'de': 'Kontotyp',
      'es': 'Tipo de cuenta',
    },
    'cta_tipo_requerido': {
      'en': 'Choose the account type',
      'ar': 'اختر نوع الحساب',
      'de': 'Wähle den Kontotyp',
      'es': 'Elige el tipo de cuenta',
    },
    'cta_entidad': {
      'en': 'Bank or app',
      'ar': 'البنك أو التطبيق',
      'de': 'Bank oder App',
      'es': 'Banco o aplicación',
    },
    'cta_nro': {
      'en': 'Account number',
      'ar': 'رقم الحساب',
      'de': 'Kontonummer',
      'es': 'Número de cuenta',
    },
    'cta_exenta': {
      'en': 'Exempt from 4x1000',
      'ar': 'معفى من 4x1000',
      'de': 'Von 4x1000 befreit',
      'es': 'Exenta de 4x1000',
    },
    'cta_exenta_ayuda': {
      'en': 'Turn on if your bank marked this account as GMF exempt',
      'ar': 'فعّل إذا كان الحساب معفى',
      'de': 'Aktivieren, wenn die Bank das Konto befreit hat',
      'es': 'Actívalo si tu banco marcó esta cuenta como exenta del GMF',
    },
    'cta_efectivo_sin_gmf': {
      'en': 'Cash never pays 4x1000',
      'ar': 'النقد لا يدفع 4x1000',
      'de': 'Bargeld zahlt nie 4x1000',
      'es': 'El efectivo nunca paga 4x1000',
    },
    'cta_saldo_inicial': {
      'en': 'Opening balance',
      'ar': 'الرصيد الافتتاحي',
      'de': 'Anfangssaldo',
      'es': 'Saldo inicial',
    },
    'cta_saldo_inicial_ayuda': {
      'en': 'Money the account already has today (optional)',
      'ar': 'المال الموجود اليوم (اختياري)',
      'de': 'Geld, das heute schon vorhanden ist (optional)',
      'es': 'Dinero que ya tiene la cuenta hoy (opcional)',
    },
    'cta_guardada': {
      'en': 'Account saved',
      'ar': 'تم حفظ الحساب',
      'de': 'Konto gespeichert',
      'es': 'Cuenta guardada',
    },
    'cta_portafolios': {
      'en': 'Portfolios',
      'ar': 'المحافظ',
      'de': 'Portfolios',
      'es': 'Portafolios',
    },
    'cta_portafolios_ayuda': {
      'en': 'The main one receives the account transactions; pockets and CDs add to its balance.',
      'ar': 'الرئيسية تستقبل الحركات؛ الجيوب تضاف إلى الرصيد.',
      'de': 'Das Hauptportfolio erhält die Buchungen; Unterkonten zählen zum Saldo.',
      'es': 'El principal recibe los movimientos de la cuenta; las cajitas, bolsillos y CDTs suman a su saldo.',
    },
    'cta_principal': {
      'en': 'Main',
      'ar': 'رئيسية',
      'de': 'Haupt',
      'es': 'Principal',
    },
    'cta_nueva_cajita': {
      'en': 'New pocket',
      'ar': 'جيب جديد',
      'de': 'Neues Unterkonto',
      'es': 'Nueva cajita o bolsillo',
    },
    'cta_cajita_ayuda': {
      'en': 'Pockets, savings boxes or CDs of this same account',
      'ar': 'جيوب أو ودائع لهذا الحساب',
      'de': 'Unterkonten oder Festgeld dieses Kontos',
      'es': 'Cajitas, bolsillos o CDTs de esta misma cuenta',
    },
    'cta_cajita_creada': {
      'en': 'Pocket created',
      'ar': 'تم إنشاء الجيب',
      'de': 'Unterkonto erstellt',
      'es': 'Cajita creada',
    },
    'cta_crear': {
      'en': 'Create',
      'ar': 'إنشاء',
      'de': 'Erstellen',
      'es': 'Crear',
    },
    'cta_cancelar': {
      'en': 'Cancel',
      'ar': 'إلغاء',
      'de': 'Abbrechen',
      'es': 'Cancelar',
    },
    'cta_editar': {
      'en': 'Edit',
      'ar': 'تعديل',
      'de': 'Bearbeiten',
      'es': 'Editar',
    },
    'cta_eliminar': {
      'en': 'Delete account',
      'ar': 'حذف الحساب',
      'de': 'Konto löschen',
      'es': 'Eliminar cuenta',
    },
    'cta_eliminar_mensaje': {
      'en': 'The account and its main portfolio will be deleted.',
      'ar': 'سيتم حذف الحساب ومحفظته الرئيسية.',
      'de': 'Das Konto und sein Hauptportfolio werden gelöscht.',
      'es': 'Se eliminarán la cuenta y su portafolio principal.',
    },
    'cta_eliminada': {
      'en': 'Account deleted',
      'ar': 'تم حذف الحساب',
      'de': 'Konto gelöscht',
      'es': 'Cuenta eliminada',
    },
    'cta_efectivo_info': {
      'en': 'Money arrives here when you do not choose another account.',
      'ar': 'يصل المال هنا إذا لم تختر حسابًا آخر.',
      'de': 'Hierher kommt Geld, wenn du kein anderes Konto wählst.',
      'es': 'Aquí llega el dinero cuando no indicas otra cuenta.',
    },
    'cta_ver_movimientos': {
      'en': 'See transactions',
      'ar': 'عرض الحركات',
      'de': 'Buchungen ansehen',
      'es': 'Ver movimientos',
    },
    'cta_numero_invalido': {
      'en': 'Enter only numbers',
      'ar': 'أدخل أرقامًا فقط',
      'de': 'Nur Zahlen eingeben',
      'es': 'Escribe solo números',
    },
    // Aportes, rendimientos y conversión (trx_ / aport_)
    'trx_mas': {
      'en': 'More actions',
      'ar': 'إجراءات أخرى',
      'de': 'Weitere Aktionen',
      'es': 'Más acciones',
    },
    'trx_aportar': {
      'en': 'Contribute',
      'ar': 'مساهمة',
      'de': 'Einzahlen',
      'es': 'Aportar',
    },
    'trx_aportar_ayuda': {
      'en': 'Money leaves the contributions account of this portfolio (or Cash / Undefined) and pays its 4x1000.',
      'ar': 'يخرج المال من حساب المساهمات أو النقد.',
      'de': 'Das Geld kommt vom Einzahlungskonto (oder Bargeld) und zahlt dessen 4x1000.',
      'es': 'El dinero sale de la cuenta de aportes de este portafolio (o de Efectivo / Sin definir) y paga su 4x1000.',
    },
    'trx_rendimiento': {
      'en': 'Record return',
      'ar': 'تسجيل عائد',
      'de': 'Ertrag erfassen',
      'es': 'Registrar rendimiento',
    },
    'trx_rendimiento_ayuda': {
      'en': 'It is recorded as income of this portfolio and moved to its returns account.',
      'ar': 'يسجل كدخل ثم ينقل إلى حساب العوائد.',
      'de': 'Wird als Einnahme erfasst und auf das Ertragskonto übertragen.',
      'es': 'Se registra como ingreso de este portafolio y pasa a su cuenta de rendimientos.',
    },
    'trx_reinvertir': {
      'en': 'Reinvest (keep it here)',
      'ar': 'إعادة الاستثمار',
      'de': 'Reinvestieren (hier lassen)',
      'es': 'Reinvertir (dejarlo aquí)',
    },
    'trx_valor': {
      'en': 'Amount',
      'ar': 'المبلغ',
      'de': 'Betrag',
      'es': 'Valor',
    },
    'trx_valor_requerido': {
      'en': 'Enter an amount greater than zero',
      'ar': 'أدخل مبلغًا أكبر من صفر',
      'de': 'Betrag größer als null eingeben',
      'es': 'Escribe un valor mayor a cero',
    },
    'trx_registrar_btn': {
      'en': 'Save',
      'ar': 'حفظ',
      'de': 'Speichern',
      'es': 'Registrar',
    },
    'trx_aporte_hecho': {
      'en': 'Contribution saved',
      'ar': 'تم حفظ المساهمة',
      'de': 'Einzahlung gespeichert',
      'es': 'Aporte registrado',
    },
    'trx_rendimiento_hecho': {
      'en': 'Return saved',
      'ar': 'تم حفظ العائد',
      'de': 'Ertrag gespeichert',
      'es': 'Rendimiento registrado',
    },
    'trx_convertir': {
      'en': 'Convert into account',
      'ar': 'تحويل إلى حساب',
      'de': 'In Konto umwandeln',
      'es': 'Convertir en cuenta',
    },
    'trx_convertir_ayuda': {
      'en': 'This portfolio becomes the main portfolio of a new account. Its transactions are kept.',
      'ar': 'تصبح هذه المحفظة الرئيسية لحساب جديد.',
      'de': 'Dieses Portfolio wird Hauptportfolio eines neuen Kontos. Buchungen bleiben erhalten.',
      'es': 'Este portafolio pasa a ser el principal de una cuenta nueva. Sus movimientos se conservan.',
    },
    'trx_convertir_btn': {
      'en': 'Convert',
      'ar': 'تحويل',
      'de': 'Umwandeln',
      'es': 'Convertir',
    },
    'trx_convertido': {
      'en': 'Account created',
      'ar': 'تم إنشاء الحساب',
      'de': 'Konto erstellt',
      'es': 'Cuenta creada',
    },
    'aport_seccion_aportes': {
      'en': 'Contributions and returns',
      'ar': 'المساهمات والعوائد',
      'de': 'Einzahlungen und Erträge',
      'es': 'Aportes y rendimientos',
    },
    'aport_seccion_aportes_ayuda': {
      'en': 'Where the money for this portfolio comes from and where its returns go',
      'ar': 'من أين يأتي المال وإلى أين تذهب العوائد',
      'de': 'Woher das Geld kommt und wohin die Erträge gehen',
      'es': 'De dónde sale el dinero de este portafolio y a dónde llegan sus rendimientos',
    },
    'aport_cuenta_aportes': {
      'en': 'Contributions account',
      'ar': 'حساب المساهمات',
      'de': 'Einzahlungskonto',
      'es': 'Cuenta de aportes',
    },
    'aport_sin_cuenta': {
      'en': 'Cash / Undefined',
      'ar': 'نقد / غير محدد',
      'de': 'Bargeld / Undefiniert',
      'es': 'Efectivo / Sin definir',
    },
    'aport_misma_cuenta': {
      'en': 'Returns go to the same account',
      'ar': 'العوائد إلى نفس الحساب',
      'de': 'Erträge auf dasselbe Konto',
      'es': 'Los rendimientos llegan a la misma cuenta',
    },
    'aport_misma_cuenta_ayuda': {
      'en': 'Turn off to choose a different account',
      'ar': 'أوقف لاختيار حساب آخر',
      'de': 'Ausschalten, um ein anderes Konto zu wählen',
      'es': 'Desactívalo para elegir otra cuenta',
    },
    'aport_cuenta_rendimientos': {
      'en': 'Returns account',
      'ar': 'حساب العوائد',
      'de': 'Ertragskonto',
      'es': 'Cuenta de rendimientos',
    },
    'pre_cuenta': {
      'en': 'Account',
      'ar': 'الحساب',
      'de': 'Konto',
      'es': 'Cuenta',
    },
    'pre_cuenta_ayuda': {
      'en': 'Only counts spending that leaves this account',
      'ar': 'يحسب فقط ما يخرج من هذا الحساب',
      'de': 'Zählt nur Ausgaben von diesem Konto',
      'es': 'Solo cuenta lo que se gasta desde esta cuenta',
    },
    'pre_todas_cuentas': {
      'en': 'All accounts',
      'ar': 'كل الحسابات',
      'de': 'Alle Konten',
      'es': 'Todas las cuentas',
    },
    'cta_tipo_T': {
      'en': 'Credit card',
      'ar': 'بطاقة ائتمان',
      'de': 'Kreditkarte',
      'es': 'Tarjeta de crédito',
    },
    'cta_tipo_P': {
      'en': 'Loan',
      'ar': 'قرض',
      'de': 'Kredit',
      'es': 'Préstamo',
    },
  },
].reduce((a, b) => a..addAll(b));
