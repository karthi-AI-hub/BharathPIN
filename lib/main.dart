import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'screens/no_internet_screen.dart';
import 'services/connectivity_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize connectivity service
  await ConnectivityService().initialize();

  runApp(const IndiaPostFinderApp());
}

class IndiaPostFinderApp extends StatefulWidget {
  const IndiaPostFinderApp({super.key});

  @override
  State<IndiaPostFinderApp> createState() => _IndiaPostFinderAppState();
}

class _IndiaPostFinderAppState extends State<IndiaPostFinderApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isNoInternetScreenShown = false;

  @override
  void initState() {
    super.initState();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivityService.connectivityStream.listen((isConnected) {
      if (!isConnected && !_isNoInternetScreenShown) {
        _showNoInternetScreen();
      } else if (isConnected && _isNoInternetScreenShown) {
        _hideNoInternetScreen();
      }
    });
  }

  void _showNoInternetScreen() {
    if (_navigatorKey.currentState != null && !_isNoInternetScreenShown) {
      _isNoInternetScreenShown = true;
      _navigatorKey.currentState!.push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              NoInternetScreen(
            onConnected: () {
              _hideNoInternetScreen();
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          fullscreenDialog: true,
        ),
      );
    }
  }

  void _hideNoInternetScreen() {
    if (_navigatorKey.currentState != null && _isNoInternetScreenShown) {
      _isNoInternetScreenShown = false;
      _navigatorKey.currentState!.pop();
    }
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'India Post Office Pincode Finder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: _navigatorKey,
      home: const SplashScreen(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}
