// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

const kThemeModeKey = '__theme_mode__';
SharedPreferences? _prefs;

abstract class FlutterFlowTheme {
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();

  static ThemeMode get themeMode {
    final darkMode = _prefs?.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.system
        : darkMode
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? _prefs?.remove(kThemeModeKey)
      : _prefs?.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static FlutterFlowTheme of(BuildContext context) {
    // return Theme.of(context).brightness == Brightness.dark
    //     ? DarkModeTheme()
    //     : LightModeTheme();
    return DarkModeTheme();
  }

  @Deprecated('Use primary instead')
  Color get primaryColor => primary;

  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;

  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  @Deprecated('Use displaySmallFamily instead')
  String get title1Family => displaySmallFamily;

  @Deprecated('Use displaySmall instead')
  TextStyle get title1 => typography.displaySmall;

  @Deprecated('Use headlineMediumFamily instead')
  String get title2Family => typography.headlineMediumFamily;

  @Deprecated('Use headlineMedium instead')
  TextStyle get title2 => typography.headlineMedium;

  @Deprecated('Use headlineSmallFamily instead')
  String get title3Family => typography.headlineSmallFamily;

  @Deprecated('Use headlineSmall instead')
  TextStyle get title3 => typography.headlineSmall;

  @Deprecated('Use titleMediumFamily instead')
  String get subtitle1Family => typography.titleMediumFamily;

  @Deprecated('Use titleMedium instead')
  TextStyle get subtitle1 => typography.titleMedium;

  @Deprecated('Use titleSmallFamily instead')
  String get subtitle2Family => typography.titleSmallFamily;

  @Deprecated('Use titleSmall instead')
  TextStyle get subtitle2 => typography.titleSmall;

  @Deprecated('Use bodyMediumFamily instead')
  String get bodyText1Family => typography.bodyMediumFamily;

  @Deprecated('Use bodyMedium instead')
  TextStyle get bodyText1 => typography.bodyMedium;

  @Deprecated('Use bodySmallFamily instead')
  String get bodyText2Family => typography.bodySmallFamily;

  @Deprecated('Use bodySmall instead')
  TextStyle get bodyText2 => typography.bodySmall;

  String get displayLargeFamily => typography.displayLargeFamily;

  TextStyle get displayLarge => typography.displayLarge;

  String get displayMediumFamily => typography.displayMediumFamily;

  TextStyle get displayMedium => typography.displayMedium;

  String get displaySmallFamily => typography.displaySmallFamily;

  TextStyle get displaySmall => typography.displaySmall;

  String get headlineLargeFamily => typography.headlineLargeFamily;

  TextStyle get headlineLarge => typography.headlineLarge;

  String get headlineMediumFamily => typography.headlineMediumFamily;

  TextStyle get headlineMedium => typography.headlineMedium;

  String get headlineSmallFamily => typography.headlineSmallFamily;

  TextStyle get headlineSmall => typography.headlineSmall;

  String get titleLargeFamily => typography.titleLargeFamily;

  TextStyle get titleLarge => typography.titleLarge;

  String get titleMediumFamily => typography.titleMediumFamily;

  TextStyle get titleMedium => typography.titleMedium;

  String get titleSmallFamily => typography.titleSmallFamily;

  TextStyle get titleSmall => typography.titleSmall;

  String get labelLargeFamily => typography.labelLargeFamily;

  TextStyle get labelLarge => typography.labelLarge;

  String get labelMediumFamily => typography.labelMediumFamily;

  TextStyle get labelMedium => typography.labelMedium;

  String get labelSmallFamily => typography.labelSmallFamily;

  TextStyle get labelSmall => typography.labelSmall;

  String get bodyLargeFamily => typography.bodyLargeFamily;

  TextStyle get bodyLarge => typography.bodyLarge;

  String get bodyMediumFamily => typography.bodyMediumFamily;

  TextStyle get bodyMedium => typography.bodyMedium;

  String get bodySmallFamily => typography.bodySmallFamily;

  TextStyle get bodySmall => typography.bodySmall;

  Typography get typography => ThemeTypography(this);
}

// class LightModeTheme extends FlutterFlowTheme {
//   @Deprecated('Use primary instead')
//   Color get primaryColor => primary;
//
//   @Deprecated('Use secondary instead')
//   Color get secondaryColor => secondary;
//
//   @Deprecated('Use tertiary instead')
//   Color get tertiaryColor => tertiary;
//
//   late Color primary = const Color(0xFF6F61EF);
//   late Color secondary = const Color(0xFF39D2C0);
//   late Color tertiary = const Color(0xFFEE8B60);
//   late Color alternate = const Color(0xFFE5E7EB);
//   late Color primaryText = const Color(0xFF15161E);
//   late Color secondaryText = const Color(0xFF606A85);
//   late Color primaryBackground = const Color(0xFFF1F4F8);
//   late Color secondaryBackground = const Color(0xFFFFFFFF);
//   late Color accent1 = const Color(0x4D9489F5);
//   late Color accent2 = const Color(0x4C39D2C0);
//   late Color accent3 = const Color(0x4CEE8B60);
//   late Color accent4 = const Color(0x9AFFFFFF);
//   late Color success = const Color(0xFF048178);
//   late Color warning = const Color(0xFFFCDC0C);
//   late Color error = const Color(0xFFFF5963);
//   late Color info = const Color(0xFFFFFFFF);
// }

abstract class Typography {
  String get displayLargeFamily;

  TextStyle get displayLarge;

  String get displayMediumFamily;

  TextStyle get displayMedium;

  String get displaySmallFamily;

  TextStyle get displaySmall;

  String get headlineLargeFamily;

  TextStyle get headlineLarge;

  String get headlineMediumFamily;

  TextStyle get headlineMedium;

  String get headlineSmallFamily;

  TextStyle get headlineSmall;

  String get titleLargeFamily;

  TextStyle get titleLarge;

  String get titleMediumFamily;

  TextStyle get titleMedium;

  String get titleSmallFamily;

  TextStyle get titleSmall;

  String get labelLargeFamily;

  TextStyle get labelLarge;

  String get labelMediumFamily;

  TextStyle get labelMedium;

  String get labelSmallFamily;

  TextStyle get labelSmall;

  String get bodyLargeFamily;

  TextStyle get bodyLarge;

  String get bodyMediumFamily;

  TextStyle get bodyMedium;

  String get bodySmallFamily;

  TextStyle get bodySmall;
}

/// Tipografía de la app: fuente del sistema (Segoe UI en Windows, Roboto en
/// Android, SF en iOS). No descarga fuentes: la app funciona 100 % offline.
class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final FlutterFlowTheme theme;

  /// Familia vacía = fuente por defecto de la plataforma. Se conserva el
  /// getter `*Family` por compatibilidad con las pantallas existentes.
  static const String familiaSistema = '';

  TextStyle _estilo(double tamano, FontWeight peso, Color color, double alto) =>
      TextStyle(
        color: color,
        fontSize: tamano,
        fontWeight: peso,
        height: alto,
        letterSpacing: 0,
      );

  String get displayLargeFamily => familiaSistema;

  TextStyle get displayLarge =>
      _estilo(40.0, FontWeight.w600, theme.primaryText, 1.2);

  String get displayMediumFamily => familiaSistema;

  TextStyle get displayMedium =>
      _estilo(36.0, FontWeight.w600, theme.primaryText, 1.2);

  String get displaySmallFamily => familiaSistema;

  TextStyle get displaySmall =>
      _estilo(32.0, FontWeight.w600, theme.primaryText, 1.25);

  String get headlineLargeFamily => familiaSistema;

  TextStyle get headlineLarge =>
      _estilo(28.0, FontWeight.w600, theme.primaryText, 1.25);

  String get headlineMediumFamily => familiaSistema;

  TextStyle get headlineMedium =>
      _estilo(24.0, FontWeight.w600, theme.primaryText, 1.3);

  String get headlineSmallFamily => familiaSistema;

  TextStyle get headlineSmall =>
      _estilo(20.0, FontWeight.w600, theme.primaryText, 1.3);

  String get titleLargeFamily => familiaSistema;

  TextStyle get titleLarge =>
      _estilo(20.0, FontWeight.w600, theme.primaryText, 1.3);

  String get titleMediumFamily => familiaSistema;

  TextStyle get titleMedium =>
      _estilo(16.0, FontWeight.w600, theme.primaryText, 1.4);

  String get titleSmallFamily => familiaSistema;

  TextStyle get titleSmall =>
      _estilo(14.0, FontWeight.w600, theme.primaryText, 1.4);

  String get labelLargeFamily => familiaSistema;

  TextStyle get labelLarge =>
      _estilo(14.0, FontWeight.w500, theme.secondaryText, 1.4);

  String get labelMediumFamily => familiaSistema;

  TextStyle get labelMedium =>
      _estilo(12.0, FontWeight.w500, theme.secondaryText, 1.35);

  String get labelSmallFamily => familiaSistema;

  TextStyle get labelSmall =>
      _estilo(11.0, FontWeight.w500, theme.secondaryText, 1.3);

  String get bodyLargeFamily => familiaSistema;

  TextStyle get bodyLarge =>
      _estilo(16.0, FontWeight.w400, theme.primaryText, 1.4);

  String get bodyMediumFamily => familiaSistema;

  TextStyle get bodyMedium =>
      _estilo(14.0, FontWeight.w400, theme.primaryText, 1.4);

  String get bodySmallFamily => familiaSistema;

  TextStyle get bodySmall =>
      _estilo(12.0, FontWeight.w400, theme.primaryText, 1.35);
}

class DarkModeTheme extends FlutterFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;

  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;

  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  // Paleta oscura sobria (todos los colores opacos para un contraste estable).
  late Color primary = const Color(0xFF6366F1);
  late Color secondary = const Color(0xFF1A1D24);
  late Color tertiary = const Color(0xFF6366F1);
  late Color alternate = const Color(0xFF2A2E37);
  late Color primaryText = const Color(0xFFE8EAED);
  late Color secondaryText = const Color(0xFF9AA0AA);
  late Color primaryBackground = const Color(0xFF111318);
  late Color secondaryBackground = const Color(0xFF1A1D24);
  late Color accent1 = const Color(0xFF262A45);
  late Color accent2 = const Color(0xFF1E3A34);
  late Color accent3 = const Color(0xFF3D2A1E);
  late Color accent4 = const Color(0xFF22262E);
  late Color success = const Color(0xFF22A06B);
  late Color warning = const Color(0xFFE2A33A);
  late Color error = const Color(0xFFE5484D);
  late Color info = const Color(0xFF3B82F6);
}

extension TextStyleHelper on TextStyle {
  /// Mantiene la firma heredada de FlutterFlow, pero ignora `fontFamily` y
  /// `useGoogleFonts`: nunca descarga fuentes y conserva la tipografía del
  /// tema, de modo que todas las pantallas se ven iguales sin editarlas.
  TextStyle override({
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = true,
    TextDecoration? decoration,
    double? lineHeight,
  }) =>
      copyWith(
        color: color,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        decoration: decoration,
        height: lineHeight,
      );
}
