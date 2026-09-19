import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/activation_screen.dart';
import 'screens/register_screen.dart';
import 'services/isar_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const PioSystemApp(),
    ),
  );
}

class PioSystemApp extends StatefulWidget {
  const PioSystemApp({super.key});

  @override
  State<PioSystemApp> createState() => _PioSystemAppState();
}

class _PioSystemAppState extends State<PioSystemApp> {
  final IsarService _isarService = IsarService();
  bool _isLoading = true;
  bool _hasAdmin = false;
  bool _isActivated = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    bool hasAdmin = await _isarService.hasAdminRegistered();
    bool activated = false;
    
    if (hasAdmin) {
      activated = await _isarService.isDeviceActivated();
    }

    setState(() {
      _hasAdmin = hasAdmin;
      _isActivated = activated;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'PioSystem',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          home: _isLoading 
              ? Scaffold(body: Center(child: CircularProgressIndicator(color: themeProvider.colors.primary)))
              : (!_hasAdmin 
                  ? const RegisterScreen() 
                  : (_isActivated ? const LoginScreen() : const ActivationScreen())),
        );
      },
    );
  }
}
