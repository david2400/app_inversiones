import 'package:flutter/material.dart';

import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:inversiones/config/database_config.dart';
// import 'package:workmanager/workmanager.dart';

import 'ui/utils/flutter_flow_theme.dart';
import 'ui/utils/flutter_flow_util.dart';
import 'ui/utils/internationalization.dart';

// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) {
//     // Aquí defines el proceso que quieres ejecutar.
//     print("Tarea ejecutada: $task");
//
//     // Puedes realizar operaciones como:
//     // - Consultar una API.
//     // - Actualizar datos locales.
//     // - Enviar notificaciones.
//
//     return Future.value(true); // Indica que la tarea se completó correctamente.
//   });
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();
  // await initFirebase();

  DatabaseHelper databaseHelper = DatabaseHelper();
  databaseHelper.database;

  // Workmanager().initialize(
  //   callbackDispatcher, // Función que define la tarea
  //   isInDebugMode: true, // Cambia a false en producción
  // );
  //
  // // Registrar una tarea periódica
  // Workmanager().registerPeriodicTask(
  //   "uniqueTaskName", // Identificador único de la tarea
  //   "simpleTask", // Nombre de la tarea
  //   frequency: Duration(hours: 24), // Intervalo de repetición
  //   initialDelay: Duration(minutes: 5), // (Opcional) Retraso inicial
  //   inputData: {"key": "value"}, // (Opcional) Datos que se pasan a la tarea
  // );


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
  Locale? _locale = Locale('en');

  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

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
        // GlobalMaterialLocalizations.delegate,
        // GlobalWidgetsLocalizations.delegate,
        // GlobalCupertinoLocalizations.delegate,
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('de'),
        Locale('ar'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
