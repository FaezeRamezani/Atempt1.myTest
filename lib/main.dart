import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import 'package:provider/provider.dart';

import 'Logic/Providers/Language/language_provider.dart';
import 'Logic/Providers/Theme/theme_provider.dart';
import 'Presentation/Screens/add_entry.dart';
import 'Presentation/Screens/add_installment.dart';
import 'Presentation/Screens/category.dart';
import 'Presentation/Screens/intro.dart';
import 'Presentation/Screens/login.dart';
import 'Presentation/Screens/navigation.dart';
import 'Presentation/Screens/splash.dart';
import 'Presentation/Theme/theme.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await dotenv.load(fileName: '.env');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          builder: (context, child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(
                textScaler: TextScaler.noScaling,
                alwaysUse24HourFormat: true,
              ),
              child: EasyLoading.init()(context, child),
            );
          },
          themeMode: ThemeMode.light,
          theme: MyThemes.lightTheme,
          darkTheme: MyThemes.darkTheme,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            PersianMaterialLocalizations.delegate,
            PersianCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US'), Locale('fa', 'IR')],
          locale: languageProvider.localeMode,
          initialRoute: SplashScreen.routeName,
          routes: {
            SplashScreen.routeName: (context) => const SplashScreen(),
            IntroScreen.routeName: (context) => const IntroScreen(),
            LoginScreen.routeName: (context) => const LoginScreen(),
            NavigationScreen.routeName: (context) => const NavigationScreen(),
            AddReportScreen.routeName: (context) => const AddReportScreen(),
            AddInstallmentScreen.routeName: (context) =>
                const AddInstallmentScreen(),
            CategoryScreen.routeName: (context) =>
                const CategoryScreen(),
          },
        );
      },
    );
  }
}
