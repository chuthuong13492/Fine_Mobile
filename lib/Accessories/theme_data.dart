import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Fira Sans',
      primarySwatch: Colors.green,
      primaryColor: FineTheme.palettes.primary200,
      scaffoldBackgroundColor: Color(0xFFF5F5F5),
      toggleableActiveColor: FineTheme.palettes.primary200,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // textTheme: TextTheme(
      //     headline1: BeanOiTheme.typography.h1,
      //     headline2: BeanOiTheme.typography.h2,
      //     headline3: kTitleTextStyle,
      //     headline4: kSubtitleTextStyle,
      //     headline5: kDescriptionTextStyle,
      //     headline6: kSubdescriptionTextStyle,
      //     subtitle1: BeanOiTheme.typography.subtitle1,
      //     subtitle2: BeanOiTheme.typography.subtitle2),
    );
  }
}

// TODO: Setup design system (constants)
// TODO: Map to theme data