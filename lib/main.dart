import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:inversiones/config/database_config.dart';

import 'ui/utils/flutter_flow_theme.dart';
import 'ui/utils/flutter_flow_util.dart';
import 'ui/utils/internationalization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();
  // await initFirebase();

  DatabaseHelper.inicializarPlataforma();
  DatabaseHelper databaseHelper = DatabaseHelper();
  databaseHelper.database;


  await FlutterFlowTheme.initialize();


  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale = const Locale('es');

  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  final ThemeData _temaOscuro = construirTemaOscuro();

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  // late Stream<BaseAuthUser> userStream;
  //
  // final authUserSub = authenticatedUserStream.listen((_) {});

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    // userStream = inversionesFirebaseUserStream()
    //   ..listen((user) {
    //     _appStateNotifier.update(user);
    //   });
    // jwtTokenStream.listen((_) {});
    Future.delayed(
      const Duration(milliseconds: 1000),
          () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
    // authUserSub.cancel();

    super.dispose();
  }

  void setLocale(String language) {
    setState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => setState(() {
    _themeMode = mode;
    FlutterFlowTheme.saveThemeMode(mode);
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Inversiones',
      localizationsDelegates: const [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('de'),
        Locale('ar'),
      ],
      // La app solo tiene tema oscuro (FlutterFlowTheme.of siempre devuelve
      // DarkModeTheme): se usa el mismo ThemeData en ambos modos para que
      // los widgets de Material no cambien a claro según el sistema.
      theme: _temaOscuro,
      darkTheme: _temaOscuro,
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}

/// Tema Material 3 oscuro y sobrio, alineado con la paleta de [DarkModeTheme]
/// y la tipografía de [ThemeTypography]. Configura los widgets estándar
/// (campos, botones, tarjetas, diálogos, AppBar, snackbars) para que salgan
/// con el estilo correcto sin decorarlos uno por uno. No usa fuentes
/// descargadas: toma la fuente del sistema.
ThemeData construirTemaOscuro() {
  final tema = DarkModeTheme();
  const radioCampo = 8.0;
  const radioTarjeta = 12.0;
  const altoMinimoTactil = 48.0;

  final esquema = ColorScheme.fromSeed(
    seedColor: tema.primary,
    brightness: Brightness.dark,
  ).copyWith(
    primary: tema.primary,
    onPrimary: Colors.white,
    secondary: tema.primary,
    onSecondary: Colors.white,
    surface: tema.secondaryBackground,
    onSurface: tema.primaryText,
    onSurfaceVariant: tema.secondaryText,
    outline: tema.alternate,
    outlineVariant: tema.alternate,
    error: tema.error,
    onError: Colors.white,
  );

  final textos = TextTheme(
    displayLarge: tema.displayLarge,
    displayMedium: tema.displayMedium,
    displaySmall: tema.displaySmall,
    headlineLarge: tema.headlineLarge,
    headlineMedium: tema.headlineMedium,
    headlineSmall: tema.headlineSmall,
    titleLarge: tema.titleLarge,
    titleMedium: tema.titleMedium,
    titleSmall: tema.titleSmall,
    bodyLarge: tema.bodyLarge,
    bodyMedium: tema.bodyMedium,
    bodySmall: tema.bodySmall,
    labelLarge: tema.labelLarge,
    labelMedium: tema.labelMedium,
    labelSmall: tema.labelSmall,
  );

  final bordeCampo = OutlineInputBorder(
    borderRadius: BorderRadius.circular(radioCampo),
    borderSide: BorderSide(color: tema.alternate),
  );
  final formaBoton = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radioCampo),
  );
  const tamanoBoton = Size(64, altoMinimoTactil);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: esquema,
    textTheme: textos,
    primaryTextTheme: textos,
    scaffoldBackgroundColor: tema.primaryBackground,
    canvasColor: tema.primaryBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: tema.primaryBackground,
      foregroundColor: tema.primaryText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: tema.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: tema.secondaryBackground,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radioTarjeta),
        side: BorderSide(color: tema.alternate),
      ),
    ),
    dividerTheme: DividerThemeData(color: tema.alternate, space: 1, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tema.secondaryBackground,
      border: bordeCampo,
      enabledBorder: bordeCampo,
      focusedBorder: bordeCampo.copyWith(
        borderSide: BorderSide(color: tema.primary, width: 1.5),
      ),
      errorBorder: bordeCampo.copyWith(
        borderSide: BorderSide(color: tema.error),
      ),
      focusedErrorBorder: bordeCampo.copyWith(
        borderSide: BorderSide(color: tema.error, width: 1.5),
      ),
      labelStyle: tema.bodyMedium.copyWith(color: tema.secondaryText),
      floatingLabelStyle: tema.bodySmall.copyWith(color: tema.primary),
      hintStyle: tema.bodyMedium.copyWith(color: tema.secondaryText),
      helperStyle: tema.bodySmall.copyWith(color: tema.secondaryText),
      errorStyle: tema.bodySmall.copyWith(color: tema.error),
      prefixIconColor: tema.secondaryText,
      suffixIconColor: tema.secondaryText,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: tamanoBoton,
        shape: formaBoton,
        textStyle: tema.labelLarge,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: tema.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: tamanoBoton,
        shape: formaBoton,
        textStyle: tema.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: tema.primaryText,
        side: BorderSide(color: tema.alternate),
        minimumSize: tamanoBoton,
        shape: formaBoton,
        textStyle: tema.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: tema.primary,
        minimumSize: tamanoBoton,
        shape: formaBoton,
        textStyle: tema.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: tema.secondaryText,
        minimumSize: const Size(altoMinimoTactil, altoMinimoTactil),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: tema.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: tema.secondaryBackground,
      selectedColor: tema.accent1,
      side: BorderSide(color: tema.alternate),
      labelStyle: tema.labelMedium.copyWith(color: tema.primaryText),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: tema.accent4,
      contentTextStyle: tema.bodyMedium,
      actionTextColor: tema.primary,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: tema.secondaryBackground,
      elevation: 0,
      titleTextStyle: tema.titleLarge,
      contentTextStyle: tema.bodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radioTarjeta),
        side: BorderSide(color: tema.alternate),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: tema.secondaryBackground,
      modalBackgroundColor: tema.secondaryBackground,
      elevation: 0,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: tema.primaryBackground,
      elevation: 0,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: tema.secondaryBackground,
      elevation: 0,
      textStyle: tema.bodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radioCampo),
        side: BorderSide(color: tema.alternate),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: tema.secondaryText,
      textColor: tema.primaryText,
      titleTextStyle: tema.bodyLarge,
      subtitleTextStyle: tema.bodySmall.copyWith(color: tema.secondaryText),
      minVerticalPadding: 8,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: tema.primary,
      linearTrackColor: tema.alternate,
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: const WidgetStatePropertyAll(Colors.white),
      side: BorderSide(color: tema.secondaryText),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: tema.accent4,
        borderRadius: BorderRadius.circular(radioCampo),
        border: Border.all(color: tema.alternate),
      ),
      textStyle: tema.bodySmall,
    ),
  );
}
